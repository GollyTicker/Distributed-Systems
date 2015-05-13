-module(utils).
-export([
    log/3,          randomInt/1, connectToNameService/2,
    lookup/3,       killMe/2,
    sleepSeconds/1, seconds/1,
    sleepMillis/1,  millis/1   
  ]).

% Eine Datei mit den Utilities

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

debugMode() -> true.

% Aufruf:
% log(0,hbq,["Hallo ",self()," ",[1,2]]).
log(Datei,Module,List) -> 
  F = fun(X) ->
    case io_lib:printable_list(X) of
      true -> X;
      false -> to_String(X)
    end
  end,
  Str = to_String(Module) ++ ">> " ++ lists:flatmap(F,List) ++ "\n",
  case debugMode() of
    true -> logging(Datei,Str);
    false -> ok %io:format(Str)
  end.


randomInt(Num) ->
  random:seed(erlang:now()),
  random:uniform(Num).

connectToNameService(NSnode, NSname) ->
  net_adm:ping(NSnode),
  timer:sleep(500),
  NameService = global:whereis_name(NSname),
  NameService.

lookup(NameService,Self,What) -> 
  NameService ! {Self, {lookup, What}},
  receive
    not_found -> not_found;
    {pin, PID} -> PID
  end.
%

% seconds(45.1) -> 45
% Für Aufrufe auf Timer-Funktionen. Z.B. timer:sleep(seconds(12.1))
seconds(S) -> millis(1000*S).
%
millis(M) -> 
  M2 = case type_is(M) of
      float -> round(M);
      integer -> M
  end,
  max(0,M2).
%

sleepSeconds(S) ->  timer:sleep(seconds(S)).
sleepMillis(S) ->  timer:sleep(millis(S)).
%

killMe(Name, NameService) ->
  NameService ! {self(),{unbind,Name}},
  unregister(Name).
%