@echo off
cd /d "%~dp0"

REM -------------------------------
REM Ensure config, Downloads, logs exist
REM -------------------------------
if not exist "%~dp0config" mkdir "%~dp0config"
if not exist "%~dp0Downloads" mkdir "%~dp0Downloads"
if not exist "%~dp0Downloads\logs" mkdir "%~dp0Downloads\logs"

REM -------------------------------
REM Delete previous container log
REM -------------------------------
if exist "%~dp0Downloads\logs\container.log" del "%~dp0Downloads\logs\container.log"

REM -------------------------------
REM Delete .built file to force rebuild if needed
REM -------------------------------
if exist "%~dp0yt-dlp-auto.built" del "%~dp0yt-dlp-auto.built"

REM -------------------------------
REM Check Docker
REM -------------------------------
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Starting Docker Desktop...
    if exist "C:\Program Files\Docker\Docker Desktop.exe" (
        start "" "C:\Program Files\Docker\Docker Desktop.exe"
    ) else if exist "C:\Program Files (x86)\Docker\Docker Desktop.exe" (
        start "" "C:\Program Files (x86)\Docker\Docker Desktop.exe"
    ) else (
        echo Docker Desktop not found. Please install Docker Desktop.
        pause
        exit /b 1
    )
)

echo Waiting for Docker to be ready...
set WAIT_COUNT=0
:WAIT_DOCKER
docker info >nul 2>&1
if errorlevel 1 (
    set /a WAIT_COUNT+=1
    if %WAIT_COUNT% GEQ 60 (
        echo Docker did not start within 2 minutes. Exiting.
        pause
        exit /b 1
    )
    timeout /t 2 >nul
    goto WAIT_DOCKER
)
echo Docker is running.

REM -------------------------------
REM Build Docker image if missing
REM -------------------------------
docker image inspect yt-dlp-auto >nul 2>&1
if errorlevel 1 (
    echo Docker image yt-dlp-auto not found, building...
    docker build -t yt-dlp-auto . > "%~dp0Downloads\logs\container.log" 2>&1
    if errorlevel 1 (
        echo Docker build FAILED! Check container.log for details.
        if exist "%~dp0yt-dlp-auto.built" del "%~dp0yt-dlp-auto.built"
        exit /b 1
    )
    type nul > "%~dp0yt-dlp-auto.built"
)

REM -------------------------------
REM Run container and save log
REM -------------------------------
echo Running yt-dlp container...
docker run --rm ^
  -v "%~dp0Downloads:/downloads" ^
  -v "%~dp0config:/config" ^
  yt-dlp-auto > "%~dp0Downloads\logs\container.log" 2>&1

REM -------------------------------
REM Cleanup empty Downloads folder
REM -------------------------------
set HASFILES=
for /f %%I in ('dir /b "%~dp0Downloads"') do set HASFILES=1
if not defined HASFILES (
    rd /s /q "%~dp0Downloads"
)

echo All done.
pause