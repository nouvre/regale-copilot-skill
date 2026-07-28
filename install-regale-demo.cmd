@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-copilot-user-assets.ps1"

if errorlevel 1 (
  echo.
  echo Install failed. Review the error above.
  pause
  exit /b 1
)

echo.
echo Install complete. Restart GitHub Copilot, then run /agent and select Regale Demo.
pause
