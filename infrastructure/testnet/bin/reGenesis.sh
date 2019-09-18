#!/bin/bash 

echo "Execute from infrastructures/testnet/"

PWD="$(pwd)"

for (( c=1; c<5; c++ ))
do
    # echo "$PWD"
    cd identities/general$c/geth
    echo "Deleting general$c chaindata"
    rm -rf chaindata
    rm -rf lightchaindata
    cd ..
    cd ..
    cd ..
done

for (( c=1; c<3; c++ ))
do
    # echo "$PWD"
    cd identities/validator$c/geth
    echo "Deleting validator$c chaindata"
    rm -rf chaindata
    rm -rf lightchaindata
    cd ..
    cd ..
    cd ..
done

cd identities/main/geth
echo "Deleting main chaindata"
rm -rf chaindata
rm -rf lightchaindata
cd ..
cd ..
cd ..

echo " "
echo " "

echo "Regenesis general1"
geth --datadir identities/general1 init alastria-node/data/genesis.json

echo "Regenesis general2"
geth --datadir identities/general2 init alastria-node/data/genesis.json

echo "Regenesis general3"
geth --datadir identities/general3 init alastria-node/data/genesis.json

echo "Regenesis general4"
geth --datadir identities/general4 init alastria-node/data/genesis.json

echo "Regenesis main"
geth --datadir identities/main init alastria-node/data/genesis.json

echo "Regenesis validator1"
geth --datadir identities/validator1 init alastria-node/data/genesis.json

echo "Regenesis validator2"
geth --datadir identities/validator2 init alastria-node/data/genesis.json


echo "Deleting not required 'keystore' folders of main, validator1 and validator2 nodes"
rm -rf ${PWD}/identities/main/keystore
rm -rf ${PWD}/identities/validator1/keystore
rm -rf ${PWD}/identities/validator2/keystore