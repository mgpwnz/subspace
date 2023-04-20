#!/bin/bash
echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update &> /dev/null
apt-get install protobuf-compiler
apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends tzdata git ca-certificates curl build-essential libssl-dev pkg-config libclang-dev cmake jq
echo -e "\e[1m\e[32m1.2. Install Rust \e[0m" && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

echo "=================================================="

echo -e "\e[1m\e[32m1.3. Installing wget... \e[0m" && sleep 1
sudo apt install wget -y &> /dev/null
cd $HOME
mkdir sub/ && cd sub
echo -e "\e[1m\e[32m2. Git clone \e[0m" && sleep 1
git clone https://github.com/subspace/subspace.git
cd $HOME/sub/subspace
echo -e "\e[1m\e[32m3. Compiling... \e[0m" && sleep 1
git checkout gemini-3d-2023-apr-18 
cargo build --profile production --bin subspace-node --bin subspace-farmer

echo -e "\e[1m\e[32m4. Moving node to /root/sub/subspace-node ... \e[0m" && sleep 1
sudo mv /root/sub/subspace/target/production/subspace-node $HOME/sub/subspace-node

echo "=================================================="

echo -e "\e[1m\e[32m5. Moving farmer to /root/sub/subspace-farmer ... \e[0m" && sleep 1
sudo mv /root/sub/subspace/target/production/subspace-farmer $HOME/sub/subspace-farmer

echo "=================================================="

echo -e "\e[1m\e[32m6. Giving permissions to subspace-farmer & subspace-node ... \e[0m" && sleep 1
sudo chmod +x $HOME/sub/subspace*

echo "=================================================="

echo -e "\e[1m\e[32m7. Enter Polkadot JS address to receive rewards \e[0m"
read -p "Address: " ADDRESS

echo "=================================================="

echo -e "\e[1m\e[32m8. Enter Subspace Node name \e[0m"
read -p "Node Name : " NODE_NAME

echo "=================================================="

echo -e "\e[1m\e[32m9. Enter Subspace Farmer Plot Size. For example 30G (means 30 Gigabyte) \e[0m"
read -p "Plot Size : " PLOTSIZE

echo "=================================================="

echo -e "\e[1m\e[92m Node Name: \e[0m" $NODE_NAME

echo -e "\e[1m\e[92m Address:  \e[0m" $ADDRESS

echo -e "\e[1m\e[92m Plot Size:  \e[0m" $PLOTSIZE

echo -e "\e[1m\e[91m    10 Continue the process (y/n) \e[0m"
read -p "(y/n)?" response
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

    echo "=================================================="

    echo -e "\e[1m\e[32m11. Creating service for Subspace Node \e[0m"

    echo "[Unit]
Description=Subspace Node

[Service]
User=$USER
WorkingDirectory=/root/sub/
ExecStart=/root/sub/subspace-node --chain gemini-3d --execution wasm --state-pruning archive --blocks-pruning archive --validator --dsn-disable-private-ips --no-private-ipv4 --name '$NODE_NAME'
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-node.service

    sudo mv $HOME/subspace-node.service /etc/systemd/system

    echo "=================================================="

    echo -e "\e[1m\e[32m13. Creating service for Subspace Farmer \e[0m"

    echo "[Unit]
Description=Subspace Farmer

[Service]
User=$USER
WorkingDirectory=/root/sub/
ExecStart=/root/sub/subspace-farmer farm --reward-address $ADDRESS --plot-size $PLOTSIZE --disable-private-ips
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
    " > $HOME/subspace-farmer.service

    sudo mv $HOME/subspace-farmer.service /etc/systemd/system

    echo "=================================================="

    # Enabling services
    sudo systemctl daemon-reload
    sudo systemctl enable subspace-farmer.service
    sudo systemctl enable subspace-node.service

    # Starting services
    sudo systemctl restart subspace-node.service
    sudo systemctl restart subspace-farmer.service

    echo "=================================================="

    echo -e "\e[1m\e[32mNode Started \e[0m"
    echo -e "\e[1m\e[32mFarmer Started \e[0m"

    echo "=================================================="

    echo -e "\e[1m\e[32mTo stop the Subspace Node: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl stop subspace-node.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo start the Subspace Node: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl start subspace-node.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Node Logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-node.service -f \n \e[0m" 

    echo -e "\e[1m\e[32mTo stop the Subspace Farmer: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl stop subspace-farmer.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo start the Subspace Farmer: \e[0m" 
    echo -e "\e[1m\e[39m    systemctl start subspace-farmer.service \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer signed block logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -o cat | grep 'Successfully signed block' \n \e[0m" 

    echo -e "\e[1m\e[32mTo check the Subspace Farmer default logs: \e[0m" 
    echo -e "\e[1m\e[39m    journalctl -u subspace-farmer.service -f \n \e[0m" 
else
    echo -e "\e[1m\e[91m    You have terminated the process \e[0m"
fi