param(
    [Parameter(Mandatory = $true)][string]$ProjectPath,
    [string]$OutputDirectory,
    [ValidateSet("all", "duplicates", "sequence", "setup-errors", "flow")]
    [string[]]$Audits = @("all"),
    [switch]$CreateBackup,
    [switch]$CreateAggressiveCopy
)

$ErrorActionPreference = "Stop"
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $env:TEMP ("regale-refinement-audits-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$inspector = Join-Path $PSScriptRoot "inspect-rglx.ps1"
$inspectionArgs = @{
    ProjectPath = $ProjectPath
    OutputDirectory = $OutputDirectory
}
if ($CreateBackup) { $inspectionArgs.CreateBackup = $true }
if ($CreateAggressiveCopy) { $inspectionArgs.CreateAggressiveCopy = $true }
& $inspector @inspectionArgs

$reportPath = Join-Path $OutputDirectory "report.json"
$selected = if ($Audits -contains "all") {
    @("duplicates", "sequence", "setup-errors", "flow")
} else {
    @($Audits | Select-Object -Unique)
}
$auditPaths = @()

foreach ($audit in $selected) {
    $script = Join-Path $PSScriptRoot "audit-$audit.ps1"
    $auditPath = Join-Path $OutputDirectory "audit-$audit.json"
    & $script -ReportPath $reportPath -OutputPath $auditPath
    $auditPaths += $auditPath
}

$planPath = Join-Path $OutputDirectory "refinement-plan.json"
& (Join-Path $PSScriptRoot "merge-refinement-plan.ps1") `
    -ReportPath $reportPath -AuditPaths $auditPaths -OutputPath $planPath

Write-Output "Audit workspace: $OutputDirectory"
Write-Output "Selected audits: $($selected -join ', ')"
