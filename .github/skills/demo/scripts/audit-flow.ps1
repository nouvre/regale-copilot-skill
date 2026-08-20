param(
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "refinement-audit-common.ps1")
$report = Read-RefinementReport $ReportPath
if (-not $OutputPath) { $OutputPath = Join-Path (Split-Path $ReportPath -Parent) "audit-flow.json" }
$contracts = @()

foreach ($section in @($report.sections | Sort-Object sectionNumber)) {
    $pages = @($report.pages | Where-Object sectionNumber -eq $section.sectionNumber | Sort-Object pageNumber)
    if ($pages.Count -eq 0) { continue }
    $entry = $pages[0]
    $outcome = $pages[$pages.Count - 1]
    $actionPages = @($pages | Where-Object {
        $_.hasBuildTimeline -or @($_.navigation).Count -gt 0
    })
    $contracts += [pscustomobject]@{
        sectionNumber = [int]$section.sectionNumber
        sectionId = [string]$section.sectionId
        sectionTitle = [string]$section.sectionTitle
        originalPageCount = [int]$section.originalPageCount
        minimumRetainedPages = [int]$section.minimumRetainedPages
        automaticRemovalLimit = [int]$section.automaticRemovalLimit
        entryPageId = [string]$entry.pageId
        actionCandidatePageIds = [object[]]@($actionPages | ForEach-Object { [string]$_.pageId })
        outcomeCandidatePageId = [string]$outcome.pageId
        pagesWithInboundNavigation = [object[]]@($pages | Where-Object inboundNavigationCount -gt 0 | ForEach-Object { [string]$_.pageId })
        pagesWithLockedInboundNavigation = [object[]]@($pages | Where-Object inboundLockedNavigationCount -gt 0 | ForEach-Object { [string]$_.pageId })
        validationStatus = "requires-visual-entry-action-outcome-confirmation"
    }
}

$document = Write-RefinementAudit -Audit "flow" -ReportPath $ReportPath `
    -OutputPath $OutputPath -SectionContracts $contracts
Write-Output "Flow audit: $OutputPath"
Write-Output "Section contracts: $($document.sectionContracts.Count)"
