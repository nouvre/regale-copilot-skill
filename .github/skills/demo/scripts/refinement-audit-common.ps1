function Read-RefinementReport {
    param([Parameter(Mandatory = $true)][string]$ReportPath)

    if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) {
        throw "Refinement report not found: $ReportPath"
    }
    return Get-Content -LiteralPath $ReportPath -Raw | ConvertFrom-Json
}

function New-RefinementFinding {
    param(
        [Parameter(Mandatory = $true)][string]$Audit,
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter(Mandatory = $true)]$Page,
        [Parameter(Mandatory = $true)][ValidateSet("Remove", "Review")][string]$ProposedVerdict,
        [Parameter(Mandatory = $true)][ValidateSet("high", "medium", "low")][string]$Confidence,
        [Parameter(Mandatory = $true)][string]$Reason,
        [string]$RetargetPageId,
        [string[]]$ProtectedPageIds = @(),
        [hashtable]$Evidence = @{}
    )

    return [pscustomobject]@{
        findingId = "$Audit-$Type-$($Page.pageId)"
        audit = $Audit
        type = $Type
        sectionNumber = [int]$Page.sectionNumber
        sectionTitle = [string]$Page.sectionTitle
        pageNumber = [int]$Page.pageNumber
        pageId = [string]$Page.pageId
        proposedVerdict = $ProposedVerdict
        confidence = $Confidence
        reason = $Reason
        retargetPageId = $RetargetPageId
        protectedPageIds = [object[]]@($ProtectedPageIds | Where-Object { $_ } | Select-Object -Unique)
        evidence = [pscustomobject]$Evidence
    }
}

function Write-RefinementAudit {
    param(
        [Parameter(Mandatory = $true)][string]$Audit,
        [Parameter(Mandatory = $true)][string]$ReportPath,
        [Parameter(Mandatory = $true)][string]$OutputPath,
        [object[]]$Findings = @(),
        [object[]]$ReviewItems = @(),
        [object[]]$SectionContracts = @()
    )

    $document = [pscustomobject]@{
        schemaVersion = 1
        audit = $Audit
        reportPath = (Resolve-Path -LiteralPath $ReportPath).Path
        generatedAt = (Get-Date).ToString("o")
        findings = [object[]]@($Findings)
        reviewItems = [object[]]@($ReviewItems)
        sectionContracts = [object[]]@($SectionContracts)
    }
    $document | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    return $document
}
