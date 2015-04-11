-module(utils).
-export([log/3]).

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

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
  logging(Datei,Str).



