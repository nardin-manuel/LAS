#!/bin/sh

while [ ! "$(curl -s influx:8086/api/v2/setup | jq -r ".allowed")" = "false" ]
do
    echo "Wait DB...";
    sleep 5s;
done

if [ ! -f "/run/secrets/influx_token" ]; then
    echo "Token secret not found!";
    while [ ! -f "/run/secrets/influx_token" ]
        do
            sleep 1s;
        done
fi

INFLUXDB_BUCKET="$(jq -r ".INFLUXDB_BUCKET" /my_config)"
INFLUXDB_ORG="$(jq -r ".INFLUXDB_ORG" /my_config)"
MINER_ADDRESS="$(jq -r ".MINER_ADDRESS" /my_config)"

if [ ! -f "/root/key/public.key" ]; then
    echo "Wait for bootnode to start"
    while [ ! -f "/root/key/public.key" ]
        do
            sleep 5s;
        done
fi

if [ ! -d /root/.ethereum/keystore ]; then
    echo "keystore not found, running 'geth init'..."
     geth init /opt/genesis.json
fi

geth --verbosity 3 \
--networkid 69 \
--nat extip:"$(hostname -i)" \
--syncmode "full" \
--http \
    --http.addr=0.0.0.0 \
    --http.port 8545 \
    --http.api=eth,net,web3,personal \
    --http.corsdomain "*" \
--metrics \
    --metrics.influxdbv2 \
    --metrics.influxdb.bucket $INFLUXDB_BUCKET \
    --metrics.influxdb.organization $INFLUXDB_ORG \
    --metrics.influxdb.endpoint "http://influx:8086" \
    --metrics.influxdb.token "$(cat /run/secrets/influx_token)" \
    --metrics.influxdb.tags "host=$(hostname -i)" \
--mine \
    --miner.threads=1 \
    --miner.etherbase=$MINER_ADDRESS \
--bootnodes "$(cat /root/key/public.key)"