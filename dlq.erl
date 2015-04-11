-module(dlq).
-export([initDLQ/2, expectedNr/1, push2DLQ/3, deliverMSG/4]).
-import(werkzeug,[to_String/1]).
-import(utils,[log/3]).


initDLQ(Size, Datei) -> 
  werkzeug:logging(Datei, "initialized dlq"),
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
      log(Datei,dlq,["dlq too big. removing oldest message"]),
      tl(DQueue);
    _Smaller -> DQueue
  end,
  TSdlqin = now(),
  Entry2 = Entry ++ [TSdlqin],
  log(Datei,dlq,["Message ",getNr(Entry)," into dlq"]),
  [DQueue2 ++ [Entry2],Size,Datei].

% Ausliefern einer Nachricht an einen Leser-Client
deliverMSG(Nr,ClientPID,DLQ,Datei) -> 
  {Terminated, Msg} = smallestNrGt(DLQ, Nr),
  TSdlqout = now(),
  Msg2 = Msg ++ [TSdlqout],
  [SendNr|_] = Msg2,
  ClientPID ! {reply,Msg2,Terminated},
  log(Datei,dlq,["Message ",SendNr," sent to client ", ClientPID]).

% smallestNrGt(DLQ,Nr) => {Terminated,[SendNr,Msg,TS1...TSn]}
% Liefert die nächste höhere Nachricht nach Nr aus der DLQ zurück.
% Gibt es diese nicht, wird eine dummy Nachricht zurückgegeben und Terminated == true.
% Fehlernachrichten werden nicht übertragen.
smallestNrGt([Queue,_,_]=DLQ, Nr) ->
  DroppedQueue = lists:dropwhile(
    fun(X) -> 
      getNr(X) < Nr and realMsg(X) 
    end, Queue),
  case DroppedQueue of
    [] ->
        TS = now(),
        {true, [Nr,"Sorry. No new messages for you :o",TS,TS,TS]};
    [Msg|_] -> {false, Msg}
  end.

% realMsg: Entry -> Bool
realMsg([{_,_}|_]) -> false;
realMsg(_) -> true.

getNr(Entry) ->
  case hd(Entry) of
    {Nr1, Nr2} -> Nr2;
    Nr -> Nr
  end.



