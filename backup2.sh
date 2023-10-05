#!/bin/bash
# root
cd $HOME
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1U17u_eXhJjN-hQrCPH4E1IxTLkb7vh3W' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1U17u_eXhJjN-hQrCPH4E1IxTLkb7vh3W" -O file.tar.gz && rm -rf /tmp/cookies.txt
echo Download complite !
sleep 3
cd /
tar -xvf /root/file.tar.gz
cd $HOME
rm file.tar.gz
