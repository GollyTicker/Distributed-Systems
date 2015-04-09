-module(dlq).
-export([initDLQ/2, expectedNr/1, push2DLQ/3, deliverMSG/4]).


initDLQ(Size, Datei) -> 
  werkzeug:logging(Datei, "initialized DLQ\n"),
  [[], Size, Datei].

% TODO: Bei deliver und expectedNr auch die Fehlernachrichten berücksichtigen.

% Abfrage welche Nachrichtennummer in der DLQ gespeichert werden kann
expectedNr([[],_,_]) -> 1;
expectedNr([DQueue,_,_]) -> lists:head(lists:last(DQueue)).

% Speichern einer Nachricht in der DLQ
% [NNr,Msg,TSclientout,TShbqin]
push2DLQ([DQueue,Size,Datei],Entry,_) ->
  DQueue2 = case lists:size(DQueue) of
    Size -> lists:tail(DQueue); % DLQ zu groß. älteste Nachricht entfernen.
    Smaller -> DQueue
  end,
  [DQueue2 ++ [Entry],Size,Datei].

% Ausliefern einer Nachricht an einen Leser-Client
deliverMSG(MSGNr,ClientPID,Queue,Datei) -> undefined.

