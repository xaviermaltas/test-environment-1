#!/bin/sh
echo "[*] Installing required dependencies"
PWD="${pwd}"

sudo apt-get install default-jdk
sudo apt-get install wget netcat

echo "[*] Installing Alastria Node Repository"
git clone https://github.com/alastria/alastria-node.git
cd alastria-node/
git checkout develop

echo "Current Directory"
cd ..
ls
# ln -s $PWD/alastria $HOME/alastria

sudo -H $PWD/alastria-node/scripts/bootstrap.sh
# sudo -H ~/alastria/alastria/alastria-node/scripts/bootstrap.sh
