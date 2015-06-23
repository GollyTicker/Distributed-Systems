-module(sync).

-export([
  fstByMillis/1,
  frameNoByMillis/1,
  slotNoByMillis/1,
  slotTimeByMillis/1,
  millisToNextFrame/1,
  millisToSlot/2,
  safeSleep/1,
  waitToNextFrame/1,
  slot_duration/0,
  waitToEndOfFrame/1,
  safeSleepClock/2]).

-define(SLOT_HALVE, 20).
-define(SLEEP_OFFSET, 5).

slot_duration() -> 40.

% {Frame, Slot, SlotRest}
fstByMillis(M) -> {frameNoByMillis(M), slotNoByMillis(M), slotTimeByMillis(M)}.

frameNoByMillis(M) -> M div 1000.
slotNoByMillis(M) -> restInFrame(M) div 40 + 1.
slotTimeByMillis(M) -> restInFrame(M) rem 40.

restInFrame(M) -> M rem 1000.

millisToNextFrame(M) -> restInFrame(M).

millisToSlot(Slot, M) ->
  {_, CurrentSlot, RestInCurrentSlot} = fstByMillis(M),
  SlotDiff = (Slot - CurrentSlot),
  (SlotDiff * slot_duration()) - (?SLOT_HALVE - RestInCurrentSlot).

safeSleep(Millis) ->
  erlang:send_after(Millis,self(),timer),
  receive timer -> ok end.
  
%  timer:sleep(max(Millis - ?SLEEP_OFFSET, 0)).
% maybe polling or multiple-sleeps?
  
safeSleepClock(Clock,Millis) ->
  Before = clock:getMillis(Clock),
  timer:sleep(max(Millis - ?SLEEP_OFFSET, 0)),
  After = clock:getMillis(Clock),
  TrueWait = After - Before,
  Overhead = TrueWait - Millis,
  Overhead.

waitToNextFrame(Clock) ->
  MillisToNextFrame = millisToNextFrame(clock:getMillis(Clock)),
  safeSleep(MillisToNextFrame).
  
waitToEndOfFrame(Clock) ->
  MillisToEndOfFrame = millisToNextFrame(clock:getMillis(Clock)),
  safeSleep(MillisToEndOfFrame).


