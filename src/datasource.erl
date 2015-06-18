-module(datasource).
-export([init/0]).

-import(io,[get_chars/2]).
-import(utils,[log/3]).

-define(LOG, "log/datasource.log").

% Abfrage der aktuellen 24 Bytes: 
% PID ! {self(),currentData}
% receive {chars, Chars} -> ... end

init() -> loop().

loop() ->
  receive
    {Sender,currentData} ->
      Chars = get_chars('',24),
      log(?LOG, datasource,["Read: ", lists:sublist(Chars,10), " ..."]),
      Sender ! {chars,Chars},
      loop()
  end.
