#!/bin/bash

echo -e "\e[1m\e[32m1. Updating dependencies... \e[0m" && sleep 1
sudo apt update &> /dev/null

echo "=================================================="

echo -e "\e[1m\e[32m2. Installing wget... \e[0m" && sleep 1
sudo apt install wget -y &> /dev/null
cd $HOME
mkdir subspace/
echo -e "\e[1m\e[32m3. Downloading subspace node binary ... \e[0m" && sleep 1
sudo wget https://github.com/subspace/subspace/releases/download/gemini-3d-2023-apr-18/subspace-node-ubuntu-x86_64-v3-gemini-3d-2023-apr-18 &> /dev/null

echo "=================================================="

echo -e "\e[1m\e[32m4. Downloading subspace farmer binary ... \e[0m" && sleep 1
sudo https://github.com/subspace/subspace/releases/download/gemini-3d-2023-apr-18/subspace-farmer-ubuntu-x86_64-v3-gemini-3d-2023-apr-18 &> /dev/null

echo "=================================================="

echo -e "\e[1m\e[32m5. Moving node to /usr/local/bin/subspace-node ... \e[0m" && sleep 1
sudo mv subspace-node* $HOME/subspace/subspace-node

echo "=================================================="

echo -e "\e[1m\e[32m6. Moving farmer to /usr/local/bin/subspace-farmer ... \e[0m" && sleep 1
sudo mv subspace-farmer* $HOME/subspace/subspace-farmer

echo "=================================================="

echo -e "\e[1m\e[32m7. Giving permissions to subspace-farmer & subspace-node ... \e[0m" && sleep 1
sudo chmod +x $HOME/subspace/subspace*

echo "=================================================="

echo -e "\e[1m\e[32m8. Enter Polkadot JS address to receive rewards \e[0m"
read -p "Address: " ADDRESS

echo "=================================================="

echo -e "\e[1m\e[32m9. Enter Subspace Node name \e[0m"
read -p "Node Name : " NODE_NAME

echo "=================================================="

echo -e "\e[1m\e[32m9. Enter Subspace Farmer Plot Size. For example 30G (means 30 Gigabyte) \e[0m"
read -p "Plot Size : " PLOTSIZE

echo "=================================================="

echo -e "\e[1m\e[92m Node Name: \e[0m" $NODE_NAME

echo -e "\e[1m\e[92m Address:  \e[0m" $ADDRESS

echo -e "\e[1m\e[92m Plot Size:  \e[0m" $PLOTSIZE

echo -e "\e[1m\e[91m    11.1 Continue the process (y/n) \e[0m"
read -p "(y/n)?" response
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then

    echo "=================================================="

    echo -e "\e[1m\e[32m12. Creating service for Subspace Node \e[0m"

    echo "[Unit]
Description=Subspace Node

[Service]
User=$USER
WorkingDirectory=/root/subspace/
ExecStart=/root/subspace/subspace-node --chain gemini-3d --execution wasm --state-pruning archive --blocks-pruning archive --validator --dsn-disable-private-ips --no-private-ipv4 --name '$NODE_NAME'
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
WorkingDirectory=/root/subspace/
ExecStart=/root/subspace/subspace-farmer farm --reward-address $ADDRESS --plot-size $PLOTSIZE --disable-private-ips
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