-module(datasink).
-export([init/0]).

-import(utils,[log/3]).

% logPath(TeamStr) -> "log/datasink-" ++ TeamStr ++ ".log".

init() -> loop().

loop() ->
  receive
    {newData, _ReceiverTeam, _SenderTeam, _Data} ->
      ok%log(logPath(ReceiverTeam), datasink, ["  Datasink: ", SenderTeam ," -> ",ReceiverTeam])
  end,
  loop().
