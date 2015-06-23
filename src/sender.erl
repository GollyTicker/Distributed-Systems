-module(sender).
-export([init/6]).

-import(utils,[log/3]).
-import(datasource,[getNewSource/1]).


init(Config,Station,Source,Broker,Clock,Team) ->
  log(sender, Team,["Sender start"]),

  Con = udp_connect(Config),
  CurrNr = undefined,

  sync:waitToNextFrame(Clock),

  FrameSent = 0,
  FrameNotSent = 0,
  loop(Con, CurrNr, Station, Source, Broker, Clock,Team,FrameSent,FrameNotSent).


loop(Con, CurrNr, Station, Source, Broker, Clock,Team, FrameSent, FrameNotSent) -> 
  Data = getNewSource(Source),
  
  SentNextNr = case CurrNr of
    undefined ->
      log(sender, Team,["CurrNr is undefined."]),
      undefined;
    _ ->
      M = clock:getMillis(Clock),
      TimeToWait = sync:millisToSlot(CurrNr,M),
      case TimeToWait >= 0 of
        true ->
          sync:safeSleep(TimeToWait),
          ReserveNr = getNextFrameSlotNr(Broker),
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data, Team);

        false -> 
          log(sender, Team, ["TimeToWait is negative, SentNextNr = undefined."]),
          undefined
      end
  end,
  
  %% neue Nummer für nächstes Frame holen, falls nichts gesendet wurde.
  {NextNr2, NewFrameSent, NewFrameNotSent} = case SentNextNr of
    undefined ->
      sync:waitToEndOfFrame(Clock),
      {getNextFrameSlotNr(Broker), FrameSent, FrameNotSent + 1};
    _ -> 
      {SentNextNr, FrameSent + 1, FrameNotSent}
  end,

  log(sender, Team, ["Sent+NotSent=Total ",FrameSent, "+", FrameNotSent, "=", FrameSent+FrameNotSent]),
  sync:waitToNextFrame(Clock),
  
  loop(Con, NextNr2, Station, Source, Broker, Clock, Team, NewFrameSent, NewFrameNotSent).


getNextFrameSlotNr(Broker) -> 
  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, ReserveNr} ->  ReserveNr
  end.

sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data, Team) ->
  SlotNr = sync:slotNoByMillis(clock:getMillis(Clock)),

  CorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr),
  
  log(sender,Team, ["SlotCorrect: ",CorrectSlot," IsFree: ",IsFree," ",CNr," -> ",ReserveNr]),
  
  case (CorrectSlot and IsFree) of
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
