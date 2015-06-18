
./terminate.sh

# > ls
# out/
# ├── datasource/
# ├── spawner.sh
# └── startStations.sh

cd ..
./build.sh
cd out

interfaceName=eth2
mcastAddress=225.10.1.2
receivePort=15010
firstIndex=1
lastIndex=1
UTCoffsetMs=1

stationClass=A
./startStations.sh $interfaceName $mcastAddress $receivePort $firstIndex $lastIndex $stationClass $UTCoffsetMs

stationClass=B
# ./startStations.sh $interfaceName $mcastAddress $receivePort $firstIndex $lastIndex $stationClass $UTCoffsetMs

# ./STDMAsniffer 225.10.1.2 15010 eth2 -adapt
