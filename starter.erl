-module(starter).

-export([start/1]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3, connectToNameService/2]).

-import(ggt,[spawnggt/5]).

-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).

% {steeringval,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer}: die steuernden Werte für die ggT-Prozesse werden im Starter Prozess gesetzt; Arbeitszeit ist die simulierte Verzögerungszeit zur Berechnung in Sekunden, TermZeit ist die Wartezeit in Sekunden, bis eine Wahl für eine Terminierung initiiert wird, Quota ist die konkrete Anzahl an benotwendigten Zustimmungen zu einer Terminierungsabstimmung und GGTProzessnummer ist die Anzahl der zu startenden ggT-Prozesse.


start([StarterNrStr, _Start]) ->
  StarterNr = list_to_integer(StarterNrStr),
  Cfg = loadCfg(),
  Datei = list_to_atom("log/ggt"++ to_String(StarterNr)++"@" ++ atom_to_list(node()) ++ ".log"),
  NSnode = Cfg#cfg.nsnode,
  NSname = Cfg#cfg.nsname,
  NameService = connectToNameService(NSnode, NSname),

  NameService ! {self(), {lookup, Cfg#cfg.koordname}},
  KID = receive
    not_found -> log(Datei,starter,["Koordinator not found: ", Cfg#cfg.koordname]);
    {pin, PID} -> log(Datei,starter,["Koordinator found: ", PID]), PID
  end,

  steeringVal(Cfg, NameService, KID, StarterNr,Datei).

startggts(_,_,_,_,0,_,_,_) -> ok;
startggts(Cfg,
          ArbeitsZeit,
          TermZeit,
          Quota,
          GGTNo,
          NameService,
          StarterNr,
          Datei) ->
  GGTname = lists:flatmap(fun(X) -> to_String(X) end,[Cfg#cfg.teamnr,Cfg#cfg.pgruppe,GGTNo,StarterNr]),
  log(Datei,starter,["Spawning ggt ", GGTNo, " with Name ", GGTname]),
  spawnggt(Cfg,NameService,GGTname,GGTNo,StarterNr),
  startggts(Cfg,ArbeitsZeit,TermZeit,Quota,GGTNo - 1,NameService,StarterNr,Datei).


steeringVal(Cfg, NameService, KID, StarterNr,Datei) ->
  KID ! {self(), getsteeringval},
  receive 
    {steeringval,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer} -> 
      log(Datei,starter,["Received steeringval:",ArbeitsZeit," ",TermZeit," ",Quota," ",GGTProzessnummer]),
      startggts(Cfg,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer,NameService,StarterNr,Datei);
    Any -> Any 
  end.


loadCfg() ->
  {ok, ConfigList} = file:consult("ggt.cfg"),
  {ok, PGruppe} = get_config_value(praktikumsgruppe, ConfigList),
  {ok, TeamNr} = get_config_value(teamnummer, ConfigList),
  {ok, NSnode} = get_config_value(nameservicenode, ConfigList),
  {ok, NSname} = get_config_value(nameservicename, ConfigList),
  {ok, KoordName} = get_config_value(koordinatorname, ConfigList),
  Cfg = #cfg{pgruppe = PGruppe, teamnr = TeamNr, nsnode = NSnode, nsname = NSname, koordname = KoordName},
  Cfg.



