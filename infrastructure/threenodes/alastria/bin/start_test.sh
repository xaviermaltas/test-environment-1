#!/bin/bash
set -u
set -e

echo "Excecute from alastria folder"

PWD="$(pwd)"

_TIME=$(date +%Y%m%d%H%M%S)

CARPETA="$1"
NETID=9535753591
mapfile -t IDENTITY <"${PWD}"/"$CARPETA"/IDENTITY
mapfile -t NODE_TYPE <"${PWD}"/"$CARPETA"/NODE_TYPE
NODE_IP="127.0.0.1"

generate_conf() {
   #define parameters which are passed in.
   NODE_IP="$1"
   CONSTELLATION_PORT="$2"
   OTHER_NODES="$3"
   PWD="$4"
   CARPETA="$5"

   #define the template.
   cat  << EOF
# Externally accessible URL for this node (this is what's advertised)
url = "http://$NODE_IP:$CONSTELLATION_PORT/"
# Port to listen on for the public API
port = $CONSTELLATION_PORT
# Socket file to use for the private API / IPC
socket = "$PWD/$CARPETA/constellation/constellation.ipc"
# Initial (not necessarily complete) list of other nodes in the network.
# Constellation will automatically connect to other nodes not in this list
# that are advertised by the nodes below, thus these can be considered the
# "boot nodes."
othernodes = ["$OTHER_NODES"]
# The set of public keys this node will host
publickeys = ["$PWD/$CARPETA/constellation/keystore/node.pub"]
# The corresponding set of private keys
privatekeys = ["$PWD/$CARPETA/constellation/keystore/node.key"]
# Optional file containing the passwords to unlock the given privatekeys
# (one password per line -- add an empty line if one key isn't locked.)
passwords = "$PWD/$CARPETA/passwords.txt"
# Where to store payloads and related information
storage = "$PWD/$CARPETA/constellation/data"
# Verbosity level (each level includes all prior levels)
#   - 0: Only fatal errors
#   - 1: Warnings
#   - 2: Informational messages
#   - 3: Debug messages
verbosity = 2
EOF
}

check_port() {
	PORT_TO_TEST="$1"
	RETVAL=1
	
	set +u
	set +e

	while [ $RETVAL -ne 0 ]
	do
		netcat -z -v localhost $PORT_TO_TEST
		RETVAL=$?
		[ $RETVAL -eq 0 ] && echo "[*] constellation node at $PORT_TO_TEST is now up."
		[ $RETVAL -ne 0 ] && sleep 1
		
	done

	set -u
	set -e	
}

PUERTO=0
if [[ "$CARPETA" == "validator" ]]; then
	PUERTO=0
else
	if [[ "$CARPETA" == "general1" ]]; then
		PUERTO=1
	else
		PUERTO=2
	fi
fi

GLOBAL_ARGS="--networkid $NETID --identity $IDENTITY --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --rpcport 2200$PUERTO --port 2100$PUERTO --targetgaslimit 18446744073709551615 --ethstats $IDENTITY:bb98a0b6442386d0cdf8a31b267892c1@$NODE_IP:3000 "
CONSTELLATION_PORT="900$PUERTO"

if [[ "$CARPETA" == "validator" ]]; then
	echo "[*] Executing validator"
	nohup geth --datadir "${PWD}"/"$CARPETA" $GLOBAL_ARGS --mine --minerthreads 1 --syncmode "full" 2>> "${PWD}"/logs/quorum_"$CARPETA"_"${_TIME}".log &
	# geth --exec 'istanbul.propose("0xB50001FfA410F4D03663D69540c1C8e1C017e7e6", true)' attach ${CARPETA}/geth.ipc
else
	if [[ "$PUERTO" == "1" ]]; then
		OTHER_NODES="http://127.0.0.1:9002/"
	else 
		OTHER_NODES="http://127.0.0.1:9001/"
	fi
	echo "[*] Executing general{$PUERTO}"
	generate_conf "${NODE_IP}" "${CONSTELLATION_PORT}" "$OTHER_NODES" "${PWD}" "${CARPETA}" > "${PWD}"/"$CARPETA"/constellation/constellation.conf
	nohup constellation-node "${PWD}"/"$CARPETA"/constellation/constellation.conf 2>> "${PWD}"/logs/constellation_"$CARPETA"_"${_TIME}".log &
	check_port $CONSTELLATION_PORT
	nohup env PRIVATE_CONFIG="${PWD}"/"$CARPETA"/constellation/constellation.conf geth --datadir "${PWD}"/"$CARPETA" --debug $GLOBAL_ARGS 2>> "${PWD}"/logs/quorum_"$CARPETA"_"${_TIME}".log &
fi

echo "Verify if ${PWD}/logs/ have new files."

set +u
set +e
