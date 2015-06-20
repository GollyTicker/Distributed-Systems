-module(receiver).
-export([init/5]).

-import(utils,[log/3]).

-define(LOG, "log/receiver.log").

init(Con,Team,Sink,Broker,Clock) -> 
  log(?LOG,receiver,["Receiver start"]),

  {Frame, _, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  Diffs = [],
  Self = self(),
  spawn(fun() -> udp_receiver:init(Self, Con) end),

  sync:waitToNextFrame(Clock),
  
  loop(Diffs, Frame, Team, Sink, Broker, Clock).

loop(Diffs, Frame, Team, Sink, Broker, Clock) -> 
  MillisToNextFrame = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToNextFrame(X) end),
  log(?LOG,receiver,["Time To Next Frame: ", MillisToNextFrame]),

  NewDiffs = receive 
    {newmessage,Packet} ->
      TSReceive = clock:getMillisByFunc(Clock, fun(X) -> X end),
      log(?LOG,receiver,["Received Packet(",size(Packet),")."]),
      Broker ! {self(), doesPacketCollide, Packet, TSReceive},
      Diffs;

    {collides, _Msg} -> 
      log(?LOG,receiver,["Ignored Message."]),
      Diffs;

    {notCollides, {SType,Data,_,TS}, TSReceive} ->
      log(?LOG,receiver,["Accepted Message."]),
      sendToSink(Team, Sink, Data),
      updateDiff(SType, Diffs, TS, TSReceive)

  after MillisToNextFrame ->
    Avg = averageDiffs(Diffs),
    Clock ! {updateOffset, Avg},
    []

  end,

  loop(NewDiffs, Frame, Team, Sink, Broker, Clock).

averageDiffs([]) -> 0;
averageDiffs(Diffs) -> round(lists:sum(Diffs) / length(Diffs)).

updateDiff(SType, Diffs, TS, TSReceive) ->
  case SType of
    "A" ->
      Diff = TS - TSReceive,
      [Diff|Diffs];
    "B" ->
      Diffs
  end.

sendToSink(Team, Sink, Data) ->
  case ourStation(Team, Data) of
    true -> 
      Sink ! {newData, Team, Data};
    _ -> ok
  end.

ourStation(TeamStr, Data) -> utils:getTeam(Data) == TeamStr.
