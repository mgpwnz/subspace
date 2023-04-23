#!/bin/bash
# Default variables
version="gemini-3d-2023-apr-21"
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -ml|--multi)
            function="multi"
            shift
            ;;   
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
        -una|--uninstallall)
            function="uninstallall"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install() {
#docker install
cd
touch $HOME/.bash_profile
if ! docker --version; then
		echo -e "${C_LGn}Docker installation...${RES}"
		sudo apt update
		sudo apt upgrade -y
		sudo apt install curl apt-transport-https ca-certificates gnupg lsb-release -y
		. /etc/*-release
		wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt update
		sudo apt install docker-ce docker-ce-cli containerd.io -y
		docker_version=`apt-cache madison docker-ce | grep -oPm1 "(?<=docker-ce \| )([^_]+)(?= \| https)"`
		sudo apt install docker-ce="$docker_version" docker-ce-cli="$docker_version" containerd.io -y
	fi
	if ! docker-compose --version; then
		echo -e "${C_LGn}Docker Сompose installation...${RES}"
		sudo apt update
		sudo apt upgrade -y
		sudo apt install wget jq -y
		local docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
		sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
		sudo chmod +x /usr/bin/docker-compose
		. $HOME/.bash_profile
	fi
cd $HOME
#create var
#SUBSPACE_WALLET_ADDRESS
if [ ! $SUBSPACE_WALLET_ADDRESS ]; then
		read -p "Enter wallet address: " SUBSPACE_WALLET_ADDRESS
		echo 'export SUBSPACE_WALLET_ADDRESS='${SUBSPACE_WALLET_ADDRESS} >> $HOME/.bash_profile
	fi
#SUBSPACE_NODE_NAME
if [ ! $SUBSPACE_NODE_NAME ]; then
		read -p "Enter node name: " SUBSPACE_NODE_NAME
		echo 'export SUBSPACE_NODE_NAME='$SUBSPACE_NODE_NAME >> $HOME/.bash_profile
	fi
#SUBSPACE_PLOT_SIZE
if [ ! $SUBSPACE_PLOT_SIZE ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE
		echo 'export SUBSPACE_PLOT_SIZE='$SUBSPACE_PLOT_SIZE >> $HOME/.bash_profile
	fi
   . $HOME/.bash_profile
   sleep 1
#version
#local subspace_version=`wget -qO- https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name"`
#create dir and config
if [ ! -d $HOME/subspace ]; then
mkdir $HOME/subspace
fi
cd $HOME/subspace
sleep 1
 # Create script 
  tee $HOME/subspace/docker-compose.yml > /dev/null <<EOF
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$version
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32333:32333"
        - "0.0.0.0:32433:32433"
      restart: unless-stopped
      command: [
        "--chain", "gemini-3d",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "archive",
        "--state-pruning", "archive",
        "--port", "32333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/32433",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--dsn-disable-private-ips",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5

    farmer:
      depends_on:
        node:
          condition: service_healthy
      image: ghcr.io/subspace/farmer:$version
      volumes:
        - farmer-data:/var/subspace:rw
      ports:
        - "0.0.0.0:32533:32533"
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--disable-private-ips",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/32533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS}",
        "--plot-size", "$SUBSPACE_PLOT_SIZE"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000

}

multi() {
#docker install
cd
touch $HOME/.bash_profile
if ! docker --version; then
		echo -e "${C_LGn}Docker installation...${RES}"
		sudo apt update
		sudo apt upgrade -y
		sudo apt install curl apt-transport-https ca-certificates gnupg lsb-release -y
		. /etc/*-release
		wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt update
		sudo apt install docker-ce docker-ce-cli containerd.io -y
		docker_version=`apt-cache madison docker-ce | grep -oPm1 "(?<=docker-ce \| )([^_]+)(?= \| https)"`
		sudo apt install docker-ce="$docker_version" docker-ce-cli="$docker_version" containerd.io -y
	fi
	if ! docker-compose --version; then
		echo -e "${C_LGn}Docker Сompose installation...${RES}"
		sudo apt update
		sudo apt upgrade -y
		sudo apt install wget jq -y
		local docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
		sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
		sudo chmod +x /usr/bin/docker-compose
		. $HOME/.bash_profile
	fi
cd $HOME
#create config multi
		read -p "Enter quantity: " MNODE
		echo 'export MNODE='$MNODE  
while [ $MNODE -gt 0 ]
do
# var
#SUBSPACE_WALLET_ADDRESS
		read -p "Enter wallet $MNODE: " SUBSPACE_WALLET_ADDRESS
		echo 'export SUBSPACE_WALLET_ADDRESS'$MNODE=${SUBSPACE_WALLET_ADDRESS}
#SUBSPACE_NODE_NAME
		read -p "Enter node name$MNODE: " SUBSPACE_NODE_NAME
		echo 'export SUBSPACE_NODE_NAME'$MNODE=$SUBSPACE_NODE_NAME
#SUBSPACE_PLOT_SIZE
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE
		echo 'export SUBSPACE_PLOT_SIZE'$MNODE=$SUBSPACE_PLOT_SIZE
#create dir and config
if [ ! -d $HOME/subspace$MNODE ]; then
mkdir $HOME/subspace$MNODE
fi
cd $HOME/subspace$MNODE
sleep 1
 # Create script 
 tee $HOME/subspace$MNODE/docker-compose.yml > /dev/null <<EOF
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$version
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:3${MNODE}333:3${MNODE}333"
        - "0.0.0.0:3${MNODE}433:3${MNODE}433"
      restart: unless-stopped
      command: [
        "--chain", "gemini-3d",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "archive",
        "--state-pruning", "archive",
        "--port", "3${MNODE}333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/34433",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--dsn-disable-private-ips",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 5

    farmer:
      depends_on:
        node:
          condition: service_healthy
      image: ghcr.io/subspace/farmer:$version
      volumes:
        - farmer-data:/var/subspace:rw
      ports:
        - "0.0.0.0:3${MNODE}533:3${MNODE}533"
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--disable-private-ips",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/3${MNODE}533",
        "--reward-address", "$SUBSPACE_WALLET_ADDRESS",
        "--plot-size", "$SUBSPACE_PLOT_SIZE"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
. $HOME/.bash_profile
echo Create config node $MNODE
#docker run
docker compose up -d
echo NODA №$MNODE ZAPUSHENA
MNODE=$[ $MNODE - 1 ]
done
cd $HOME
}

uninstall() {
cd $HOME/subspace
docker compose down -v
sudo rm -rf $HOME/subspace 
echo "Done"
cd
}
uninstallall() {
cd $HOME

if [ -d $HOME/subspace1 ]; then
		cd $HOME/subspace && docker compose down -v  
    sudo rm -rf $HOME/subspace
    echo Node 1 delete
	fi
if [ -d $HOME/subspace2 ]; then
		cd $HOME/subspace2 && docker compose down -v 
    sudo rm -rf $HOME/subspace2
    echo Node 2 delete
	fi
if [ -d $HOME/subspace3 ]; then
		cd $HOME/subspace3 && docker compose down -v 
    sudo rm -rf $HOME/subspace3
    echo Node 3 delete
	fi
if [ -d $HOME/subspace4 ]; then
		cd $HOME/subspace4 && docker compose down -v 
    sudo rm -rf $HOME/subspace4
    echo Node 4 delete
	fi
if [ -d $HOME/subspace5 ]; then
		cd $HOME/subspace5 && docker compose down -v
    sudo rm -rf $HOME/subspace5
    echo Node 5 delete
	fi
if [ -d $HOME/subspace6 ]; then
		cd $HOME/subspace6 && docker compose down -v
    sudo rm -rf $HOME/subspace6
    echo Node 6 delete
	fi
 if [ -d $HOME/subspace7 ]; then
		cd $HOME/subspace7 && docker compose down -v
    sudo rm -rf $HOME/subspace7
    echo Node 7 delete
	fi
if [ -d $HOME/subspace8 ]; then
		cd $HOME/subspace8 && docker compose down -v
    sudo rm -rf $HOME/subspace8
    echo Node 8 delete
	fi
if [ -d $HOME/subspace9 ]; then
		cd $HOME/subspace9 && docker compose down -v
    sudo rm -rf $HOME/subspace9
    echo Node 9 delete
	fi 
cd $HOME
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function
