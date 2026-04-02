@echo off
setlocal enabledelayedexpansion

:: 1. CONFIGURATION
set "VER=138.0.7204.303"
set "URL=https://github.com/Alex313031/Thorium-Win/releases/download/M%VER%/thorium_AVX_%VER%.zip"
set "ZIP_PATH=%temp%\thorium_temp.zip"
set "EXTRACT_DIR=%USERPROFILE%\Downloads\ThoriumBrowser"
set "BIN_DIR=%EXTRACT_DIR%\BIN"
set "USER_DATA_DIR=%EXTRACT_DIR%\USER_DATA"
set "LAUNCHER_PATH=%USERPROFILE%\Downloads\Launch_Thorium.bat"

echo ===========================================
echo   Thorium Portable Installer (No Admin)
echo ===========================================

:: 2. DOWNLOAD
echo [1/5] Downloading...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%URL%', '%ZIP_PATH%')"

:: 3. EXTRACT
echo [2/5] Extracting...
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%EXTRACT_DIR%' -Force"
del "%ZIP_PATH%"

:: 4. SETUP USER DATA & FIRST RUN
echo [3/5] Setting up User Data...
if not exist "%USER_DATA_DIR%" mkdir "%USER_DATA_DIR%"
:: Creating the "First Run" file inside USER_DATA to skip setup screens
type nul > "%USER_DATA_DIR%\First Run"

:: 5. LOCATE THE EXE IN BIN
echo [4/5] Locating thorium.exe...
set "EXE_PATH=%BIN_DIR%\thorium.exe"

:: Verify if the path exists, if not, search for it
if not exist "!EXE_PATH!" (
    for /r "%EXTRACT_DIR%" %%f in (thorium.exe) do set "EXE_PATH=%%f"
)

:: 6. CREATE THE PORTABLE LAUNCHER
echo [5/5] Creating Launcher...
(
echo @echo off
echo START "" "!EXE_PATH!" --user-data-dir="%USER_DATA_DIR%" --allow-outdated-plugins --disable-logging --disable-breakpad --disable-encryption --disable-machine-id --enable-features="dns-over-https<DoHTrial" --force-fieldtrials="DoHTrial/Group1" --force-fieldtrial-params="DoHTrial.Group1:server/https%%3A%%2F%%2F1.1.1.1%%2Fdns-query/method/POST"
) > "%LAUNCHER_PATH%"

echo.
echo SUCCESS! 
echo - Browser binary: !EXE_PATH!
echo - 'First Run' file: %USER_DATA_DIR%\First Run
echo - Use 'Launch_Thorium.bat' in your Downloads to start.
pause
