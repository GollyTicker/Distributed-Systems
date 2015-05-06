-module(starter).

-export([start/0]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3]).

-import(ggt,[spawnggt/5]).

% {steeringval,ArbeitsZeit,TermZeit,Quota,GGTProzessnummer}: die steuernden Werte für die ggT-Prozesse werden im Starter Prozess gesetzt; Arbeitszeit ist die simulierte Verzögerungszeit zur Berechnung in Sekunden, TermZeit ist die Wartezeit in Sekunden, bis eine Wahl für eine Terminierung initiiert wird, Quota ist die konkrete Anzahl an benotwendigten Zustimmungen zu einer Terminierungsabstimmung und GGTProzessnummer ist die Anzahl der zu startenden ggT-Prozesse.


% ruft spawnggt(Cfg,ggtName,ggtNr,StarterNr) auf.

start() ->
  Cfg = loadCfg(),
  NameService = connectToNameService(Cfg),
  % cfg <- getsteeringval
  % spawnggt(Cfg,NameService,ggtName,ggtNr,StarterNr).
  %  0.
  NameService.


-record(cfg, {pgruppe, teamnr, nsnode, nsname, koordname}).


loadCfg() ->
  {ok, ConfigList} = file:consult("ggt.cfg"),
  {ok, PGruppe} = get_config_value(praktikumsgruppe, ConfigList),
  {ok, TeamNr} = get_config_value(teamnummer, ConfigList),
  {ok, NSnode} = get_config_value(nameservicenode, ConfigList),
  {ok, NSname} = get_config_value(nameservicename, ConfigList),
  {ok, KoordName} = get_config_value(koordinatorname, ConfigList),
  Cfg = #cfg{pgruppe = PGruppe, teamnr = TeamNr, nsnode = NSnode, nsname = NSname, koordname = KoordName},
  Cfg.

connectToNameService(Cfg) ->
  NSnode = Cfg#cfg.nsnode,
  NSname = Cfg#cfg.nsname,
  net_adm:ping(NSnode),
  timer:sleep(500),
  NameService = global:whereis_name(NSname),
  NameService.
%  
%  PID = spawn( fun() -> State = initServer(ConfigList,Datei), loop(State) end),
%  {ok, ServerName} = get_config_value(servername, ConfigList),
%  register(ServerName,PID),
%  Datei = list_to_atom("log/Server@" ++ atom_to_list(node()) ++ ".log"),
%  %log(Datei,server,["Registered as ",ServerName," on ",node()," with addr ",PID]),
%  
%  PID.





