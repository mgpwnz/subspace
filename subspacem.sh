#!/bin/bash
# Default variables
version="gemini-3f-2023-sep-13-2"
chain="gemini-3f"
function="install1"
# Options
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
        case "$1" in
        -in1|--install1)
            function="install1"
            shift
            ;;
        -in2|--install2)
            function="install2"
            shift
            ;;
        -in3|--install3)
            function="install3"
            shift
            ;;
        -in4|--install4)
            function="install4"
            shift
            ;;
        -in5|--install5)
            function="install5"
            shift
            ;;
        -up1|--update1)
            function="update1"
            shift
            ;;
        -up2|--update2)
            function="update2"
            shift
            ;;
        -up3|--update3)
            function="update3"
            shift
            ;;
        -up4|--update4)
            function="update4"
            shift
            ;;
        -up5|--update5)
            function="update5"
            shift
            ;;       
        -un1|--uninstall1)
            function="uninstall1"
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
        -un4|--uninstall4)
            function="uninstall4"
            shift
            ;;
        -un5|--uninstall5)
            function="uninstall5"
            shift
            ;;
        *|--)
		break
		;;
	esac
done
install1() {
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
install2() {
cd $HOME
#create var
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
#SUBSPACE_PLOT_SIZE2
if [ ! $SUBSPACE_PLOT_SIZE2 ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE2
		echo 'export SUBSPACE_PLOT_SIZE2='$SUBSPACE_PLOT_SIZE2 >> $HOME/.bash_profile
	fi
   . $HOME/.bash_profile
   sleep 1
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
        - "0.0.0.0:33333:33333"
        - "0.0.0.0:33433:33433"
      restart: unless-stopped
      command: [
        "--chain", "$chain",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "33333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/33433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME2"
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
        - "0.0.0.0:33533:33533"
      restart: unless-stopped
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/33533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS2}",
        "path=/var/subspace,size=$SUBSPACE_PLOT_SIZE2",
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
cd $HOME
}
install3() {
cd $HOME
#create var
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
   . $HOME/.bash_profile
   sleep 1
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
        - "0.0.0.0:34333:34333"
        - "0.0.0.0:34433:34433"
      restart: unless-stopped
      command: [
        "--chain", "$chain",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "34333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/34433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME3"
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
        - "0.0.0.0:34533:34533"
      restart: unless-stopped
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/34533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS3}",
        "path=/var/subspace,size=$SUBSPACE_PLOT_SIZE3",
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
cd $HOME
}
install4() {
cd $HOME
#create var
#SUBSPACE_WALLET_ADDRESS4
if [ ! $SUBSPACE_WALLET_ADDRESS4 ]; then
		read -p "Enter wallet address4: " SUBSPACE_WALLET_ADDRESS4
		echo 'export SUBSPACE_WALLET_ADDRESS4='${SUBSPACE_WALLET_ADDRESS4} >> $HOME/.bash_profile
	fi
#SUBSPACE_NODE_NAME4
if [ ! $SUBSPACE_NODE_NAME4 ]; then
		read -p "Enter node name4: " SUBSPACE_NODE_NAME4
		echo 'export SUBSPACE_NODE_NAME4='$SUBSPACE_NODE_NAME4 >> $HOME/.bash_profile
	fi
#SUBSPACE_PLOT_SIZE4
if [ ! $SUBSPACE_PLOT_SIZE4 ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE4
		echo 'export SUBSPACE_PLOT_SIZE4='$SUBSPACE_PLOT_SIZE4 >> $HOME/.bash_profile
	fi
   . $HOME/.bash_profile
   sleep 1
#create dir and config
if [ ! -d $HOME/subspace4 ]; then
mkdir $HOME/subspace4
fi
cd $HOME/subspace4
sleep 1
 # Create script 
  tee $HOME/subspace4/docker-compose.yml > /dev/null <<EOF
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
        "--chain", "$chain",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "35333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/35433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME4"
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
        - "0.0.0.0:35533:35533"
      restart: unless-stopped
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/35533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS4}",
        "path=/var/subspace,size=$SUBSPACE_PLOT_SIZE4",
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
cd $HOME
}
install5() {
cd $HOME
#create var
#SUBSPACE_WALLET_ADDRESS5
if [ ! $SUBSPACE_WALLET_ADDRESS5 ]; then
		read -p "Enter wallet address5: " SUBSPACE_WALLET_ADDRESS5
		echo 'export SUBSPACE_WALLET_ADDRESS5='${SUBSPACE_WALLET_ADDRESS5} >> $HOME/.bash_profile
	fi
#SUBSPACE_NODE_NAME5
if [ ! $SUBSPACE_NODE_NAME5 ]; then
		read -p "Enter node name5: " SUBSPACE_NODE_NAME5
		echo 'export SUBSPACE_NODE_NAME5='$SUBSPACE_NODE_NAME5 >> $HOME/.bash_profile
	fi
#SUBSPACE_PLOT_SIZE5
if [ ! $SUBSPACE_PLOT_SIZE5 ]; then
		read -p "Enter plot size 50-100G: " SUBSPACE_PLOT_SIZE5
		echo 'export SUBSPACE_PLOT_SIZE5='$SUBSPACE_PLOT_SIZE5 >> $HOME/.bash_profile
	fi
   . $HOME/.bash_profile
   sleep 1
#create dir and config
if [ ! -d $HOME/subspace5 ]; then
mkdir $HOME/subspace5
fi
cd $HOME/subspace5
sleep 1
 # Create script 
  tee $HOME/subspace5/docker-compose.yml > /dev/null <<EOF
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:$version
      volumes:
        - node-data:/var/subspace:rw
      ports:
        - "0.0.0.0:36333:36333"
        - "0.0.0.0:36433:36433"
      restart: unless-stopped
      command: [
        "--chain", "$chain",
        "--base-path", "/var/subspace",
        "--execution", "wasm",
        "--blocks-pruning", "256",
        "--state-pruning", "archive",
        "--port", "36333",
        "--dsn-listen-on", "/ip4/0.0.0.0/tcp/36433",
        "--rpc-cors", "all",
        "--rpc-methods", "unsafe",
        "--rpc-external",
        "--no-private-ipv4",
        "--validator",
        "--name", "$SUBSPACE_NODE_NAME5"
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
        - "0.0.0.0:36533:36533"
      restart: unless-stopped
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--listen-on", "/ip4/0.0.0.0/tcp/36533",
        "--reward-address", "${SUBSPACE_WALLET_ADDRESS5}",
        "path=/var/subspace,size=$SUBSPACE_PLOT_SIZE5",
      ]
  volumes:
    node-data:
    farmer-data:
EOF
sleep 2
#docker run
docker compose up -d && docker compose logs -f --tail 1000
cd $HOME
}
#need rework
update1() {
if [  -d $HOME/subspace ]; then
cd $HOME/subspace
sed -i.bak "s/:gemini-3.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
update2() {
if [  -d $HOME/subspace2 ]; then
cd $HOME/subspace2
sed -i.bak "s/:gemini-3.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
update3() {
if [  -d $HOME/subspace3 ]; then
cd $HOME/subspace3
sed -i.bak "s/:gemini-3.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
update4() {
if [  -d $HOME/subspace4 ]; then
cd $HOME/subspace4
sed -i.bak "s/:gemini-3.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
update5() {
if [  -d $HOME/subspace5 ]; then
cd $HOME/subspace5
sed -i.bak "s/:gemini-3.*/:$version/" docker-compose.yml
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_up.sh)
cd
fi
}
uninstall1() {
cd $HOME/subspace
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace 
echo "Done"
cd
}
uninstall2() {
cd $HOME/subspace2
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace2 
echo "Done"
cd
}
uninstall3() {
cd $HOME/subspace3
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace3 
echo "Done"
cd
}
uninstall4() {
cd $HOME/subspace4
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace4 
echo "Done"
cd
}
uninstall5() {
cd $HOME/subspace5
. <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_un.sh)
sudo rm -rf $HOME/subspace5 
echo "Done"
cd
}
# Actions
sudo apt install wget -y &>/dev/null
cd
$function
