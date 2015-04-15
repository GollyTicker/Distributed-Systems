-module(hbq).
-export([startHBQ/0]).
-import(utils,[log/3]).
-import(werkzeug, [get_config_value/2, to_String/1, timeMilliSecond/0, type_is/1]).
-import(dlq, [initDLQ/2, push2DLQ/3, expectedNr/1, deliverMSG/4]).

% Die HBQ

% startHBQ (aus dem Entwurf)
startHBQ() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  Datei = list_to_atom("log/HB-DLQ@" ++ atom_to_list(node()) ++ ".log"),
  register(HbqName, self()),
  log(Datei,hbq,["Registered as ",HbqName," on ",node()]),
  loop([a,b,Datei],ConfigList).


% Die HBQ Loop
loop([HBQ, DLQ, Datei], ConfigList) ->
  receive
    Any ->
      log(Datei,hbq,["Received: ",Any]),
      case Any of 

        % initHBQ (aus dem Entwurf)
        {Server, {request,initHBQ}} ->
          State = initHBQ(Datei, ConfigList, Server),
          Server ! {reply, ok},
          loop(State,ConfigList);

        % pushHBQ (aus dem Entwurf)
        {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
          {NewHBQ, NewDLQ} = pushHBQ(HBQ, DLQ, [NNr,Msg,TSclientout]),
          Server ! {reply, ok},
          loop([NewHBQ, NewDLQ, Datei],ConfigList);

        % deliverMSG (aus dem Entwurf)
        {Server, {request,deliverMSG, NNr,ToClient}} ->
          SendNNr = deliverMSG(NNr,ToClient,DLQ,Datei),
          Server ! {reply, SendNNr},
          loop([HBQ, DLQ, Datei],ConfigList);

        % dellHBQ (aus dem Entwurf)
        {Server, {request,dellHBQ}} ->
          HBQDead = dellHBQ(ConfigList,Datei),
          Server ! {reply, HBQDead};

        Any -> 
          log(Datei,hbq,["Received unknown message: ",Any]),
          loop([HBQ, DLQ, Datei],ConfigList)

      end
  end.


% Initialisieren der HBQ
initHBQ(Datei, ConfigList, Server) -> 
  {ok,DLQLimit} = get_config_value(dlqlimit, ConfigList),
  Size = (2*DLQLimit)/3,
  SizeStr = float_to_list(Size,[{decimals,0}]),
  HBQ = [[], Size, Datei],
  log(Datei,hbq,["initialized hbq, size = ",SizeStr," by ",Server]),
  DLQ = initDLQ(DLQLimit, Datei),
  [HBQ, DLQ, Datei].


% Speichern einer Nachricht in der HBQ
% pushHBQ: HBQ -> DLQ -> {HBQ,DLQ}
pushHBQ([_,_,Datei]=HBQ, DLQ, Entry) -> 
  TShbqin = now(),
  [Nr|_] = Entry2 = Entry ++ [TShbqin],

  % 1. expected nr holen
  ExpNr = expectedNr(DLQ),

  % 2. in HBQ einfügen, falls die Nachricht veraltet ist
  HBQ2 = case (not (Nr < ExpNr)) of
    true -> sortedInsert(HBQ,Entry2,Datei);
    false -> HBQ
  end,

  % 3. Lücke schließen, falls die HBQ zu groß ist
  DLQ2 = closeGapIfTooBig(HBQ2,DLQ,ExpNr),

  % 4. Korrekt geordnete Elemente von der HBQ in die DLQ weiterleiten.  
  flush2DLQ(HBQ2,DLQ2).


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
      NewDLQ = push2DLQ(DLQ,Entry,HDatei),
      flush2DLQ([HTail,HSize,HDatei],NewDLQ);
    false -> {HBQ, DLQ}
  end.

% sortedInsert: HBQ -> Entry -> Datei -> HBQ
sortedInsert([HQueue,HS,HD], [NNr|_] = Entry,Datei) -> 
  CMP = fun([NNr2|_]) -> NNr >= NNr2 end,
  Heads = lists:takewhile(CMP, HQueue),
  Tails = lists:dropwhile(CMP, HQueue),
  log(Datei,hbq,["#",NNr," into hbq"]),
  HQueue2 = Heads ++ [Entry|Tails],
  [HQueue2,HS,HD].

% Schreibt eine Fehlernachricht in die DLQ falls die HBQ zu groß ist.
% closeGapIfTooBig: HBQ -> DLQ -> Int -> DLQ
closeGapIfTooBig(HBQ,DLQ,ExpNr) ->
  [HQueue,HSize,HDatei] = HBQ,
  % 2. Falls HBQ zu groß und eine Lücke vorne
  GapAtBeginning = case HQueue of
    [[Nr2|_]|_] -> ExpNr < Nr2;
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
dellHBQ(ConfigList,Datei) ->
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  Success = case unregister(HbqName) of
    true -> ok;
    _ -> nok
  end,
  log(Datei,hbq,["Shutdown hbq and dlq: ",Success]).


% Hilfsmethoden zum Printen von DLQ und HBQ
toStringQueue([Queue|_]) -> to_String(lists:map(fun(X) -> hd(X) end,Queue)).

logQueues(HBQ,DLQ,Datei) ->
  log(Datei,hbq,[" HBQ: ",toStringQueue(HBQ)]),
  log(Datei,dlq,[" DLQ: ",toStringQueue(DLQ)]).
