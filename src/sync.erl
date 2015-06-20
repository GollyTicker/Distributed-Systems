-module(sync).

-export([fstByMillis/1,millisToNextFrame/1,millisToSlot/2]).

-define(SLOT_DURATION, 40).
-define(SLOT_HALVE, 20).

% {Frame, Slot, SlotRest}
fstByMillis(M) ->
  RestInFrame = restInFrame(M),
  {M div 1000, RestInFrame div 40 + 1, RestInFrame rem 40}.

restInFrame(M) -> M rem 1000.

millisToNextFrame(M) -> restInFrame(M).


millisToSlot(Slot, M) ->
  {_, CurrentSlot, RestInCurrentSlot} = fstByMillis(M),
  SlotDiff = (Slot - CurrentSlot),
  (SlotDiff * ?SLOT_DURATION) - (?SLOT_HALVE - RestInCurrentSlot).