#!/bin/bash
version=gemini-3f-2023-sep-11
repo=v0.6.7-alpha

if [ -e /usr/local/bin/subspace-node ]; then
echo  SUBSPACE Advanced
read -r -p "Update node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        . <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/sub_adv.sh) -up
        ;;
    *)
        echo Update canceled !
        break
        ;;
esac
fi

if [ -e /root/subspace/docker-compose.yml ]; then
echo SUBSPACE DOCKER
read -r -p "Update node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        . <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace.sh) -up
        ;;
    *)
        echo Update canceled !
        break
        ;;
esac
fi

if [ -e /usr/local/bin/pulsar ]; then
echo SUBSPACE Pulsar
read -r -p "Update node? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        . <(wget -qO- https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_cli.sh) -up
        ;;
    *)
        echo Update canceled ! 
        break
        ;;
esac
fi