@echo off
title CipherForge CLI
echo ==========================================
echo   CipherForge CLI
echo ==========================================
echo.
echo Generating a sample password...
echo.

rem Auto-detect a Python interpreter that can import the cipherforge package
set "PYTHON="

for %%p in (python python3 py) do (
    for /f "delims=" %%i in ('where %%p 2^>nul') do (
        "%%i" -c "import cipherforge" >nul 2>&1
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
        "%%d" -c "import cipherforge" >nul 2>&1
        if not errorlevel 1 (
            set "PYTHON=%%d"
            goto :found
        )
    )
)

echo Error: No Python with the cipherforge package found!
echo Install dependencies: pip install -r requirements.txt
pause
exit /b 1

:found
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
