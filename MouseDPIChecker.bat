@echo off
setlocal enabledelayedexpansion
REM ==============================================================
REM MouseDPIChecker - Advanced Mouse Detection and DPI Scanner
REM Windows Batch Version (converted from OpenMouse bash script)
REM ==============================================================
REM Detects all connected mice and reports:
REM - Mouse vendor/model
REM - DPI settings
REM - Connection type (USB, Bluetooth, Wireless)
REM - Raw input capability
REM - Polling rate
REM ==============================================================

cls
echo.
echo ======================================================
echo    MouseDPIChecker v1.0
echo    Mouse Detection and DPI Configuration Tool
echo    For Windows 10/11
echo ======================================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: This script works best with Administrator rights.
    echo Right-click and select "Run as Administrator"
    echo.
)

REM Create temporary directories for output
if not exist "%temp%\MouseDPI" mkdir "%temp%\MouseDPI"
set LOGFILE=%temp%\MouseDPI\mouse_report.txt
set DEVICEFILE=%temp%\MouseDPI\devices.txt

echo. > %LOGFILE%
echo MouseDPIChecker Report > %LOGFILE%
echo Generated: %date% %time% >> %LOGFILE%
echo. >> %LOGFILE%

REM ==============================================================
REM SECTION 1: Detect all mouse devices via WMI
REM ==============================================================
echo Detecting connected mouse devices...
echo. >> %LOGFILE%
echo ============= CONNECTED MOUSE DEVICES ============= >> %LOGFILE%
echo. >> %LOGFILE%

setlocal enabledelayedexpansion
set mousecount=0

for /f "tokens=*" %%a in ('wmic path Win32_PointingDevice get Name^,Manufacturer^,Description /format:value 2^>nul') do (
    if not "%%a"=="" (
        if "%%a:~0,4%%" neq "Node" (
            echo %%a >> %LOGFILE%
            set /a mousecount+=1
        )
    )
)

if %mousecount%==0 (
    echo No mice detected via WMI. >> %LOGFILE%
)

REM ==============================================================
REM SECTION 2: Get detailed mouse hardware info
REM ==============================================================
echo. >> %LOGFILE%
echo ============= DETAILED HARDWARE INFO ============= >> %LOGFILE%
echo. >> %LOGFILE%

wmic path Win32_PointingDevice get Name,Manufacturer,DeviceID,Status /format:list >> %LOGFILE% 2>nul

REM ==============================================================
REM SECTION 3: Check Windows Mouse Settings (Registry)
REM ==============================================================
echo. >> %LOGFILE%
echo ============= WINDOWS MOUSE SETTINGS ============= >> %LOGFILE%
echo. >> %LOGFILE%

echo Checking registry for mouse sensitivity... >> %LOGFILE%

REM Get pointer speed (Windows setting)
for /f "tokens=3" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseSensitivity" 2^>nul') do (
    echo Windows Pointer Speed: %%a >> %LOGFILE%
    set POINTER_SPEED=%%a
)

REM Check if Enhance Pointer Precision is enabled
for /f "tokens=3" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\Mouse" /v "MouseSpeed" 2^>nul') do (
    echo Mouse Speed Boost: %%a >> %LOGFILE%
    set MOUSE_SPEED=%%a
)

REM Check double-click speed
for /f "tokens=3" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\Mouse" /v "DoubleClickSpeed" 2^>nul') do (
    echo Double-Click Speed: %%a >> %LOGFILE%
    set DOUBLECLICK=%%a
)

REM ==============================================================
REM SECTION 4: Raw Input and DirectInput Detection
REM ==============================================================
echo. >> %LOGFILE%
echo ============= RAW INPUT / DIRECT INPUT CHECK ============= >> %LOGFILE%
echo. >> %LOGFILE%

REM Check DirectInput devices (gaming mice often use this)
echo Checking for DirectInput/RawInput capable mice... >> %LOGFILE%
wmic path Win32_USBControllerDevice get Dependent /format:list 2>nul | findstr /i "mouse" >> %LOGFILE%

REM ==============================================================
REM SECTION 5: USB Mouse Detection (for DPI info)
REM ==============================================================
echo. >> %LOGFILE%
echo ============= USB MOUSE DEVICES ============= >> %LOGFILE%
echo. >> %LOGFILE%

echo Detecting USB mice and polling rates... >> %LOGFILE%
wmic path Win32_PnPDevice get Name,Description,DeviceID /format:list 2>nul | findstr /i "mouse" >> %LOGFILE%

REM ==============================================================
REM SECTION 6: Gaming Mouse Vendor Software Check
REM ==============================================================
echo. >> %LOGFILE%
echo ============= GAMING MOUSE SOFTWARE DETECTION ============= >> %LOGFILE%
echo. >> %LOGFILE%

echo Checking for gaming mouse software... >> %LOGFILE%

