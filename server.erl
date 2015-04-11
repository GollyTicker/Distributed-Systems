
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
    {nid,Nr} -> S ! {dropmessage,[Nr,"Hallo",now()]}
  end,
  0.

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
  {ok, HBQname} = get_config_value(hbqname,ConfigList),
  HBQservice = {HBQname,HBQnode},
  
  log(Datei, server,["Initializing hbq - Address: ",HBQservice]),
  HBQservice ! {self(), {request,initHBQ}},
  receive
    {reply, ok} -> log(Datei,server,["Received ok from hbq"])
  end,
  
  Timer = timer:send_after(Latency*1000,shutdown),
  
  log(Datei,server,["Initialized Server"]),
  State = [0,1, CMEM, HBQservice, Timer, Latency, ConfigList, Datei],
  State.


% loop: State -> Nothing
loop([LoopNr,Nr,CMEM, HBQ, Timer, Latency, ConfigList, Datei]) ->
  log(Datei,server,["======= ",LoopNr," ======="]),
  receive
    Any ->
      log(Datei,server,["Received: ",Any]),
      case Any of 
      
        {Redakteur, getmsgid}  ->
          NewTimer = werkzeug:reset_timer(Timer,Latency,shutdown),
          Redakteur ! {nid, Nr},
          log(Datei,server,["MsgNr ",Nr," to editor ",Redakteur]),
          loop([LoopNr+1,Nr+1,CMEM, HBQ, NewTimer, Latency, ConfigList, Datei]);
          
        {Client, getmessages} ->
          NewTimer = werkzeug:reset_timer(Timer,Latency,shutdown),
          ClientNr = cmem:getClientNNr(CMEM,Client),
          HBQ ! {self(), {request,deliverMSG,ClientNr,Client}},
          receive
            {reply,SendNr} ->
              CMEM2 = cmem:updateClient(CMEM,Client,SendNr,Datei),
              loop([LoopNr+1,Nr,CMEM2, HBQ, NewTimer, Latency, ConfigList, Datei])
          end;
        
        {dropmessage, [NNr,Msg,TSclientout]} -> 
          NewTimer = werkzeug:reset_timer(Timer,Latency,shutdown),
          HBQ ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
          receive {reply, ok} ->
            log(Datei,server,["Inserted ",NNr," into hbq"]),
            loop([LoopNr+1,Nr,CMEM, HBQ, NewTimer, Latency, ConfigList, Datei]) 
          end;
          
        shutdown -> 
          HBQ ! {self(),{request,dellHBQ}},
          receive 
            {reply, HBQDead} -> HBQDead
          end,
          {ok, ServerName} = get_config_value(servername, ConfigList),
          case unregister(ServerName) of
            true -> log(Datei,server,["Shutdown Server ",now()]), ok;
            _ -> nok
          end;

        Any ->
          log(Datei,server,["Received unknown message: ",Any]),
          NewTimer = werkzeug:reset_timer(Timer,Latency,shutdown),
          loop([LoopNr+1,Nr,CMEM, HBQ, NewTimer, Latency, ConfigList, Datei])
          
      end
  end
  .





