#!/bin/bash

# Default variables
function="install"
version=gemini-3g-2023-dec-20

# Options
option_value() { echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }

# Progress bar function
progress_bar() {
  local progress="$1"
  local length=50
  local percentage=$((progress * 100 / length))
  local bar=""
  local fill_length=$((progress * length / 100))

  for ((i=0; i<fill_length; i++)); do
    bar+="="
  done

  printf "[%-50s] %d%%\r" "$bar" "$percentage"
}

# Download and execute the script directly with a progress bar
wget --quiet -O - https://github.com/mgpwnz/subspace/blob/main/sub_adv.sh | {
  progress=0
  while read -r line; do
    progress_bar "$progress"
    ((progress++))
  done
  echo -e "\n"  # Move to the next line after progress bar completion
} | bash -s -- "$@"
