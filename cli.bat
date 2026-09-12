@echo off
title CipherForge CLI
echo ==========================================
echo   CipherForge CLI
echo ==========================================
echo.
echo Generating a sample password...
echo.

rem Use system Python with tkinter support
set "PYTHON=C:\Users\Administrator\AppData\Local\Programs\Python\Python313\python.exe"

if not exist "%PYTHON%" (
    echo Error: System Python not found!
    pause
    exit /b 1
)

"%PYTHON%" "%~dp0cli.py" passgen --length 16
echo.
echo Usage examples:
echo   python cli.py passgen --length 12
echo   python cli.py hash --algo SHA-256 --text hello
echo   python cli.py encrypt --algo AES-256-GCM --password xxx --in f.txt --out f.enc
echo.
echo Type python cli.py --help for full usage
echo ==========================================
pause
