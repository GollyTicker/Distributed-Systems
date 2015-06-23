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

  {Bef,Aft} = sync:waitToNextFrame(Clock),
  log(logPath(TeamStr),sender,["WaitToNext ",Bef," -> ",Aft]),

  loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr).

loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr) -> 
  Data = getNewSource(Source),
  
  %should be at the beginning of Frame:
  {_F,S,ST} = sync:fstByMillis(clock:getMillis(Clock)),
  case S of
    1 -> ok;
    _ -> log(logPath(TeamStr),sender,["Not at Frame beginning! ", S, ", ",ST])
  end,
  
  SentNextNr = case CurrNr of
    undefined ->
      log(logPath(TeamStr),sender,["[0] CurrNr undef"]),
      undefined;
    _ ->
      M = clock:getMillis(Clock),
      TimeToWait = sync:millisToSlot(CurrNr,M),
      % log(logPath(TeamStr),sender,["  millisToSlot(",sync:slotNoByMillis(M)," -> ",CurrNr,") => ",TimeToWait]),
      case TimeToWait >= 0 of
        true -> 
          %Overhead = sync:safeSleepClock(Clock,TimeToWait),
          %log(logPath(TeamStr),sender,["Sleep overhead(ms): ",Overhead]),          
          sync:safeSleep(TimeToWait),
          ReserveNr = getNextFrameSlotNr(Broker),
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data, TeamStr);

        false -> 
          log(logPath(TeamStr),sender,["[1] TimeToWait negative"]),
          undefined
      end
  end,
  
  
  %% neue Nummer für nächstes Frame holen, falls nichts gesendet wurde.
  case SentNextNr of
    undefined -> 
      % wait to a time before the end of Frame.
      {Bef1,Aft1} = sync:waitToEndOfFrame(Clock),
      log(logPath(TeamStr),sender,["WaitToEnd ",Bef1," -> ",Aft1]),
      Broker ! {self(), getNextFrameSlotNr},
      receive
        {nextFrameSlotNr, NextNr2} -> 
          NextNr2,
          Asked = true
      end;
    NextNr2 ->
      NextNr2,
      Asked = true
  end,
  
  % log(logPath(TeamStr),sender,["[2] asked(",Asked,"): Send in ", NextNr2, " in next Frame"]),

  {Bef,Aft} = sync:waitToNextFrame(Clock),
  log(logPath(TeamStr),sender,["WaitToNext ",Bef," -> ",Aft]),
  
  loop(Con, NextNr2, Station, Source, Broker, Clock,TeamStr).

getNextFrameSlotNr(Broker) -> 
  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, ReserveNr} ->  ReserveNr
  end.

sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data, TeamStr) ->
  SlotNr = sync:slotNoByMillis(clock:getMillis(Clock)),
  
  CorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr),
  CanSendMessage = CorrectSlot and IsFree,
  %Why = case {CorrectSlot,IsFree} of
  %  {false,false} -> 
  log(logPath(TeamStr),sender,["[3] Send Message? ", CanSendMessage]),
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


