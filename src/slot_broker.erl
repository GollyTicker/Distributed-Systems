-module(slot_broker).
-export([init/2]).
-import(utils,[log/3]).

logPath(TeamStr) -> "log/slot_broker-" ++ TeamStr ++ ".log".

init(Clock,TeamStr) -> 
  log(logPath(TeamStr),slot_broker,["SlotBroker start"]),
  Slots = lists:seq(1, 25),

  sync:waitToNextFrame(Clock),
  
  {CurrFrame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),

  loop([], CurrFrame, Slots, Slots, Clock,TeamStr).


loop(Requests, PrevFrame, PrevCSlots, PrevNSlots, Clock,TeamStr) ->

  % Frameübergang
  {CurrFrame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  {CSlots,NSlots} = case PrevFrame < CurrFrame of
    true ->
      log(logPath(TeamStr),slot_broker,["(",TeamStr,") Next Frame"]),
      log(logPath(TeamStr),slot_broker,["(",TeamStr,") CSlots: ", PrevCSlots]),
      log(logPath(TeamStr),slot_broker,["(",TeamStr,") NSlots: ", PrevNSlots]),
      {PrevNSlots,lists:seq(1,25)};
    false -> {PrevCSlots,PrevNSlots}
  end,

  {_, _, SlotTime} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),

  receive
    {PID, doesPacketCollide, Packet, TS} ->
      {_, CSlot, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
      NewCSlots = lists:delete(CSlot,CSlots),
      NewRequests = [{PID, utils:parsePacket(Packet), TS}|Requests],
      loop(NewRequests, CurrFrame, NewCSlots, NSlots, Clock,TeamStr);

    % Sender
    {PID, getNextFrameSlotNr} ->
      PID ! {nextFrameSlotNr, getUnoccupiedSlot(NSlots)},
      loop(Requests, CurrFrame, CSlots, NSlots, Clock,TeamStr);

    {PID, isFree, Slot} ->
      PID ! case lists:member(Slot, CSlots) of
        true -> free;
        false -> occupied
      end,
      loop(Requests, CurrFrame, CSlots, NSlots, Clock,TeamStr)

  after 
    sync:slot_duration() - SlotTime ->
      case Requests of 
        []  -> 
          loop([], CurrFrame, CSlots, NSlots, Clock,TeamStr);

        [{PID, Msg, TS}] ->
          {_,_,NSlot,_} = Msg,
          NewNSlots = lists:delete(NSlot,NSlots),
          PID ! {notCollides, Msg, TS},
          loop([], CurrFrame, CSlots, NewNSlots, Clock,TeamStr);

        [_,_|_] -> 
          lists:map(fun({PID, Msg, _}) -> PID ! {collides, Msg} end, Requests), 
          loop([], CurrFrame, CSlots, NSlots, Clock,TeamStr)
      end

  end.

getUnoccupiedSlot(Slots) -> lists:nth(utils:randomInt(length(Slots)), Slots).



