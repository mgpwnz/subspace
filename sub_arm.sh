#!/bin/bash
version=gemini-3f-2023-sep-05
sudo apt update &> /dev/null
apt-get install protobuf-compiler -y
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 3
sudo apt install wget -y &> /dev/null
cd $HOME
#download binary
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-node-ubuntu-aarch64-${version} &> /dev/null
wget https://github.com/subspace/subspace/releases/download/${version}/subspace-farmer-ubuntu-aarch64-${version} &> /dev/null
sleep 1
sudo mv subspace-node-ubuntu-aarch64-${version} /usr/local/bin/subspace-node
sudo mv subspace-farmer-ubuntu-aarch64-${version} /usr/local/bin/subspace-farmer
sudo chmod +x /usr/local/bin/subspace*
# add var
echo -e "\e[1m\e[32m8. Enter Polkadot JS address to receive rewards \e[0m"
read -p "Address: " ADDRESS
echo -e "\e[1m\e[32m9. Enter Subspace Node name \e[0m"
read -p "Node Name : " NODE_NAME

echo -e "\e[1m\e[92m Node Name: \e[0m" $NODE_NAME

echo -e "\e[1m\e[92m Address:  \e[0m" $ADDRESS

sleep 1
#create service
    echo "[Unit]
Description=Subspace Node

[Service]
User=$USER
ExecStart=subspace-node  --chain gemini-3f  --blocks-pruning 256 --execution wasm --state-pruning archive --validator --name '$NODE_NAME'
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-node.service

    sudo mv $HOME/subspace-node.service /etc/systemd/system


    echo "[Unit]
Description=Subspace Farmer

[Service]
User=$USER
ExecStart=subspace-farmer farm --reward-address $ADDRESS path=/root,size=200GiB
Restart=always
RestartSec=10
LimitNOFILE=10000

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
