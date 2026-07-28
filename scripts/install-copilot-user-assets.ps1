param(
    [string]$RegaleMcpBridgePath = "C:\Program Files\Regale Studio UAT\regale-mcp-bridge.exe"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$copilotHome = Join-Path $HOME ".copilot"
$agentTargetDir = Join-Path $copilotHome "agents"
$skillTargetDir = Join-Path $copilotHome "skills\demo"
$mcpConfigPath = Join-Path $copilotHome "mcp-config.json"

$agentSource = Join-Path $repoRoot ".github\agents\regale-demo.agent.md"
$skillSource = Join-Path $repoRoot ".github\skills\demo"

if (-not (Test-Path $agentSource)) {
    throw "Agent file not found: $agentSource"
}

if (-not (Test-Path $skillSource)) {
    throw "Skill directory not found: $skillSource"
}

if (-not (Test-Path $RegaleMcpBridgePath)) {
    Write-Warning "Regale MCP bridge was not found at '$RegaleMcpBridgePath'. Install Regale Studio UAT or rerun this script with -RegaleMcpBridgePath."
}

New-Item -ItemType Directory -Force -Path $agentTargetDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $skillTargetDir -Parent) | Out-Null

Copy-Item -Force $agentSource (Join-Path $agentTargetDir "regale-demo.agent.md")
if (Test-Path $skillTargetDir) {
    Remove-Item -Recurse -Force $skillTargetDir
}
Copy-Item -Recurse -Force $skillSource $skillTargetDir

New-Item -ItemType Directory -Force -Path $copilotHome | Out-Null

if (Test-Path $mcpConfigPath) {
    $mcpConfig = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
} else {
    $mcpConfig = [pscustomobject]@{}
}

if (-not $mcpConfig.PSObject.Properties.Name.Contains("mcpServers")) {
    $mcpConfig | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([pscustomobject]@{})
}

$serverConfig = [pscustomobject]@{
    type = "stdio"
    command = $RegaleMcpBridgePath
    args = @()
    tools = @("*")
}

if ($mcpConfig.mcpServers.PSObject.Properties.Name.Contains("regale-studio-uat")) {
    $mcpConfig.mcpServers.PSObject.Properties.Remove("regale-studio-uat")
}

$mcpConfig.mcpServers | Add-Member -MemberType NoteProperty -Name "regale-studio-uat" -Value $serverConfig

$json = $mcpConfig | ConvertTo-Json -Depth 20
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($mcpConfigPath, $json, $utf8NoBom)

Write-Host "Installed Regale Demo agent to: $(Join-Path $agentTargetDir "regale-demo.agent.md")"
Write-Host "Installed Regale Demo skill to: $skillTargetDir"
Write-Host "Updated Copilot MCP config: $mcpConfigPath"
Write-Host ""
Write-Host "Restart GitHub Copilot, then run /agent and select Regale Demo."
