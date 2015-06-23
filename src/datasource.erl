-module(datasource).
-export([init/0,getNewData/1]).

-import(io,[get_chars/2]).
-import(utils,[log/3]).


init() -> loop().

loop() ->
  receive 
    {Sender,currentData} ->
      Chars = get_chars('',24),
      log(datasource, utils:getTeam(Chars), ["Read: ", utils:getTeam(Chars), " ..."]),
      Sender ! {payload,Chars},
      loop()
  end.

getNewData(Source) ->
  Source ! {self(),currentData},
  receive 
    {payload, Data} -> 
      Data
  end.
