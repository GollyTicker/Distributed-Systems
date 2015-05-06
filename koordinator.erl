-module(koordinator).

-export([start/0]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3]).

% {From:,getsteeringval} Die Anfrage nach den steuernden Werten durch den Starter Prozess (From ist seine PID).
% {hello,Clientname}: Ein ggT-Prozess meldet sich beim Koordinator mit Namen Clientname an (Name ist der lokal registrierte Name, keine PID!).
% {briefmi,{Clientname,CMi,CZeit}}: Ein ggT-Prozess mit Namen Clientname (keine PID!) informiert über sein neues Mi CMi um CZeit Uhr. 
% {From,briefterm,{Clientname,CMi,CZeit}}: Ein ggT-Prozess mit Namen Clientname (keine PID!) und Absender From (ist PID) informiert über über die Terminierung der Berechnung mit Ergebnis CMi um CZeit Uhr.
% reset: Der Koordinator sendet allen ggT-Prozessen das kill-Kommando und bringt sich selbst in den initialen Zustand, indem sich Starter wieder melden können.
% step: Der Koordinator beendet die Initialphase und bildet den Ring. Er wartet nun auf den Start einer ggT-Berechnung.
% prompt: Der Koordinator erfragt bei allen ggT-Prozessen per tellmi deren aktuelles Mi ab und zeigt dies im log an.
% nudge: Der Koordinator erfragt bei allen ggT-Prozessen per pingGGT deren Lebenszustand ab und zeigt dies im log an.
% toggle: Der Koordinator verändert den Flag zur Korrektur bei falschen Terminierungsmeldungen.
% {calc,WggT}: Der Koordinator startet eine neue ggT-Berechnung mit Wunsch-ggT WggT.
% kill: Der Koordinator wird beendet und sendet allen ggT-Prozessen das kill-Kommando.

start() -> 0.

% Der Server

% Servername aus der Config holen, server started, registrieren.
% start: IO PID
start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  Datei = list_to_atom("log/Server@" ++ atom_to_list(node()) ++ ".log"),
  PID = spawn( fun() -> State = initServer(ConfigList,Datei), loop(State) end),
  {ok, ServerName} = get_config_value(servername, ConfigList),
  register(ServerName,PID),
  
  log(Datei,server,["Registered as ",ServerName," on ",node()," with addr ",PID]),
  
  PID. 


% initialisieren des CMEM, HBQ, DLQ, Logging und Erzeugen des Initialzustands
% initServer: ConfigList -> Datei -> State
initServer(ConfigList,Datei) -> 
  log(Datei,server,["Initalizing Server"]),

  {ok, RemTime} = get_config_value(clientlifetime, ConfigList),
  CMEM = cmem:initCMEM(RemTime,Datei),
  
  {ok, Latency} = get_config_value(latency,ConfigList),

  {ok, HBQnode} = get_config_value(hbqnode,ConfigList),
  {ok, _HBQname} = get_config_value(hbqname,ConfigList),
  % HBQservice = {_HBQname,HBQnode},
  
  HBQservice = spawn(HBQnode,fun() -> hbq:startHBQ() end),

  log(Datei, server,["Initializing hbq - Address: ",HBQservice]),
  HBQservice ! {self(), {request,initHBQ}},
  receive
    {reply, ok} -> log(Datei,server,["Received ok from hbq"])
  end,
  
  log(Datei,server,["Initialized Server"]),
  State = [0,1, CMEM, HBQservice, Latency, ConfigList, Datei],
  State.

% Der Server-Loop
% loop: State -> Nothing
loop([LoopNr,Nr,CMEM, HBQ, Latency, ConfigList, Datei]) ->
  log(Datei,server,["======= ",LoopNr," ======="]),
  receive

    % getmsgid (aus em Entwurf)
    {Redakteur, getmsgid}  ->
      Redakteur ! {nid, Nr},
      log(Datei,server,["#",Nr," to editor ",Redakteur]),
      loop([LoopNr+1,Nr+1,CMEM, HBQ, Latency, ConfigList, Datei]);
      
    % getmessages (aus em Entwurf)
    {Client, getmessages} ->
      ClientNr = cmem:getClientNNr(CMEM,Client),
      log(Datei,server,["Client ",Client," should receive ",ClientNr]),
      HBQ ! {self(), {request,deliverMSG,ClientNr,Client}},
      receive
        {reply,SendNr} ->
          CMEM2 = cmem:updateClient(CMEM,Client,SendNr,Datei),
          loop([LoopNr+1,Nr,CMEM2, HBQ, Latency, ConfigList, Datei])
      end;
    
    % dropmessage (aus em Entwurf)
    {dropmessage, [NNr,Msg,TSclientout]} -> 
      HBQ ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
      receive {reply, ok} ->
        log(Datei,server,["Inserted #",NNr," into hbq"]),
        loop([LoopNr+1,Nr,CMEM, HBQ, Latency, ConfigList, Datei]) 
      end;

    Any ->
      log(Datei,server,["Received unknown message: ",Any]),
      loop([LoopNr+1,Nr,CMEM, HBQ, Latency, ConfigList, Datei])

  after Latency * 1000 -> 
      shutdown(HBQ, ConfigList, Datei)
  
  end
  .


shutdown(HBQ, ConfigList, Datei)->
  HBQ ! {self(),{request,dellHBQ}},
  receive 
    {reply, HBQDead} -> HBQDead
  end,
  {ok, ServerName} = get_config_value(servername, ConfigList),
  case unregister(ServerName) of
    true -> log(Datei,server,["Shutdown Server at ",timeMilliSecond()]), ok;
    _ -> nok
  end.





