-module(dlq).
-export([initDLQ/2, expectedNr/1, push2DLQ/3, deliverMSG/4]).


initDLQ(Size, Datei) -> 
  werkzeug:logging(Datei, "initialized DLQ\n"),
  [[], Size, Datei].

% Abfrage welche Nachrichtennummer in der DLQ gespeichert werden kann
expectedNr(Queue) -> 1;
expectedNr(Queue) -> 
  [NNr,_,_] = lists:last(Queue),
  NNr.

% Speichern einer Nachricht in der DLQ
% [NNr,Msg,TSclientout,TShbqin]
push2DLQ(Queue,Entry,Datei) ->
  Queue ++ [Entry].

% Ausliefern einer Nachricht an einen Leser-Client
deliverMSG(MSGNr,ClientPID,Queue,Datei) -> undefined.

