-module(sender).
-export([init/6]).

-import(utils,[log/3]).
-import(datasource,[getNewSource/1]).

init(Config,Station,Source,Broker,Clock,TeamStr) ->
  log(sender, TeamStr,["Sender start"]),

  Con = udp_connect(Config),
  CurrNr = undefined,

  sync:waitToNextFrame(Clock),

  loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr).


loop(Con, CurrNr, Station, Source, Broker, Clock,TeamStr) -> 
  Data = getNewSource(Source),
  
  SentNextNr = case CurrNr of
    undefined ->
      log(sender, TeamStr,["[0] CurrNr undef"]),
      undefined;
    _ ->
      M = clock:getMillis(Clock),
      TimeToWait = sync:millisToSlot(CurrNr,M),
      %log(sender, TeamStr,["  millisToSlot(",sync:slotNoByMillis(M)," -> ",CurrNr,") => ",TimeToWait]),
      case TimeToWait >= 0 of
        true -> 
          %Overhead = sync:safeSleepClock(Clock,TimeToWait),
          %log(sender, TeamStr,["Sleep overhead(ms): ",Overhead]),          
          sync:safeSleep(TimeToWait),
          ReserveNr = getNextFrameSlotNr(Broker),
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data, TeamStr);

        false -> 
          log(sender, TeamStr, ["[1] TimeToWait negative"]),
          undefined
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
    NextNr2 ->
      NextNr2
  end,
  
  % log(sender, TeamStr, ["[2] asked(",Asked,"): Send in ", NextNr2, " in next Frame"]),

  sync:waitToNextFrame(Clock),
  
  loop(Con, NextNr2, Station, Source, Broker, Clock,TeamStr).

getNextFrameSlotNr(Broker) -> 
  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, ReserveNr} ->  ReserveNr
  end.

sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data, TeamStr) ->
  M = clock:getMillis(Clock),
  SlotNr = sync:slotNoByMillis(M),
  Frame = sync:frameNoByMillis(M),
  CorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr),
  CanSendMessage = CorrectSlot and IsFree,
  log(sender,TeamStr,
    ["[3] Frame: ",Frame,
      " SlotCorrect: ", CorrectSlot,
      " IsFree: ", IsFree,
      " ",CNr," -> ",ReserveNr]),
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


udp_connect(Con) ->
  {IFAddr, Port, MCA} = Con,
  Socket = werkzeug:openSe(IFAddr, Port),
  {Socket, IFAddr, Port, MCA}.


% Debugging
checkPre({beginningOfFrame,Clock,TeamStr}) ->
  {_F,S,ST} = sync:fstByMillis(clock:getMillis(Clock)),
  case S of
    1 -> ok;
    _ -> log(sender, TeamStr, ["Not at Frame beginning! (",sync:framePercent(clock:getMillis(Clock)),") ", S, ", ",ST])
  end.
