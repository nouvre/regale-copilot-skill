@echo off
setlocal

rem Use this only if a build stopped with "that tool isn't available".
rem It registers all ~138 Regale tools instead of the demo-build subset, which makes
rem every build step slower. Please report which tool was missing so it can be added
rem to the default list, then switch back by running install-regale-demo.cmd.

echo Installing with ALL Regale tools registered (slower builds).
echo Use install-regale-demo.cmd instead unless a build reported a missing tool.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-copilot-user-assets.ps1" -AllTools

if errorlevel 1 (
  echo.
  echo Install failed. Review the messages above.
)

pause
