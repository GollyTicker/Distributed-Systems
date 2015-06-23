-module(utils).
-export([log/3,randomInt/1, atom_to_integer/1, createPacket/4, parsePacket/1, getTeam/1]).

% Eine Datei mit den Utilities

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

debugMode() -> true.

% Aufruf:
% log(0,hbq,["Hallo ",self()," ",[1,2]]).
log(Datei,Module,List) -> %0.
%log2(Datei,Module,List) ->
  F = fun(X) ->
    case io_lib:printable_list(X) of
      true -> X;
      false -> to_String(X)
    end
  end,
  Str = to_String(Datei) ++ ">> " ++ lists:flatmap(F,List) ++ "\n",
  case debugMode() of
    true -> logging(Datei,Str);
    false -> ok %io:format(Str)
  end.


randomInt(Num) ->
  random:seed(now()),
  random:uniform(Num).

atom_to_integer(X) -> list_to_integer(atom_to_list(X)).

createPacket(Station,Data,Slot,TS) ->
  <<(list_to_binary(Station)):1/binary,
    (list_to_binary(Data)):24/binary,
    Slot:8/integer,
    TS:64/integer-big>>. 

parsePacket(<<Station:1/binary, 
              Data:24/binary, 
              Slot:8/integer, 
              TS:64/integer-big>>) -> 
  { binary_to_list(Station), 
    binary_to_list(Data), 
    Slot, 
    TS }.

getTeam(Data) -> lists:sublist(Data, 10).
