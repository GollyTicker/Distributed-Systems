-module(hbq).
-export([start/0]).
-import(werkzeug, [logging/2, get_config_value/2, to_String/1, timeMilliSecond/0, type_is/1]).
-import(dlq, [initDLQ/2, push2DLQ/3, expectedNr/1, deliverMSG/4]).

% lc([server,werkzeug,cmem,hbq,dlq]).
% HBQ = hbq:start().

start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  Datei = list_to_atom("log/HB-DLQ@" ++ atom_to_list(node()) ++ ".log"),
  PID = spawn(fun() -> loop([a,b,Datei],ConfigList) end),
  register(HbqName, PID),
  PID.

loop([HBQ, DLQ, Datei], ConfigList) ->
  receive
    Any ->
      logging(Datei,"Received: " ++ to_String(Any) ++ "\n"),
      case Any of 

        {Server, {request,initHBQ}} ->
          State = initHBQ(Datei, ConfigList),
          Server ! {reply, ok},
          loop(State,ConfigList);

        {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
          {NewHBQ, NewDLQ} = pushHBQ(HBQ, DLQ, [NNr,Msg,TSclientout]),
          Server ! {reply, ok},
          logging(Datei, "pushHBQ - HBQ new msg: " ++ to_String([NNr,Msg,TSclientout]) ++ "\n"),
          loop([NewHBQ, NewDLQ, Datei],ConfigList);

        {Server, {request,deliverMSG, NNr,ToClient}} ->
          SendNNr = deliverMSG(NNr,ToClient,DLQ,Datei),
          Server ! {reply, SendNNr},
          loop([HBQ, DLQ, Datei],ConfigList);

        {Server, {request,dellHBQ}} ->
          HBQDead = dellHBQ(ConfigList),
          Server ! {reply, HBQDead};

        Any -> 
          logging(Datei, "Received unknown message: " ++ to_String(Any) ++ "\n")

      end
  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ(Datei, ConfigList) -> 
  {ok,DLQLimit} = get_config_value(dlqlimit, ConfigList),
  HBQ = [[], (2*DLQLimit)/3, Datei],
  logging(Datei, "initialized HBQ\n"),
  DLQ = initDLQ(DLQLimit, Datei),
  [HBQ, DLQ, Datei].


% Speichern einer Nachricht in der HBQ
% HBQ ! {self(), {request,pushHBQ,[NNr,Msg,TSclientout]}}
% receive {reply, ok} 
% pushHBQ: HBQ -> DLQ -> {HBQ,DLQ}
pushHBQ([HQueue,HSize,HDatei] = HBQ,
        DLQ,
        Entry) -> 
  % 1. in HBQ einfügen
  NewHQueue = sortedInsert(HQueue,Entry),
  % 2. expected nr holen
  ExpNr = expectedNr(DLQ),
  % 3. Lücke schließen, falls die HBQ zu groß ist
  DLQ2 = closeGapIfTooBig(HBQ,DLQ,ExpNr),
  % 4. Korrekt geordnete Elemente von der HBQ in die DLQ weiterleiten.
  HBQ2 = [NewHQueue,HSize,HDatei],
  flush2DLQ(HBQ2,DLQ2).

% flush2DLQ: HBQ -> DLQ -> {HBQ,DLQ}
flush2DLQ([[],_,_]=HBQ,DLQ) -> {HBQ, DLQ};
flush2DLQ([[HH|HTail],HSize,HDatei]=HBQ,DLQ) -> 
  [HNr,_,_] = HH,
  ExpNr = expectedNr(DLQ),
  case ExpNr == HNr of
    true -> 
      NewDLQ = push2DLQ(DLQ,HH,HDatei),
      logging(HDatei,"HBQ -> DLQ - Nr: " ++ to_String(ExpNr) ++ "\n"),
      flush2DLQ([HTail,HSize,HDatei],NewDLQ);
    false -> {HBQ, DLQ}
  end.

% sortedInsert: HQueue -> Entry -> HQueue
sortedInsert(HQueue, [NNr,_,_] = Entry) -> 
  CMP = fun([NNr2,_,_]) -> NNr >= NNr2 end,
  Heads = lists:takewhile(CMP, HQueue),
  Tails = lists:dropwhile(CMP, HQueue),
  Heads ++ [Entry|Tails].

% Schreibt eine Fehlernachricht in die DLQ falls die HBQ zu groß ist.
% closeGapIfTooBig: HBQ -> DLQ -> Int -> DLQ
closeGapIfTooBig(HBQ,DLQ,ExpNr) ->
  [HQueue,HSize,HDatei] = HBQ,
  % 2. Falls HBQ zu groß und eine Lücke vorne
  GapAtBeginning = case HQueue of
    [[Nr2,_,_]|_] -> ExpNr + 1 /= Nr2;
    _ -> false
  end,
  TooBig = length(HQueue) > HSize,

  % dann: Fehlernachricht erzeugen und in die DLQ pushen
  DLQ2 = case (TooBig and GapAtBeginning) of
    true ->
      [[SmallestNrInHBQ,_,_]|_] = HQueue, % Lücke von ExpNr bis SmallestNrInHBQ
      FehlerMSG = fehlerNachricht(ExpNr,SmallestNrInHBQ),
      push2DLQ(DLQ,FehlerMSG,HDatei);
    false -> DLQ
  end,
  DLQ2.

% Fehlernachricht erzeugen:
fehlerNachricht(ExpNr,SmallestNrInHBQ) -> 
  Msg = io_lib:format("Fehlernachricht fuer Nachrichtennummern ~p bis ~p um ~p\n",[ExpNr, SmallestNrInHBQ - 1, timeMilliSecond()]),
  [{ExpNr, SmallestNrInHBQ - 1}, Msg, erlang:now()].

% Terminierung der HBQ
% HBQ ! {self(), {request,dellHBQ}}
% receive {reply, ok} 
dellHBQ(ConfigList) ->
  {ok, HbqName} = get_config_value(hbqname, ConfigList),
  case unregister(HbqName) of
    true -> ok;
    _ -> nok
  end.



