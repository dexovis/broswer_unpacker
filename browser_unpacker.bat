@echo off
setlocal enabledelayedexpansion

:: 1. CONFIGURATION
set "VER=138.0.7204.303"
set "URL=https://github.com/Alex313031/Thorium-Win/releases/download/M%VER%/thorium_AVX_%VER%.zip"
set "ZIP_PATH=%USERPROFILE%\Downloads\temp_download.zip"
set "EXTRACT_DIR=%USERPROFILE%\Downloads\BrowserApp"
set "LAUNCHER_PATH=%USERPROFILE%\Downloads\Launch_Browser.bat"

echo ===========================================
echo   Browser Auto-Installer (No Admin)
echo ===========================================

:: 2. DOWNLOAD (Optimized for speed)
echo [1/4] Downloading...
powershell -Command "& { $ProgressPreference = 'SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_PATH%' -UserAgent 'Mozilla/5.0' }"

if not exist "%ZIP_PATH%" (
    echo ERROR: Download failed. Check your connection.
    pause
    exit /b
)

:: 3. EXTRACT
echo [2/4] Extracting...
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"
:: Fixed this line to actually unzip the file
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%EXTRACT_DIR%' -Force"
del "%ZIP_PATH%"

:: 4. RENAME (Thorium -> Browser)
echo [3/4] Renaming instances to 'browser'...
powershell -Command "Get-ChildItem -Path '%EXTRACT_DIR%' -Recurse | Sort-Object {$_.FullName.Length} -Descending | ForEach-Object { $newName = $_.Name -ireplace 'thorium', 'browser'; if ($_.Name -ne $newName) { Rename-Item -Path $_.FullName -NewName $newName } }"

:: 5. CREATE LAUNCHER WITH CLOUDFLARE DNS FLAGS
echo [4/4] Creating Launcher with Cloudflare DNS...
set "EXE_PATH="
for /r "%EXTRACT_DIR%" %%f in (browser.exe) do (
    set "EXE_PATH=%%f"
)

if defined EXE_PATH (
    echo @echo off > "%LAUNCHER_PATH%"
    echo start "" "!EXE_PATH!" --enable-features="dns-over-https<DoHTrial" --force-fieldtrials="DoHTrial/Group1" --force-fieldtrial-params="DoHTrial.Group1:server/https%%3A%%2F%%2F1.1.1.1%%2Fdns-query/method/POST" >> "%LAUNCHER_PATH%"
    
    echo.
    echo SUCCESS!
    echo - Cloudflare DNS is forced via the launcher flags.
    echo - Run 'Launch_Browser.bat' in your Downloads to start.
) else (
    echo ERROR: Could not find browser.exe. Check if extraction worked.
)

pause