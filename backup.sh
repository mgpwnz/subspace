#!/bin/bash
# root
cd $HOME
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1AEM8vb1Ew4SnD8KtrdNDONZKyjXA1yw4' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1AEM8vb1Ew4SnD8KtrdNDONZKyjXA1yw4" -O file.tar.gz && rm -rf /tmp/cookies.txt
echo Download complite !
sleep 3
cd /
tar -xvf /root/file.tar.gz
cd $HOME
rm file.tar.gz
