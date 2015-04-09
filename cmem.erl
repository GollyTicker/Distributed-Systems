-module(cmem).
-import(werkzeug,[logging/2,get_config_value/2,to_String/1]).
-export([initCMEM/2,updateClient/4,getClientNNr/2, refreshCMEM/1]).

% CMEM ADT: [LastSeenMapping,RemTime,Datei]

% LastSeenMapping: Abbildung von ClientID auf dessen letzten Anfragezeitpunkt un die dazugehörige Nachrichtennummer
% Als Liste von dreier Tupeln [{ClientID, NNr,LastTime}]

% initCMEM: Initialisieren des CMEM
% initCMEM: Int -> Datei -> CMEM
initCMEM(RemTime,Datei) ->
  CMEM = [[], RemTime, Datei],
  logging(Datei,"Initialized CMEM\n"),
  CMEM.

% updateClient: Speichern/Aktualisieren eines Clients in dem CMEM
% updateClient: CMEM -> ClientID -> Nr -> Datei -> CMEM
updateClient(CMEM,ClientID,NNr,Datei) ->

  logging(Datei, io_lib:format("updateClient(~p,~p,~p,~p)\n",[CMEM,ClientID,NNr,Datei])),
  
  [LastSeenMap, RemTime, Datei] = CMEM,
  
  % Einfügen des Clients in die Map
  NewMap2 = insert(ClientID,NNr,LastSeenMap),
  CMEM2 = [NewMap2,RemTime,Datei],
  
  logging(Datei, io_lib:format("updateClient: new CMEM: ~p\n",[CMEM2])),
  CMEM2.


% Löscht veraltete Clients aus der CMEM.
% refreshCMEM: CMEM -> CMEM
refreshCMEM(CMEM) ->
  [LastSeenMap, RemTime, Datei] = CMEM,
  
  % Alle veralteten Clients filtern.
  NewMap = lists:filter(
                        fun({ClientID,_NNr,{MegaSec,Sec,MicroSec}}) ->
                          logging(Datei,"refreshCMEM: Client last seen: " ++ to_String({MegaSec,Sec,MicroSec}) ++ "\n"),
                          LastSeenPlusRemTime = {MegaSec,Sec + RemTime, MicroSec},
                          Now = erlang:now(),
                          case werkzeug:compareNow(LastSeenPlusRemTime,Now) of
                            before ->
                              logging(Datei, "refreshCMEM:Client vergessen: " ++ to_String(ClientID) ++ "\n"),
                              false;
                            _ -> true
                          end
                        end
                        ,LastSeenMap),
  
  % Speichern und zurückgeben
  CMEM2 = [NewMap,RemTime,Datei],
  
  logging(Datei, io_lib:format("refreshCMEM: new CMEM: ~p\n",[CMEM2])),
  CMEM2.


% getClientNNr: Abfrage welche Nachrichtennummer der Client als nächstes erhalten darf
% getClientNNr: CMEM -> ClientID -> Nr
getClientNNr(CMEM,ClientID) ->
  logging(datei(CMEM), io_lib:format("getClientNNr(~p,~p)\n",[CMEM,ClientID])),
  CMEM2 = refreshCMEM(CMEM),    % löschen alter Clients
  Nr =
    case getClient(ClientID,CMEM2) of
      {NNr,_} -> NNr;
      false -> 1   % ein unbekannter Client erhält die erste Nachricht
    end,
  {CMEM2,Nr}.



% Hilfsmethode um einen Client zu holen: Returnt ein false oder ein Tupel
% getClient: ClientID -> CMEM -> ({Nr,Timestamp} | false)
getClient(ClientID,[Map,_,_]) ->
  case lists:keytake(ClientID,1,Map) of
    false -> false;
    {_,NNr,TS} -> {NNr,TS}
  end.

% Client in CMEM (neu) einfügen
% insert: ClientID -> Nr -> Map -> Map
insert(ClientID,NNr,Map) ->
  Elem = {ClientID,NNr,erlang:now()},
  lists:keystore(ClientID,1,Map,Elem).

% datei: CMEM -> Datei
datei([_,_,Datei]) -> Datei.

