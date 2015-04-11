
-module(server).
-import(werkzeug,[get_config_value/2,to_String/1]).
-import(utils,[log/3]).
-export([start/0,client/1]).

% lc([server,hbq,...])
% make:all().
% unregister(SERVERPID).
% f().

client(S) ->
  S ! {self(), getmsgid},
  receive
    {nid,Nr} -> S ! {dropmessage,[Nr,"Hallo",erlang:now()]}
  end,
  0.


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
  Datei = list_to_atom("log/Server@" ++ atom_to_list(node()) ++ ".log"),
  PID = spawn( fun() -> State = initServer(ConfigList,Datei), loop(State) end),
  {ok, ServerName} = get_config_value(servername, ConfigList),
  register(ServerName,PID),
  log(Datei,server,["Registered as ",ServerName," on ",node()," with addr ",PID]),
  PID. 


% initialisieren des CMEM, HBQ, DLQ, Logging und Erzeugen des Initialzustands
% initServer: ConfigList -> State
initServer(ConfigList,Datei) -> 
  log(Datei,server,["Initalizing Server"]),

  {ok, RemTime} = get_config_value(clientlifetime, ConfigList),
  CMEM = cmem:initCMEM(RemTime,Datei),

  {ok, HBQnode} = get_config_value(hbqnode,ConfigList),
  {ok, HBQname} = get_config_value(hbqname,ConfigList),
  HBQservice = {HBQname,HBQnode},
  log(Datei, server,["Initializing hbq - Address: ",HBQservice]),
  HBQservice ! {self(), {request,initHBQ}},
  receive
    {reply, ok} -> log(Datei,server,["Received ok from hbq"])
  end,
  
  log(Datei,server,["Initialized Server"]),
  State = [0,1, CMEM, HBQservice, ConfigList, Datei],
  State.


% loop: State -> Nothing
loop([LoopNr,Nr,CMEM, HBQ, ConfigList, Datei]) ->
  log(Datei,server,["======= ",LoopNr," ======="]),
  receive
    Any ->
      log(Datei,server,["Received: ",Any]),
      case Any of 
      
        {Redakteur, getmsgid}  ->
          Redakteur ! {nid, Nr},
          log(Datei,server,["MsgNr ",Nr," to editor ",Redakteur]),
          loop([LoopNr+1,Nr+1,CMEM, HBQ, ConfigList, Datei]);
          
        {Client, getmessages} ->
          {ClientNr,CMEM2} = cmem:getClientNNr(CMEM,Client),
          HBQ ! {self(), {request,deliverMSG,ClientNr,Client}},
          loop([LoopNr+1,Nr,CMEM2, HBQ, ConfigList, Datei]);
        
        {reply,ClientID,SendNNr} ->
          CMEM2 = cmem:updateClient(CMEM,ClientID,SendNNr,Datei),
          loop([LoopNr+1,Nr,CMEM2, HBQ, ConfigList, Datei]);
        
        {dropmessage, [NNr,Msg,TSclientout]} -> 
          HBQ ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
          receive {reply, ok} ->
            log(Datei,server,["Inserted ",NNr," into hbq"]),
            loop([LoopNr+1,Nr,CMEM, HBQ, ConfigList, Datei]) 
          end;
          
        {Sender,shutdown} -> 
          HBQ ! {self(),{request,dellHBQ}},
          receive 
            {reply, HBQDead} -> HBQDead
          end,
          {ok, ServerName} = get_config_value(servername, ConfigList),
          Sender ! case unregister(ServerName) of
            true -> log(Datei,server,["Shutdown Server ",now()]), ok;
            _ -> nok
          end;

        Any ->
          log(Datei,server,["Received unknown message: ",Any]),
          loop([LoopNr+1,Nr,CMEM, HBQ, ConfigList, Datei])
          
      end
  end
  .





