-module(datasink).
-export([init/0]).

-import(utils,[log/4]).


init() -> loop().

loop() ->
  receive
    {newData, ReceiverTeam, SenderTeam, Data} ->
      log(false,datasink, ReceiverTeam, ["Datasink: ", SenderTeam ," -> ",ReceiverTeam, " :: ", Data])
  end,
  loop().
