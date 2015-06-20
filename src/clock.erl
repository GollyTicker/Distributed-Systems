-module(clock).
-export([init/1,getMillisByFunc/2]).
-import(utils,[log/3]).

-define(LOG,"log/clock.log").


init(Offset) -> 
  log(?LOG,clock,["Clock start"]),
  loop(Offset).

% PID ! {self(), getCurrentTimeMillis}
% receive {timeMillis, MillisSince1970 } -> ... end

% PID ! {updateOffset, Delta}
% no response.

loop(Offset) ->
  receive
  
    {Sender, getCurrentTimeMillis} ->
      {MegaSecs, Secs, MicroSecs} = now(),
    	Millis = (MegaSecs * 1000000000 + Secs * 1000 + MicroSecs div 1000) + Offset,
    	Sender ! {timeMillis, Millis},
    	loop(Offset);
    	
  	{updateOffset, Delta} ->
  	  NewOffset = Offset + Delta,
  	  loop(NewOffset);
  
  	Any -> 
      log(?LOG, clock, ["Received unknown message: ", Any])
    	
  end.


getMillisByFunc(Clock, Func) ->
  Clock ! {self(), getCurrentTimeMillis},
  receive 
    {timeMillis, Millis} -> 
      Func(Millis)
  end.



