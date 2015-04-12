-module(editor).
-export([execute/3]).
-import(werkzeug,[timeMilliSecond/0]).
-import(utils,[log/3,randomInt/1]).


execute(ServerService, 
  {ClientNumber, SendIntervall}, Datei) ->

  Nrs = loop(5, ServerService, [],
    {ClientNumber, SendIntervall}, 
     Datei),

  % unique id without any response
  ServerService ! {self(), getmsgid},

  % log if the requested id was received
  receive
    {nid, Nr} -> 
      log(Datei,editor,["Message ",Nr," at ",timeMilliSecond()," Forgot to send"])
  end,

  Nrs.


loop(0,_,Nrs,_,_) -> Nrs;
loop(Count, ServerService, Nrs,
    {ClientNumber, SendIntervall}, 
     Datei) -> 

  ServerService ! {self(), getmsgid},

  % Sendintervall after each id request
  timer:sleep(trunc(SendIntervall*1000)),

  receive
    {nid, Nr} ->
      Content = createText(),
      % log: dropped message NR at 16.06 09:55:43,525| content
      log(Datei,editor,["Dropped message ",Nr," at ",timeMilliSecond()," with ",Content]),
      ServerService ! {dropmessage, [Nr,Content,now()]},
      loop(Count - 1, ServerService, [Nr|Nrs],
          {ClientNumber, SendIntervall}, Datei);

    Any -> % terminate...
      log(Datei,editor,["Unknown message: ", Any])
  end.

% TODO: Hello world for Quotes
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
  lists:nth(randomInt(length(Quotes)), Quotes),
  "Hello World".
