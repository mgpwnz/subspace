#!/bin/bash
# Default variables
function="install"
version=Gemini-3g-2023-nov-16
#version=gemini-3g-2023-oct-31
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
	    -up|--update)
            function="update"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
sudo apt update &> /dev/null
apt-get install protobuf-compiler -y
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 3
sudo apt install wget -y &> /dev/null
sudo apt-get install libgomp1 -y &> /dev/null
cd $HOME
mkdir subspace_adv
#download binary
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-node-ubuntu-x86_64-skylake-${version} &> /dev/null
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-farmer-ubuntu-x86_64-skylake-${version} &> /dev/null
sleep 1
sudo mv subspace-node-ubuntu-x86_64-skylake-${version} /usr/local/bin/subspace-node
sudo mv subspace-farmer-ubuntu-x86_64-skylake-${version} /usr/local/bin/subspace-farmer
sudo chmod +x /usr/local/bin/subspace*
# add var
echo -e "\e[1m\e[32m1. Enter Polkadot JS address to receive rewards \e[0m"
read -p "Address: " ADDRESS
echo -e "\e[1m\e[32m2. Enter Subspace Node name \e[0m"
read -p "Node Name : " NODE_NAME
echo -e "\e[1m\e[32m3. Enter Subspace Farmer Plot Size. For example 30G (means 30 Gigabyte) \e[0m"
read -p "Plot Size : " PLOTSIZE

echo -e "\e[1m\e[92m Node Name: \e[0m" $NODE_NAME

echo -e "\e[1m\e[92m Address:  \e[0m" $ADDRESS

echo -e "\e[1m\e[92m Plot Size:  \e[0m" $PLOTSIZE
sleep 1
#create service node
    echo "[Unit]
Description=Subspace Node

[Service]
User=$USER
ExecStart=subspace-node  --chain gemini-3g  --blocks-pruning 256 --execution wasm --state-pruning archive-canonical  --no-private-ip --validator --name '$NODE_NAME' 
Restart=always
RestartSec=10
Nice=-5
KillSignal=SIGINT
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-node.service

    sudo mv $HOME/subspace-node.service /etc/systemd/system


    echo "[Unit]
Description=Subspace Farmer

    [Service]
User=$USER
ExecStart=subspace-farmer farm --farm-during-initial-plotting --reward-address $ADDRESS path=/root/subspace_adv,size=$PLOTSIZE
KillSignal=SIGINT
Restart=always
RestartSec=10
Nice=-5
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-farmer.service

    sudo mv $HOME/subspace-farmer.service /etc/systemd/system


# Enabling services
    sudo systemctl daemon-reload
    sudo systemctl enable subspace-farmer.service
    sudo systemctl enable subspace-node.service

# Starting services
    sudo systemctl restart subspace-node.service
    sudo systemctl restart subspace-farmer.service
#logs
    echo -e "\e[1m\e[32mTo check the Subspace Node Logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-node.service -f \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer signed block logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -o cat | grep 'Successfully signed reward' \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer default logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -f \n \e[0m"
}
uninstall() {
sudo systemctl disable subspace-farmer.service
sudo systemctl disable subspace-node.service
sudo rm /etc/systemd/system/subspace-farmer.service /etc/systemd/system/subspace-node.service
sudo rm /usr/local/bin/subspace-farmer /usr/local/bin/subspace-node 
sudo rm -rf $HOME/subspace_adv $HOME/.local/share/subspace-node/
echo "Done"
cd $HOME
}
update() {
cd $HOME
sudo apt update &> /dev/null
sudo apt install wget -y &> /dev/null
sudo apt-get install libgomp1 -y &> /dev/null
#download cli
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-node-ubuntu-x86_64-skylake-${version} &> /dev/null
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-farmer-ubuntu-x86_64-skylake-${version} &> /dev/null
sleep 1
sudo mv subspace-node-ubuntu-x86_64-skylake-${version} /usr/local/bin/subspace-node
sudo mv subspace-farmer-ubuntu-x86_64-skylake-${version} /usr/local/bin/subspace-farmer
sudo chmod +x /usr/local/bin/subspace*
sleep 1
# Enabling services
    sudo systemctl daemon-reload
# Starting services
    sudo systemctl restart subspace-node.service
    sudo systemctl restart subspace-farmer.service
echo -e "Your subspace node \e[32mUpdate\e[39m!"
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function