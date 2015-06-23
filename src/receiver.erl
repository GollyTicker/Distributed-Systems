-module(receiver).
-export([init/5]).

-import(utils,[log/3]).

init(Con,Team,Sink,Broker,Clock) -> 
  log(receiver, Team, ["Receiver start"]),
  udp_connect(Con, Team),

  Frame = sync:frameNoByMillis(clock:getMillis(Clock)),
  Diffs = [],

  sync:waitToNextFrame(Clock),
  
  loop(Diffs, Frame, Team, Sink, Broker, Clock).


loop(Diffs, Frame, Team, Sink, Broker, Clock) -> 

  NewDiffs = receive 
    {newmessage,Packet} ->
      TSReceive = clock:getMillis(Clock),
      Broker ! {self(), doesPacketCollide, Packet, TSReceive},
      Diffs;

    {notCollides, {SType,Data,_,TS}, TSReceive} ->
      sendToSink(Team, Sink, Data),
      updateDiff(SType, Diffs, TS, TSReceive)

    % once each frame: use the diffs to update the clock.
  after sync:millisToNextFrame(clock:getMillis(Clock)) ->
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

sendToSink(ReceiverTeam, Sink, Data) ->
  SenderTeam = utils:getTeam(Data),
  Sink ! {newData, ReceiverTeam, SenderTeam, Data}.

udp_connect(Con, Team) ->
  Self = self(),
  spawn(fun() -> udp_receiver:init(Self, Con, Team) end).
