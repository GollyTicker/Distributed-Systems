-module(datasink).
-export([init/0]).

-import(utils,[log/3]).

-define(LOG, "log/datasink.log").

init() -> loop().

loop() ->
  receive
    {newData, Team, Data} ->
      log(?LOG, datansink, ["Datasink (from: ", Team ,") received: ", utils:getTeam(Data)])
  end,
  loop().