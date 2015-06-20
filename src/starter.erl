-module(starter).
-export([start/1]).
-import(utils,[log/3, atom_to_integer/1]).

-define(LOG, "log/starter.log").

start(CmdArgs) ->
  {IFName, MCA, Port, Station, Offset} = parseConfig(CmdArgs),
  Con = {IFName, Port, MCA},

  DataSource = spawn(fun() -> datasource:init() end),
  DataSink = spawn(fun() -> datasink:init() end),
  
  timer:sleep(300),
  
  Clock = spawn(fun() -> clock:init(Offset) end),
  Broker = spawn(fun() -> slot_broker:init(Clock) end),

  spawn(fun() -> receiver:init(Con,DataSink,Broker,Clock) end),
  spawn(fun() -> sender:init(Con,Station,DataSource,Broker,Clock) end).


parseConfig([InterfaceName, McastAddress, ReceivePort, StationType, UTCoffsetMs]) ->
  IFAddr = get_interface_ip(atom_to_list(InterfaceName)),

  {ok,MCAddr} = inet:parse_ipv4_address(atom_to_list(McastAddress)),

  Port = atom_to_integer(ReceivePort),
  Offset = atom_to_integer(UTCoffsetMs),
  Station = atom_to_list(StationType),


  log(?LOG, starter, ["IFAddr: ", IFAddr, " MCAddr: ", MCAddr, 
                      " Port: ", Port, " Station: ", Station,
                      " Offset: ", Offset]),
  {IFAddr, MCAddr, Port, Station, Offset}.

get_interface_ip(InterfaceName) ->
  {ok, Interfaces} = inet:getifaddrs(),
  FullInterface = proplists:get_value(InterfaceName, Interfaces),
  IPAdresses = proplists:lookup_all(addr, FullInterface),
  log(?LOG, starter, ["IPAdresses: ", IPAdresses]),
  fetch_ipv4_adr(IPAdresses).

fetch_ipv4_adr(Addrs) ->
  IPv4Addresses = lists:map(fun({addr,X}) -> inet:parse_ipv4_address(inet:ntoa(X)) end, Addrs),
  log(?LOG, starter, ["IPv4Adresses: ", IPv4Addresses]),
  {ok, Addr} = hd(lists:filter(fun(X) -> X /= {error,einval} end, IPv4Addresses)),
  Addr.

