-module(starter).
-export([start/0]).

start() ->
  spawn(fun() -> datasource:init() end),
  spawn(fun() -> datasink:init() end),
  spawn(fun() -> clock:init() end),
  spawn(fun() -> receiver:init() end),
  spawn(fun() -> sender:init() end),
  spawn(fun() -> slot_broker:init() end).