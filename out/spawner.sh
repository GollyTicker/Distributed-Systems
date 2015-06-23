
./terminate.sh

# > ls
# out/
# ├── datasource/
# ├── spawner.sh
# └── startStations.sh

cd ..
./build.sh
cd out

interfaceName=wlan0
mcastAddress=225.10.1.2
receivePort=15010
UTCoffsetMs=10

./startStations.sh $interfaceName $mcastAddress $receivePort 1 7 A $UTCoffsetMs

./startStations.sh $interfaceName $mcastAddress $receivePort 8 15 B $UTCoffsetMs

./STDMAsniffer $mcastAddress $receivePort $interfaceName -adapt
