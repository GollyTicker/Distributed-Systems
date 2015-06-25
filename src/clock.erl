-module(clock).
-export([init/3,getMillis/1]).
-import(utils,[log/4]).

init(Offset,TeamStr,DS) -> 
  log(DS,clock, TeamStr, ["Clock start"]),
  loop(Offset,TeamStr,DS).
  
loop(Offset,TeamStr,DS) ->
  receive
  
    {Sender, getCurrentTimeMillis} ->
    	Millis = unixMillis() + Offset,
    	Sender ! {timeMillis, Millis},
    	loop(Offset,TeamStr,DS);
    	
  	{updateOffset, Delta} ->
  	  NewOffset = Offset + Delta,
      case Delta >= 5 of
        true -> log(DS, clock, TeamStr, ["Larger update: Delta, ",Delta,", NewOffset: ", NewOffset]);
        false -> ok
      end,
  	  loop(NewOffset,TeamStr,DS);
  
  	Any -> 
      log(DS,clock, TeamStr, ["Received unknown message: ", Any])
    	
  end.

unixMillis() ->
  {MegaSecs, Secs, MicroSecs} = now(),
  MegaSecs * 1000000000 + Secs * 1000 + MicroSecs div 1000.

getMillis(Clock) ->
  Clock ! {self(), getCurrentTimeMillis},
  receive 
    {timeMillis, Millis} -> 
      Millis
  end.

