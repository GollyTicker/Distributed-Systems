-module(ggt).

-export([spawnggt/8]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3,lookup/3,killMe/2,sleepSeconds/1,seconds/1]).

-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).
-record(st,{
            left=undefined,   right=undefined,
            mi=undefined,     votemode=false,
            nvotes=undefined, lastactivity=undefined
          }).
%
initialState() -> #st{lastactivity = now()}.

% {setneighbors,LeftN,RightN}: die (lokal auf deren Node registrieten und im Namensdienst registrierten) Namen (keine PID!) des linken und rechten Nachbarn werden gesetzt.
% {setpm,MiNeu}: die von diesem Prozess zu berabeitenden Zahl für eine neue Berechnung wird gesetzt.
% {sendy,Y}: der rekursive Aufruf der ggT Berechnung.
% {From,{vote,Initiator}}: Wahlnachricht für die Terminierung der aktuellen Berechnung; Initiator ist der Initiator dieser Wahl (Name des ggT-Prozesses, keine PID!) und From (ist PID) ist sein Absender.
% {voteYes,Name}: erhaltenes Abstimmungsergebnis, wobei Name der Name des Absenders ist (keine PID!).
% {From,tellmi}: Sendet das aktuelle Mi an From (ist PID): From ! {mi,Mi}. Wird vom Koordinator z.B. genutzt, um bei einem Berechnungsstillstand die Mi-Situation im Ring anzuzeigen.
% {From,pingGGT}: Sendet ein pongGGT an From (ist PID): From ! {pongGGT,GGTname}. Wird vom Koordinator z.B. genutzt, um auf manuelle Anforderung hin die Lebendigkeit des Rings zu prüfen.
% kill: der ggT-Prozess wird beendet.

spawnggt(Cfg,NameService,GGTname,GGTnr,StarterNr,AZ,TZ,Q) -> 
  Datei = list_to_atom("log/"++ to_String(GGTname)++"@" ++ atom_to_list(node()) ++ ".log"),
  
  log(Datei,GGTname,["Registering at nameservice: ",GGTname]),
  register(GGTname, self()),
  NameService ! {self(), {rebind, GGTname, node()}},
  receive
    ok -> log(Datei,GGTname,["Registered at nameservice: ",GGTname])
  end,

  KID = lookup(NameService,self(),Cfg#cfg.koordname),
  log(Datei,GGTname,["Lookup koordinator: ", KID]),
  
  KID ! {hello, GGTname},
  State = initialState(),
  loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,State,Datei).
%

% Sends a reminder after TermZeit seconds. The remainder has a Timestamp included.
% The timestamp is also written into the state and returned.
% If no other relevant message has come in the specified time, then the timestamp will be
% equal and one can start a vote.
% All only happens, when the state of the ggts is already sufficiently
% initialized. That means, that neighbors have been set
% and Mi is not undefined
% War der ggt im votemode, wird dies auch deaktiviert.
startTerminationReminder(TermZeit,State,Quota,GGTname,Datei) -> 
  case initialized(State) of
    true ->
      LastActivityTS = now(),
      timer:send_after(seconds(TermZeit),{tryVoting,LastActivityTS}),
      St = State#st{lastactivity = LastActivityTS},
      terminateVoting(St,Quota,GGTname,Datei);
    false -> State
  end.
