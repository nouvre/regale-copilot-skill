param(
    [string]$RepoZipUrl = "https://github.com/nouvre/regale-copilot-skill/archive/refs/heads/main.zip",
    [string]$RegaleMcpBridgePath = "C:\Program Files\Regale Studio UAT\regale-mcp-bridge.exe"
)

$ErrorActionPreference = "Stop"

$workDir = Join-Path $env:TEMP ("regale-copilot-skill-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir "regale-copilot-skill.zip"
$extractDir = Join-Path $workDir "extract"

New-Item -ItemType Directory -Force -Path $workDir | Out-Null
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

try {
    Write-Host "Downloading latest Regale Demo Copilot setup..."
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $zipPath

    Write-Host "Extracting installer..."
    Expand-Archive -Force -Path $zipPath -DestinationPath $extractDir

    $installer = Get-ChildItem -Path $extractDir -Filter "install-copilot-user-assets.ps1" -Recurse | Select-Object -First 1
    if (-not $installer) {
        throw "Could not find install-copilot-user-assets.ps1 in downloaded package."
    }

    Write-Host "Installing Copilot agent, skill, and MCP configuration..."
    & $installer.FullName -RegaleMcpBridgePath $RegaleMcpBridgePath
} finally {
    if (Test-Path $workDir) {
        Remove-Item -Recurse -Force $workDir
    }
}
