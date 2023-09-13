#!/bin/bash
version=gemini-3f-2023-sep-11
repo=v0.6.7-alpha

if [ -e /usr/local/bin/subspace-node ]; then
echo  adv
fi

if [ -e $HOME/subspace/docker-compose.yml ]; then
echo docker
fi

if [ -e /usr/local/bin/pulsar ]; then
echo Pulsar
fi
echo done