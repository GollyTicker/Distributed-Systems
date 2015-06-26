-module(utils).
-export([log/4,log/5,logDataSink/3,randomInt/1, atom_to_integer/1, createPacket/4, parsePacket/1, getTeam/1]).

-import(werkzeug,[to_String/1,logging/2,type_is/1]).

-define(DEBUG, true).

% conditional logging
log(false, _, _, _, _) -> nolog;
log(true, DS,Module, Team, List) -> log(DS,Module, Team, List).

% general fast logging
log(DS,M,T,L) -> case ?DEBUG of true -> DS ! {logging,M,T,L}; false -> ok end.

% slow logging in DataSink
logDataSink(Module, Team, List) ->
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
          Inhalt = ModTeamStr ++ ">> " ++ lists:flatmap(F,List) ++ "\n",
          file:write_file(Datei,Inhalt,[append]);
        false -> nolog
      end.

%
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
