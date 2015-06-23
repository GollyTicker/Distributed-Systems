-module(udp_receiver).
-export([init/3]).

-import(utils,[log/3]).

logPath(TeamStr) -> "log/udp-" ++ TeamStr ++ ".log".

init(PID, Con, TeamStr) ->
  log(logPath(TeamStr), upd_receiver, ["UDP Receiver start"]),
  {IFAddr, Port, MCA} = Con,
  Socket = werkzeug:openRec(MCA, IFAddr, Port),
  gen_udp:controlling_process(Socket, self()), 
  loop(PID, Socket).

loop(PID, Socket) ->
  {ok, {_Address, _Port, Packet}} = gen_udp:recv(Socket, 0),
  PID ! {newmessage, Packet},
  loop(PID, Socket).
