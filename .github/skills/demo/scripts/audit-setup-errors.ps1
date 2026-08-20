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
        $signals = @($page.textSignals)
        $isExplicitFirstRun = @($signals | Where-Object {
            $_ -match "welcome to (the )?new"
        }).Count -gt 0
        if ($isExplicitFirstRun -and $page.nextPageId) {
            $findings += New-RefinementFinding -Audit "setup-errors" -Type "explicit-first-run-onboarding" `
                -Page $page -ProposedVerdict "Remove" -Confidence "high" `
                -Reason "explicit first-run welcome page precedes a retained usable successor" `
                -RetargetPageId ([string]$page.nextPageId) `
                -ProtectedPageIds @([string]$page.nextPageId) `
                -Evidence @{ textSignals = [object[]]$signals; thumbnailPath = [string]$page.thumbnailPath }
        } else {
            $findings += New-RefinementFinding -Audit "setup-errors" -Type "setup-or-onboarding-review" `
                -Page $page -ProposedVerdict "Review" -Confidence "medium" `
                -Reason "page contains sign-in, setup, or ambiguous onboarding text" `
                -Evidence @{ textSignals = [object[]]$signals; thumbnailPath = [string]$page.thumbnailPath }
        }
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
