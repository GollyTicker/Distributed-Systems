-module(slot_broker).
-export([init/1]).
-import(utils,[log/3]).

-define(LOG, "log/slot_broker.log").

init(Clock) -> 
  log(?LOG,slot_broker,["SlotBroker start"]),
  Slots = lists:seq(1, 25),

  sync:waitToNextFrame(Clock),
  
  {CurrFrame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),

  loop([], CurrFrame, Slots, Slots, Clock).


loop(Requests, PrevFrame, PrevCSlots, PrevNSlots, Clock) ->

  % Frameübergang
  {CurrFrame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  {CSlots,NSlots} = case PrevFrame < CurrFrame of
    true -> {PrevNSlots,lists:seq(1,25)};
    false -> {PrevCSlots,PrevNSlots}
  end,

  {_, _, SlotTime} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),

  receive
    {PID, doesPacketCollide, Packet, TS} ->
      {_, CSlot, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
      NewCSlots = lists:delete(CSlot,CSlots),
      NewRequests = [{PID, utils:parsePacket(Packet), TS}|Requests],
      loop(NewRequests, CurrFrame, NewCSlots, NSlots, Clock);

    % Sender
    {PID, getNextFrameSlotNr} ->
      PID ! {nextFrameSlotNr, getUnoccupiedSlot(NSlots)},
      loop(Requests, CurrFrame, CSlots, NSlots, Clock);

    {PID, isFree, Slot} ->
      PID ! case lists:member(Slot, CSlots) of
        true -> free;
        false -> occupied
      end,
      loop(Requests, CurrFrame, CSlots, NSlots, Clock)

  after 
    SlotTime ->
      case Requests of 
        []  -> 
          loop([], CurrFrame, CSlots, NSlots, Clock);

        [{PID, Msg, TS}] ->
          {_,_,NSlot,_} = Msg,
          NewNSlots = lists:delete(NSlot,NSlots),
          PID ! {notCollides, Msg, TS},
          loop([], CurrFrame, CSlots, NewNSlots, Clock);

        [_,_|_] -> 
          lists:map(fun({PID, Msg, _}) -> PID ! {collides, Msg} end, Requests), 
          loop([], CurrFrame, CSlots, NSlots, Clock)
      end

  end.

getUnoccupiedSlot(Slots) -> lists:nth(utils:randomInt(length(Slots)), Slots).



