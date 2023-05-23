#!/bin/bash
while true
do
read -r -p "Do you have erros? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        docker compose down
        docker compose pull
        docker compose up -d
        break
        ;;
    *)
        docker compose logs -f
        ;;
esac
done