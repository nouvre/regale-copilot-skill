param(
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "refinement-audit-common.ps1")
$report = Read-RefinementReport $ReportPath
if (-not $OutputPath) { $OutputPath = Join-Path (Split-Path $ReportPath -Parent) "audit-sequence.json" }
$findings = @()
$reviewItems = @()

foreach ($page in @($report.pages | Where-Object promptHandoffCandidate | Sort-Object sectionNumber, pageNumber)) {
    $findings += New-RefinementFinding -Audit "sequence" -Type "prompt-handoff" `
        -Page $page -ProposedVerdict "Remove" -Confidence "high" `
        -Reason ([string]$page.promptHandoffReason) `
        -RetargetPageId ([string]$page.promptHandoffSuccessorPageId) `
        -ProtectedPageIds @([string]$page.promptHandoffSuccessorPageId) `
        -Evidence @{
            terminalComposerTexts = [object[]]@($page.terminalComposerTexts)
            terminalChatOutputCount = [int]$page.terminalChatOutputCount
            successorPageId = [string]$page.promptHandoffSuccessorPageId
        }
}

foreach ($window in @($report.sequenceWindows | Sort-Object sectionNumber, currentPageNumber)) {
    $currentPage = @($report.pages | Where-Object pageId -eq $window.currentPageId | Select-Object -First 1)
    if ($currentPage.Count -gt 0 -and $currentPage[0].promptHandoffCandidate) { continue }
    $reviewItems += [pscustomobject]@{
        type = "ordered-screenshot-window"
        sectionNumber = [int]$window.sectionNumber
        sectionTitle = [string]$window.sectionTitle
        currentPageNumber = [int]$window.currentPageNumber
        currentPageId = [string]$window.currentPageId
        previousPageId = [string]$window.previousPageId
        nextPageId = [string]$window.nextPageId
        sequenceWindowPath = [string]$window.sequenceWindowPath
        decision = "Review CURRENT (DECIDE) for visible story continuity"
    }
}

$document = Write-RefinementAudit -Audit "sequence" -ReportPath $ReportPath `
    -OutputPath $OutputPath -Findings $findings -ReviewItems $reviewItems
Write-Output "Sequence audit: $OutputPath"
Write-Output "Deterministic findings: $($document.findings.Count)"
Write-Output "Visual review windows: $($document.reviewItems.Count)"
