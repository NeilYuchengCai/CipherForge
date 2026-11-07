@echo off
title CipherForge GUI
echo Starting CipherForge GUI...
echo.

rem Auto-detect a Python interpreter that has tkinter support
set "PYTHON="

for %%p in (python python3 py) do (
    for /f "delims=" %%i in ('where %%p 2^>nul') do (
        "%%i" -c "import tkinter" >nul 2>&1
        if not errorlevel 1 (
            set "PYTHON=%%i"
            goto :found
        )
    )
)

rem Fallback: common system install locations
for %%d in (
    "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
    "C:\Python313\python.exe"
    "C:\Python312\python.exe"
    "C:\Python311\python.exe"
    "C:\Python310\python.exe"
) do (
    if exist %%d (
        "%%d" -c "import tkinter" >nul 2>&1
        if not errorlevel 1 (
            set "PYTHON=%%d"
            goto :found
        )
    )
)

echo Error: No Python with tkinter found!
echo Please install Python 3.10+ from https://python.org (tick "tkinter" / "tcl/tk")
pause
exit /b 1

:found
echo Using: %PYTHON%
"%PYTHON%" "%~dp0gui.py"
if errorlevel 1 (
    echo.
    echo Failed to start GUI.
    pause
)
