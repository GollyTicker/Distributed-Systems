-module(datasource).
-export([init/0,getNewSource/1]).

-import(io,[get_chars/2]).
-import(utils,[log/3]).

% logPath(TeamStr) -> "log/datasource-" ++ TeamStr ++ ".log".

% Abfrage der aktuellen 24 Bytes: 
% PID ! {self(),currentData}
% receive {payload, Chars} -> ... end

init() -> loop().

loop() ->
  receive
    
    {Sender,currentData} ->
      Chars = get_chars('',24),
      % log(logPath(utils:getTeam(Chars)), datasource,["Read: ", utils:getTeam(Chars), " ..."]),
      Sender ! {payload,Chars},
      loop()

  end.


getNewSource(Source) ->
  Source ! {self(),currentData},
  receive 
    {payload, Data} -> 
      Data
  end.
