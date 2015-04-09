
-module(server).
-import(werkzeug,[logging/2,get_config_value/2,to_String/1]).
-export([start/0]).

% lc([server,hbq,...])
% make:all().
% unregister(SERVERPID).
% f().


% Abweichungen vom Entwurf:
% 1. getClientNNr
  % als Antwort von getClientNNr kommt nicht nur die Nummer
  % sondern auch ein neues CMEM. In diesem CMEM sind alte Clients gelöscht.
% 2. {reply,SendNNr} während einer Client-Abfrage
  % es wird dort die Adresse des Clients mitgesendet {reply,Client,SendNNr}
  % da es nicht möglich ist aus der Message den Client, den es betrifft zurückzuschließen.
  % Das wäre aber möglich, wenn man auf blockierend wartet...


% Servername aus der Config holen, server started, registrieren.
% start: IO PID
start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  PID = spawn( fun() -> State = initServer(ConfigList), loop(State) end),
  {ok, ServerName} = get_config_value(servername, ConfigList),
  register(ServerName,PID),
  PID. 


% initialisieren des CMEM, HBQ, DLQ, Logging und Erzeugen des Initialzustands
% initServer: ConfigList -> State
initServer(ConfigList) -> 

  Datei = list_to_atom("log/Server@" ++ atom_to_list(node()) ++ ".log"),
  logging(Datei, "Initalizing Server\n"),

  {ok, RemTime} = get_config_value(clientlifetime, ConfigList),
  CMEM = cmem:initCMEM(RemTime,Datei),

  {ok, HBQnode} = get_config_value(hbqnode,ConfigList),
  {ok, HBQname} = get_config_value(hbqname,ConfigList),
  HBQservice = {HBQname,HBQnode},
  logging(Datei, "Initializing HBQ - Address: " ++ werkzeug:to_String(HBQservice) ++ "\n"),
  HBQservice ! {self(), {request,initHBQ}},
  receive
    {reply, ok} -> logging(Datei, "Erhielt OK von HBQ\n")
  end,
  
  logging(Datei, "initialized Server\n"),
  State = [0,1, CMEM, HBQservice, ConfigList, Datei],
  State.


% loop: State -> Nothing
loop([LoopNr,Nr,CMEM, HBQ, ConfigList, Datei]) ->
  logging(Datei, io_lib:format("======= ~p =======\n",[LoopNr])),
  receive
    
    {Client, getmessages} ->
      {ClientNr,CMEM2} = cmem:getClientNNr(CMEM,Client),
      HBQ ! {self(), {request,deliverMSG,ClientNr,Client}},
      loop([LoopNr+1,Nr,CMEM2, HBQ, ConfigList, Datei]);
    
    {reply,ClientID,SendNNr} ->
      CMEM2 = cmem:updateClient(CMEM,ClientID,SendNNr,Datei),
      loop([LoopNr+1,Nr,CMEM2, HBQ, ConfigList, Datei]);
    
    {dropmessage, [NNr,Msg,TSclientout]} -> undefined;
    
    {Redakteur, getmsdid}  ->
      Redakteur ! {nid, Nr},
      loop([LoopNr+1,Nr+1,CMEM, HBQ, ConfigList, Datei]);
      
    Any ->
      logging(Datei,"Received unknown message: " ++ to_String(Any) ++ "\n"),
      loop([LoopNr+1,Nr,CMEM, HBQ, ConfigList, Datei])
    
  end
  .





