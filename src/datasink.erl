-module(datasink).
-export([init/0]).

-import(utils,[log/3]).


init() -> loop().

loop() ->
  receive
    {newData, ReceiverTeam, SenderTeam, Data} ->
      log(datasink, ReceiverTeam, ["Datasink: ", SenderTeam ," -> ",ReceiverTeam, " :: ", Data])
  end,
  loop().
