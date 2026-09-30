@echo off
:: =========================================================
:: Wi-Fi Password Extractor & File Exporter
:: =========================================================

:: 1. Define the output file name (you can change this)
set "OUTPUT_FILE=WiFi_Passwords.txt"

:: Clear the output file if it already exists
> "%OUTPUT_FILE%" echo ========================================
>> "%OUTPUT_FILE%" echo   Saved Wi-Fi Passwords
>> "%OUTPUT_FILE%" echo   Date: %date% %time%
>> "%OUTPUT_FILE%" echo ========================================
>> "%OUTPUT_FILE%" echo.

:: 2. Get all Wi-Fi Profile Names
:: We use 'netsh wlan show profiles' to list them
for /f "skip=9 tokens=4 delims= " %%a in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    
    :: 3. For each profile, get the password
    for /f "tokens=4 delims=: " %%b in ('netsh wlan show profile name="%%a" key=clear ^| findstr "Key Content"') do (
        
        :: 4. Write to the console AND the file
        echo SSID: %%a | Password: %%b
        
        :: Append to the output file
        echo ---------------------------------------- >> "%OUTPUT_FILE%"
        echo SSID: %%a >> "%OUTPUT_FILE%"
        echo Password: %%b >> "%OUTPUT_FILE%"
    )
)

:: 5. Add a footer to the file
echo. >> "%OUTPUT_FILE%"
echo ======================================== >> "%OUTPUT_FILE%"
echo   Extraction Complete >> "%OUTPUT_FILE%"
echo ======================================== >> "%OUTPUT_FILE%"

:: 6. Open the file so you can see it immediately
start "" "%OUTPUT_FILE%"

pause