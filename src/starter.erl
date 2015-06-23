-module(starter).
-export([start/1]).
-import(utils,[log/3, atom_to_integer/1]).

logPath(TeamStr) -> "log/starter-" ++ TeamStr ++ ".log".

start(CmdArgs) ->
  
  {IFAddr, MCAddr, Port, Station, Offset} = parseConfig(CmdArgs),
  Con = {IFAddr, Port, MCAddr},

  DataSource = spawn(fun() -> datasource:init() end),
  DataSink = spawn(fun() -> datasink:init() end),
  
  TeamStr = utils:getTeam(datasource:getNewSource(DataSource)),

  log(logPath(TeamStr), starter, ["IFAddr: ", IFAddr, " MCAddr: ", MCAddr, 
                      " Port: ", Port, " Station: ", Station,
                      " Offset: ", Offset]),
  
  Clock = spawn(fun() -> clock:init(Offset,TeamStr) end),
  Broker = spawn(fun() -> slot_broker:init(Clock,TeamStr) end),

  spawn(fun() -> receiver:init(Con,TeamStr,DataSink,Broker,Clock) end),
  spawn(fun() -> sender:init(Con,Station,DataSource,Broker,Clock,TeamStr) end).


parseConfig([InterfaceName, McastAddress, ReceivePort, StationType, UTCoffsetMs]) ->
  IFAddr = get_interface_ip(atom_to_list(InterfaceName)),

  {ok,MCAddr} = inet:parse_ipv4_address(atom_to_list(McastAddress)),

  Port = atom_to_integer(ReceivePort),
  Offset = atom_to_integer(UTCoffsetMs),
  Station = atom_to_list(StationType),
  {IFAddr, MCAddr, Port, Station, Offset}.

get_interface_ip(InterfaceName) ->
  {ok, Interfaces} = inet:getifaddrs(),
  FullInterface = proplists:get_value(InterfaceName, Interfaces),
  IPAdresses = proplists:lookup_all(addr, FullInterface),
  fetch_ipv4_adr(IPAdresses).

fetch_ipv4_adr(Addrs) ->
  IPv4Addresses = lists:map(fun({addr,X}) -> inet:parse_ipv4_address(inet:ntoa(X)) end, Addrs),
  {ok, Addr} = hd(lists:filter(fun(X) -> X /= {error,einval} end, IPv4Addresses)), 
  Addr.

