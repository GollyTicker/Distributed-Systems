-module(utils).
-export([log/3,randomInt/1, atom_to_integer/1, createPacket/4, parsePacket/1, getTeam/1]).

% Eine Datei mit den Utilities

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

debugMode() -> true.

log(Module, Team, List) ->
  case debugMode() of
    true ->
      F = fun(X) ->
        case io_lib:printable_list(X) of
          true -> X;
          false -> to_String(X)
        end
      end,
      Datei = logPath(Module, Team),
      Str = Module ++ ">> " ++ lists:flatmap(F,List) ++ "\n",
      logging(Datei,Str);
    _ -> ok
  end.

logPath(Module, Team) -> 
  "log/" ++ Module ++ "-" ++ Team ++ ".log".

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
