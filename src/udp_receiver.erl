-module(udp_receiver).
-export([init/2]).

-import(utils,[log/3]).

-define(LOG, "log/udp_receiver.log").

init(PID, Con) ->
  log(?LOG, upd_receiver, ["UDPReceiver start"]),
  {IFAddr, Port, MCA} = Con,
  Socket = werkzeug:openRec(MCA, IFAddr, Port),
  gen_udp:controlling_process(Socket, self()), 
  loop(PID, Socket).

loop(PID, Socket) ->
  {ok, {_Address, _Port, Packet}} = gen_udp:recv(Socket, 0),
  log(?LOG, upd_receiver, ["UDP Received Packet."]),
  PID ! {newmessage, Packet},
  loop(PID, Socket).