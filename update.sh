#!/bin/bash
version=gemini-3f-2023-sep-11
repo=v0.6.7-alpha

if [ -e /etc/systemd/system/subspace-node.servise ]; then
echo  adv
fi

if [ -e $HOME/subspace/docker-compose-logs.yml ]; then
echo docker
fi

if [ -e /etc/systemd/system/subspace.service ]; then
echo Pulsar
fi
echo done