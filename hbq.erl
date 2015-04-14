-module(hbq).
-export([start/0]).
-import(utils,[log/3]).
-import(werkzeug, [get_config_value/2, to_String/1, timeMilliSecond/0, type_is/1]).
-import(dlq, [initDLQ/2, push2DLQ/3, expectedNr/1, deliverMSG/4]).

% make:all().
% HBQ = hbq:start().


start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  Datei = list_to_atom("log/HB-DLQ@" ++ atom_to_list(node()) ++ ".log"),
  PID = spawn(fun() -> loop([a,b,Datei],ConfigList) end),
  register(HbqName, PID),
  log(Datei,hbq,["Registered as ",HbqName," on ",node()]),
  PID.

loop([HBQ, DLQ, Datei], ConfigList) ->
  receive
    Any ->
      log(Datei,hbq,["Received: ",Any]),
      case Any of 

        {Server, {request,initHBQ}} ->
          State = initHBQ(Datei, ConfigList, Server),
          Server ! {reply, ok},
          loop(State,ConfigList);

        {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
          {NewHBQ, NewDLQ} = pushHBQ(HBQ, DLQ, [NNr,Msg,TSclientout]),
          Server ! {reply, ok},
          loop([NewHBQ, NewDLQ, Datei],ConfigList);

        {Server, {request,deliverMSG, NNr,ToClient}} ->
          SendNNr = deliverMSG(NNr,ToClient,DLQ,Datei),
          Server ! {reply, SendNNr},
          loop([HBQ, DLQ, Datei],ConfigList);

        {Server, {request,dellHBQ}} ->
          HBQDead = dellHBQ(ConfigList,Datei),
          Server ! {reply, HBQDead};

        Any -> 
          log(Datei,hbq,["Received unknown message: ",Any]),
          loop([HBQ, DLQ, Datei],ConfigList)

      end
  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ(Datei, ConfigList, Server) -> 
  {ok,DLQLimit} = get_config_value(dlqlimit, ConfigList),
  Size = (2*DLQLimit)/3,
  SizeStr = float_to_list(Size,[{decimals,0}]),
  HBQ = [[], Size, Datei],
  log(Datei,hbq,["initialized hbq, size = ",SizeStr," by ",Server]),
  DLQ = initDLQ(DLQLimit, Datei),
  [HBQ, DLQ, Datei].


% Speichern einer Nachricht in der HBQ
% HBQ ! {self(), {request,pushHBQ,[NNr,Msg,TSclientout]}}
% receive {reply, ok} 
% pushHBQ: HBQ -> DLQ -> {HBQ,DLQ}
pushHBQ([HQueue,HSize,HDatei] = HBQ,
        DLQ,
        Entry) -> 
  TShbqin = now(),
  Entry2 = Entry ++ [TShbqin],
  % 1. in HBQ einfügen
  NewHQueue = sortedInsert(HQueue,Entry2,HDatei),
  % 2. expected nr holen
  ExpNr = expectedNr(DLQ),
  % 3. Lücke schließen, falls die HBQ zu groß ist
  DLQ2 = closeGapIfTooBig(HBQ,DLQ,ExpNr),
  % 4. Korrekt geordnete Elemente von der HBQ in die DLQ weiterleiten.
  HBQ2 = [NewHQueue,HSize,HDatei],
  
  flush2DLQ(HBQ2,DLQ2).

toStringQueue([Queue|_]) -> to_String(lists:map(fun(X) -> hd(X) end,Queue)).

logQueues(HBQ,DLQ,Datei) ->
  log(Datei,hbq,[" HBQ: ",toStringQueue(HBQ)]),
  log(Datei,dlq,[" DLQ: ",toStringQueue(DLQ)]).

% flush2DLQ: HBQ -> DLQ -> {HBQ,DLQ}
flush2DLQ([[],_,Datei]=HBQ,DLQ) ->
  log(Datei,hbq,["hbq completely flushed into dlq"]),
  logQueues(HBQ,DLQ,Datei),
  {HBQ, DLQ};
flush2DLQ([[Entry|HTail],HSize,HDatei]=HBQ,DLQ) -> 
  [HNr|_] = Entry,
  ExpNr = expectedNr(DLQ),
  case ExpNr == HNr of
    true -> 
      TShbqout = now(),
      Entry2 = Entry ++ [TShbqout],
      NewDLQ = push2DLQ(DLQ,Entry2,HDatei),
      flush2DLQ([HTail,HSize,HDatei],NewDLQ);
    false -> {HBQ, DLQ}
  end.

% sortedInsert: HQueue -> Entry -> Datei -> HQueue
sortedInsert(HQueue, [NNr|_] = Entry,Datei) -> 
  CMP = fun([NNr2|_]) -> NNr >= NNr2 end,
  Heads = lists:takewhile(CMP, HQueue),
  Tails = lists:dropwhile(CMP, HQueue),
  log(Datei,hbq,["#",NNr," into hbq"]),
  Heads ++ [Entry|Tails].

% Schreibt eine Fehlernachricht in die DLQ falls die HBQ zu groß ist.
% closeGapIfTooBig: HBQ -> DLQ -> Int -> DLQ
closeGapIfTooBig(HBQ,DLQ,ExpNr) ->
  [HQueue,HSize,HDatei] = HBQ,
  % 2. Falls HBQ zu groß und eine Lücke vorne
  GapAtBeginning = case HQueue of
    [[Nr2|_]|_] -> ExpNr + 1 /= Nr2;
    _ -> false
  end,
  TooBig = length(HQueue) > HSize,

  % dann: Fehlernachricht erzeugen und in die DLQ pushen
  DLQ2 = case (TooBig and GapAtBeginning) of
    true ->
      [[SmallestNrInHBQ|_]|_] = HQueue, % Lücke von ExpNr bis SmallestNrInHBQ
      FehlerMSG = fehlerNachricht(ExpNr,SmallestNrInHBQ,HDatei),
      NewDLQ = push2DLQ(DLQ,FehlerMSG,HDatei),
      logQueues(HBQ,NewDLQ,HDatei),
      NewDLQ;
    false -> DLQ
  end,
  DLQ2.

% Fehlernachricht erzeugen:
fehlerNachricht(ExpNr,SmallestNrInHBQ,Datei) -> 
  To = SmallestNrInHBQ - 1,
  Msg =
    io_lib:format("Missing Message for Msg #~p bis #~p um ",[ExpNr, To])
    ++ timeMilliSecond(),
  TS = now(),
  log(Datei,hbq,["Generated missing message from #",ExpNr," to #",To]),
  % TSclientout, TShbqin
  [{ExpNr, To}, Msg,TS,TS].

% Terminierung der HBQ
% HBQ ! {self(), {request,dellHBQ}}
% receive {reply, ok} 
dellHBQ(ConfigList,Datei) ->
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  case unregister(HbqName) of
    true -> ok;
    _ -> nok
  end,
  log(Datei,hbq,["Shutdown hbq and dlq"]).



