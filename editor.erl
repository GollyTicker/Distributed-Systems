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
  case N of
    0 -> ok;
    _ -> 
      spawnClient(N, ServerService, ClientConfig),
      spawnClients(N-1, ServerService, ClientConfig)
  end.

spawnClient(ClientNumber, 
            ServerService, 
            {LifeTime, SendIntervall}) ->
              spawn(
                fun() -> 
                  Datei = createLogFile(ClientNumber),
                  LoopCount = 1,
                  log(Datei,editor,["Spawning client ", ClientNumber, " for ", node()]),
                  loop(LoopCount, ServerService, 
                      {ClientNumber,LifeTime,SendIntervall}, 
                      Datei) 
                end
              ).

loop(LoopCount, ServerService, 
    {ClientNumber, LifeTime, SendIntervall}, 
     Datei) -> 

  % TODO: currently one can do 
  %   id for message but it should be possible to have
  %   several ids before dropping messages?
  % a unique msgid request is sent after 5th message that does not get a "dropmessage"
  ServerService ! {self(), getmsgid},
  % Sendintervall after each id request
  timer:sleep(SendIntervall*1000),

  % we start at index 1 not 0
  Rem5Message = LoopCount rem (5 + 1) == 0,
  receive
    {nid, Nr} ->
      % new Send intervall after N = 5 messages and
      NewSendIntervall = case Rem5Message of
        true -> randomSendIntervall(SendIntervall);
        false ->
          ServerService ! {dropmessage, [Nr,createText(),now()]},
          SendIntervall
      end;
    Any -> 
      NewSendIntervall = SendIntervall,
      log(Datei,editor,["Unknown message: ", Any])

  % Should we use a timeout here?
  after 5000 ->
    NewSendIntervall = SendIntervall,
    log(Datei,editor,["Timeout while waiting for a msgid"])

  end,

  % TODO: Find out how lifetime is calculated
  case timeExpired(LifeTime) of 
    true -> 
      log(Datei,editor, ["Editor ",ClientNumber," was successfully eliminated!"]);
    false -> 
      loop(LoopCount + 1, ServerService, 
          {ClientNumber, LifeTime, NewSendIntervall}, 
           Datei)
  end.

  % TODO: Change to client here


% TODO: currently random, need to implement later
timeExpired(LifeTime) ->
  LifeTime < randomInt(LifeTime) + 10.

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
  lists:nth(randomInt(length(Quotes)), Quotes).

randomInt(Num) ->
  random:seed(erlang:now()),
  random:uniform(Num).
