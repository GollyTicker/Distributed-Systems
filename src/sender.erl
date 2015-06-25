-module(sender).
-export([init/6]).

-import(utils,[log/3]).
-import(datasource,[getNewData/1]).


init(Config,Station,Source,Broker,Clock,Team) ->
  log(sender, Team,["Sender start"]),

  Con = udp_connect(Config),
  CurrNr = undefined,

  sync:waitToNextFrame(Clock), % loop invariant

  FrameSent = 0,
  FrameNotSent = 0,
  frameLoop(Con, CurrNr, Station, Source, Broker, Clock, Team,FrameSent,FrameNotSent).


% loop invariant: Each iteration begins its execution at the beginning of a frame.

frameLoop(Con, CurrNr, Station, Source, Broker, Clock, Team, FrameSent, FrameNotSent) -> 
  Data = getNewData(Source),
  
  SentNextNr = case CurrNr of
    undefined -> undefined; % do nothing in very first iteration
    _ ->
      % scroll to the specified slot and send the message.
      TimeToWait = sync:millisToSlot(CurrNr,clock:getMillis(Clock)),
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
  
  sync:waitToEndOfFrame(Clock), % at the end of the frame
  % If nothing was sent, we need a new SlotNr for the next frame.
  % If something was sent, check whether it didn't accidently collide. If so, then forget the reservation nr.
  NothingSent = (SentNextNr =:= undefined),
  OurSlotCollided = not isFree(Broker,CurrNr),
  
  {NextNr2, NewFrameSent, NewFrameNotSent} =
    case (NothingSent or OurSlotCollided) of
      true  ->  {getNextFrameSlotNr(Broker), FrameSent, FrameNotSent + 1};
      false ->  {SentNextNr, FrameSent + 1, FrameNotSent}
  end,
  
  case ((not NothingSent) and OurSlotCollided) of
    true -> log(sender, Team, ["Our Sent Message Collided: ", CurrNr]);
    false -> ok
  end,

  log(sender, Team, ["Sent+NotSent=Total ",FrameSent, "+", FrameNotSent, "=", FrameSent+FrameNotSent]),
  
  sync:waitToNextFrame(Clock), % loop invariant
  
  frameLoop(Con, NextNr2, Station, Source, Broker, Clock, Team, NewFrameSent, NewFrameNotSent).

% CNr:       The slot nr we have to send the message in
% ReserveNr: The slot nr to reserve in the next frame, if we succeed
sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data, Team) ->
  SlotNr = sync:slotNoByMillis(clock:getMillis(Clock)),

  IsCorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr),
  
  log(sender,Team, ["IsCorrectSlot: ",IsCorrectSlot," IsFree: ",IsFree," ",CNr," -> ",ReserveNr]),
  
  case (IsCorrectSlot and IsFree) of
    true -> 
      {Socket, _, Port, MCA} = Con,
      Packet = createPacket(Clock,Station,Data,ReserveNr),
      gen_udp:send(Socket, MCA, Port, Packet),
      ReserveNr;
    false -> undefined
  end.


isFree(Broker, CNr) ->
  Broker ! {self(), isFree, CNr},
  receive
    free -> true;
    occupied -> false     
  end.

getNextFrameSlotNr(Broker) -> 
  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, ReserveNr} ->  ReserveNr
  end.

createPacket(Clock,Station,Data,Slot) ->
  TS = clock:getMillis(Clock),
  utils:createPacket(Station,Data,Slot,TS).

udp_connect(Con) ->
  {IFAddr, Port, MCA} = Con,
  Socket = werkzeug:openSe(IFAddr, Port),
  {Socket, IFAddr, Port, MCA}.
