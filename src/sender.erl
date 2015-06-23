-module(sender).
-export([init/6]).

-import(utils,[log/3]).
-import(datasource,[getNewSource/1]).

logPath(TeamStr) -> "log/sender-" ++ TeamStr ++ ".log".

init(InitalCon,Station,Source,Broker,Clock,TeamStr) ->
  log(logPath(TeamStr),sender,["Sender start"]),

  {IFAddr, Port, MCA} = InitalCon,
  Socket = werkzeug:openSe(IFAddr, Port),
  Con = {Socket, IFAddr, Port, MCA},

  CurrNr = undefined,
  NextNr = undefined,

  sync:waitToNextFrame(Clock),

  loop(Con, CurrNr, NextNr, Station, Source, Broker, Clock,TeamStr).

loop(Con, CurrNr, NextNr, Station, Source, Broker, Clock,TeamStr) -> 
  Data = getNewSource(Source),
  

  SentNextNr = case CurrNr of
    undefined -> undefined;
    _ ->
      TimeToWait = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToSlot(CurrNr, X) end),
      case TimeToWait >= 0 of
        true -> 
          sync:safeSleep(TimeToWait),
          Broker ! {self(), getNextFrameSlotNr},
          receive
            {nextFrameSlotNr, ReserveNr} -> 
              ReserveNr
          end,
          sendMessage(Con, Clock, Broker, CurrNr, ReserveNr, Station, Data,TeamStr);
        false -> undefined
      end
  end,
  
  
  %% neue Nummer für nächstes Frame holen, falls nichts gesendet wurde.
  case SentNextNr of
    undefined -> 
      %% TODO:
      % wait to a time before the end of Frame.
      Broker ! {self(), getNextFrameSlotNr},
      receive
        {nextFrameSlotNr, NextNr2} -> 
          NextNr2
      end,
    NextNr2 -> NextNr2
  end,

  sync:waitToNextFrame(Clock),
  
  loop(Con, NextNr2, Station, Source, Broker, Clock,TeamStr).

sendMessage(Con, Clock, Broker, CNr, ReserveNr, Station, Data,TeamStr) ->
  {_, SlotNr, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  CanSendMessage =
    true
    or (CNr == SlotNr)
    and isFree(Broker, CNr),
  log(logPath(TeamStr),sender,["Send Message? ", CanSendMessage]),
  case CanSendMessage of
    true -> 
      {Socket, _, Port, MCA} = Con,
      Packet = createPacket(Clock,Station,Data,ReserveNr),
      gen_udp:send(Socket, MCA, Port, Packet),
      ReserveNr
    false -> undefined % Zeit verpasst oder occupied
  end.

isFree(Broker, CNr) ->
  Broker ! {self(), isFree, CNr},
  receive
    free -> true;
    occupied -> false     
  end.

createPacket(Clock,Station,Data,Slot) ->
  TS = clock:getMillisByFunc(Clock, fun(X) -> X end),
  utils:createPacket(Station,Data,Slot,TS).


