-module(koordinator).

-export([start/0]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1]).
-import(utils,[log/3, connectToNameService/2]).


-record(cfg, {worktime, termtime, ggtNo, nsnode, nsname, koordname, quota, toggle}).

% {From:,getsteeringval} Die Anfrage nach den steuernden Werten durch den Starter Prozess (From ist seine PID).
% {hello,Clientname}: Ein ggT-Prozess meldet sich beim Koordinator mit Namen Clientname an (Name ist der lokal registrierte Name, keine PID!).
% {briefmi,{Clientname,CMi,CZeit}}: Ein ggT-Prozess mit Namen Clientname (keine PID!) informiert über sein neues Mi CMi um CZeit Uhr. 
% {From,briefterm,{Clientname,CMi,CZeit}}: Ein ggT-Prozess mit Namen Clientname (keine PID!) und Absender From (ist PID) informiert über über die Terminierung der Berechnung mit Ergebnis CMi um CZeit Uhr.
% reset: Der Koordinator sendet allen ggT-Prozessen das kill-Kommando und bringt sich selbst in den initialen Zustand, indem sich Starter wieder melden können.
% step: Der Koordinator beendet die Initialphase und bildet den Ring. Er wartet nun auf den Start einer ggT-Berechnung.
% prompt: Der Koordinator erfragt bei allen ggT-Prozessen per tellmi deren aktuelles Mi ab und zeigt dies im log an.
% nudge: Der Koordinator erfragt bei allen ggT-Prozessen per pingGGT deren Lebenszustand ab und zeigt dies im log an.
% toggle: Der Koordinator verändert den Flag zur Korrektur bei falschen Terminierungsmeldungen.
% {calc,WggT}: Der Koordinator startet eine neue ggT-Berechnung mit Wunsch-ggT WggT.
% kill: Der Koordinator wird beendet und sendet allen ggT-Prozessen das kill-Kommando.

start() ->
  Cfg = loadCfg(),
  NSnode = Cfg#cfg.nsnode,
  NSname = Cfg#cfg.nsname,
  NameService = connectToNameService(NSnode, NSname),

  KoordName = Cfg#cfg.koordname,
  register(KoordName, self()),
  NameService ! {self(), {rebind, KoordName, node()}},
  receive
    ok -> io:format("Cool");
    in_use -> io:format("Not Cool")
  end,

  loop(Cfg, NameService),
  % cfg <- getsteeringval
  % spawnggt(Cfg,NameService,ggtName,ggtNr,StarterNr).
  %  0.
  NameService.

loop(Cfg, NameService) -> 
  receive 
    {From,getsteeringval} -> 
      From ! {
                steeringval, 
                Cfg#cfg.worktime, 
                Cfg#cfg.termtime, 
                Cfg#cfg.quota, 
                Cfg#cfg.ggtNo
              },
      loop(Cfg, NameService);
    Any -> Any
  end.

loadCfg() ->
  {ok, ConfigList} = file:consult("koordinator.cfg"),
  {ok, WorkTime} = get_config_value(arbeitszeit, ConfigList),
  {ok, TermTime} = get_config_value(termzeit, ConfigList),
  {ok, GGTProcessNo} = get_config_value(ggtprozessnummer, ConfigList),

  {ok, NSnode} = get_config_value(nameservicenode, ConfigList),
  {ok, NSname} = get_config_value(nameservicename, ConfigList),
  {ok, KoordName} = get_config_value(koordinatorname, ConfigList),

  {ok, Quota} = get_config_value(quote, ConfigList),
  {ok, Toggle} = get_config_value(korrigieren, ConfigList),
  #cfg{
    worktime = WorkTime, 
    termtime = TermTime, 
    ggtNo = GGTProcessNo, 
    nsnode = NSnode, 
    nsname = NSname, 
    koordname = KoordName, 
    quota = Quota, 
    toggle = Toggle
  }.


