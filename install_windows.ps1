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
