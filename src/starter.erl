-module(starter).
-export([start/0]).

start() ->
  spawn(fun() -> datasource:loop() end),
  spawn(fun() -> datasink:loop() end),
  spawn(fun() -> clock:loop() end),
  spawn(fun() -> receiver:loop() end),
  spawn(fun() -> sender:loop() end),
  spawn(fun() -> slot_broker:loop() end).