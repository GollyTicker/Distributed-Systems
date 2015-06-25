-module(sender).
-export([init/7]).

-import(utils,[log/4]).
-import(datasource,[getNewData/1]).


init(Config,Station,Source,Broker,Clock,Team,DS) ->
  log(DS,sender, Team,["Sender start"]),

  Con = udp_connect(Config),
  CurrNr = undefined,

  sync:waitToNextFrame(Clock), % loop invariant

  FrameSent = 0,
  FrameNotSent = 0,
  CurrFrame = sync:frameNoByMillis(clock:getMillis(Clock)),
  frameLoop(CurrFrame,Con, CurrNr, Station, Source, Broker, Clock, Team,FrameSent,FrameNotSent,DS).


% loop invariant: Each iteration begins its execution at the beginning of a frame.

frameLoop(CurrFrame, Con, CurrNr, Station, Source, Broker, Clock, Team, FrameSent, FrameNotSent,DS) -> 
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
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data, Team,DS);

        false -> 
          log(DS,sender, Team, ["TimeToWait is negative, SentNextNr = undefined."]),
          undefined
      end
  end,
  
  sync:waitToEndOfFrame(Clock), % at the end of the frame
  PreCond = checkPre(endOfFrame,Clock,Team,CurrFrame,DS),
  case PreCond of
    ok -> 
      % If nothing was sent, we need a new SlotNr for the next frame.
      % If something was sent, check whether it didn't accidently collide. If so, then forget the reservation nr.
      NothingSent = (SentNextNr =:= undefined),
      OurSlotCollided = case CurrNr of undefined -> false; _ -> ourSlotCollided(Broker,CurrNr) end,
      {NextNr2, NewFrameSent, NewFrameNotSent} =
        case (NothingSent or OurSlotCollided) of
          true  ->  Nr = getNextFrameSlotNr(Broker),
                    log(DS,sender, Team, ["Failed Sending. Trying my luck with ", Nr, " next frame"]),
                    {Nr, FrameSent, FrameNotSent + 1};
          false ->  log(DS,sender, Team, ["Sending successful. Reserved ", SentNextNr]),
                    {SentNextNr, FrameSent + 1, FrameNotSent}
      end,
      log(DS,sender, Team, ["Sent+NotSent=Total ",FrameSent, "+", FrameNotSent, "=", FrameSent+FrameNotSent]);
    
    nok -> % somehow we missed the end of the frame. be safe and reset to initial state.
      {NextNr2,NewFrameSent,NewFrameNotSent} = {undefined, FrameSent, FrameNotSent + 1}
  end,
  sync:waitToNextFrame2(CurrFrame,Clock), % loop invariant
  
  NewFrame = sync:frameNoByMillis(clock:getMillis(Clock)),
  
  Diff = NewFrame - CurrFrame,
  case Diff > 1 of
    false -> % ok
      frameLoop(NewFrame, Con, NextNr2, Station, Source, Broker, Clock, Team, NewFrameSent, NewFrameNotSent,DS);
    true -> % waited too much. reset everything!
      log(DS,sender, Team, ["Runtime too slow. Accidently skipped a frame. ", CurrFrame," -> ",NewFrame]),
      frameLoop(NewFrame, Con, undefined, Station, Source, Broker, Clock, Team, NewFrameSent, NewFrameNotSent + 1,DS)
  end.

% CNr:       The slot nr we have to send the message in
% ReserveNr: The slot nr to reserve in the next frame, if we succeed
sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data, Team,DS) ->
  SlotNr = sync:slotNoByMillis(clock:getMillis(Clock)),

  IsCorrectSlot = CNr == SlotNr,
  IsFree = isFree(Broker, CNr),
  
  log(DS,sender,Team, ["IsCorrectSlot: ",IsCorrectSlot," IsFree: ",IsFree," ",CNr," -> ",ReserveNr]),
  
  case (IsCorrectSlot and IsFree) of
    true -> 
      {Socket, _, Port, MCA} = Con,
      Packet = createPacket(Clock,Station,Data,ReserveNr),
      gen_udp:send(Socket, MCA, Port, Packet),
      ReserveNr;
    false -> undefined
  end.

checkPre(endOfFrame,Clock,Team,ShouldBeFrame,DS) ->
  {WasFrame,SlotNr,SlotTime} = FST = sync:fstByMillis(clock:getMillis(Clock)),
  case ((SlotNr =:= 25) and (SlotTime> 20) and (ShouldBeFrame =:= WasFrame)) of
    true -> ok;
    false -> log(DS,sender,Team,["Precondition violated: ShouldBeFrame ",ShouldBeFrame,", EndOfFrame failed with fst ", FST]),
             nok
  end.

ourSlotCollided(Broker,CurrNr) ->
  Broker ! {self(), didSlotCollide, CurrNr},
  receive Bool -> Bool end.

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
