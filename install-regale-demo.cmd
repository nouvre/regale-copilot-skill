@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-copilot-user-assets.ps1" %*

if errorlevel 1 (
  echo.
  echo Install failed. Review the messages above.
)

pause
