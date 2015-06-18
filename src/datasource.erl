-module(datasource).
-export([init/0]).

-import(io,[get_chars/2]).
-import(utils,[log/3]).

% Abfrage der aktuellen 24 Bytes: 
% PID ! {self(),currentData}
% receive {bytes, Bytes} -> ... end

init() ->
  spawn( fun() -> reader(self()) end ),
  loop(eof).

loop(Chars) ->
  receive
    {Sender,currentData} -> Sender ! {bytes,Chars}, loop(Chars);
    {newdata,NewChars}   -> loop(NewChars)
  end

reader(Loop) ->
  log(bla,datasource,["Waiting to read."]),
  Chars = get_chars('',24),
  Loop ! {newdata,Chars},
  timer:sleep(1000),
  log(bla,datasource,["Read: ", Resp]),
  reader(Loop).
