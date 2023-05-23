#!/bin/bash
while true
do
docker compose down -v
read -r -p "Do you have errors? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo -e "Try again"
        ;;
    *)
        echo Remove directory
        break
        ;;
esac
done