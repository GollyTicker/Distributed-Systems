-module(datasource).
-export([init/0,getNewSource/1]).

-import(io,[get_chars/2]).
-import(utils,[log/3]).

-define(LOG, "log/datasource.log").

% Abfrage der aktuellen 24 Bytes: 
% PID ! {self(),currentData}
% receive {payload, Chars} -> ... end

init() -> loop().

loop() ->
  receive
    
    {Sender,currentData} ->
      Chars = get_chars('',24),
      log(?LOG, datasource,["Read: ", utils:getTeam(Chars), " ..."]),
      Sender ! {payload,Chars},
      loop()

  end.


getNewSource(Source) ->
  Source ! {self(),currentData},
  receive 
    {payload, Data} -> 
      Data
  end.