-module(dlq).
-export([initDLQ/2, expectedNr/1, push2DLQ/3, deliverMSG/4]).
-import(werkzeug,[logging/2,to_String/1]).


initDLQ(Size, Datei) -> 
  werkzeug:logging(Datei, "initialized DLQ\n"),
  [[], Size, Datei].

% Eine Message ist entweder eine Fehlermessage die eine Lücke von Nachricht Nr1 bis Nr2 schließt
% oder eine reguläre Nachricht mit der eindeutigen Nr
% [{Nr1, Nr2}, Msg, Ts1..Tsn]
% [Nr, Msg, Ts1..Tsn]
expectedNr([[],_,_]) -> 1;
expectedNr([DQueue,_,_]) -> getNr(lists:last(DQueue)) + 1.

% Speichern einer Nachricht in der DLQ
% [NNr,Msg,TSclientout,TShbqin]
push2DLQ([DQueue,Size,Datei],Entry,_) ->
  DQueue2 = case length(DQueue) of
    Size ->
      logging(Datei,"DLQ zu groß. älteste Nachricht entfernen."),
      tl(DQueue);
    Smaller -> DQueue
  end,
  [DQueue2 ++ [Entry],Size,Datei].

% TODO: Bei deliver die Fehlernachrichten berücksichtigen.
% Ausliefern einer Nachricht an einen Leser-Client
deliverMSG(Nr,ClientPID,DLQ,Datei) -> 
  {Terminated, SendNr, Msg} = smallestNrGt(DLQ, Nr),
  ClientPID ! {reply,[SendNr,Msg,now()],Terminated}.

% smallestNrGt(DLQ,Nr) => {Terminated,SendNr,Msg}
% Liefert die nächste höhere Nachricht nach Nr aus der DLQ zurück.
% Gibt es diese nicht, wird eine dummy Nachricht zurückgegeben und Terminated == true.
% Fehlernachrichten werden nicht übertragen.
smallestNrGt([Queue,_,_]=DLQ, Nr) ->
  DroppedQueue = lists:dropwhile(
    fun(X) -> 
      getNr(X) < Nr and realMsg(X) 
    end, Queue),
  case DroppedQueue of
    [] -> {true, Nr, "Sorry. No new messages for you :o"};
    [H|_] -> {false, getNr(H), "looong complicated message..."} % TODO: Message übertragen
  end.

% realMsg: Entry -> Bool
realMsg([{_,_}|_]) -> false;
realMsg(_) -> true.

getNr(Entry) ->
  case hd(Entry) of
    {Nr1, Nr2} -> Nr2;
    Nr -> Nr
  end.



