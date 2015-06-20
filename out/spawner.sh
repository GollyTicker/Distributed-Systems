
./terminate.sh

# > ls
# out/
# ├── datasource/
# ├── spawner.sh
# └── startStations.sh

cd ..
./build.sh
cd out

interfaceName=en0
mcastAddress=225.10.1.2
receivePort=15010
UTCoffsetMs=1

./startStations.sh $interfaceName $mcastAddress $receivePort 1 5 A $UTCoffsetMs

# ./startStations.sh $interfaceName $mcastAddress $receivePort 2 4 B $UTCoffsetMs

# ./STDMAsniffer $mcastAddress $receivePort $interfaceName -adapt
