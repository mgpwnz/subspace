#!/bin/bash
while true
do
docker compose down
docker compose pull
docker compose up -d
read -r -p "Do you have errors? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        docker compose down
        docker compose pull
        docker compose up -d
        ;;
    *)
        docker compose logs -f
        break
        ;;
esac
done