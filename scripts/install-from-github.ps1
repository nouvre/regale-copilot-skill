param(
    [string]$RepoZipUrl = "https://github.com/nouvre/regale-copilot-skill/archive/refs/heads/main.zip",

    # Normally auto-detected. Pass this only if detection fails.
    [string]$RegaleMcpBridgePath,

    # Register every Regale tool instead of the demo-build subset. Use this only if a
    # build stopped because a tool was not registered.
    [switch]$AllTools
)

$ErrorActionPreference = "Stop"

# TLS 1.2 is not the default on stock Windows PowerShell 5.1; without this the download
# from GitHub fails with a connection error that reads like a network outage.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$workDir = Join-Path $env:TEMP ("regale-copilot-skill-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir "regale-copilot-skill.zip"
$extractDir = Join-Path $workDir "extract"

New-Item -ItemType Directory -Force -Path $workDir | Out-Null
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

try {
    Write-Host "Downloading latest Regale Demo Copilot setup..."
    Invoke-WebRequest -UseBasicParsing -Uri $RepoZipUrl -OutFile $zipPath

    Write-Host "Extracting installer..."
    Expand-Archive -Force -Path $zipPath -DestinationPath $extractDir

    $installer = Get-ChildItem -Path $extractDir -Filter "install-copilot-user-assets.ps1" -Recurse |
        Select-Object -First 1
    if (-not $installer) {
        throw "Could not find install-copilot-user-assets.ps1 in downloaded package."
    }

    # Files extracted from an internet download carry a mark-of-the-web that can block
    # execution regardless of execution policy.
    Get-ChildItem -Path $extractDir -Filter "*.ps1" -Recurse | Unblock-File

    $installerArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $installer.FullName)
    if ($RegaleMcpBridgePath) {
        $installerArgs += @("-RegaleMcpBridgePath", $RegaleMcpBridgePath)
    }
    if ($AllTools) {
        $installerArgs += "-AllTools"
    }

    & powershell.exe @installerArgs
    exit $LASTEXITCODE
} finally {
    if (Test-Path $workDir) {
        Remove-Item -Recurse -Force $workDir -ErrorAction SilentlyContinue
    }
}
