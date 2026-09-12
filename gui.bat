@echo off
title CipherForge GUI
echo Starting CipherForge GUI...
echo.

rem Use system Python with tkinter support
set "PYTHON=C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe"

if not exist "%PYTHON%" (
    echo Error: System Python not found!
    echo Looking for: %PYTHON%
    pause
    exit /b 1
)

"%PYTHON%" "%~dp0gui.py"
if errorlevel 1 (
    echo.
    echo Failed to start GUI.
    pause
)
