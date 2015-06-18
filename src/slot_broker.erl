-module(slot_broker).
-export([init/0]).

init() -> loop(5).

loop(0) -> io:format("Fin");
loop(N) -> 
  io:format("Looping slot broker"),
  loop(N - 1).