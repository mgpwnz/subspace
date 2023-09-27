#!/bin/bash
# root
cd $HOME
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1qH4HnvWegoivNxkoEG3O0brsA4UdBmvn' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1qH4HnvWegoivNxkoEG3O0brsA4UdBmvn" -O file.tar.gz && rm -rf /tmp/cookies.txt
if [ ! -s /root/file.tar.gz ]; then
echo -e "\e[31mАрхів не завантаженно!!!\e[39m"
sleep 3
else
echo -e "\e[7mАрхів завантажено, йде розпаковка...\e[0m"
sleep 3
cd /
tar -xvf /root/file.tar.gz
cd $HOME
rm file.tar.gz
echo -e "\e[7mБаза готова до роботи.\e[0m"
fi
