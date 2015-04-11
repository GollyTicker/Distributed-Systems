-module(editor).
-export([start/0]).
-import(werkzeug,[get_config_value/2]).
-import(utils,[log/3]).



start() ->
  {ok, ConfigList} = file:consult("client.cfg"),
  {ok, Clients} = get_config_value(clients, ConfigList),

  spawnClients(Clients, ConfigList).

spawnClients(N, ConfigList) -> 
  case N > 0 of
    true -> 
      spawnClient(N, ConfigList),
      spawnClients(N-1, ConfigList);
    false -> ok
  end.

spawnClient(ClientNumber, ConfigList) ->
  spawn(
    fun() -> 
      Datei = createLogFile(ClientNumber),
      log(Datei,editor,["Creating Editor ",ClientNumber," on ",node()]),
      loop(ConfigList, Datei) 
    end
  ).

loop(ConfigList, Datei) -> 
  log(Datei,editor,["Let's loop!"]),
  undefined.

createLogFile(ClientNumber) ->
  Base = "log/Client_",
  NodeName = atom_to_list(node()),
  End = "@KI-VS.log",
  list_to_atom(Base ++ ClientNumber ++ NodeName ++ End).


% Maybe use later...
loadVariables(ConfigList) ->
  {ok, ServerName} = get_config_value(servername, ConfigList),
  {ok, ServerNode} = get_config_value(servernode, ConfigList),
  {ok, Clients} = get_config_value(clients, ConfigList),
  {ok, LifeTime} = get_config_value(lifetime, ConfigList),
  {ok, SendIntervall} = get_config_value(sendeintervall, ConfigList),
  {
    ServerName, ServerNode,
    Clients, LifeTime, SendIntervall
  }.







