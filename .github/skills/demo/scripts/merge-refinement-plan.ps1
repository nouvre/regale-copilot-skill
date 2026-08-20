param(
    [Parameter(Mandatory = $true)][string]$ReportPath,
    [Parameter(Mandatory = $true)][string[]]$AuditPaths,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "refinement-audit-common.ps1")
$report = Read-RefinementReport $ReportPath
if (-not $OutputPath) { $OutputPath = Join-Path (Split-Path $ReportPath -Parent) "refinement-plan.json" }

$auditDocuments = @()
foreach ($path in $AuditPaths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Audit result not found: $path" }
    $auditDocuments += Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

$allFindings = @($auditDocuments | ForEach-Object { @($_.findings) })
$allReviewItems = @($auditDocuments | ForEach-Object { @($_.reviewItems) })
$sectionContracts = @($auditDocuments | ForEach-Object { @($_.sectionContracts) })
$globallyProtected = @($allFindings | ForEach-Object { @($_.protectedPageIds) } | Where-Object { $_ } | Select-Object -Unique)
$planPages = @()

foreach ($page in @($report.pages | Sort-Object sectionNumber, pageNumber)) {
    $pageFindings = @($allFindings | Where-Object pageId -eq $page.pageId)
    $removeFindings = @($pageFindings | Where-Object {
        $_.proposedVerdict -eq "Remove" -and $_.confidence -eq "high"
    })
    $reviewFindings = @($pageFindings | Where-Object proposedVerdict -eq "Review")
    $retargets = @($removeFindings | ForEach-Object { $_.retargetPageId } | Where-Object { $_ } | Select-Object -Unique)
    $isProtected = $globallyProtected -contains [string]$page.pageId
    $hasRetargetConflict = $retargets.Count -gt 1

    $verdict = "Keep"
    $reason = "no focused audit proposed removal or review"
    if ($removeFindings.Count -gt 0 -and -not $isProtected -and -not $hasRetargetConflict) {
        $verdict = "Remove"
        $reason = @($removeFindings | ForEach-Object { [string]$_.reason } | Select-Object -Unique) -join "; "
    } elseif ($reviewFindings.Count -gt 0 -or
        ($removeFindings.Count -gt 0 -and $isProtected) -or
        $hasRetargetConflict) {
        $verdict = "Review"
        $reasons = @($reviewFindings | ForEach-Object { [string]$_.reason })
        if ($isProtected) { $reasons += "page is a protected survivor for another finding" }
        if ($hasRetargetConflict) { $reasons += "audits proposed conflicting navigation targets" }
        if ($reasons.Count -eq 0) { $reasons += "focused audit finding requires flow validation" }
        $reason = @($reasons | Select-Object -Unique) -join "; "
    } elseif ($isProtected) {
        $reason = "protected survivor for a focused audit removal"
    }

    $planPages += [pscustomobject]@{
        sectionNumber = [int]$page.sectionNumber
        sectionTitle = [string]$page.sectionTitle
        pageNumber = [int]$page.pageNumber
        pageId = [string]$page.pageId
        proposedVerdict = $verdict
        reason = $reason
        retargetPageId = if ($retargets.Count -eq 1) { [string]$retargets[0] } else { $null }
        findingIds = [object[]]@($pageFindings | ForEach-Object { [string]$_.findingId })
        findingTypes = [object[]]@($pageFindings | ForEach-Object { [string]$_.type } | Select-Object -Unique)
    }
}

$plan = [pscustomobject]@{
    schemaVersion = 1
    projectPath = [string]$report.projectPath
    projectSha256 = [string]$report.projectSha256
    reportPath = (Resolve-Path -LiteralPath $ReportPath).Path
    backupPath = [string]$report.backupPath
    aggressiveCopyPath = [string]$report.aggressiveCopyPath
    generatedAt = (Get-Date).ToString("o")
    audits = [object[]]@($auditDocuments | ForEach-Object { [string]$_.audit })
    counts = [pscustomobject]@{
        pages = $planPages.Count
        keep = @($planPages | Where-Object proposedVerdict -eq "Keep").Count
        remove = @($planPages | Where-Object proposedVerdict -eq "Remove").Count
        review = @($planPages | Where-Object proposedVerdict -eq "Review").Count
        visualReviewWindows = $allReviewItems.Count
    }
    pages = [object[]]$planPages
    visualReviewItems = [object[]]$allReviewItems
    sectionContracts = [object[]]$sectionContracts
}
$plan | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8

Write-Output "Refinement plan: $OutputPath"
Write-Output "Verdicts: Keep $($plan.counts.keep), Remove $($plan.counts.remove), Review $($plan.counts.review)"
Write-Output "Visual sequence windows: $($plan.counts.visualReviewWindows)"
