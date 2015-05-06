-module(ggt).

-export([spawnggt/8]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3,lookup/3,killMe/2]).

-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).
-record(st, {left=undefined, right=undefined, mi=undefined, initiator=undefined, nvotes=undefined}).


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
  State = #st{},
  loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,State,Datei).


loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,State,Datei) -> 
  log(Datei,GGTname,["Ready ggt CFG teamnr: ",Cfg#cfg.teamnr]),   
  NewState = receive 
    {setneighbors,LeftName,RightName} -> 
      LeftID = lookup(NameService,self(),LeftName),
      RightID = lookup(NameService,self(),RightName),
      log(Datei, GGTname, ["setneighbors l: ", LeftID, " r: ", RightID]),
      State#st{left = LeftID, right = RightID};

    {setpm,MiNeu} -> 
      log(Datei, GGTname, ["setpm ", MiNeu]),
      State#st{mi = MiNeu};

    {sendy,Y} -> 
      log(Datei, GGTname, ["sendy ", Y]),
      sendY(State, Y);

    {From,{vote,Initiator}} -> 
      
      ok;

    {voteYes,Name} -> 
      
      ok;

    {From,tellmi} -> 
      log(Datei, GGTname, ["tellmi ", From]),
      From ! {mi, State#st.mi},
      State;

    {From,pingGGT} -> 
      log(Datei, GGTname, ["pingGGT ", From]),
      From ! {pongGGT, GGTname},
      State;

    kill -> 
      log(Datei, GGTname, ["terminating ggt: ", GGTname]),
      Msg = killMe(GGTname, NameService),
      log(Datei, GGTname, ["terminated with: ", Msg]),
      Msg;

    Any -> 
      log(Datei, GGTname, ["Received unknown message: ", Any]), State

  end,
  case NewState of
    killed -> killed;
    _ -> 
      log(Datei, GGTname, ["New state: ", NewState]),
      loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,AZ,TZ,Q,NewState,Datei)
  end.


% if y < Mi:
%   Mi := mod(Mi-1,y)+1
%   send #Mi to all neighbours
% fi 
% State -> Int -> State
sendY(State, Y) ->
  case Y < State#st.mi of
    true -> 
      NewMi = ((State#st.mi-1) rem Y)+1,
      NewState = State#st{mi = NewMi},
      State#st.left ! {sendy, NewMi},
      State#st.right ! {sendy, NewMi},
      NewState;
    _ -> State
  end.

