-module(koordinator).
-export([start/0]).

-import(werkzeug,[timeMilliSecond/0,get_config_value/2,to_String/1,bestimme_mis/2,shuffle/1]).
-import(utils,[log/3,lookup/3,connectToNameService/2,killMe/2]).

-import(lists,[take/2,map/2,zipwith/3,nth/2,max/1]).
-import(sets,[to_list/1,from_list/1,add_element/2]).

-record(cfg, {worktime, termtime, ggtNo, nsnode, nsname, koordname, quota, toggle}).
-record(st, {phase=initial, wggt=undefined, smi=undefined, ggtset=sets:new(),ggtring=[],toggle=0}).
% phase is element of {initial, ready}

start() ->
  Cfg = loadCfg(),
  NSnode = Cfg#cfg.nsnode,
  NSname = Cfg#cfg.nsname,
  NameService = connectToNameService(NSnode, NSname),
  Datei = list_to_atom("log/Koordinator@" ++ atom_to_list(node()) ++ ".log"),

  KoordName = Cfg#cfg.koordname,
  log(Datei,koord,["Registering at nameservice: ",KoordName]),
  register(KoordName, self()),
  NameService ! {self(), {rebind, KoordName, node()}},
  receive
    ok -> log(Datei,koord,["Registered at nameservice: ",KoordName])
  end,

  State = initialState(Cfg,Datei),
  loop(Cfg,KoordName,NameService,State,Datei).

initialState(Cfg,Datei) -> 
  log(Datei,koord,["Now in initial State."]),
  #st{toggle=Cfg#cfg.toggle}.

loop(Cfg,KoordName,NameService,State,Datei) -> 
  NewState = receive 
    
    % Initialisierungsphase
    
    {From,getsteeringval} -> 
      From ! {steeringval,Cfg#cfg.worktime,Cfg#cfg.termtime,Cfg#cfg.quota,Cfg#cfg.ggtNo},
      State;

    {hello,GGTname} ->
      Func = fun() -> 
        NewSet = add_element(GGTname, State#st.ggtset),
        log(Datei,koord,["Adding new GGT: ",GGTname]),
        State#st{ggtset = NewSet}
      end,
      inPhase(initial,Func,State);

    step ->
      F = fun() ->
        Ring = makeRing(State#st.ggtset),
        log(Datei,koord,["Made Ring of size ",ggtCount(State),": ",Ring]),
        SetNeighbors = fun(GGTname) ->
          {Left,Right} = lookupNeighbors(Ring,GGTname),
          log(Datei,koord,["Set neighbors <",Left, ",", GGTname, ",",Right,">"]),
          {setneighbors,Left,Right}
        end,
        sendToGGTsByFunc(NameService, SetNeighbors,Ring),
        State#st{phase=ready,ggtring=Ring}
      end,
      inPhase(initial,F,State);
      
    % Arbeitsphase
      
    {calc,WggT} ->
      F = fun() ->
        log(Datei,koord,["Received new calculation wish: ",WggT]),
        [InitialY| Mis] = List = bestimme_mis(WggT,ggtCount(State) + 1),
        SmallestMi = max(List) + 1,
        NewState = State#st{wggt = WggT, smi = SmallestMi},
        log(Datei,koord,["Mis: ",Mis]),
        log(Datei,koord,["InitialY: ",InitialY," Initial SmallestMi: ",SmallestMi]),
        % Fehler ab hier:
        SetMiNeu = fun(GGTname,MiNeu) ->
          lookupAndSend(NameService,GGTname,{setpm,MiNeu})
        end,
        zipwith(SetMiNeu,State#st.ggtring,Mis),
        
        InitialGGTs = pickInitialGGTs(State#st.ggtring),
        log(Datei,koord,["InitialGGTs: ",InitialGGTs]),
        sendToGGTsList(NameService,{sendy,InitialY},InitialGGTs),
        
        NewState
      end,
      inPhase(ready,F,State);
      
    {briefmi,{GGTname,CMi,CZeit}} -> 
      log(Datei,koord,["briefmi: ",GGTname,", ",CMi,", ",CZeit]),
      State;

    {From,briefterm,{GGTname,CMi,CZeit}} -> State;

    % Manuelle Kommandos
    
    prompt -> 
      sendToGGTs(NameService,{self(),tellmi},State#st.ggtset),
      State;
    {mi, Mi} -> 
      log(Datei, koord, ["Mi: ", Mi]),
      State;

    nudge -> 
      sendToGGTs(NameService,{self(),pingGGT},State#st.ggtset),
      State;
    {pongGGT, GGTname} -> 
      log(Datei, koord, ["Process ",GGTname, " alive."]),
      State;

    toggle ->
      State#st{toggle = (1 - State#st.toggle)};
      
    kill -> 
      log(Datei, koord, ["Terminating koordinator: ", KoordName]),
      Msg = killMe(KoordName, NameService),
      sendToGGTs(NameService,kill,State#st.ggtset),
      log(Datei, koord, ["Terminated with: ", Msg]),
      Msg;

    reset ->
      log(Datei, koord, ["Reset koordinator. Killing GGTs."]),
      sendToGGTs(NameService,kill,State#st.ggtset),
      initialState(Cfg,Datei);
    
    Any -> 
      log(Datei, koord, ["Received unknown message: ", Any]), State
  end,
  case NewState of
    killed -> killed;
    State -> loop(Cfg,KoordName,NameService,NewState,Datei);  % State didn't change
    _ -> 
      log(Datei, koord, ["New state: ", NewState]),
      loop(Cfg,KoordName,NameService,NewState,Datei)
  end.

% ggtCount :: State -> Int
ggtCount(State) -> sets:size(State#st.ggtset).

% picks 20% of the GGTs, but at least 2 of them.
pickInitialGGTs(L) -> take(percent(L), shuffle(L)).
percent(L) -> 
  P = round(length(L) * 0.2),
  case P > 2 of
    true -> P;
    false -> 2
  end.


lookupNeighbors([], _) -> throw("Ring should not be empty!");
lookupNeighbors(Ring, N) -> 
  I = string:str(Ring, [N]),
  Ri = case I == length(Ring) of
    true -> 1;
    false -> I + 1
  end,
  Li = case I == 1 of
    true -> length(Ring);
    false -> I - 1
  end,
  {nth(Li, Ring), nth(Ri, Ring)}.


% makeRing :: Set GGTname -> List GGTname
makeRing(Set) -> shuffle(to_list(Set)).
  
% Zum Beispiel:
% inPhase(ready,fun() -> 1 end,State);
% Ruft die Funktion nur in einer bestimmten Phase auf.
% Übernimmt den neuen Zustand, oder bleibt gleich.
inPhase(Phase,Fun,State) ->
  case State#st.phase of
    Phase -> 
      Fun();
    _ -> State
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

% Beispiel
% sendToGGTsByFunc(NameService, fun(GGTname) -> {setneighbors,..,,...}) end,Ring).
sendToGGTsByFunc(NameService,Func,GGTring) ->
  map(fun(X) -> lookupAndSend(NameService,X,Func(X)) end,GGTring),
  ok.

sendToGGTs(NameService,Msg,GGTset) -> sendToGGTsList(NameService,Msg,to_list(GGTset)).

sendToGGTsList(NameService,Msg,GGTlist) ->
  map(fun(X) -> lookupAndSend(NameService,X,Msg) end,GGTlist),
  ok.
  
lookupAndSend(NameService,Name,Msg) ->
  PID = lookup(NameService,self(),Name),
  PID ! Msg.