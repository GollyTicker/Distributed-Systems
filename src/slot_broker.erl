-module(slot_broker).
-export([init/2]).
-import(utils,[log/3]).


slots() -> lists:seq(1,25).

init(Clock,Team) -> 
  log(slot_broker, Team, ["SlotBroker start"]),
  
  sync:waitToNextFrame(Clock),
  
  CurrFrame = sync:frameNoByMillis(clock:getMillis(Clock)),

  loop([], CurrFrame, slots(), slots(), Clock, Team).


loop(Requests, PrevFrame, PrevCSlots, PrevNSlots, Clock, Team) ->

  % Frameübergang
  CurrFrame = sync:frameNoByMillis(clock:getMillis(Clock)),
  {CSlots,NSlots} = case PrevFrame < CurrFrame of
    true ->
      {slots(),slots()};
    false -> {PrevCSlots,PrevNSlots}
  end,

  SlotTime = sync:slotTimeByMillis(clock:getMillis(Clock)),

  receive
    {PID, doesPacketCollide, Packet, TS} ->
      CSlot = sync:slotNoByMillis(clock:getMillis(Clock)),
      NewCSlots = lists:delete(CSlot,CSlots),
      NewRequests = [{PID, utils:parsePacket(Packet), TS}|Requests],
      loop(NewRequests, CurrFrame, NewCSlots, NSlots, Clock,Team);

    % Sender
    {PID, getNextFrameSlotNr} ->
      NFSN = getUnoccupiedSlot(NSlots),
      PID ! {nextFrameSlotNr, NFSN},
      loop(Requests, CurrFrame, CSlots, NSlots, Clock,Team);

    {PID, isFree, Slot} ->
      PID ! case lists:member(Slot, CSlots) of
        true -> free;
        false -> occupied
      end,
      loop(Requests, CurrFrame, CSlots, NSlots, Clock,Team)

  after 
    sync:slotDuration() - SlotTime ->
      case Requests of 
        []  -> 
          loop([], CurrFrame, CSlots, NSlots, Clock,Team);

        [{PID, Msg, TS}] ->
          {_,_,NSlot,_} = Msg,
          NewNSlots = lists:delete(NSlot,NSlots),
          PID ! {notCollides, Msg, TS},
          loop([], CurrFrame, CSlots, NewNSlots, Clock,Team);

        _ -> 
          collisionLog(Team, Requests),
          loop([], CurrFrame, CSlots, NSlots, Clock,Team)
      end

  end.

getUnoccupiedSlot(Slots) ->
  N = utils:randomInt(length(Slots)),
  lists:nth(N, Slots).

collisionLog(Team, Requests) ->
  {_,{_,_,Slot,_},_} = hd(Requests),
  Teams = lists:map(fun({_,{_,TeamBytes,_,_},_}) -> util:getTeam(TeamBytes) end, Requests),
  AreWeMembers = lists:member(Team, Teams),
  log(slot_broker, Team, ["Collision in slot: ", Slot," Teams: ["] ++ str:join(Teams, ", ") ++ ["] Member? ", AreWeMembers]).


