-module(sender).
-export([init/0]).

init() -> loop(5).

loop(0) -> io:format("Fin");
loop(N) -> 
  io:format("Looping sender"),
  loop(N - 1).