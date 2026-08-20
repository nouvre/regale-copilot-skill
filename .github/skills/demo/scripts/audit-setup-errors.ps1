param(
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "refinement-audit-common.ps1")
$report = Read-RefinementReport $ReportPath
if (-not $OutputPath) { $OutputPath = Join-Path (Split-Path $ReportPath -Parent) "audit-setup-errors.json" }
$findings = @()

foreach ($page in @($report.pages | Sort-Object sectionNumber, pageNumber)) {
    $reasons = @($page.qualityReviewReasons)
    if ($reasons -contains "onboarding-or-setup-text") {
        $findings += New-RefinementFinding -Audit "setup-errors" -Type "setup-or-onboarding" `
            -Page $page -ProposedVerdict "Review" -Confidence "medium" `
            -Reason "page contains onboarding, first-run, sign-in, or setup text" `
            -Evidence @{ textSignals = [object[]]@($page.textSignals); thumbnailPath = [string]$page.thumbnailPath }
    }
    if ($reasons -contains "blocked-or-error-text") {
        $findings += New-RefinementFinding -Audit "setup-errors" -Type "blocked-or-error" `
            -Page $page -ProposedVerdict "Review" -Confidence "medium" `
            -Reason "page contains blocked, error, no-result, or failure text" `
            -Evidence @{ textSignals = [object[]]@($page.textSignals); thumbnailPath = [string]$page.thumbnailPath }
    }
}

$document = Write-RefinementAudit -Audit "setup-errors" -ReportPath $ReportPath `
    -OutputPath $OutputPath -Findings $findings
Write-Output "Setup/error audit: $OutputPath"
Write-Output "Findings: $($document.findings.Count)"
