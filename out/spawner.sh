
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
UTCoffsetMsA=0 #90
UTCoffsetMsB=0 #40

./startStations.sh $interfaceName $mcastAddress $receivePort 1 5 A $UTCoffsetMsA

./startStations.sh $interfaceName $mcastAddress $receivePort 6 25 B $UTCoffsetMsB

./STDMAsniffer $mcastAddress $receivePort $interfaceName -adapt | tee log/sniffer.log - # slows down sniffer
