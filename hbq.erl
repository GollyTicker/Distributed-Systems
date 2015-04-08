-module(hbq).
-export([start/0]).


start() ->
  PID = spawn(fun() -> loop([a,b,c]) end),
  register(hbqNode, PID),
  PID.

loop([HBQ, DLQ, Datei]) ->
  receive
    {Server, {request,initHBQ}} ->
      State = initHBQ(),
      Server ! {reply, ok},
      loop(State);
    {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
      NewHBQ = pushHBQ(HBQ, [NNr,Msg,TSclientout]),
      Server ! {reply, ok},
      loop([NewHBQ, DLQ, Datei]);
    {Server, {request,deliverMSG, NNr,ToClient}} ->
      SendNNr = deliverMSG(HBQ, [NNr,ToClient]),
      Server ! {reply, SendNNr};
    {Server, {request,dellHBQ}} ->
      HBQDead = dellHBQ(),
      Server ! {reply, HBQDead};
    Any -> 
      werkzeug:logging(Datei, "Received unknown message: " ++ werkzeug:to_String(Any))
  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ() -> 
  Datei = list_to_atom("log/HB-DLQ@" ++ atom_to_list(node()) ++ ".log"),
  HBQ = [[], 2*Size/3, Datei],
  werkzeug:logging(Datei, "initialized HBQ\n"),
  DLQ = dlq:initDLQ(Size, Datei),
  [HBQ, DLQ, Datei].


% Speichern einer Nachricht in der HBQ
% HBQ ! {self(), {request,pushHBQ,[NNr,Msg,TSclientout]}}
% receive {reply, ok} 
pushHBQ(HBQ, Entry) -> 
  [Queue,Size,Datei] = HBQ, 
  [NNr,_,_] = Entry,
  Heads = lists:takewhile(fun([NNr2,_,_]) -> NNr >= NNr2 end, Queue),
  Tails = lists:dropwhile(fun([NNr2,_,_]) -> NNr >= NNr2 end, Queue),
  NewQueue = Heads ++ [Entry|Tails],
  [NewQueue,Size,Datei].


% Abfrage einer Nachricht
% HBQ ! {self(), {request,deliverMSG,NNr,ToClient}}
% receive {reply, SendNNr}
deliverMSG(HBQ, [NNr,ToClient]) -> undefined.

% Terminierung der HBQ
% HBQ ! {self(), {request,dellHBQ}}
% receive {reply, ok} 
dellHBQ() -> undefined.

