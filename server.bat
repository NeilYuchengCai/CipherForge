@echo off
title CipherForge Web Server
echo ==========================================
echo   CipherForge Web Server
echo ==========================================
echo.
echo Please select an option:
echo.
echo   [1] Start Localhost  (http://127.0.0.1:8000)
echo   [2] Start LAN        (will show your IP)
echo   [3] Stop server
echo   [q] Quit
echo.
set /p MODE=Select (1/2/3/q):
if /i "%MODE%"=="q" goto :eof
if /i "%MODE%"=="3" (
    echo.
    echo Stopping CipherForge server...
    taskkill /f /im uvicorn.exe 2>nul
    taskkill /f /fi "WINDOWTITLE eq CipherForge*" /im python.exe 2>nul
    echo Server stopped.
    pause
    goto :eof
)

rem Use system Python with tkinter support
set "PYTHON=C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe"

if not exist "%PYTHON%" (
    echo Error: System Python not found!
    echo Install fastapi and uvicorn: pip install fastapi uvicorn
    pause
    exit /b 1
)

echo Using: %PYTHON%
echo.
if /i "%MODE%"=="2" (
    echo Starting LAN mode...
    "%PYTHON%" "%~dp0server.py" --host 0.0.0.0
) else if /i "%MODE%"=="1" (
    echo Starting localhost mode...
    "%PYTHON%" "%~dp0server.py"
) else (
    echo Invalid option.
)
if errorlevel 1 (
    echo.
    echo Error: startup failed
    pause
)
goto :eof
