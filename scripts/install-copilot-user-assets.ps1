param(
    # Normally auto-detected. Pass this only if detection fails, or to pick a specific
    # Regale install when several are present.
    [string]$RegaleMcpBridgePath,

    # Register every tool Regale Studio exposes instead of the demo-build subset below.
    # Use this if a build stops because a tool it needed was not registered — then tell us
    # which one, so it can be added to $DemoBuildTools.
    [switch]$AllTools,

    # Skip the "restart Copilot now?" question at the end.
    [switch]$NoRestartPrompt
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
    "save_project", "update_properties", "list_sections", "list_pages", "get_page", "remove_page",
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

$BridgeExeName = "regale-mcp-bridge.exe"

function Write-Check {
    param([bool]$Ok, [string]$Message, [string]$Detail)

    if ($Ok) {
        Write-Host "  [ok]   $Message" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $Message" -ForegroundColor Red
    }
    if ($Detail) {
        Write-Host "         $Detail" -ForegroundColor DarkGray
    }
}

# Locate regale-mcp-bridge.exe without making the user find it. Cheapest and most
# authoritative sources first: a Studio that is already running tells us exactly which
# install Copilot should talk to.
function Find-RegaleBridge {
    $candidates = New-Object System.Collections.Generic.List[string]

    # 1. A running Regale Studio — the bridge sits next to RegaleStudio.exe.
    foreach ($proc in @(Get-Process -Name "RegaleStudio" -ErrorAction SilentlyContinue)) {
        if ($proc.Path) {
            $candidates.Add((Join-Path (Split-Path $proc.Path -Parent) $BridgeExeName))
        }
    }

    # 2. Conventional install locations.
    $roots = @(
        $env:ProgramFiles,
        ${env:ProgramFiles(x86)},
        (Join-Path $env:LOCALAPPDATA "Programs")
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($root in $roots) {
        foreach ($name in @("Regale Studio UAT", "Regale Studio")) {
            $candidates.Add((Join-Path (Join-Path $root $name) $BridgeExeName))
        }
    }

    # 3. Whatever the uninstall registry recorded, for non-default install paths.
    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($key in $uninstallKeys) {
        foreach ($entry in @(Get-ItemProperty $key -ErrorAction SilentlyContinue)) {
            if ($entry.DisplayName -like "Regale*" -and $entry.InstallLocation) {
                $candidates.Add((Join-Path $entry.InstallLocation $BridgeExeName))
            }
        }
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -PathType Leaf $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    # 4. Last resort: a shallow scan of the Program Files roots.
    foreach ($root in $roots) {
        $hit = Get-ChildItem -Path $root -Filter $BridgeExeName -Recurse -Depth 2 `
            -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) {
            return $hit.FullName
        }
    }

    return $null
}

# The Copilot desktop app and CLI both read $env:USERPROFILE\.copilot. Do not use $HOME:
# PowerShell lets a HOME environment variable (Git Bash, WSL) override it, which would
# install the assets into a directory Copilot never reads.
function Get-CopilotProcesses {
    $installDir = Join-Path (Join-Path $env:LOCALAPPDATA "Programs") "GitHub Copilot"
    if (-not (Test-Path $installDir)) {
        return @()
    }

    return @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $path = $null
        try { $path = $_.Path } catch { }
        $path -and $path.StartsWith($installDir, [StringComparison]::OrdinalIgnoreCase)
    })
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$copilotHome = Join-Path $env:USERPROFILE ".copilot"
$agentTargetDir = Join-Path $copilotHome "agents"
$skillTargetDir = Join-Path $copilotHome "skills\demo"
$mcpConfigPath = Join-Path $copilotHome "mcp-config.json"

$agentSource = Join-Path $repoRoot ".github\agents\regale-demo.agent.md"
$skillSource = Join-Path $repoRoot ".github\skills\demo"

# ---------------------------------------------------------------------------
# Preflight — report everything that is wrong before writing anything, so the
# user fixes one list rather than rerunning the installer three times.
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Checking your machine..." -ForegroundColor Cyan

$problems = New-Object System.Collections.Generic.List[string]

$agentSourceOk = Test-Path -PathType Leaf $agentSource
Write-Check $agentSourceOk "Regale Demo agent file found"
if (-not $agentSourceOk) {
    $problems.Add("Agent file not found: $agentSource. Re-download this repository.")
}

$pipelineSource = Join-Path $skillSource "BUILD_PIPELINE.md"
$skillSourceOk = (Test-Path -PathType Container $skillSource) -and (Test-Path -PathType Leaf $pipelineSource)
Write-Check $skillSourceOk "Demo skill and BUILD_PIPELINE.md found"
if (-not $skillSourceOk) {
    $problems.Add("Skill files not found under: $skillSource. Re-download this repository.")
}

if ($RegaleMcpBridgePath) {
    if (Test-Path -PathType Leaf $RegaleMcpBridgePath) {
        $bridgePath = (Resolve-Path $RegaleMcpBridgePath).Path
    } else {
        $bridgePath = $null
        $problems.Add("No $BridgeExeName at the -RegaleMcpBridgePath you gave: $RegaleMcpBridgePath")
    }
} else {
    $bridgePath = Find-RegaleBridge
    if (-not $bridgePath) {
        $problems.Add("Could not find $BridgeExeName. Install Regale Studio UAT, or rerun with -RegaleMcpBridgePath ""C:\Path\To\$BridgeExeName"" (it sits beside RegaleStudio.exe).")
    }
}
Write-Check ([bool]$bridgePath) "Regale MCP bridge found" $bridgePath

# Copilot's own presence is advisory. The CLI can live outside the desktop app's
# directory, so a miss here is worth saying but is not worth blocking the install.
$copilotInstallDir = Join-Path (Join-Path $env:LOCALAPPDATA "Programs") "GitHub Copilot"
$copilotSeen = (Test-Path $copilotInstallDir) -or (Test-Path $copilotHome) -or
    [bool](Get-Command "copilot" -ErrorAction SilentlyContinue)
if ($copilotSeen) {
    Write-Check $true "GitHub Copilot found"
} else {
    Write-Host "  [warn] GitHub Copilot was not detected" -ForegroundColor Yellow
    Write-Host "         Installing anyway. Install and sign in to Copilot, then rerun this if the agent does not appear." -ForegroundColor DarkGray
}

if ($problems.Count -gt 0) {
    Write-Host ""
    Write-Host "Cannot install yet:" -ForegroundColor Red
    foreach ($problem in $problems) {
        Write-Host "  - $problem" -ForegroundColor Red
    }
    Write-Host ""
    exit 1
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Installing..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path $copilotHome | Out-Null
New-Item -ItemType Directory -Force -Path $agentTargetDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $skillTargetDir -Parent) | Out-Null

$agentTarget = Join-Path $agentTargetDir "regale-demo.agent.md"
Copy-Item -Force $agentSource $agentTarget

if (Test-Path $skillTargetDir) {
    Remove-Item -Recurse -Force $skillTargetDir
}
Copy-Item -Recurse -Force $skillSource $skillTargetDir

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
    command = $bridgePath
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

# ---------------------------------------------------------------------------
# Verify — read back what we just wrote. Most "Regale tools unavailable" reports
# are a config that never landed, and this is where that becomes visible.
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Verifying..." -ForegroundColor Cyan

$failures = New-Object System.Collections.Generic.List[string]

$agentOk = Test-Path -PathType Leaf $agentTarget
Write-Check $agentOk "Agent installed" $agentTarget
if (-not $agentOk) { $failures.Add("agent file") }

$pipelineTarget = Join-Path $skillTargetDir "BUILD_PIPELINE.md"
$skillOk = (Test-Path -PathType Leaf $pipelineTarget) -and
    (Test-Path -PathType Leaf (Join-Path $skillTargetDir "SKILL.md"))
Write-Check $skillOk "Skill installed" $skillTargetDir
if (-not $skillOk) { $failures.Add("skill files") }

$configOk = $false
try {
    $written = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
    $server = $written.mcpServers."regale-studio-uat"
    $configOk = $null -ne $server -and $server.command -eq $bridgePath -and
        (Test-Path -PathType Leaf $server.command)
} catch {
    $configOk = $false
}
Write-Check $configOk "MCP config valid and points at a real bridge" $mcpConfigPath
if (-not $configOk) { $failures.Add("MCP config") }

if ($AllTools) {
    Write-Host "         Registered ALL Regale tools (-AllTools). Builds will be slower." -ForegroundColor DarkGray
} else {
    Write-Host "         Registered $($DemoBuildTools.Count) of Regale's ~138 tools - the demo-build subset." -ForegroundColor DarkGray
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Install finished with problems: $($failures -join ', ')." -ForegroundColor Red
    Write-Host "Copy the output above when reporting it." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# ---------------------------------------------------------------------------
# Restart Copilot — it reads agents, skills, and MCP config only at startup, and
# closing the window is not enough. Offering it here removes the step people miss.
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "Install complete." -ForegroundColor Green

$copilotProcs = @(Get-CopilotProcesses)
$canPrompt = -not $NoRestartPrompt -and [Environment]::UserInteractive -and
    -not [Console]::IsInputRedirected

if ($copilotProcs.Count -eq 0) {
    Write-Host "Start GitHub Copilot, type /agent, and select Regale Demo."
} elseif (-not $canPrompt) {
    Write-Host "GitHub Copilot is running. Restart it fully (system tray -> Exit, then reopen)," -ForegroundColor Yellow
    Write-Host "then type /agent and select Regale Demo." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "GitHub Copilot is running and must be restarted to pick this up." -ForegroundColor Yellow
    $answer = Read-Host "Restart it now? Unsaved chats may be lost. [y/N]"

    if ($answer -match '^\s*y') {
        $exePath = $copilotProcs[0].Path
        foreach ($proc in $copilotProcs) {
            try { Stop-Process -Id $proc.Id -Force -ErrorAction Stop } catch { }
        }
        try {
            Start-Process -FilePath $exePath | Out-Null
            Write-Host "Restarted. Type /agent and select Regale Demo." -ForegroundColor Green
        } catch {
            Write-Host "Could not relaunch Copilot automatically. Start it yourself, then type /agent." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Restart Copilot yourself (system tray -> Exit, then reopen), then type /agent."
    }
}

Write-Host ""
