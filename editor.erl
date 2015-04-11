-module(editor).
-export([start/0]).
-import(werkzeug,[get_config_value/2, to_String/1]).
-import(utils,[log/3]).


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


spawnClients(N, ServerService, ClientConfig) -> 
  case N > 0 of
    true -> 
      spawnClient(N, ServerService, ClientConfig),
      spawnClients(N-1, ServerService, ClientConfig);
    false -> ok
  end.

spawnClient(ClientNumber, 
            ServerService, 
            {LifeTime, SendIntervall}) ->
  spawn(
    fun() -> 
      Datei = createLogFile(ClientNumber),
      log(Datei,editor,["Spawning client ", ClientNumber, " for ", node()]),
      loop(ServerService, 
          {ClientNumber,LifeTime,SendIntervall}, 
          Datei) 
    end
  ).

loop(ServerService, 
    {ClientNumber, LifeTime, SendIntervall}, 
     Datei) -> 
  ServerService ! {self(), getmsgid},
  receive
    {nid, Nr} ->
      ServerService ! {dropmessage, [Nr,createText(),now()]};
    Any -> 
      log(Datei,editor,["Unknown message: ", Any])
  end,
  loop(ServerService, 
      {ClientNumber, LifeTime, SendIntervall}, 
       Datei),

  log(Datei,editor,["Editor ",ClientNumber," was too controversial and eliminated!"]).


createLogFile(ClientNumber) ->
  Base = "log/Client_" ++ to_String(ClientNumber),
  NodeName = to_String(node()),
  End = "@KI-VS.log",
  list_to_atom(Base ++ NodeName ++ End).

% Text Helper...
createText() ->
  Quotes = [
    "People are just about as happy as they make up their minds to be - Abraham Lincoln ",
    "Everyone has problems, some are just better at hiding them - Unknown ",
    "If we did all the things that we are capable of doing, we would literally astound ourselves - Thomas Edison ",
    "Life is 10% what happens to us and 90% how we react to it - Dennis P. Kimbro ",
    "Sometimes your joy is the source of your smile, but sometimes your smile can be the source of your joy - Thich Nhat Hahn ",
    "Life is not lost by dying; life is lost minute by minute, day by dragging day, in all the thousand small uncaring ways - Stephen Vincent Ben't ",
    "Only by going too far can one possibly find out how far one can go - Jon dyer ",
    "People only see what they are prepared to see - Ralph Waldo Emerson ",
    "Don't be afraid to fail because only through failure do you learn to succeed ",
    "Its true that we dont know what weve got until we lose it, but its also true that we dont know what weve been missing until it arrives ",
    "Learn from the mistakes of others. You cant live long enough to make them all yourself - Chanakya ",
    "The tongue weighs practically nothing, but so few people can hold it ",
    "It takes only a minute to get a crush on someone, an hour to like someone, and a day to love someone; but it takes a lifetime to forget someone ",
    "Always put yourself in the others shoes. If you feel that it hurts you, it probably hurts the person too ",
    "The happiest of people dont necessarily have the best of everything they just make the most of everything that comes along their way ",
    "Many people will walk in and out or your life, But only true friends will leave footprints in your heart ",
    "To handle yourself, use your head, To handle others, use your heart ",
    "He who loses money, loses much; He who loses a friend, loses more; He who loses faith, loses all ",
    "If someone betrays you once, its his fault. If he betrays you twice, its your fault ",
    "God Gives every bird its food, But he does not throw it into its nest "
  ],
  random:seed(erlang:now()),
  lists:nth(random:uniform(length(Quotes)), Quotes).


