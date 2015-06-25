-module(datasink).
-export([init/0]).

-import(utils,[log/5,logDataSink/3]).


init() -> loop().

loop() ->
  receive
    {newData, ReceiverTeam, SenderTeam, Data} ->
      log(true,self(),datasink, ReceiverTeam, ["Datasink: ", SenderTeam ," -> ",ReceiverTeam, " :: ", Data]);
    {logging,M,T,L} -> logDataSink(M,T,L)
  end,
  loop().