%
initialized(S) ->
  IsDefined = fun(X) -> X =/= undefined end,
  lists:all(IsDefined,[S#st.left,S#st.right,S#st.mi]).
%

% Gibt an, ob seit der letzten Aktivität (2tes Argument)
% mindestens TermZeit/2-viele Sekunden vergangen sind.
voteYesTimePassed(TermZeitSec,{MegaSec,Sec,MicroSec}) -> 
  LimitSec = TermZeitSec div 2,
  CompareTS = {MegaSec,Sec+LimitSec,MicroSec},
  Now = now(),
  case werkzeug:compareNow(CompareTS,Now) of
    before -> true;
    _ -> false
  end.

terminateVoting(St,Quota,GGTname,Datei) ->
  case St#st.votemode of
    true -> log(Datei,GGTname,["  ## Voting ends with ",St#st.nvotes,"/",Quota," ##  "]);
    false -> ok
  end,
  St#st{votemode = false, nvotes = 0}.
%

loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,StateBefore,Datei) -> 
   receive Msg -> Msg end,  % Erlang bindet auch so die Mesasge an Msg.
   State = case Msg of
    {setpm,_} -> startTerminationReminder(TZ,StateBefore,Q,GGTname,Datei);
    {sendy,_} -> startTerminationReminder(TZ,StateBefore,Q,GGTname,Datei);
    _ -> StateBefore
  end,
  NewState = case Msg of
    % Initialisierungsphase:
    
    {setneighbors,LeftName,RightName} -> 
      LeftID = lookup(NameService,self(),LeftName),
      RightID = lookup(NameService,self(),RightName),
      log(Datei, GGTname, ["setneighbors l: ", LeftName, " r: ", RightName]),
      State#st{left = LeftID, right = RightID};

    {setpm,MiNeu} -> 
      log(Datei, GGTname, ["setpm: ", MiNeu]),
      State#st{mi = MiNeu};

    % Arbeitsphase: 
    {sendy,Y} -> 
      log(Datei, GGTname, ["sendy: ", Y]),
      sendY(State, Y, KID,AZ, GGTname, Datei);

    {From,{vote,_Initiator}} -> 
      % Aufgabenstellung - Punkt 22
      case voteYesTimePassed(TZ,State#st.lastactivity) of
        true  -> From ! {voteYes, GGTname};
        false -> ignoreWahlkampf
      end,
      State;

    {voteYes,Name} -> 
      case State#st.votemode of
        true  -> 
          Votes = State#st.nvotes + 1,
          log(Datei,GGTname,[Votes,"/",Q," - ",Name," agrees."]),
          NewSt = State#st{nvotes = Votes},
          NewSt2 = case Votes >= Q of
            true  ->
              St = terminateVoting(NewSt,Q,GGTname,Datei),
              log(Datei,GGTname,[" ## Success with Mi = ",State#st.mi,"## "]),
              KID ! {self(),briefterm,{GGTname,State#st.mi,now()}},
              St;
            false -> NewSt
          end,
          NewSt2;
        false -> State
      end;
      
    {tryVoting,EarlierActivityTS} ->
      case State#st.lastactivity of
        EarlierActivityTS ->
          % no new activities since then. start voting!
          startVoting(NameService,GGTname,State,Datei);
        _ -> State% sth. has happend. don't start a voting.
      end;
    
    % Terminierungsphase:
    
    kill -> 
      log(Datei, GGTname, ["terminating ggt: ", GGTname]),
      Msg = killMe(GGTname, NameService),
      log(Datei, GGTname, ["terminated with: ", Msg]),
      Msg;
    
    % Meta-kommandos vom Koordinator:
    
    {From,tellmi} -> 
      log(Datei, GGTname, ["tellmi ", From]),
      From ! {mi, State#st.mi},
      State;

    {From,pingGGT} -> 
      log(Datei, GGTname, ["pingGGT ", From]),
      From ! {pongGGT, GGTname},
      State;

    Any -> 
      log(Datei, GGTname, ["   ### Received unknown message: ###", Any]), State
  end,
  case NewState of
    killed -> killed;
    State -> loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,NewState,Datei);  % State didn't change
    _ -> 
      log(Datei, GGTname, ["New state: ", NewState]),
      loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,NewState,Datei)
  end.
%
startVoting(NameService,GGTname,State,Datei) ->
  log(Datei,GGTname,["  ## Initiate voting with Mi = ",State#st.mi,"##  "]),
  NameService ! {self(),{multicast,vote,GGTname}},
  State#st{votemode = true, nvotes = 0}.
%

% if y < Mi:
%   Mi := mod(Mi-1,y)+1
%   send #Mi to all neighbours
% fi 
% State -> Int -> State
sendY(State, Y, Koordinator, ArbeitsZeit,GGTname, Datei) ->
  case Y < State#st.mi of
    true -> 
      NewMi = ((State#st.mi-1) rem Y)+1,
      sleepSeconds(ArbeitsZeit),
      NewState = State#st{mi = NewMi},
      log(Datei, GGTname,["Update Mi: ", NewMi]),
      Koordinator ! {briefmi,{GGTname,NewMi,now()}},
      State#st.left ! {sendy, NewMi},
      State#st.right ! {sendy, NewMi},
      NewState;
    _ -> State
  end.
%

