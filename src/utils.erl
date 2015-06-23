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


% return a number from 1 to Num.
randomInt(Num) ->
  RandInt255 = hd(binary_to_list(crypto:strong_rand_bytes(1))), % 0 .. 255, int
  RandIntNminus1 = RandInt255/255*(Num-1), % 0 .. (N - 1), float
  trunc(RandIntNminus1) + 1. % 1 .. N, int

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
