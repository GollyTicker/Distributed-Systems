-module(receiver).
-export([loop/0]).

loop() -> 
  io:format("Looping receiver").