-module(datasource).
-export([init/1,getNewData/1]).

-import(io,[get_chars/2]).
-import(utils,[log/5]).


init(DSink) -> loop(DSink).

loop(DSink) ->
  receive 
    {Sender,currentData} ->
      Chars = get_chars('',24),
      Sender ! {payload,Chars},
      loop(DSink)
  end.

getNewData(Source) ->
  Source ! {self(),currentData},
  receive 
    {payload, Data} -> 
      Data
  end.
