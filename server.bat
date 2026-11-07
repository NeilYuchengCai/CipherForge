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

rem Auto-detect a Python interpreter that has fastapi and uvicorn
set "PYTHON="

for %%p in (python python3 py) do (
    for /f "delims=" %%i in ('where %%p 2^>nul') do (
        "%%i" -c "import fastapi, uvicorn" >nul 2>&1
        if not errorlevel 1 (
            set "PYTHON=%%i"
            goto :found
        )
    )
)

for %%d in (
    "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    "C:\Python313\python.exe"
    "C:\Python312\python.exe"
    "C:\Python311\python.exe"
) do (
    if exist %%d (
        "%%d" -c "import fastapi, uvicorn" >nul 2>&1
        if not errorlevel 1 (
            set "PYTHON=%%d"
            goto :found
        )
    )
)

echo Error: No Python with FastAPI/Uvicorn found!
echo Install: pip install fastapi uvicorn
pause
exit /b 1

:found
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
