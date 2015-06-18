-module(receiver).
-export([init/3]).

init(_Sink,_Broker,_Clock) -> loop(0).

% millisToNextFrame(M)
% fstByMillis(M)

loop(0) -> io:format("Fin");
loop(N) -> 
  io:format("Looping receiver"),
  loop(N - 1).
