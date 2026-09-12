@echo off
title CipherForge Interactive CLI
echo ==========================================
echo   CipherForge Interactive CLI
echo ==========================================
echo.
echo Starting interactive CLI...
echo Type help for available commands
echo.

rem Use system Python with tkinter support
set "PYTHON=C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe"

if not exist "%PYTHON%" (
    echo Error: System Python not found!
    pause
    exit /b 1
)

"%PYTHON%" "%~dp0cipherforge_cli.py"
if errorlevel 1 (
    echo.
    echo Error: startup failed
    pause
)
