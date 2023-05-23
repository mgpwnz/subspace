#!/bin/bash
function update {
docker compose down
docker compose pull
docker compose up -d
}
function logs {
docker compose logs -f
}
read -r -p "Do you have erros? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        update
        break
        ;;
    *)
        logs
        ;;
esac