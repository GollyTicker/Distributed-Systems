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
      loop(State)
    {Server, {request, pushHBQ, [NNr,Msg,TSclientout]}} -> 
      Server ! pushHBQ(NNr,Msg,TSclientout)
    {Server, {request,deliverMSG,NNr,ToClient}} ->
      Server ! deliverMSG(NNr,ToClient)
    {Server, {request,dellHBQ}} ->
      Server ! dellHBQ()
  end.

% Initialisieren der HBQ
% HBQ ! {self(), {request,initHBQ}}
% receive {reply, ok} 
initHBQ() -> 
  Datei = list_to_atom("log/HB-DLQ@" ++ atom_to_list(node()) ++ ".log"),
  HBQ = [[], 2*Size/3, Datei],
  werkzeug:logging(Datei, "initialized HBQ\n"),
  DLQ = initDLQ(Size, Datei)
  [HBQ, DLQ, Datei].



% Speichern einer Nachricht in der HBQ
% HBQ ! {self(), {request,pushHBQ,[NNr,Msg,TSclientout]}}
% receive {reply, ok} 
pushHBQ(NNr,Msg,TSclientout) -> undefined.

% Abfrage einer Nachricht
% HBQ ! {self(), {request,deliverMSG,NNr,ToClient}}
% receive {reply, SendNNr}
deliverMSG(NNr,ToClient) -> undefined.

% Terminierung der HBQ
% HBQ ! {self(), {request,dellHBQ}}
% receive {reply, ok} 
dellHBQ() -> undefined.

