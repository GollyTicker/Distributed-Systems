-module(receiver).
-export([init/4]).

-import(utils,[log/3]).

-define(LOG, "log/receiver.log").

init(Con,Sink,Broker,Clock) -> 
  {Frame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  Diffs = [],
  %werkzeug:openRecA(MultiCast, Addr, Port)
  loop(Diffs, Frame, Sink, Broker, Clock).

% millisToNextFrame(M)
% fstByMillis(M)
loop(Diffs, Frame, Sink, Broker, Clock) -> 
  MillisToNextFrame = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToNextFrame(X) end),
  
  NewDiffs = receive 
    {udp, _ReceiveSocket, _IP, _InPortNo, Packet} ->
      TSReceive = clock:getMillisByFunc(Clock, fun(X) -> X end),

      log(?LOG,receiver,["Received Packet(",size(Packet),"): ", Packet]),
      Broker ! {self(), doesPacketCollide, Packet, TSReceive},
      Diffs;

    {collides, _Packet} -> 
      Diffs;

    {notCollides, Packet, TSReceive} ->    
      {SType,Data,_,TS} = Parsed = utils:parsePacket(Packet),
      log(?LOG,receiver,["Parsed Packet: ", Parsed]),
      sendToSink(Sink, Data),
      updateDiff(SType, Diffs, TS, TSReceive)


  after MillisToNextFrame ->
    Avg = averageDiffs(Diffs),
    Clock ! {updateOffset, Avg},
    []
  end,

  loop(NewDiffs, Frame, Sink, Broker, Clock).

averageDiffs([]) -> 0;
averageDiffs(Diffs) -> lists:sum(Diffs) / length(Diffs).

updateDiff(SType, Diffs, TS, TSReceive) ->
  case SType of
    "A" ->
      Diff = TS - TSReceive,
      [Diff|Diffs];
    "B" ->
      Diffs
  end.

sendToSink(Sink, Data) ->
  case ourStation(Data) of
    true -> 
      Sink ! {newData, Data};
    _ -> ok
  end.

ourStation(Data) -> lists:sublist(Data, 10) == "team 10-1". % TODO.
