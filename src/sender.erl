-module(sender).
-export([init/3]).

init(Source,Broker,Clock) ->
  Source ! {self(),currentData},
  receive {chars, Chars} -> utils:log(sender,sender,["Source Sender :",Chars]) end,
  loop(Source,Broker,Clock,0).

loop(Source,Broker,Clock,0) -> io:format("Fin");
loop(Source,Broker,Clock,N) -> 
  io:format("Looping sender"),
  loop(Source,Broker,Clock,N - 1).
