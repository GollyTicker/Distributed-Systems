-module(clock).
-export([init/2,getMillisByFunc/2,getMillis/1]).
-import(utils,[log/3]).

logPath(TeamStr) -> "log/clock-" ++ TeamStr ++ ".log".


init(Offset,TeamStr) -> 
  log(logPath(TeamStr),clock,["Clock start"]),
  loop(Offset,TeamStr).

% PID ! {self(), getCurrentTimeMillis}
% receive {timeMillis, MillisSince1970 } -> ... end

% PID ! {updateOffset, Delta}
% no response.

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
      log(logPath(TeamStr), clock, ["Received unknown message: ", Any])
    	
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

