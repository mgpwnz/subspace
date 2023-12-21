#!/bin/bash

total_steps=10
current_step=0

function progress_bar() {
  local progress=$((current_step * 100 / total_steps))
  local bar_size=$((progress / 2))
  local color='\e[32m'  # ANSI-код для зеленого кольору
  local reset='\e[0m'   # ANSI-код для скидання кольору

  printf "[${color}%-50s${reset}] ${color}%d%%${reset}\r" $(printf "#%.0s" $(seq 1 $bar_size)) $progress
}

# Ваші команди по крокам
for ((i=0; i<total_steps; i++)); do
  # Ваш код для кожного кроку
  sleep 1  # Приклад затримки
  ((current_step++))
  progress_bar
done

echo -e "\nСкрипт виконано!"