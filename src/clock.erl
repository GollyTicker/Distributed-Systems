-module(clock).
-export([init/2,getMillisByFunc/2,getMillis/1]).
-import(utils,[log/3]).

init(Offset,TeamStr) -> 
  log(clock, TeamStr, ["Clock start"]),
  loop(Offset,TeamStr).
  
loop(Offset,TeamStr) ->
  receive
  
    {Sender, getCurrentTimeMillis} ->
    	Millis = unixMillis() + Offset,
    	Sender ! {timeMillis, Millis},
    	loop(Offset,TeamStr);
    	
  	{updateOffset, Delta} ->
  	  NewOffset = Offset + Delta,
  	  loop(NewOffset,TeamStr);
  
  	Any -> 
      log(clock, TeamStr, ["Received unknown message: ", Any])
    	
  end.

unixMillis() ->
  {MegaSecs, Secs, MicroSecs} = now(),
  MegaSecs * 1000000000 + Secs * 1000 + MicroSecs div 1000.

getMillisByFunc(Clock, Func) ->
  Clock ! {self(), getCurrentTimeMillis},
  receive 
    {timeMillis, Millis} -> 
      Func(Millis)
  end.

getMillis(Clock) ->
  Clock ! {self(), getCurrentTimeMillis},
  receive 
    {timeMillis, Millis} -> 
      Millis
  end.

