#!/bin/bash
version=gemini-3f-2023-sep-11
repo=v0.6.7-alpha

if [ -f /etc/systemd/system/subspace-node.servise ]; then
echo  adv
fi

if [ -f $HOME/subspace/docker-compose-logs.yml ]; then
echo docker
fi

if [ -f /etc/systemd/system/subspace.servise ]; then
echo Pulsar
fi
echo done