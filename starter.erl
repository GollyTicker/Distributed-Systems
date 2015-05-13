-module(starter).
-export([start/1,startM/2]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3, connectToNameService/2,lookup/3]).
-import(ggt,[spawnggt/8]).

% {steeringval,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer}: die steuernden Werte für die ggT-Prozesse werden im Starter Prozess gesetzt; Arbeitszeit ist die simulierte Verzögerungszeit zur Berechnung in Sekunden, TermZeit ist die Wartezeit in Sekunden, bis eine Wahl für eine Terminierung initiiert wird, Quota ist die konkrete Anzahl an benotwendigten Zustimmungen zu einer Terminierungsabstimmung und GGTProzessnummer ist die Anzahl der zu startenden ggT-Prozesse.

-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).

startM(_,0) -> ok;
startM(StarterNr,Many) -> spawn(fun() -> start(StarterNr) end), startM(StarterNr+1,Many-1).


start(StarterNr) ->
  Cfg = loadCfg(),
  Datei = list_to_atom("log/ggt"++ to_String(StarterNr)++"@" ++ atom_to_list(node()) ++ ".log"),
  NSnode = Cfg#cfg.nsnode,
  NSname = Cfg#cfg.nsname,
  NameService = connectToNameService(NSnode, NSname),
  KID = lookup(NameService,self(),Cfg#cfg.koordname),
  log(Datei,starter,["Lookup koordinator: ", KID]),

  steeringVal(Cfg, NameService, KID, StarterNr,Datei).


startggts(_,_,_,_,0,_,_,_) -> ok;
startggts(Cfg,AZ,TZ,Q,
          GGTNo,NameService,StarterNr,Datei) ->
  
  GGTname = makeGGTname(Cfg,StarterNr,GGTNo),
  log(Datei,starter,["Spawning ggt ", GGTNo, " with Name ", GGTname]),
  spawn(fun() -> spawnggt(Cfg,NameService,GGTname,GGTNo,StarterNr,AZ,TZ,Q) end),

  startggts(Cfg,AZ,TZ,Q,GGTNo - 1,NameService,StarterNr,Datei).


steeringVal(Cfg, NameService, KID, StarterNr,Datei) ->
  KID ! {self(), getsteeringval},
  receive 
    {steeringval,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer} -> 
      log(Datei,starter,["Received steeringval:",ArbeitsZeit," ",TermZeit," ",Quota," ",GGTProzessnummer]),
      startggts(Cfg,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer,NameService,StarterNr,Datei);
    Any -> Any 
  end.


makeGGTname(Cfg,StarterNr,GGTNo) ->
  list_to_atom(
    lists:flatmap(
      fun(X) -> to_String(X) end,
      [Cfg#cfg.teamnr,Cfg#cfg.pgruppe,GGTNo,StarterNr]
    )
  ).


loadCfg() ->
  {ok, ConfigList} = file:consult("ggt.cfg"),
  {ok, PGruppe} = get_config_value(praktikumsgruppe, ConfigList),
  {ok, TeamNr} = get_config_value(teamnummer, ConfigList),
  {ok, NSnode} = get_config_value(nameservicenode, ConfigList),
  {ok, NSname} = get_config_value(nameservicename, ConfigList),
  {ok, KoordName} = get_config_value(koordinatorname, ConfigList),
  Cfg = #cfg{pgruppe = PGruppe, teamnr = TeamNr, nsnode = NSnode, nsname = NSname, koordname = KoordName},
  Cfg.



