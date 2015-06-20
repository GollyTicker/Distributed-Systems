-module(slot_broker).
-export([init/1]).

init(Clock) -> loop(Clock).
loop(Clock) -> 
  receive
    {PID, doesPacketCollide, Packet, TS} ->
      PID ! {notCollides, Packet, TS};

    {PID, getNextFrameSlotNr} ->
      PID ! {nextFrameSlotNr, 20};

    {PID, isFree, Slot} ->
      PID ! free

  end,
  loop(Clock).


