--------------------
Kompilieren der Dateien:
--------------------
Zu dem Paket gehören die erl-Dateien
client.erl, editor.erl, reader.erl, cmem.erl, dlq.erl, hbq.erl, server.erl, werkzeug.erl, utils.erl

sowie die Dateien
Readme.txt, client.cfg, server.cfg und die logs in log/


erl -name wk -setcookie hallo
1> make:all().

oder

bash> erl -make

--------------------
Starten des Servers:
--------------------
In zwei shells:
bash> erl -name hbqNode -setcookie hallo
bash> erl -name server -setcookie hallo -run server start

% in der server.cfg:
% {latency, 10}. Zeit in Sekunden, die der Server bei Leerlauf wartet, bevor er sich beendet
% {clientlifetime,4}.                               Zeitspanne, in der sich an den Client erinnert wird
% {servername, wk}.                                 Name des Servers als Atom
% {hbqname, hbq}.                                   Name der HBQ als Atom
% {hbqnode, 'hbqNode@KI-VS'}.    Name der Node der HBQ als Atom
% {dlqlimit, 42}.                                   Größe der DLQ

Starten des Clients:
--------------------
bash> erl -name client -setcookie hallo -run client start

% 'server@lab23.cpt.haw-hamburg.de': Name der Server Node, erhält man zB über node()
% ' wegen dem - bei haw-hamburg, da dies sonst als minus interpretiert wird.
% in der client.cfg:
% {clients, 5}.                                     Anzahl der Clients, die gestartet werden sollen
% {lifetime, 42}.                                   Laufzeit der Clients
% {servername, wk}.                                 Name des Servers
% {servernode, 'server@KI-VS'}.  Node des Servers
% {sendeintervall, 3}.                              Zeitabstand der einzelnen Nachrichten
% {lab, "lab24"}.                                   Name des Rechners auf dem wir sind (wird zum erstellen der Textzeilen verwendet)
% {group, "1"}.                                     Unsere Praktikumsgruppe (wird zum erstellen der Textzeilen verwendet)
% {team, "10"}.                                     Unsere Teamnummer (wird zum erstellen der Textzeilen verwendet)

Runterfahren:
-------------
2> Ctrl/Strg Shift G
-->q

Informationen zu Prozessen:
-------------
2> pman:start().
2> process_info(PID).
