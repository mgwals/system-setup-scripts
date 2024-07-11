# System Setup Scripts

This repository contains scripts to automate the setup and configuration of software on Windows (using PowerShell) and Arch Linux (using Bash). 

## Files

- `install_windows.ps1`: PowerShell script to disable mouse acceleration, configure pagefile settings, enable the Ultimate Performance power plan, and install software on Windows.
- `install_arch.sh`: Bash script to install software on Arch Linux using pacman or yay.
- `software.txt`: Template file for users to list software to be installed with respective Windows and Arch Linux commands.

## Usage

### Windows

1. Open PowerShell as Administrator.
2. Run the `install_windows.ps1` script:
   ```powershell
   .\install_windows.ps1
   ```

### Arch Linux

1. Make the script executable:
   ```sh
   chmod +x install_arch.sh
   ```
2. Fill in the `software.txt` file with the software you want to install.
   - Follow the format: `software_name|windows_command|arch_command`
   - Example:
     ```text
     # VLC Media Player
     vlc|winget install -e --id VideoLAN.VLC|sudo pacman -S --noconfirm vlc
     ```
3. Run the `install_arch.sh` script:
   ```sh
   ./install_arch.sh
   ```

## software.txt Format

The `software.txt` file should contain entries in the following format:
```
software_name|windows_command|arch_command
```

### Supported Package Managers

- **Windows:** `winget`
- **Arch Linux:** `pacman`, `yay`

### Example Entries:
```
# VLC Media Player
vlc|winget install -e --id VideoLAN.VLC|sudo pacman -S --noconfirm vlc

# Brave Browser
brave|winget install -e --id Brave.Brave|yay -S --noconfirm brave-bin
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
