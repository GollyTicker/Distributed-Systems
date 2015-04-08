-module(hello).
-export([hello_world/0, start/1, rpc/2]).

hello_world() -> io:format("~s!", ["Hello", "World"]).

print(S) -> io:format("~sn", [S]).

start(Name) ->
  PID = spawn(fun() -> loop() end),
  register(Name,PID),
  PID.

rpc(ServerID, Query) ->
  ServerID ! {self(), Query},
  receive
    {msg, Msg} -> print("rpc#" ++ Msg);
    _ -> ok
  end.

loop() ->
  receive
    {PID, Msg} -> print("Server: " ++ Msg), io:format(""), PID ! {msg, "Back#" ++ Msg}, loop();
    Any -> print("Server something: " ++ Any), loop()
  end.


% Client
%
% (a@ws67)> SPID = {server,'b@ws67.eduroam'}.
% (a@ws67)> hello:rpc(SPID,"Hi").  
% ...output...

% Server
% (b@wb67)> SID = hello:start(server).
% (b@wb67)> registered()

