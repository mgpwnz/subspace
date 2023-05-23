#!/bin/bash
while true
do
docker compose down
docker compose pull
docker compose up -d
read -r -p "Do you have errors? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo -e "You node \e[7mReinstall\e[0m"
        ;;
    *)
        docker compose logs -f
        break
        ;;
esac
done