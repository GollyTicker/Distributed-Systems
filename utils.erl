-module(utils).
-export([log/3,randomInt/1]).

% Eine Datei mit den Utilities

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

debugMode() -> false.

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
