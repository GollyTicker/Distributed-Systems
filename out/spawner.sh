
# ./terminate.sh

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
UTCoffsetMs=0

./startStations.sh $interfaceName $mcastAddress $receivePort 1 1 A $UTCoffsetMs

./startStations.sh $interfaceName $mcastAddress $receivePort 2 25 B $UTCoffsetMs

./STDMAsniffer $mcastAddress $receivePort $interfaceName -adapt | tee log/sniffer.log # slows down sniffer

# ./startStations.sh eth2 225.10.1.2 15010 25 25 B 10