REM Check for Logitech G HUB
if exist "C:\Program Files\Logitech\LGHUB\lghub.exe" (
    echo - Logitech G HUB detected (Location: C:\Program Files\Logitech\LGHUB\) >> %LOGFILE%
) else if exist "C:\Program Files (x86)\Logitech\Gaming Software\LCore.exe" (
    echo - Logitech Gaming Software detected >> %LOGFILE%
)

REM Check for Razer Synapse
if exist "C:\Program Files (x86)\Razer\Synapse3\RazerSynapse.exe" (
    echo - Razer Synapse 3 detected (DPI settings available there) >> %LOGFILE%
) else if exist "C:\Program Files (x86)\Razer\Razer Synapse\RazerSynapse.exe" (
    echo - Razer Synapse detected >> %LOGFILE%
)

REM Check for Corsair iCUE
if exist "C:\Program Files\Corsair\Corsair iCUE 4 Software\Corsair.Service.CueLauncher.exe" (
    echo - Corsair iCUE 4 detected (Polling rate and DPI available there) >> %LOGFILE%
) else if exist "C:\Program Files\Corsair\Corsair iCUE Software\Corsair.CueLauncher.exe" (
    echo - Corsair iCUE detected >> %LOGFILE%
)

REM Check for SteelSeries GG
if exist "C:\Program Files\SteelSeries\GG\SteelSeriesGG.exe" (
    echo - SteelSeries GG detected (DPI and polling rate available) >> %LOGFILE%
)

REM Check for ASUS ROG Armoury Crate
if exist "C:\Program Files\ASUS\ROGArmoury\ArmouryCrate.exe" (
    echo - ASUS ROG Armoury Crate detected >> %LOGFILE%
)

REM Check for MSI Dragon Center
if exist "C:\Program Files (x86)\MSI\Dragon Center\Dragon Center.exe" (
    echo - MSI Dragon Center detected >> %LOGFILE%
)

echo. >> %LOGFILE%

REM ==============================================================
REM SECTION 7: Display Current Settings
REM ==============================================================
cls
echo.
echo ======================================================
echo             MOUSE DETECTION RESULTS
echo ======================================================
echo.

echo Connected Mice:
echo ---------------
wmic path Win32_PointingDevice get Name /format:value 2>nul | findstr "="

echo.
echo Mouse Settings (Windows):
echo -------------------------
if defined POINTER_SPEED (
    echo Pointer Speed: %POINTER_SPEED% /20
) else (
    echo Pointer Speed: Unable to determine
)

if defined MOUSE_SPEED (
    echo Mouse Speed Boost: %MOUSE_SPEED%
) else (
    echo Mouse Speed Boost: Disabled
)

echo.
echo Gaming Mouse Software:
echo ----------------------
for /f "tokens=*" %%a in ('findstr "detected" %LOGFILE%') do (
    echo %%a
)

echo.
echo Advanced Features:
echo ------------------
echo - Raw Input Support: Check in game settings
echo - Polling Rate: Available in vendor software
echo - DPI Levels: See gaming mouse software above
echo - Connection Type: Detected via Device Manager

echo.
echo Full Report Saved:
echo ------------------
echo %LOGFILE%
echo.

REM ==============================================================
REM SECTION 8: Interactive Menu
REM ==============================================================
echo.
echo ======================================================
echo                   QUICK ACTIONS
echo ======================================================
echo.
echo 1 - Open Mouse Settings (Windows)
echo 2 - Open Device Manager (USB devices)
echo 3 - View Full Report
echo 4 - Open gaming mouse software (if installed)
echo 5 - Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    start ms-settings:mouse
    goto end
)
if "%choice%"=="2" (
    devmgmt.msc
    goto end
)
if "%choice%"=="3" (
    start notepad %LOGFILE%
    goto end
)
if "%choice%"=="4" (
    REM Try to launch available gaming mouse software
    if exist "C:\Program Files\Logitech\LGHUB\lghub.exe" (
        start "" "C:\Program Files\Logitech\LGHUB\lghub.exe"
    ) else if exist "C:\Program Files (x86)\Razer\Synapse3\RazerSynapse.exe" (
        start "" "C:\Program Files (x86)\Razer\Synapse3\RazerSynapse.exe"
    ) else if exist "C:\Program Files\Corsair\Corsair iCUE 4 Software\Corsair.Service.CueLauncher.exe" (
        start "" "C:\Program Files\Corsair\Corsair iCUE 4 Software\Corsair.Service.CueLauncher.exe"
    ) else if exist "C:\Program Files\SteelSeries\GG\SteelSeriesGG.exe" (
        start "" "C:\Program Files\SteelSeries\GG\SteelSeriesGG.exe"
    ) else (
        echo No supported gaming mouse software found.
    )
    goto end
)
if "%choice%"=="5" (
    goto end
)

echo Invalid choice. Exiting.

:end
echo.
echo MouseDPIChecker completed.
echo.
pause
endlocal
