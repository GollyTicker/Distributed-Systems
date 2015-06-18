-module(starter).
-export([start/0]).

start() ->
  DataSource = spawn(fun() -> datasource:init() end),
  DataSink = spawn(fun() -> datasink:init() end),
  timer:sleep(300),
  Clock = spawn(fun() -> clock:init() end),
  Broker = spawn(fun() -> slot_broker:init(Clock) end),
  spawn(fun() -> receiver:init(DataSink,Broker,Clock) end),
  spawn(fun() -> sender:init(DataSource,Broker,Clock) end).
