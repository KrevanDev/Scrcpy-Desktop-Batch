@echo off
setlocal enabledelayedexpansion
cls

:: ==========================================
::  Configuration Variables
:: ==========================================
REM Set Window Display Resolution/DPI
set RES_DPI=1560x1008/180

REM Set Window Title
set TITLE=Scrcpy Android Desktop Mode

REM Scrcpy Input Options
set OPTIONS=-Sw --always-on-top

:: ==========================================
::  Create Display
:: ==========================================
echo [1/3] Creating overlay display...
adb shell settings put global overlay_display_devices %RES_DPI% > nul 2>&1

REM Delay for creating the display
timeout /t 2 /nobreak > nul

:: ==========================================
::  Detect Display ID
:: ==========================================
echo [2/3] Searching for Display ID...

set "dID="

scrcpy --list-displays > "%TEMP%\displays.txt" 2> nul

for /f "tokens=2 delims==" %%A in ('findstr /C:"--display-id=" "%TEMP%\displays.txt"') do (
    set "dID=%%A"
)

for /f "tokens=1 delims= " %%B in ("%dID%") do set "dID=%%B"

del "%TEMP%\displays.txt" > nul 2>&1

if "%dID%"=="" (
    echo [ERR] Could not find a valid Display ID
    echo     - Ensure Developer Options are enabled
    echo     - Ensure USB debugging is allowed
    pause
    exit /b
)

echo [OK] Found Display ID: %dID%

:: ==========================================
::  Launch Scrcpy Window
:: ==========================================
echo [3/3] Launching Scrcpy...
echo.

scrcpy --display-id %dID% -K -M %OPTIONS% --window-title="%TITLE%"

:: ==========================================
::  Cleanup after closing window
:: ==========================================
echo.

adb shell settings put global overlay_display_devices "null" 2>&1
echo [OK] Overlay display destroyed.
echo.

echo Would you like to reboot your device to reset display ids?
choice /C YN /T 5 /D N /M "If no input, will automatically choose NO in 5s."
if errorlevel 2 goto :EOF
adb reboot
echo Rebooting device...

exit /b
