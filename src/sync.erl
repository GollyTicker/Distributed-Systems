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
  test/0
  %,safeSleepClock/2
  ]).

-define(SLOT_HALVE, 20).
-define(SLEEP_OFFSET, 5).

slot_duration() -> 40.

% {Frame, Slot, SlotRest}
fstByMillis(M) -> {frameNoByMillis(M), slotNoByMillis(M), slotTimeByMillis(M)}.

frameNoByMillis(M) -> M div 1000.
slotNoByMillis(M) -> restInFrame(M) div 40 + 1.
slotTimeByMillis(M) -> restInFrame(M) rem 40.

restInFrame(M) -> M rem 1000.

millisToNextFrame(M) -> 1000 - restInFrame(M).

millisToSlot(Slot, M) ->
  {_, CurrentSlot, RestInCurrentSlot} = fstByMillis(M),
  SlotDiff = (Slot - CurrentSlot),
  (SlotDiff * slot_duration()) + ?SLOT_HALVE - RestInCurrentSlot.

safeSleep(Millis) ->
  erlang:send_after(Millis,self(),timer),
  receive timer -> ok end.
  
%  timer:sleep(max(Millis - ?SLEEP_OFFSET, 0)).
% maybe polling or multiple-sleeps?

framePercent(M) -> werkzeug:to_String(restInFrame(M)/10) ++ "%".

%safeSleepClock(Clock,Millis) ->
%  Before = clock:getMillis(Clock),
%  timer:sleep(max(Millis - ?SLEEP_OFFSET, 0)),
%  After = clock:getMillis(Clock),
%  TrueWait = After - Before,
%  Overhead = TrueWait - Millis,
%  Overhead.

waitToNextFrame(Clock) ->
  M = clock:getMillis(Clock),
  Bef = framePercent(M),
  
  utils:log(logPath(""),sync,["Millis: ",M]),
  MillisToNextFrame = millisToNextFrame(M),
  
  utils:log(logPath(""),sync,["MillisToNext: ",MillisToNextFrame]),
  safeSleep(MillisToNextFrame),
  
  Aft = framePercent(clock:getMillis(Clock)),
  {Bef,Aft}.
  
waitToEndOfFrame(Clock) ->
  M = clock:getMillis(Clock),
  Bef = framePercent(M),
  
  MillisToEndOfFrame = millisToNextFrame(clock:getMillis(Clock)) - 15,
  safeSleep(MillisToEndOfFrame),
  
  Aft = framePercent(clock:getMillis(Clock)),
  {Bef,Aft}.


logPath(TeamStr) -> "log/sync-"++TeamStr++".log".

waitToNextFrameLogged(Clock,TeamStr) ->
  {B1,A1} = waitToNextFrame(Clock),
  utils:log(logPath(TeamStr),sync,["NextFrame ",B1," -> ",A1]).

test() ->   
  TeamStr = "team 10-01",
  Clock = spawn(fun() -> clock:init(0,TeamStr) end),
  
  waitToNextFrameLogged(Clock,TeamStr),
  waitToNextFrameLogged(Clock,TeamStr),
  waitToNextFrameLogged(Clock,TeamStr),
  waitToNextFrameLogged(Clock,TeamStr),
  waitToNextFrameLogged(Clock,TeamStr),
  waitToNextFrameLogged(Clock,TeamStr).

