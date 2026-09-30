@echo off
:: Gather System Information
setlocal enabledelayedexpansion

:: Get current date and time for filename
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=!dt:~0,4!" & set "MM=!dt:~4,2!" & set "DD=!dt:~6,2!"
set "HH=!dt:~8,2!" & set "Min=!dt:~10,2!" & set "Sec=!dt:~12,2%"

:: Set file name
set "filename=info_%YY%%MM%%DD%_%HH%%Min%.txt"

:: Get info
echo ======================================== > %filename%
echo SYSTEM INFO DUMP >> %filename%
echo Date: %date% Time: %time% >> %filename%
echo ======================================== >> %filename%
echo. >> %filename%
echo Username: %USERNAME% >> %filename%
echo Computer Name: %COMPUTERNAME% >> %filename%
echo IP Address: >> %filename%
ipconfig /all | findstr /C:"IPv4" >> %filename% 2>nul
echo. >> %filename%
echo Drives Available: >> %filename%
wmic logicaldisk get caption,description,size >> %filename%

:: Copy to USB root (assuming C: is the drive letter of this USB)
copy %filename% %~dp0\%filename% >nul 2>&1

:: Optional: Hide the window
exit