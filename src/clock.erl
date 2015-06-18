-module(clock).
-export([init/0]).

init() -> loop(0).

loop(0) -> io:format("Fin");
loop(N) -> 
  io:format("Looping clock"),
  loop(N - 1).
