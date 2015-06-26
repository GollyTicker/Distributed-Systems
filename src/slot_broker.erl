-module(slot_broker).
-export([init/3]).
-import(utils,[log/4]).
-import(werkzeug,[to_String/1]).


slots() -> lists:seq(1,25).

init(Clock,Team,DS) -> 
  log(DS,slot_broker, Team, ["SlotBroker start"]),
  
  % the first loop iteration has to begin at the beginning of a frame.
  sync:waitToNextFrame(Clock),
  
  CurrFrame = sync:frameNoByMillis(clock:getMillis(Clock)),

  loop([], CurrFrame, slots(), slots(), [], Clock, Team,DS).


% Prev* are the variables of the previous loop iteration
loop(Requests, PrevFrame, PrevCSlots, PrevNSlots, PrevCollSlots, Clock, Team,DS) ->

  % Reset slot-variables on frame transition
  {CurrFrame,CurrSlot,SlotTime} = sync:fstByMillis(clock:getMillis(Clock)),
  {CSlots,NSlots,CollSlots} = case PrevFrame < CurrFrame of
    true  ->
      log(DS,slot_broker, Team, [" ===== ",CurrFrame," ===== "]),
      {slots(),slots(),[]};
    false -> {PrevCSlots,PrevNSlots,PrevCollSlots}
  end,

  TimeToSlotEnd = sync:slotDuration() - SlotTime,

  receive
    % Receiver service
    % multiple-times per slot. CSlots reseted per frame.
    {PID, doesPacketCollide, Packet, TS} ->
      NewCSlots = lists:delete(CurrSlot,CSlots),
      NewRequests = [{PID, utils:parsePacket(Packet), TS}|Requests],
      loop(NewRequests, CurrFrame, NewCSlots, NSlots, CollSlots, Clock,Team,DS);

    % Sender services
    % at any given point.
    {PID, getNextFrameSlotNr} ->
      NFSN = getUnoccupiedSlot(NSlots),
      PID ! {nextFrameSlotNr, NFSN},
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team,DS);

    % during the middle of a slot, right before the sender aims to send.
    {PID, isFree, Slot} ->
      PID ! case lists:member(Slot, CSlots) of
        true -> free;
        false -> occupied
      end,
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team,DS);
      
    % at the end of each frame, the sender asks, whether the sent message collided with any other message
    {PID, didSlotCollide, SlotNr} ->
      PID ! lists:member(SlotNr,CollSlots),
      loop(Requests, CurrFrame, CSlots, NSlots, CollSlots, Clock,Team,DS)

  % receiver service
  % at the end of each slot.
  % Detect collision or valiate message to receiver.
  after 
    TimeToSlotEnd -> 
      case Requests of 
        []  -> 
          loop([], CurrFrame, CSlots, NSlots, CollSlots, Clock,Team,DS);

        [{PID, Msg, TS}] ->
          {_,_,NSlot,_} = Msg,
          NewNSlots = lists:delete(NSlot,NSlots),
          PID ! {notCollides, Msg, TS},
          loop([], CurrFrame, CSlots, NewNSlots, CollSlots, Clock,Team,DS);

        _ -> 
          collisionLog(Team, CurrSlot, Requests,DS),
          NewCollSlots = [CurrSlot|CollSlots],
          loop([], CurrFrame, CSlots, NSlots, NewCollSlots, Clock,Team,DS)
      end

  end.


getUnoccupiedSlot(Slots) ->
  N = utils:randomInt(length(Slots)),
  lists:nth(N, Slots).


collisionLog(Team, CurrSlot, Requests,DS) ->
  TeamAndTSs = lists:map(fun({_,{_,TeamBytes,_,Ts},_}) -> {utils:getTeam(TeamBytes),Ts} end, Requests),
  Teams = lists:map(fun({T,_}) -> T end,TeamAndTSs),
  AreWeMembers = lists:member(Team, Teams),
  Str = lists:map(fun(T) -> to_String(T) end, TeamAndTSs),
  log(DS,slot_broker, Team, ["Collision in slot: ", CurrSlot," Teams: [",string:join(Str, ", "),"] Member? ", AreWeMembers]).


