-module(sender).
-export([init/5]).

-import(utils,[log/3]).

-define(LOG, "log/sender.log").

init(Con,Station,Source,Broker,Clock) ->
  %Socket = werkzeug:openSe(Addr, Port),
  %gen_udp:controlling_process(Socket, self()),

  CNr = undefined,

  waitToNextFrame(Clock),

  loop(Con, CNr, Station, Source, Broker, Clock).

loop(Con, CNr, Station, Source, Broker, Clock) -> 
  log(?LOG,sender,["Next Frame!"]),
  Data = getNewSource(Source),

  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, NewNummer} -> 
      log(?LOG,sender,["NewNummer ",NewNummer]),
      NewNummer
  end,

  NewNummer2 = case CNr of
    undefined ->
      NewNummer;
    _ ->
      TimeToWait = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToSlot(CNr, X) end),
      timer:sleep(TimeToWait),
      sendMessage(Con, Clock, Broker, CNr, Station, Data)
  end, 
  waitToNextFrame(Clock),
  log(?LOG,sender,["Finished  Waiting"]),
  loop(Con, NewNummer2, Station, Source, Broker, Clock).



sendMessage(Con, Clock, Broker, CNr, Station, Data) ->
  {_, SlotNr, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  CanSendMessage = (CNr == SlotNr) and isFree(Broker, CNr),
  log(?LOG,sender,["Can I send a message?", CanSendMessage]),
  NewNr = case CanSendMessage of
    true -> 
      {Socket, Addr, Port} = Con,
      Packet = createPacket(Clock,Station,Data,CNr),
      gen_udp:send(Socket, Addr, Port, Packet),
      log(?LOG,sender,["Sent packet: ", Packet, " Con: ", Con, " CNr: " , CNr]),
      CNr;
    false -> 
      % Zeit verpasst oder occupied
      undefined
  end,
  NewNr.

isFree(Broker, CNr) ->
  Broker ! {self(), isFree, CNr},
  receive
    free -> true;
    occupied -> false     
  end.

waitToNextFrame(Clock) ->
  MillisToNextFrame = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToNextFrame(X) end),
  log(?LOG,sender,["Waiting for next Frame..", MillisToNextFrame]),
  timer:sleep(MillisToNextFrame).

getNewSource(Source) ->
  Source ! {self(),currentData},
  receive 
    {payload, Data} -> 
      utils:log(?LOG, sender,["Source Sender: ",Data]),
      Data
  end.

createPacket(Clock,Station,Data,Slot) ->
  TS = clock:getMillisByFunc(Clock, fun(X) -> X end),
  utils:createPacket(Station,Data,Slot,TS).



