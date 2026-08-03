param(
    [string]$RegaleMcpBridgePath = "C:\Program Files\Regale Studio UAT\regale-mcp-bridge.exe",

    # Register every tool Regale Studio exposes instead of the demo-build subset below.
    # Use this if a build stops because a tool it needed was not registered — then tell us
    # which one, so it can be added to $DemoBuildTools.
    [switch]$AllTools
)

$ErrorActionPreference = "Stop"

# Regale Studio 5.1 exposes ~138 MCP tools. Registering all of them costs roughly 55,000
# tokens of context on EVERY model request, and a build is 60-100 requests — so the whole
# catalogue is re-sent about eighty times per demo, slowing each step down.
#
# This is the subset BUILD_PIPELINE.md actually calls, including both documented fallback
# paths (the explicit capture loop and native screen capture). Verified against the live
# tool registry of Regale Studio 5.1.0.0.
#
# If you add a step to BUILD_PIPELINE.md that calls a new tool, add it here too.
# Permission-gated tools (save_project) are listed even though Studio hides them until the
# matching Regale permission is on — an allowlist entry for a hidden tool is harmless.
$DemoBuildTools = @(
    # Preconditions, project, and structure
    "get_agent_permissions", "get_open_project", "open_project", "new_project",
    "save_project", "update_properties", "list_sections", "list_pages", "get_page",
    "add_section", "set_selection", "set_text", "get_theme",

    # Capture profiles and sign-in
    "list_capture_profiles", "create_capture_profile", "switch_capture_profile",

    # HTML Capturer window
    "open_html_capturer", "close_html_capturer", "navigate_capturer",
    "wait_for_capturer", "get_capturer_state", "set_capture_size_mode",
    "pause_page_motion", "capture_view", "diagnose_page",

    # Driving the live page
    "list_elements", "get_element", "query_dom", "click_element",
    "click_at_coordinate", "hover_element", "scroll_view", "press_keys", "type_text",
    "set_input_value", "set_element_text", "set_element_image",

    # Build recording (the default capture path)
    "start_build_recording", "stop_build_recording", "get_recording_state",

    # Explicit capture loop and beacons (fallback)
    "capture_html_page", "get_shapes", "instantiate_theme_shape", "anchor_shape",
    "render_page",

    # Native screen capture (advanced fallback)
    "list_capture_targets", "set_capture_target", "set_capture_mode", "start_capture",
    "end_capture", "set_studio_window", "get_studio_window"
)

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

$mcpConfig = [pscustomobject]@{}
if (Test-Path $mcpConfigPath) {
    $rawMcpConfig = Get-Content $mcpConfigPath -Raw
    if (-not [string]::IsNullOrWhiteSpace($rawMcpConfig)) {
        try {
            $parsedMcpConfig = $rawMcpConfig | ConvertFrom-Json
            if ($null -ne $parsedMcpConfig) {
                $mcpConfig = $parsedMcpConfig
            }
        } catch {
            $backupPath = "$mcpConfigPath.bak"
            Copy-Item -Force $mcpConfigPath $backupPath
            Write-Warning "Existing MCP config could not be parsed. Backed it up to '$backupPath' and created a fresh config."
        }
    }
}

if (@($mcpConfig.PSObject.Properties.Name) -notcontains "mcpServers") {
    $mcpConfig | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([pscustomobject]@{})
}

if ($AllTools) {
    $toolList = @("*")
} else {
    $toolList = $DemoBuildTools
}

$serverConfig = [pscustomobject]@{
    type = "stdio"
    command = $RegaleMcpBridgePath
    args = @()
    tools = $toolList
}

if (@($mcpConfig.mcpServers.PSObject.Properties.Name) -contains "regale-studio-uat") {
    $mcpConfig.mcpServers.PSObject.Properties.Remove("regale-studio-uat")
}

$mcpConfig.mcpServers | Add-Member -MemberType NoteProperty -Name "regale-studio-uat" -Value $serverConfig

$json = $mcpConfig | ConvertTo-Json -Depth 20
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($mcpConfigPath, $json, $utf8NoBom)

Write-Host "Installed Regale Demo agent to: $(Join-Path $agentTargetDir "regale-demo.agent.md")"
Write-Host "Installed Regale Demo skill to: $skillTargetDir"
Write-Host "Updated Copilot MCP config: $mcpConfigPath"
if ($AllTools) {
    Write-Host "  Registered ALL Regale tools (-AllTools). Builds will be slower."
} else {
    Write-Host "  Registered $($DemoBuildTools.Count) of Regale's ~138 tools - the demo-build subset."
    Write-Host "  If a build stops because a tool is missing, rerun with -AllTools and report which one."
}
Write-Host ""
Write-Host "Restart GitHub Copilot, then run /agent and select Regale Demo."
