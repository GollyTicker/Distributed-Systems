-module(hbq).
-export([start/0]).

% lc([server,werkzeug,cmem,hbq,dlq]).

start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  {ok, HbqName} = werkzeug:get_config_value(hbqname, ConfigList),
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
      NewHBQ = pushHBQ(HBQ, [NNr,Msg,TSclientout]),
      Server ! {reply, ok},
      loop([NewHBQ, DLQ, Datei],ConfigList);
    {Server, {request,deliverMSG, NNr,ToClient}} ->
      SendNNr = deliverMSG(HBQ, [NNr,ToClient]),
      Server ! {reply, SendNNr},
      loop([HBQ, DLQ, Datei],ConfigList);
    {Server, {request,dellHBQ}} ->
      HBQDead = dellHBQ(),
      Server ! {reply, HBQDead};
    Any -> 
      werkzeug:logging(Datei, "Received unknown message: " ++ werkzeug:to_String(Any))
  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ(Datei, ConfigList) -> 
  DLQLimit = werkzeug:get_config_value(dlqlimit, ConfigList),
  HBQ = [[], 2*DLQLimit/3, Datei],
  werkzeug:logging(Datei, "initialized HBQ\n"),
  DLQ = dlq:initDLQ(DLQLimit, Datei),
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

