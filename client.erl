-module(client).
-export([start/0]).
-import(werkzeug,[get_config_value/2, to_String/1,timeMilliSecond/0]).
-import(utils,[log/3,randomInt/1]).


start() ->
  {ok, ConfigList} = file:consult("client.cfg"),

  {ok, LifeTime} = get_config_value(lifetime, ConfigList),
  {ok, SendIntervall} = get_config_value(sendeintervall, ConfigList),
  ClientConfig = {LifeTime, SendIntervall},

  {ok, ServerName} = get_config_value(servername, ConfigList),
  {ok, ServerNode} = get_config_value(servernode, ConfigList),
  ServerService = {ServerName,ServerNode},

  {ok, Clients} = get_config_value(clients, ConfigList),

  spawnClients(Clients, ServerService, ClientConfig).


spawnClients(Clients, ServerService, ClientConfig) ->
  case Clients of
    0 -> ok;
    _ -> 
      spawn(
        fun() ->
          timer:kill_after(LifeTime * 1000),
          loop(Clients, ServerService, ClientConfig) 
        end
      ),
      spawnClients(Clients-1, ServerService, ClientConfig)
  end.

loop(ClientNumber, ServerService, 
  {LifeTime, SendIntervall}) ->

  Datei = createLogFile(ClientNumber),
  log(Datei,editor,["Spawning client ", ClientNumber, " for ", node()]),

  Nrs = editor:execute(ServerService,
      {ClientNumber,SendIntervall}, 
      Datei),
  
  reader:execute(ServerService, Nrs, ClientNumber, Datei),

  NewSendIntervall = randomSendIntervall(SendIntervall),

  loop(ClientNumber, ServerService, {LifeTime, NewSendIntervall}).


randomSendIntervall(SendIntervall) ->
  random:seed(erlang:now()),
  OffSet = case random:uniform() < 0.5 of
    true -> -SendIntervall;
    _ -> SendIntervall
  end * 0.5,
  NewSendIntervall = SendIntervall + OffSet,
  case NewSendIntervall > 2.0 of
    true -> NewSendIntervall;
    _ -> 2.0
  end.

createLogFile(ClientNumber) ->
  Base = "log/Client_" ++ to_String(ClientNumber),
  NodeName = to_String(node()),
  End = "@KI-VS.log",
  list_to_atom(Base ++ NodeName ++ End).

