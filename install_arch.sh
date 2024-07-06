#!/bin/bash

# Function to install software based on the command
install_software_arch() {
  local software_name="$1"
  local arch_cmd="$2"

  if [ -n "$arch_cmd" ]; then
    echo "Installing $software_name on Arch Linux..."
    eval "$arch_cmd"
  else
    echo "Skipping $software_name on Arch Linux (not available)."
  fi
}

# Read common software list from file
while IFS="|" read -r software_name windows_cmd arch_cmd; do
  # Skip lines that are comments or empty
  [[ "$software_name" =~ ^#.*$ ]] && continue
  [ -z "$software_name" ] && continue
  install_software_arch "$software_name" "$arch_cmd"
done < software.txt

echo "Installation complete."
