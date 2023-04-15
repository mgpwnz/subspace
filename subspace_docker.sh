#!/bin/bash
# Default variables
version="gemini-3d-2023-apr-14"
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -in2|--second)
            function="second"
            shift
            ;;
        -in3|--three)
            function="three"
            shift
            ;;    
        -un|--uninstall)
            function="uninstall"
            shift
            ;;
        -un2|--uninstall2)
            function="uninstall2"
            shift
            ;;
        -un3|--uninstall3)
            function="uninstall3"
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
        "--chain", "gemini-3c",
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
second() {
cd $HOME
#create var2
#SUBSPACE_WALLET_ADDRESS2
if [ ! $SUBSPACE_WALLET_ADDRESS2 ]; then
		read -p "Enter wallet address2: " SUBSPACE_WALLET_ADDRESS2
		echo 'export SUBSPACE_WALLET_ADDRESS2='${SUBSPACE_WALLET_ADDRESS2} >> $HOME/.bash_profile
	fi
#SUBSPACE_NODE_NAME2
if [ ! $SUBSPACE_NODE_NAME2 ]; then
		read -p "Enter node name2: " SUBSPACE_NODE_NAME2
		echo 'export SUBSPACE_NODE_NAME2='$SUBSPACE_NODE_NAME2 >> $HOME/.bash_profile
	fi
#SUBSPACE_PLOT_SIZE
if [ ! $SUBSPACE_PLOT_SIZE2 ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE2
		echo 'export SUBSPACE_PLOT_SIZE2='$SUBSPACE_PLOT_SIZE2 >> $HOME/.bash_profile
	fi
#version
#local subspace_version=`wget -qO- https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name"`
#create dir and config
if [ ! -d $HOME/subspace2 ]; then
mkdir $HOME/subspace2
fi
cd $HOME/subspace2
sleep 1
 # Create script 
 tee $HOME/subspace2/docker-compose.yml > /dev/null <<EOF
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$version
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:34333:34333"
        - "0.0.0.0:34433:34433"
      restart: unless-stopped
      command: [
        "--chain", "gemini-3c",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "archive",
        "--state-pruning", "archive",
        "--port", "34333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/34433",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--dsn-disable-private-ips",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME2"
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
        - "0.0.0.0:34533:34533"
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--disable-private-ips",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/34533",
        "--reward-address", "$SUBSPACE_WALLET_ADDRESS2",
        "--plot-size", "$SUBSPACE_PLOT_SIZE2"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
}
three() {
cd $HOME
#create var3
#SUBSPACE_WALLET_ADDRESS3
if [ ! $SUBSPACE_WALLET_ADDRESS3 ]; then
		read -p "Enter wallet address3: " SUBSPACE_WALLET_ADDRESS3
		echo 'export SUBSPACE_WALLET_ADDRESS3='${SUBSPACE_WALLET_ADDRESS3} >> $HOME/.bash_profile
	fi
#SUBSPACE_NODE_NAME3
if [ ! $SUBSPACE_NODE_NAME3 ]; then
		read -p "Enter node name3: " SUBSPACE_NODE_NAME3
		echo 'export SUBSPACE_NODE_NAME3='$SUBSPACE_NODE_NAME3 >> $HOME/.bash_profile
	fi
#SUBSPACE_PLOT_SIZE3
if [ ! $SUBSPACE_PLOT_SIZE3 ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE3
		echo 'export SUBSPACE_PLOT_SIZE3='$SUBSPACE_PLOT_SIZE3 >> $HOME/.bash_profile
	fi
#version
#local subspace_version=`wget -qO- https://api.github.com/repos/subspace/subspace/releases/latest | jq -r ".tag_name"`
#create dir and config
if [ ! -d $HOME/subspace3 ]; then
mkdir $HOME/subspace3
fi
cd $HOME/subspace3
sleep 1
 # Create script 
 tee $HOME/subspace3/docker-compose.yml > /dev/null <<EOF
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$version
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:35333:35333"
        - "0.0.0.0:35433:35433"
      restart: unless-stopped
      command: [
        "--chain", "gemini-3c",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "archive",
        "--state-pruning", "archive",
        "--port", "35333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/35433",
        "--rpc-cors", "all",
        "--rpc-methods", "safe",
        "--unsafe-ws-external",
        "--dsn-disable-private-ips",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME3"
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
        - "0.0.0.0:35533:35533"
      restart: unless-stopped
      command: [
        "--base-path", "/var/subspace",
        "farm",
        "--disable-private-ips",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/35533",
        "--reward-address", "$SUBSPACE_WALLET_ADDRESS3",
        "--plot-size", "$SUBSPACE_PLOT_SIZE3"
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
}
uninstall() {
cd $HOME/subspace
docker compose down -v
sudo rm -rf $HOME/subspace 
echo "Done"
cd
}
uninstall2() {
cd $HOME/subspace2
docker compose down -v
sudo rm -rf $HOME/subspace2
cd 
echo "Done"
cd
}
uninstall3() {
cd $HOME/subspace3
docker compose down -v
sudo rm -rf $HOME/subspace3 
cd
echo "Done"
cd
}
# Actions
sudo apt install tmux wget -y &>/dev/null
cd
$function
