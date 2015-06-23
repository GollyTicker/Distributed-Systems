-module(utils).
-export([log/3,log/4,randomInt/1, atom_to_integer/1, createPacket/4, parsePacket/1, getTeam/1]).

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

-define(DEBUG, true).

-define(VERBOSE, false).

log(false, _, _, _) -> nolog;
log(true, Module, Team, List) -> log(Module, Team, List).

log(Module, Team, List) ->
  case ?DEBUG of
    true ->
      F = fun(X) ->
        case io_lib:printable_list(X) of
          true -> X;
          false -> to_String(X)
        end
      end,
      ModTeamStr = to_String(Module) ++ "-" ++ Team,
      Datei = logPath(Team),
      Str = ModTeamStr ++ ">> " ++ lists:flatmap(F,List) ++ "\n",
      case ?VERBOSE of
        true -> io:format(Str);
        false -> ok
      end,
      logging(Datei,Str);
    false -> nolog
  end.

logPath(Str) -> 
  "log/" ++ Str ++ ".log".

% return a number from 1 to Num.
% randomInt(Num) -> random:seed(now()), random:uniform(Num).
randomInt(Num) ->
  RandInt255 = hd(binary_to_list(crypto:strong_rand_bytes(1))), % 0 .. 255, int
  RandIntNminus1 = RandInt255/255*(Num-1), % 0 .. (N - 1), float
  round(RandIntNminus1) + 1. % 1 .. N, int

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
