-module(ggt).

-export([spawnggt/5]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3,lookup/3]).

-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).

% {setneighbors,LeftN,RightN}: die (lokal auf deren Node registrieten und im Namensdienst registrierten) Namen (keine PID!) des linken und rechten Nachbarn werden gesetzt.
% {setpm,MiNeu}: die von diesem Prozess zu berabeitenden Zahl für eine neue Berechnung wird gesetzt.
% {sendy,Y}: der rekursive Aufruf der ggT Berechnung.
% {From,{vote,Initiator}}: Wahlnachricht für die Terminierung der aktuellen Berechnung; Initiator ist der Initiator dieser Wahl (Name des ggT-Prozesses, keine PID!) und From (ist PID) ist sein Absender.
% {voteYes,Name}: erhaltenes Abstimmungsergebnis, wobei Name der Name des Absenders ist (keine PID!).
% {From,tellmi}: Sendet das aktuelle Mi an From (ist PID): From ! {mi,Mi}. Wird vom Koordinator z.B. genutzt, um bei einem Berechnungsstillstand die Mi-Situation im Ring anzuzeigen.
% {From,pingGGT}: Sendet ein pongGGT an From (ist PID): From ! {pongGGT,GGTname}. Wird vom Koordinator z.B. genutzt, um auf manuelle Anforderung hin die Lebendigkeit des Rings zu prüfen.
% kill: der ggT-Prozess wird beendet.

% {Eine Nachricht <y> ist eingetroffen}
% if y < Mi:
%   Mi := mod(Mi-1,y)+1
%   send #Mi to all neighbours
% fi 

loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,Datei) -> 
  log(Datei,GGTname,["Ready ggt CFG teamnr: ",Cfg#cfg.teamnr]),   
  receive 
    bla -> 
      loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,Datei);
    Any -> Any
  end.

spawnggt(Cfg,NameService,GGTname,GGTnr,StarterNr) -> 
  Datei = list_to_atom("log/"++ to_String(GGTname)++"@" ++ atom_to_list(node()) ++ ".log"),
  
  log(Datei,GGTname,["Registering at nameservice: ",GGTname]),
  register(GGTname, self()),
  NameService ! {self(), {rebind, GGTname, node()}},
  receive
    ok -> log(Datei,GGTname,["Registered at nameservice: ",GGTname])
  end,

  KID = lookup(NameService,self(),Cfg#cfg.koordname),
  log(Datei,GGTname,["Lookup koordinator: ", KID]),
  
  loop(Cfg,NameService,GGTname,GGTnr,StarterNr,KID,Datei).



