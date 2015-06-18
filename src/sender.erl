-module(sender).
-export([init/3]).

-define(LOG, "log/sender.log").

init(Source,Broker,Clock) ->
  
  %Source ! {self(),currentData},
  %receive {chars, Chars} -> utils:log(?LOG, sender,["Source Sender: ",Chars]) end,
  
  
  Clock ! {self(),getCurrentTimeMillis},
  receive {timeMillis, Millis} -> utils:log(?LOG, sender,["Millis: ",Millis]) end,
  
  
  loop(Source,Broker,Clock,0).

loop(_,_,_,0) -> io:format("Fin");
loop(Source,Broker,Clock,N) -> 
  io:format("Looping sender"),
  loop(Source,Broker,Clock,N - 1).
