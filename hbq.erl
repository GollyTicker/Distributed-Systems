-module(hbq).
-export([start/0]).
-import(werkzeug, [logging/2, get_config_value/2, to_String/1]).

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

    {Server, {request,initHBQ}} ->
      State = initHBQ(Datei, ConfigList),
      Server ! {reply, ok},
      loop(State,ConfigList);

    {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
      NewHBQ = pushHBQ(HBQ, DLQ, [NNr,Msg,TSclientout]),
      Server ! {reply, ok},
      logging(Datei, "HBQ content: " ++ to_String(NewHBQ)),
      loop([NewHBQ, DLQ, Datei],ConfigList);

    {Server, {request,deliverMSG, NNr,ToClient}} ->
      SendNNr = deliverMSG([HBQ, DLQ, Datei], [NNr,ToClient]),
      Server ! {reply, SendNNr},
      loop([HBQ, DLQ, Datei],ConfigList);

    {Server, {request,dellHBQ}} ->
      HBQDead = dellHBQ(),
      Server ! {reply, HBQDead};

    Any -> 
      logging(Datei, "Received unknown message: " ++ to_String(Any))

  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ(Datei, ConfigList) -> 
  DLQLimit = get_config_value(dlqlimit, ConfigList),
  HBQ = [[], DLQLimit, Datei],
  logging(Datei, "initialized HBQ\n"),
  DLQ = dlq:initDLQ(DLQLimit, Datei),
  [HBQ, DLQ, Datei].


% Speichern einer Nachricht in der HBQ
% HBQ ! {self(), {request,pushHBQ,[NNr,Msg,TSclientout]}}
% receive {reply, ok} 
pushHBQ(HBQ, DLQ, Entry) -> 
  [HQueue,HSize,HDatei] = HBQ,
  [DQueue,DSize,DDatei] = DLQ,
  [NNr,_,_] = Entry,
  Heads = lists:takewhile(fun([NNr2,_,_]) -> NNr >= NNr2 end, HQueue),
  Tails = lists:dropwhile(fun([NNr2,_,_]) -> NNr >= NNr2 end, HQueue),
  NewHQueue = Heads ++ [Entry|Tails],
  
  Diff = lists:size(DQueue) - DSize,
  NewDQueue = if Diff >= 0 then
    pushAll(DQueue, lists:sublist(HBQueue, 1, Diff), DDatei)
  else
    lists:sublist(DQueue, -Diff, lists:size(DQueue))
  end,

  NewHQueue = Heads ++ [Entry|Tails],
  [NewHQueue,Size,Datei].

pushAll(Queue,[], _) -> Queue;
pushAll(Queue, [X|Xs], Datei) ->
  NewQueue = dlq:push2DLQ(Queue, X),
  pushAll(NewQueue, Xs, Date).


% Abfrage einer Nachricht
% HBQ ! {self(), {request,deliverMSG,NNr,ToClient}}
% receive {reply, SendNNr}
deliverMSG([HBQ, DLQ, Datei], [NNr,ToClient]) -> 
  [HBQueue,_,_] = HBQ,
  [DLQueue,_,_] = DLQ,


% Terminierung der HBQ
% HBQ ! {self(), {request,dellHBQ}}
% receive {reply, ok} 
dellHBQ() -> undefined.


