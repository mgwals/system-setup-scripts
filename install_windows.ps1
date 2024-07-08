# Function to install software based on the command
function Install-SoftwareWindows {
    param (
        [string]$SoftwareName,
        [string]$WindowsCmd
    )

    if ($WindowsCmd) {
        Write-Output "Installing $SoftwareName on Windows..."
        try {
            Invoke-Expression $WindowsCmd
        } catch {
            Write-Output "Failed to install $SoftwareName. Error: $_"
        }
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

# Function to enable Ultimate Performance power plan
function Enable-UltimatePerformancePowerPlan {
    Write-Output "Enabling Ultimate Performance power plan..."
    $powerPlanGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    powercfg -duplicatescheme $powerPlanGUID
    powercfg -setactive $powerPlanGUID
}

# Disable mouse acceleration
Disable-MouseAccel

# Set pagefile size to 20480 MB initial and 40960 MB maximum
Set-Pagefile -InitialSizeMB 20480 -MaximumSizeMB 40960

# Enable Ultimate Performance power plan
Enable-UltimatePerformancePowerPlan

Write-Output "====================="
Write-Output "Reminder: Perform the following tasks manually."
Write-Output "1. Install Colemak."
Write-Output "2. Change the monitor's refresh rate."
Write-Output "3. Enable night light."
Write-Output "====================="

# Read common software list from file if it exists
if (Test-Path software.txt) {
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
} else {
    Write-Output "software.txt file not found. Skipping software installation..."
}

Write-Output "Windows installation complete."

