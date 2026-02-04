@echo off
setlocal
cd /d "%~dp0"

REM ==================================================
REM Ensure required directories exist
REM ==================================================
if not exist "%~dp0config" mkdir "%~dp0config"
if not exist "%~dp0Downloads" mkdir "%~dp0Downloads"
if not exist "%~dp0Downloads\logs" mkdir "%~dp0Downloads\logs"

REM ==================================================
REM Clean previous logs
REM ==================================================
del "%~dp0Downloads\logs\container.log" 2>nul
del "%~dp0Downloads\logs\build.log" 2>nul

REM ==================================================
REM Check Docker
REM ==================================================
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Starting Docker Desktop...

    if exist "C:\Program Files\Docker\Docker Desktop.exe" (
        start "" "C:\Program Files\Docker\Docker Desktop.exe"
    ) else if exist "C:\Program Files (x86)\Docker\Docker Desktop.exe" (
        start "" "C:\Program Files (x86)\Docker\Docker Desktop.exe"
    ) else (
        echo Docker Desktop not found.
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
        echo Docker did not start within 2 minutes.
        pause
        exit /b 1
    )
    timeout /t 2 >nul
    goto WAIT_DOCKER
)

echo Docker is running.
echo.

REM ==================================================
REM Build image if missing
REM ==================================================
docker image inspect yt-dlp-auto >nul 2>&1
if errorlevel 1 (
    echo Docker image not found. Building...

    docker build -t yt-dlp-auto . ^
        > "%~dp0Downloads\logs\build.log" 2>&1

    if errorlevel 1 (
        echo Docker build FAILED!
        echo See Downloads\logs\build.log
        pause
        exit /b 1
    )
)

REM ==================================================
REM Run container
REM ==================================================
echo Running yt-dlp container...

docker run --rm ^
  -v "%~dp0Downloads:/downloads" ^
  -v "%~dp0config:/config" ^
  yt-dlp-auto ^
  > "%~dp0Downloads\logs\container.log" 2>&1

set RUN_RC=%ERRORLEVEL%
if not "%RUN_RC%"=="0" (
    echo Container exited with errors.
    echo See Downloads\logs\container.log
    pause
    exit /b %RUN_RC%
)

REM ==================================================
REM Cleanup Downloads if no real content
REM ==================================================
set HASCONTENT=
for /f %%I in ('dir /b "%~dp0Downloads" ^| findstr /v /i logs') do set HASCONTENT=1
if not defined HASCONTENT (
    rd /s /q "%~dp0Downloads"
)

echo.
echo All done.
pause