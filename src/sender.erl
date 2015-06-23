-module(sender).
-export([init/6]).

-import(utils,[log/3]).
-import(datasource,[getNewSource/1]).

logPath(TeamStr) -> "log/sender-" ++ TeamStr ++ ".log".

init(InitalCon,Station,Source,Broker,Clock,TeamStr) ->
  log(logPath(TeamStr),sender,["Sender start"]),

  {IFAddr, Port, MCA} = InitalCon,
  Socket = werkzeug:openSe(IFAddr, Port),
  Con = {Socket, IFAddr, Port, MCA},

  CurrNr = undefined,

  sync:waitToNextFrame(Clock),

  loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr).

loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr) -> 
  Data = getNewSource(Source),
  
  SentNextNr = case CurrNr of
    undefined -> undefined;
    _ ->
      TimeToWait = sync:millisToSlot(CurrNr,clock:getMillis(Clock)),
      case TimeToWait >= 0 of
        true -> 
          %Overhead = sync:safeSleepClock(Clock,TimeToWait),
          %log(logPath(TeamStr),sender,["Sleep overhead(ms): ",Overhead]),          
          sync:safeSleep(TimeToWait),
          ReserveNr = getNextFrameSlotNr(Broker),
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data,TeamStr);

        false -> undefined
      end
  end,
  
  
  %% neue Nummer für nächstes Frame holen, falls nichts gesendet wurde.
  case SentNextNr of
    undefined -> 
      % wait to a time before the end of Frame.
      sync:waitToEndOfFrame(Clock),
      Broker ! {self(), getNextFrameSlotNr},
      receive
        {nextFrameSlotNr, NextNr2} -> 
          NextNr2
      end;
    NextNr2 -> NextNr2
  end,

  sync:waitToNextFrame(Clock),
  
  loop(Con, NextNr2, Station, Source, Broker, Clock,TeamStr).

getNextFrameSlotNr(Broker) -> 
  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, ReserveNr} ->  ReserveNr
  end.

sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data,TeamStr) ->
  SlotNr = sync:slotNoByMillis(clock:getMillisByFunc(Clock)),
  
  CorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr)
  CanSendMessage = CorrectSlot and IsFree,
  Why = case {CorrectSlot,IsFree} of
    {false,false} -> 
  log(logPath(TeamStr),sender,["Send Message? ", Why]),
  case CanSendMessage of
    true -> 
      {Socket, _, Port, MCA} = Con,
      Packet = createPacket(Clock,Station,Data,ReserveNr),
      gen_udp:send(Socket, MCA, Port, Packet),
      ReserveNr;
    false -> undefined % Zeit verpasst oder occupied
  end.

isFree(Broker, CNr) ->
  Broker ! {self(), isFree, CNr},
  receive
    free -> true;
    occupied -> false     
  end.

createPacket(Clock,Station,Data,Slot) ->
  TS = clock:getMillis(Clock),
  utils:createPacket(Station,Data,Slot,TS).


