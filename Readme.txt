 

Building im root ordner:
  ./build.sh

Zum Starten im Ordner out:
Die Startskripte sind im out Ordner. Wir haben stets spawner.sh während der Entwicklung verwendet.

  cd out/

  Start As:
  ./startStations.sh eth2 225.10.1.2 15010 1 1 A  90

  Start Bs:
  ./startStations.sh eth2 225.10.1.2 15010 2 13 B 40

  Start Stations:
  ./STDMAsniffer 225.10.1.2 15010 eth2 -adapt | tee log/sniffer.log -


Prozesse killen (im out-Ordner):
  ./terminate.sh

