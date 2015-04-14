-module(cmem).
-import(werkzeug,[logging/2,get_config_value/2,to_String/1]).
-import(utils,[log/3]).
-export([initCMEM/2,updateClient/4,getClientNNr/2, refreshCMEM/1]).

% CMEM ADT: [LastSeenMapping,RemTime,Datei]

% LastSeenMapping: Abbildung von ClientID auf dessen letzten Anfragezeitpunkt un die dazugehörige Nachrichtennummer
% Als Liste von dreier Tupeln [{ClientID, NNr,LastTime}]

% initCMEM: Initialisieren des CMEM
% initCMEM: Int -> Datei -> CMEM
initCMEM(RemTime,Datei) ->
  CMEM = [[], RemTime, Datei],
  log(Datei,cmem,["Initialized cmem"]),
  CMEM.

% updateClient: Speichern/Aktualisieren eines Clients in dem CMEM
% updateClient: CMEM -> ClientID -> Nr -> Datei -> CMEM
updateClient(CMEM,ClientID,SendNr,Datei) ->
  NextNr = SendNr + 1,
  [Map,Rem,CDatei] = CMEM2 = refreshCMEM(CMEM),
  Elem = {ClientID,NextNr,erlang:now()},
  case getClient(ClientID,CMEM2) of
    false -> log(Datei,cmem,["Added new Client ",ClientID]);
    _ -> log(Datei,cmem,["Updated Client ",ClientID," to #",NextNr])
  end,
  Map2 = lists:keystore(ClientID,1,Map,Elem),
  [Map2,Rem,CDatei].

% Löscht veraltete Clients aus der CMEM.
% refreshCMEM: CMEM -> CMEM
refreshCMEM([LastSeenMap, RemTime, Datei]) ->
  NewMap =
    lists:filter( % Alle veralteten Clients filtern.
      fun({ClientID,_NNr,{MegaSec,Sec,MicroSec}}) ->
        LastSeenPlusRemTime = {MegaSec,Sec + RemTime, MicroSec},
        Now = erlang:now(),
        case werkzeug:compareNow(LastSeenPlusRemTime,Now) of
          before ->
            log(Datei,cmem,["Deleting inactive client: ",ClientID]),
            false;
          _ -> true
        end
      end,
     LastSeenMap),
  
  [NewMap,RemTime,Datei].


% getClientNNr: Abfrage welche Nachrichtennummer der Client als nächstes erhalten darf
% getClientNNr: CMEM -> ClientID -> Nr
getClientNNr(CMEM,ClientID) ->
  case getClient(ClientID,CMEM) of
      {NNr,_} -> NNr;
      false -> 1   % ein unbekannter Client erhält die erste Nachricht
  end.



% Hilfsmethode um einen Client zu holen: Returnt ein false oder ein Tupel
% getClient: ClientID -> CMEM -> ({Nr,Timestamp} | false)
getClient(ClientID,[Map,_,_]) ->
  case lists:keytake(ClientID,1,Map) of
    false -> false;
    {value,{_client,Nr,TS},_} -> {Nr,TS}
  end.


