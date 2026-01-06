@echo off
REM Build standalone Windows .exe using PyInstaller
REM Requirements (run once):
REM   pip install pyinstaller yt-dlp

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

pyinstaller ^
  --onefile ^
  --noconsole ^
  --name "yt-downloader" ^
  main.py

echo.
echo Build complete. Executable is in the "dist" folder as yt-downloader.exe
pause


