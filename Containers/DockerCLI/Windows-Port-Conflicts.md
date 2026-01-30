# Overview

Many a times when you try to deploy/run a docker container you get port conflict warnings. However, you are very sure that you have not allocated the port to another container nor have any windows services running on those ports (verified via `netstat -ano | findstr :<port>`).

The next likely culprit would be Windows (WinNat) have resrved the port for WSL or whatever.

In this case, you should stop WSL and Docker (Desktop and services) and restart WinNat.

Example batch script:
```batch
@echo off
setlocal

echo Checking Docker Desktop engine...

docker info >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo Docker Desktop is running. Stopping Docker Desktop...

    REM Stop Docker backend processes
    taskkill /IM "Docker Desktop.exe" /F >nul 2>&1
    taskkill /IM "com.docker.backend.exe" /F >nul 2>&1
    taskkill /IM "vpnkit.exe" /F >nul 2>&1

    REM Shutdown WSL VM used by Docker
    wsl --shutdown >nul 2>&1

    echo Docker Desktop stopped.
) ELSE (
    echo Docker Desktop is not running.
)

echo Restarting WinNAT service...

net stop winnat >nul 2>&1
timeout /t 2 >nul
net start winnat >nul 2>&1

IF %ERRORLEVEL% EQU 0 (
    echo WinNAT restarted successfully.
) ELSE (
    echo Failed to restart WinNAT. Ensure script is run as Administrator.
)

echo Done.
endlocal
```
> You need to run this as Administrator

Also found here: https://github.com/hafio/solace/blob/main/broker/standalone-4-nodes/restart-winnat.bat
