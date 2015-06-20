-module(sender).
-export([init/5]).

-import(utils,[log/3]).
-import(datasource,[getNewSource/1]).

-define(LOG, "log/sender.log").

init(InitalCon,Station,Source,Broker,Clock) ->
  log(?LOG,sender,["Sender start"]),

  {IFAddr, Port, MCA} = InitalCon,
  Socket = werkzeug:openSe(IFAddr, Port),
  Con = {Socket, IFAddr, Port, MCA},

  CNr = undefined,

  sync:waitToNextFrame(Clock),

  loop(Con, CNr, Station, Source, Broker, Clock).

loop(Con, CNr, Station, Source, Broker, Clock) -> 
  Data = getNewSource(Source),

  Broker ! {self(), getNextFrameSlotNr},
  receive
    {nextFrameSlotNr, NewNummer} -> 
      NewNummer
  end,

  NewNummer2 = case CNr of
    undefined ->
      NewNummer;
    _ ->
      TimeToWait = clock:getMillisByFunc(Clock, fun(X) -> sync:millisToSlot(CNr, X) end),
      case TimeToWait >= 0 of
        true -> 
          sync:safeSleep(TimeToWait),
          sendMessage(Con, Clock, Broker, CNr, Station, Data);
        false -> NewNummer
      end
  end, 

  sync:waitToNextFrame(Clock),
  
  loop(Con, NewNummer2, Station, Source, Broker, Clock).

sendMessage(Con, Clock, Broker, CNr, Station, Data) ->
  {_, SlotNr, _} = clock:getMillisByFunc(Clock, fun(X) -> sync:fstByMillis(X) end),
  CanSendMessage = (CNr == SlotNr) and isFree(Broker, CNr),
  log(?LOG,sender,["Send Message? ", CanSendMessage]),
  NewNr = case CanSendMessage of
    true -> 
      {Socket, _, Port, MCA} = Con,
      Packet = createPacket(Clock,Station,Data,CNr),
      gen_udp:send(Socket, MCA, Port, Packet),
      log(?LOG,sender,["Sent packet: ", CNr]),
      CNr;
    false -> 
      % Zeit verpasst oder occupied
      undefined
  end,
  NewNr.

isFree(Broker, CNr) ->
  Broker ! {self(), isFree, CNr},
  receive
    free -> true;
    occupied -> false     
  end.

createPacket(Clock,Station,Data,Slot) ->
  TS = clock:getMillisByFunc(Clock, fun(X) -> X end),
  utils:createPacket(Station,Data,Slot,TS).


