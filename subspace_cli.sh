#!/bin/bash
# Default variables
function="install"
repo=v0.6.6-alpha
version=skylake-v0.6.6-alpha
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
        -upg|--upgrade)
            function="upgrade"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
while [ ! -d $HOME/subspace ]; do
sudo apt-get install wget jq ocl-icd-opencl-dev libopencl-clang-dev libgomp1 ocl-icd-libopencl1 -y
sleep 2
mkdir $HOME/subspace
cd $HOME/subspace
#download cli
wget https://github.com/subspace/pulsar/releases/download/${repo}/pulsar-ubuntu-x86_64-${version} && \
chmod +x pulsar-ubuntu-x86_64-${version} && \
./pulsar-ubuntu-x86_64-${version} init
sleep 2
#Change ports
sed -i -e "s/9933/19999/g" $HOME/.config/pulsar/settings.toml && \
sed -i -e "s/9944/19998/g" $HOME/.config/pulsar/settings.toml && \
sed -i -e "s/30333/19997/g" $HOME/.config/pulsar/settings.toml && \
sed -i -e "s/30433/19996/g" $HOME/.config/pulsar/settings.toml
#service
cd $HOME
echo "[Unit]
Description=Subspace Node
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=/root/subspace/
ExecStart=/root/subspace/pulsar-ubuntu-x86_64-${version} farm  --verbose
Restart=always
RestartSec=10
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
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service subspace status | grep active` =~ "running" ]]; then
  echo -e "Your subspace node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice subspace status\e[0m"
  echo -e "Use \e[7mjournalctl -fu subspace\e[0m for logs"
else
 echo -e "Your subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
 fi
done
}
uninstall() {
sudo systemctl disable subspace &> /dev/null
sudo systemctl stop subspace  &> /dev/null  
sudo rm -rf $HOME/subspace $HOME/.config/pulsar* &> /dev/null
sudo rm -rf $HOME/subspace $HOME/.config/subspace* &> /dev/null
sudo rm -rf $HOME/.local/share/pulsar/ &> /dev/null
sudo rm -rf $HOME/.local/share/subspace-cli/ &> /dev/null
echo "Done"
cd $HOME
}
update() {
installed=$( ls $HOME/subspace | sed -e "s%pulsar-ubuntu-x86_64-v%v%")
if [ ! -d $HOME/subspace ]; then
echo Need install node!
elif [[ ${version} != ${installed} ]]; then
cd $HOME/subspace
rm pulsar-ubuntu*
#download cli
wget https://github.com/subspace/pulsar/releases/download/${repo}/pulsar-ubuntu-x86_64-${version} && \
chmod +x pulsar-ubuntu-x86_64-${version} && \
sed -i -e "s/pulsar-ubuntu-x86_64-.*/pulsar-ubuntu-x86_64-${version} farm  --verbose/g" /etc/systemd/system/subspace.service
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1 
sudo systemctl enable subspace
sudo systemctl restart subspace
echo -e "Your subspace node \e[32mUpdate\e[39m!"
cd $HOME
else
echo -e "Your Subspace node \e[32mlast version\e[39m!"
fi
}
upgrade() {
if [ ! -d $HOME/subspace ]; then
echo Need install node!
else
cd $HOME/subspace
rm pulsar-ubuntu*
wget https://github.com/subspace/pulsar/releases/download/${repo}/pulsar-ubuntu-x86_64-${version} && \
chmod +x pulsar-ubuntu-x86_64-${version} && \
./pulsar-ubuntu-x86_64-* wipe
./pulsar-ubuntu-x86_64-* init
sed -i -e "s/pulsar-ubuntu-x86_64-.*/pulsar-ubuntu-x86_64-${version} farm  --verbose/g" /etc/systemd/system/subspace.service
sudo systemctl daemon-reload
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1 
sudo systemctl enable subspace
sudo systemctl restart subspace
echo -e "Your subspace node \e[32mUpgrade\e[39m!"
cd $HOME
fi
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function
