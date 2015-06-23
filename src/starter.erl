-module(starter).
-export([start/1]).
-import(utils,[log/3, atom_to_integer/1]).

start(CmdArgs) ->
  {IFAddr, MCAddr, Port, Station, Offset} = parseConfig(CmdArgs),
  Con = {IFAddr, Port, MCAddr},

  DataSource = spawn(fun() -> datasource:init() end),
  DataSink = spawn(fun() -> datasink:init() end),
  
  Team = utils:getTeam(datasource:getNewData(DataSource)),

  log(starter, Team,["IFAddr: ", IFAddr, " MCAddr: ", MCAddr, 
                      " Port: ", Port, " Station: ", Station,
                      " Offset: ", Offset]),
  
  Clock = spawn(fun() -> clock:init(Offset,Team) end),
  Broker = spawn(fun() -> slot_broker:init(Clock,Team) end),

  spawn(fun() -> receiver:init(Con,Team,DataSink,Broker,Clock) end),
  spawn(fun() -> sender:init(Con,Station,DataSource,Broker,Clock,Team) end).


parseConfig([InterfaceName, McastAddress, ReceivePort, StationType, UTCoffsetMs]) ->
  IFAddr = get_interface_ip(atom_to_list(InterfaceName)),
  {ok, MCAddr} = inet:parse_ipv4_address(atom_to_list(McastAddress)),
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

