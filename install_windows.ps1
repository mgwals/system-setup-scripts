# Function to install software based on the command
function Install-SoftwareWindows {
    param (
        [string]$SoftwareName,
        [string]$WindowsCmd
    )

    if ($WindowsCmd) {
        Write-Output "Installing $SoftwareName on Windows..."
        Invoke-Expression $WindowsCmd
    } else {
        Write-Output "Skipping $SoftwareName on Windows (not available)."
    }
}

# Function to disable mouse acceleration
function Disable-MouseAccel {
    Write-Output "Disabling mouse acceleration..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
}

# Function to configure pagefile settings
function Set-Pagefile {
    param (
        [int]$InitialSizeMB,
        [int]$MaximumSizeMB
    )

    Write-Output "Configuring pagefile settings..."

    # Get the current pagefile setting
    $pagefile = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='C:\\pagefile.sys'"

    if ($pagefile -eq $null) {
        # Create a new pagefile setting if it doesn't exist
        $class = [WmiClass]"\\.\root\cimv2:Win32_PageFileSetting"
        $pagefile = $class.CreateInstance()
        $pagefile.Name = "C:\\pagefile.sys"
    }

    # Set custom pagefile size
    $pagefile.InitialSize = $InitialSizeMB
    $pagefile.MaximumSize = $MaximumSizeMB

    # Commit the changes
    $result = $pagefile.Put()

    if ($result.ReturnValue -eq 0) {
        Write-Output "Pagefile settings updated successfully."
    } else {
        Write-Output "Failed to update pagefile settings. Error code: $($result.ReturnValue)"
    }
}

# Disable mouse acceleration
Disable-MouseAccel

# Set pagefile size to 20480 MB initial and 40960 MB maximum
Set-Pagefile -InitialSizeMB 20480 -MaximumSizeMB 40960

Write-Output "====================="
Write-Output "Remember to change the monitor's refresh rate manually to the highest available."
Write-Output "====================="

# Read common software list from file
Get-Content software.txt | ForEach-Object {
    # Skip lines that are comments or empty
    if ($_ -match '^#.*$' -or [string]::IsNullOrWhiteSpace($_)) {
        return
    }

    $entry = $_ -split '[|]'
    $softwareName = $entry[0]
    $windowsCmd = $entry[1]
    $archCmd = $entry[2]  # Ignore Arch command

    Install-SoftwareWindows -SoftwareName $softwareName -WindowsCmd $windowsCmd
}

Write-Output "Installation complete."
