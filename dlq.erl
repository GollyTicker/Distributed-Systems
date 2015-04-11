-module(dlq).
-export([initDLQ/2, expectedNr/1, push2DLQ/3, deliverMSG/4]).


initDLQ(Size, Datei) -> 
  werkzeug:logging(Datei, "initialized DLQ\n"),
  [[], Size, Datei].

% Eine Message ist entweder eine Fehlermessage die eine Lücke von Nachricht Nr1 bis Nr2 schließt
% oder eine reguläre Nachricht mit der eindeutigen Nr
% [{Nr1, Nr2}, Msg, Ts1..Tsn]
% [Nr, Msg, Ts1..Tsn]
expectedNr([[],_,_]) -> 1;
expectedNr([DQueue,_,_]) -> 
  case lists:head(lists:last(DQueue)) of
    {Nr1, Nr2} -> Nr2;
    Nr -> Nr
  end + 1.

% Speichern einer Nachricht in der DLQ
% [NNr,Msg,TSclientout,TShbqin]
push2DLQ([DQueue,Size,Datei],Entry,_) ->
  DQueue2 = case lists:size(DQueue) of
    Size -> lists:tail(DQueue); % DLQ zu groß. älteste Nachricht entfernen.
    Smaller -> DQueue
  end,
  [DQueue2 ++ [Entry],Size,Datei].

% TODO: Bei deliver die Fehlernachrichten berücksichtigen.
% Ausliefern einer Nachricht an einen Leser-Client
deliverMSG(MSGNr,ClientPID,Queue,Datei) -> undefined.

