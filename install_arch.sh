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

# Disable mouse acceleration in Sway
disable_mouse_accel_sway() {
  echo "Disabling mouse acceleration in Sway..."

  # Add configuration in sway config to disable mouse acceleration
  sway_config="$HOME/.config/sway/config"

  # Ensure the config directory exists
  mkdir -p "$(dirname "$sway_config")"

  # Append mouse acceleration settings to the sway config
  echo "input * {
    accel_profile flat
}" >> "$sway_config"

  echo "Mouse acceleration has been disabled. Please reload Sway configuration."
}

# Setup BorgBackup automation with systemd
setup_borgbackup_systemd() {
  echo "Setting up BorgBackup automation with systemd..."

  # Replace these placeholders with your actual HDD mount point
  local hdd_mount_point="/mnt/external"  # Change this to your actual mount point
  local hdd_service_path="/etc/systemd/system/borg-backup.service"
  local hdd_timer_path="/etc/systemd/system/borg-backup.timer"

  # Create systemd service file
  sudo bash -c "cat > $hdd_service_path <<EOL
[Unit]
Description=Borg Backup Service
Wants=borg-backup.timer
ConditionPathExists=${hdd_mount_point}

[Service]
Type=oneshot
ExecStart=/usr/bin/borg create --progress --stats ${hdd_mount_point}/::backup-{now:%Y-%m-%d} /home
EOL"

  # Create systemd timer file
  sudo bash -c "cat > $hdd_timer_path <<EOL
[Unit]
Description=Run Borg Backup periodically

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOL"

  # Enable and start the timer
  sudo systemctl enable borg-backup.timer
  sudo systemctl start borg-backup.timer

  echo "BorgBackup automation setup complete."
}

# Determine if the system is running Sway
if pgrep -x "sway" > /dev/null; then
  disable_mouse_accel_sway
else
  echo "Mouse acceleration configuration not applied. This script supports Sway."
fi

# Read common software list from file
while IFS="|" read -r software_name windows_cmd arch_cmd; do
  # Skip lines that are comments or empty
  [[ "$software_name" =~ ^#.*$ ]] && continue
  [ -z "$software_name" ] && continue
  install_software_arch "$software_name" "$arch_cmd"
done < software.txt

# Setup BorgBackup automation
setup_borgbackup_systemd

echo "Arch Linux installation complete."
