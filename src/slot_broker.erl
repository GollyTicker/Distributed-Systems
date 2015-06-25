-module(slot_broker).
-export([init/2]).
-import(utils,[log/3]).


slots() -> lists:seq(1,25).

init(Clock,Team) -> 
  log(slot_broker, Team, ["SlotBroker start"]),
  
  % the first loop iteration has to begin at the beginning of a frame.
  sync:waitToNextFrame(Clock),
  
  CurrFrame = sync:frameNoByMillis(clock:getMillis(Clock)),

  loop([], CurrFrame, slots(), slots(), [], Clock, Team).


% Prev* are the variables of the previous loop iteration
loop(Requests, PrevFrame, PrevCSlots, PrevNSlots, PrevCollSlots, Clock, Team) ->

  % Reset slot-variables on frame transition
  {CurrFrame,CurrSlot,SlotTime} = sync:fstByMillis(clock:getMillis(Clock)),
  {CSlots,NSlots,CollSlots} = case PrevFrame < CurrFrame of
    true  ->
      %log(slot_broker, Team, ["Free CSlots: ", PrevCSlots]),
      %log(slot_broker, Team, ["Free NSlots: ", PrevNSlots]),
      %log(slot_broker, Team, ["CollSlots  : ", PrevCollSlots]),
      log(slot_broker, Team, [" ===== ",CurrFrame," ===== "]),
      {slots(),slots(),[]};
    false -> {PrevCSlots,PrevNSlots,PrevCollSlots}
  end,

  receive
    % Receiver service
    % multiple-times per slot. CSlots reseted per frame.
    {PID, doesPacketCollide, Packet, TS} ->
      NewCSlots = lists:delete(CurrSlot,CSlots),
      NewRequests = [{PID, utils:parsePacket(Packet), TS}|Requests],
      loop(NewRequests, CurrFrame, NewCSlots, NSlots, CollSlots, Clock,Team);

    % Sender services
    % at any given point.
    {PID, getNextFrameSlotNr} ->
      NFSN = getUnoccupiedSlot(NSlots),
      PID ! {nextFrameSlotNr, NFSN},
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team);

    % during the middle of a slot, right before the sender aims to send.
    {PID, isFree, Slot} ->
      PID ! case lists:member(Slot, CSlots) of
        true -> free;
        false -> occupied
      end,
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team);
      
    % at the end of each frame, the sender asks, whether the sent message collided with any other message
    {PID, didSlotCollide, SlotNr} ->
      PID ! lists:member(SlotNr,CollSlots),
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team)

  % receiver service
  % at the end of each slot.
  % Detect collision or valiate message to receiver.
  after 
    sync:slotDuration() - SlotTime -> 
      case Requests of 
        []  -> 
          loop([], CurrFrame, CSlots, NSlots, CollSlots, Clock,Team);

        [{PID, Msg, TS}] ->
          {_,_,NSlot,_} = Msg,
          NewNSlots = lists:delete(NSlot,NSlots),
          PID ! {notCollides, Msg, TS},
          loop([], CurrFrame, CSlots, NewNSlots, CollSlots, Clock,Team);

        _ -> 
          collisionLog(Team, Requests),
          NewCollSlots = [CurrSlot|CollSlots],
          loop([], CurrFrame, CSlots, NSlots, NewCollSlots, Clock,Team)
      end

  end.


getUnoccupiedSlot(Slots) ->
  N = utils:randomInt(length(Slots)),
  lists:nth(N, Slots).


collisionLog(Team, Requests) ->
  {_,{_,_,Slot,_},_} = hd(Requests),
  Teams = lists:map(fun({_,{_,TeamBytes,_,_},_}) -> utils:getTeam(TeamBytes) end, Requests),
  AreWeMembers = lists:member(Team, Teams),
  log(slot_broker, Team, ["Collision in slot: ", Slot," Teams: [",string:join(Teams, ", "),"] Member? ", AreWeMembers]).


