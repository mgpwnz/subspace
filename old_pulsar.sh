#!/bin/bash
#version=gemini-3f-2023-sep-11
repo=v0.6.10-alpha
cd
rm -rf $HOME/subspace
#download
sudo apt-get install wget jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 ocl-icd-libopencl1 -y
sleep 2
#download cli
wget -O pulsar https://github.com/subspace/pulsar/releases/download/${repo}/pulsar-ubuntu-x86_64-skylake-${repo} 
chmod +x pulsar 
mv pulsar /usr/local/bin/
#service
cd $HOME
echo "[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/pulsar farm  --verbose
Restart=on-failure
LimitNOFILE=1024000
[Install]
WantedBy=multi-user.target
" > $HOME/subspace.service
sudo mv $HOME/subspace.service /etc/systemd/system
sudo systemctl restart systemd-journald 
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1 
sudo systemctl enable subspace
sudo systemctl restart subspace
journalctl -fu subspace