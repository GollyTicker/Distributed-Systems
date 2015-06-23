-module(datasink).
-export([init/0]).

-import(utils,[log/3]).

logPath(TeamStr) -> "log/datasink-" ++ TeamStr ++ ".log".

init() -> loop().

loop() ->
  receive
    {newData, ReceiverTeam, SenderTeam, _Data} ->
      log(logPath(ReceiverTeam), datasink, ["  Datasink: ", SenderTeam ," -> ",ReceiverTeam])
  end,
  loop().
