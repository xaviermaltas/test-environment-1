#!/bin/bash 

echo "Execute from infrastructures/testnet/"

PWD="$(pwd)"

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


echo "Deleting not required 'keystore' folders"
rm -rf ${PWD}/identities/main/keystore
rm -rf ${PWD}/identities/validator1/keystore
rm -rf ${PWD}/identities/validator2/keystore