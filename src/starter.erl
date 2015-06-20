-module(starter).
-export([start/1]).
-import(utils,[log/3, atom_to_integer/1]).

-define(LOG, "log/starter.log").

start(CmdArgs) ->
  {_IFName, _MCA, _Port, Station, Offset} = parseConfig(CmdArgs),

  DataSource = spawn(fun() -> datasource:init() end),
  DataSink = spawn(fun() -> datasink:init() end),
  
  timer:sleep(300),
  
  Clock = spawn(fun() -> clock:init(Offset) end),
  Broker = spawn(fun() -> slot_broker:init(Clock) end),

  spawn(fun() -> receiver:init(DataSink,Broker,Clock) end),
  spawn(fun() -> sender:init(Station, DataSource,Broker,Clock) end).


parseConfig([InterfaceName, McastAddress, ReceivePort, StationType, UTCoffsetMs]) ->
  IFName = atom_to_list(InterfaceName),
  MCA = atom_to_list(McastAddress),
  Port = atom_to_integer(ReceivePort),
  Offset = atom_to_integer(UTCoffsetMs),
  Station = atom_to_list(StationType),
  log(?LOG, starter, ["IFName: ", IFName, " MCA: ", MCA, 
                      " Port: ", Port, " Station: ", Station,
                      " Offset: ", Offset]),
  {IFName, MCA, Port, Station, Offset}.

