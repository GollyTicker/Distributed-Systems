-module(slot_broker).
-export([init/1]).

init(Clock) -> loop(0).

loop(0) -> io:format("Fin");
loop(N) -> 
  io:format("Looping slot broker"),
  loop(N - 1).
