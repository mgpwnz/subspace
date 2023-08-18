#!/bin/bash
# Default variables
version="gemini-3f-2023-aug-18"
chain="gemini-3f"
function="install"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in|--install)
            function="install"
            shift
            ;;
        -up|--update)
            function="update"
            shift
            ;;
        -un|--uninstall)
            function="uninstall"
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
        "--chain", "$chain",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "32333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/32433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME"
      ]
      healthcheck:
        timeout: 5s
        interval: 30s
        retries: 60

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
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/32533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS}",
        "path=/var/subspace,size=$SUBSPACE_PLOT_SIZE",
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000

}
#need rework
update() {
if [  -d $HOME/subspace ]; then
cd $HOME/subspace
sed -i.bak "s/:gemini-3d-2023.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
uninstall() {
cd $HOME/subspace
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace 
echo "Done"
cd
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function
