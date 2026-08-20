param(
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "refinement-audit-common.ps1")
$report = Read-RefinementReport $ReportPath
if (-not $OutputPath) { $OutputPath = Join-Path (Split-Path $ReportPath -Parent) "audit-duplicates.json" }
$findings = @()

foreach ($page in @($report.pages | Sort-Object sectionNumber, pageNumber)) {
    if ($page.redundantLeadInCandidate) {
        $findings += New-RefinementFinding -Audit "duplicates" -Type "redundant-lead-in" `
            -Page $page -ProposedVerdict "Remove" -Confidence "high" `
            -Reason ([string]$page.redundantLeadInReason) `
            -RetargetPageId ([string]$page.redundantLeadInSuccessorPageId) `
            -ProtectedPageIds @([string]$page.redundantLeadInSuccessorPageId) `
            -Evidence @{
                thumbnailSha256 = [string]$page.thumbnailSha256
                timelineDurationMs = [int64]$page.buildTimelineDurationMs
                successorPageId = [string]$page.redundantLeadInSuccessorPageId
            }
        continue
    }

    if ($page.packageEquivalentToPrevious) {
        $retarget = if ($page.nextPageId) { [string]$page.nextPageId } else { [string]$page.sequencePreviousPageId }
        $findings += New-RefinementFinding -Audit "duplicates" -Type "package-equivalent-duplicate" `
            -Page $page -ProposedVerdict "Remove" -Confidence "high" `
            -Reason "adjacent page is package-equivalent to its predecessor" `
            -RetargetPageId $retarget `
            -ProtectedPageIds @([string]$page.sequencePreviousPageId, $retarget) `
            -Evidence @{
                previousPageId = [string]$page.sequencePreviousPageId
                thumbnailSha256 = [string]$page.thumbnailSha256
            }
        continue
    }

    if ($page.thumbnailMatchesPrevious) {
        $previous = @($report.pages | Where-Object pageId -eq $page.sequencePreviousPageId | Select-Object -First 1)
        if ($previous.Count -gt 0 -and
            $previous[0].redundantLeadInCandidate -and
            $previous[0].redundantLeadInSuccessorPageId -eq $page.pageId) {
            continue
        }
        $findings += New-RefinementFinding -Audit "duplicates" -Type "visual-duplicate-review" `
            -Page $page -ProposedVerdict "Review" -Confidence "low" `
            -Reason "starting thumbnail exactly matches the predecessor, but package state differs" `
            -ProtectedPageIds @([string]$page.sequencePreviousPageId) `
            -Evidence @{
                previousPageId = [string]$page.sequencePreviousPageId
                packageEquivalent = $false
            }
    }
}

$document = Write-RefinementAudit -Audit "duplicates" -ReportPath $ReportPath `
    -OutputPath $OutputPath -Findings $findings
Write-Output "Duplicate audit: $OutputPath"
Write-Output "Findings: $($document.findings.Count)"
