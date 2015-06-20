-module(sender).
-export([init/4]).

-import(utils,[log/3]).

-define(LOG, "log/sender.log").

init(Station,Source,Broker,Clock) ->
  
  Source ! {self(),currentData},
  receive {chars, Chars} -> utils:log(?LOG, sender,["Source Sender: ",Chars]) end,
  
  Clock ! {self(),getCurrentTimeMillis},
  receive {timeMillis, Millis} -> utils:log(?LOG, sender,["Millis: ",Millis]) end,

  %log(?LOG,sender,["Parsed Packet: ", ParsedPacket]),

  % Clock ! {self(),getCurrentTimeMillis},
  % receive {timeMillis, Millis} -> utils:log(?LOG, sender,["FST: ",sync:fstByMillis(Millis)]) end,

  
  loop(Source,Broker,Clock,0).

loop(_,_,_,0) -> io:format("Fin");
loop(Source,Broker,Clock,N) -> 
  io:format("Looping sender"),
  loop(Source,Broker,Clock,N - 1).
