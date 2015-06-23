-module(sync).

-export([
  fstByMillis/1,
  frameNoByMillis/1,
  slotNoByMillis/1,
  slotTimeByMillis/1,
  slotDuration/0,
  millisToNextFrame/1,
  millisToSlot/2,
  safeSleep/1,
  waitToNextFrame/1,
  waitToEndOfFrame/1
]).

-define(SLOT_DURATION, 40).
-define(SLOT_HALVE, 20).
-define(SLEEP_OFFSET, 3). % TODO: Do we need this?
-define(FRAME_LENGTH, 1000).
-define(BEFORE_FRAME_END_OFFSET, 10).

slotDuration() -> ?SLOT_DURATION.

fstByMillis(M) -> {frameNoByMillis(M), slotNoByMillis(M), slotTimeByMillis(M)}.

frameNoByMillis(M) -> M div ?FRAME_LENGTH.
slotNoByMillis(M) -> restInFrame(M) div ?SLOT_DURATION + 1.
slotTimeByMillis(M) -> restInFrame(M) rem ?SLOT_DURATION.

restInFrame(M) -> M rem ?FRAME_LENGTH.

millisToNextFrame(M) -> ?FRAME_LENGTH - restInFrame(M).

millisToSlot(Slot, M) ->
  {_, CurrentSlot, RestInCurrentSlot} = fstByMillis(M),
  SlotDiff = (Slot - CurrentSlot),
  (SlotDiff * ?SLOT_DURATION) + ?SLOT_HALVE - RestInCurrentSlot.

safeSleep(Millis) ->
  erlang:send_after(max(Millis - ?SLEEP_OFFSET, 0),self(),timer),
  receive timer -> ok end.

waitToNextFrame(Clock) ->
  M = clock:getMillis(Clock),
  FrameBefore = frameNoByMillis(M),
  
  MillisToNextFrame = millisToNextFrame(M),
  
  safeSleep(MillisToNextFrame),
  
  FrameAfter = frameNoByMillis(clock:getMillis(Clock)),
  
  % check, that we are now in the next Frame
  case (FrameBefore == FrameAfter) of
    true -> waitToNextFrame(Clock); % wait more.
    false -> ok % ok
  end.
  
waitToEndOfFrame(Clock) ->
  MillisToEndOfFrame = millisToNextFrame(clock:getMillis(Clock)) - ?BEFORE_FRAME_END_OFFSET,
  safeSleep(MillisToEndOfFrame).

