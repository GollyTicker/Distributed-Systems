
-module(server).
-import(werkzeug,[logging/2,get_config_value/2]).
-export([start/0]).


%/* Abfragen einer Nachricht */
% Server ! {self(), getmessages}
% receive {reply,[NNr,Msg,TSclientout,TShbqin,TSdlqin,TSdlqout],Terminated} 

%/* Senden einer Nachricht */
% Server ! {dropmessage,[INNr,Msg,TSclientout]},

%/* Abfragen der eindeutigen Nachrichtennummer */
% Server ! {self(),getmsgid}
% receive {nid, Number} 


% Servername aus der Config holen, server started, registrieren.
start() ->
  {ok, ConfigList} = file:consult("server.cfg"),
  PID = spawn( fun() -> State = initServer(ConfigList), loop(State) end),
  {ok, ServerName} = get_config_value(servername, ConfigList),
  register(ServerName,PID),
  PID. 


% initialisieren des CMEM, HBQ, DLQ, Logging und Erzeugen des Initialzustands
initServer(ConfigList) -> 

  Datei = list_to_atom("log/Server@" ++ atom_to_list(node()) ++ ".log"),
  logging(Datei, "Initalizing Server\n"),

  {ok, RemTime} = get_config_value(clientlifetime, ConfigList),
  CMEM = cmem:initCMEM(RemTime,Datei),

  {ok, HBQnode} = get_config_value(hbqnode,ConfigList),
  {ok, HBQname} = get_config_value(hbqname,ConfigList),
  HBQservice = {HBQname,HBQnode},
  logging(Datei, "Initializing HBQ - Address: " ++ werkzeug:to_String(HBQname)),
  HBQservice ! {self(), {request,initHBQ}},
  receive
    {reply, ok} -> logging(Datei, "Erhielt OK von HBQ\n")
  end,
  
  logging(Datei, "initialized Server\n"),
  [CMEM, ConfigList, Datei]
  .


loop([CMEM, ConfigList, Datei]) ->
  receive
    {Client, getmessages} -> undefined;
    {dropmessage, [NNr,Msg,TSclientout]} -> undefined;
    {Redakteur, getmsdid}  -> undefined
  end
  .





