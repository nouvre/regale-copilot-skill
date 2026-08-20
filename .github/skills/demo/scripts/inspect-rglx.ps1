param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$OutputDirectory,

    [switch]$CreateBackup,

    [switch]$CreateAggressiveCopy
)

$ErrorActionPreference = "Stop"

if ($CreateAggressiveCopy -and -not $CreateBackup) {
    throw "Aggressive refinement requires -CreateBackup."
}

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
    throw "Regale project not found: $ProjectPath"
}

$resolvedProjectPath = Resolve-Path -LiteralPath $ProjectPath
$projectFile = [string]$resolvedProjectPath.ProviderPath
if ([string]::IsNullOrWhiteSpace($projectFile)) {
    $projectFile = [string]$resolvedProjectPath.Path
}
$isUncPath = $projectFile.StartsWith("\\")
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectFile)
if ($CreateAggressiveCopy -and (
    $projectName -match "\.aggressive-refine-\d{8}-\d{6}" -or
    (Split-Path $projectFile -Parent) -like "*\Regale\Aggressive Refinements"
)) {
    throw "The open project is already an aggressive refinement copy. Open the original source project before starting another aggressive refinement."
}
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $env:TEMP "regale-refinement-$stamp"
}

$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$thumbnailRoot = Join-Path $outputRoot "thumbnails"
New-Item -ItemType Directory -Force -Path $thumbnailRoot | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem

$backupPath = $null
if ($CreateBackup) {
    $projectDirectory = Split-Path $projectFile -Parent
    $backupName = "$projectName.pre-refine-$stamp.rglx"
    $fallbackDirectory = Join-Path $env:LOCALAPPDATA "Regale\Backups"
    $backupPath = if ($isUncPath) {
        New-Item -ItemType Directory -Force -Path $fallbackDirectory | Out-Null
        Join-Path $fallbackDirectory $backupName
    } else {
        Join-Path $projectDirectory $backupName
    }

    try {
        Copy-Item -LiteralPath $projectFile -Destination $backupPath -ErrorAction Stop
    } catch {
        New-Item -ItemType Directory -Force -Path $fallbackDirectory | Out-Null
        $backupPath = Join-Path $fallbackDirectory $backupName
        Copy-Item -LiteralPath $projectFile -Destination $backupPath -ErrorAction Stop
    }

    if (-not (Test-Path -LiteralPath $backupPath -PathType Leaf)) {
        throw "Pre-refinement backup was not created."
    }
    $sourceLength = (Get-Item -LiteralPath $projectFile).Length
    $backupLength = (Get-Item -LiteralPath $backupPath).Length
    if ($sourceLength -ne $backupLength) {
        throw "Pre-refinement backup size does not match the source project."
    }
    $backupArchive = [System.IO.Compression.ZipFile]::OpenRead($backupPath)
    try {
        if ($null -eq $backupArchive.GetEntry("Project.xml")) {
            throw "Pre-refinement backup is not a valid Regale project package."
        }
    } finally {
        $backupArchive.Dispose()
    }
}

$aggressiveCopyPath = $null
if ($CreateAggressiveCopy) {
    $aggressiveDirectory = Join-Path $env:LOCALAPPDATA "Regale\Aggressive Refinements"
    New-Item -ItemType Directory -Force -Path $aggressiveDirectory | Out-Null
    $aggressiveName = "$projectName.aggressive-refine-$stamp.rglx"
    $aggressiveCopyPath = Join-Path $aggressiveDirectory $aggressiveName
    Copy-Item -LiteralPath $projectFile -Destination $aggressiveCopyPath -ErrorAction Stop

    $sourceLength = (Get-Item -LiteralPath $projectFile).Length
    $aggressiveLength = (Get-Item -LiteralPath $aggressiveCopyPath).Length
    if ($sourceLength -ne $aggressiveLength) {
        throw "Aggressive refinement copy size does not match the source project."
    }
    $aggressiveArchive = [System.IO.Compression.ZipFile]::OpenRead($aggressiveCopyPath)
    try {
        if ($null -eq $aggressiveArchive.GetEntry("Project.xml")) {
            throw "Aggressive refinement copy is not a valid Regale project package."
        }
    } finally {
        $aggressiveArchive.Dispose()
    }
}

# Some UNC providers, including Parallels' \\Mac\... shares, allow PowerShell copies but
# reject .NET ZipFile random access. Normal local Windows paths are inspected directly.
$inspectionFile = $projectFile
if ($isUncPath) {
    $inspectionFile = Join-Path $outputRoot "project-snapshot.rglx"
    Copy-Item -LiteralPath $projectFile -Destination $inspectionFile -Force -ErrorAction Stop
    $sourceLength = (Get-Item -LiteralPath $projectFile).Length
    $inspectionLength = (Get-Item -LiteralPath $inspectionFile).Length
    if ($sourceLength -ne $inspectionLength) {
        throw "Local inspection snapshot size does not match the source project."
    }
}

function Get-ZipEntryText {
    param(
        [System.IO.Compression.ZipArchive]$Archive,
        [string]$EntryName
    )

    if ([string]::IsNullOrWhiteSpace($EntryName)) { return "" }
    $entry = $Archive.GetEntry($EntryName.TrimStart("/"))
    if ($null -eq $entry) { return "" }

    $stream = $entry.Open()
    $reader = New-Object System.IO.StreamReader($stream)
    try {
        return $reader.ReadToEnd()
    } finally {
        $reader.Dispose()
        $stream.Dispose()
    }
}

function Convert-HtmlToText {
    param([string]$Html)

    if ([string]::IsNullOrWhiteSpace($Html)) { return "" }
    $text = [regex]::Replace($Html, "(?is)<(script|style)[^>]*>.*?</\1>", " ")
    $text = [regex]::Replace($text, "(?s)<[^>]+>", " ")
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    return [regex]::Replace($text, "\s+", " ").Trim()
}

function Get-StringSha256 {
    param([string]$Value)

    if ([string]::IsNullOrEmpty($Value)) { return $null }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "").ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

function Get-TextSignals {
    param([string]$Text)

    $patterns = @(
        "welcome to (the )?new",
        "first[- ]run",
        "get started",
        "sign in",
        "access denied",
        "something went wrong",
        "no matching",
        "no results",
        "not found",
        "blocked",
        "error"
    )

    $signals = New-Object System.Collections.Generic.List[string]
    foreach ($pattern in $patterns) {
        $match = [regex]::Match($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($match.Success) { $signals.Add($match.Value) }
    }
    return @($signals | Select-Object -Unique)
}

function Get-NodeText {
    param($Node)
    if ($null -eq $Node) { return "" }
    return [regex]::Replace([string]$Node.InnerText, "\s+", " ").Trim()
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($inspectionFile)
try {
    $projectXmlText = Get-ZipEntryText -Archive $archive -EntryName "Project.xml"
    if ([string]::IsNullOrWhiteSpace($projectXmlText)) {
        throw "Project.xml was not found in $projectFile"
    }

    [xml]$projectXml = $projectXmlText
    # Windows PowerShell 5.1 can throw "Argument types do not match" when a generic
    # List[object] is embedded in a PSCustomObject and passed to ConvertTo-Json.
    # Page counts are small, so a native PowerShell array is the reliable choice here.
    $pageReports = @()
    $sectionReports = @()
    $sectionNumber = 0

    foreach ($section in @($projectXml.Project.Sections.Section)) {
        $sectionNumber++
        $previousHash = $null
        $previousPage = $null

        $orderedPages = @($section.Pages.Page | Sort-Object { [int]$_.Index })
        $sectionPageCount = $orderedPages.Count
        $sectionReports += [pscustomobject]@{
            sectionNumber = $sectionNumber
            sectionId = [string]$section.SectionId
            sectionTitle = [string]$section.Title
            originalPageCount = $sectionPageCount
            automaticRemovalLimit = [Math]::Max(1, [int][Math]::Floor($sectionPageCount * 0.25))
            minimumRetainedPages = if ($sectionPageCount -gt 1) { 2 } else { 1 }
        }

        foreach ($page in $orderedPages) {
            $pageNumber = [int]$page.Index
            $pageId = [string]$page.PageId
            $thumbnailEntryName = ([string]$page.PageThumbnailLocation).TrimStart("/")
            $thumbnailEntry = $archive.GetEntry($thumbnailEntryName)
            $thumbnailName = "section-{0:D2}-page-{1:D3}-{2}.png" -f $sectionNumber, $pageNumber, $pageId
            $thumbnailPath = Join-Path $thumbnailRoot $thumbnailName
            $thumbnailHash = $null

            if ($null -ne $thumbnailEntry) {
                $source = $thumbnailEntry.Open()
                $destination = [System.IO.File]::Create($thumbnailPath)
                try {
                    $source.CopyTo($destination)
                } finally {
                    $destination.Dispose()
                    $source.Dispose()
                }

                $sha = [System.Security.Cryptography.SHA256]::Create()
                $fileStream = [System.IO.File]::OpenRead($thumbnailPath)
                try {
                    $thumbnailHash = ([System.BitConverter]::ToString($sha.ComputeHash($fileStream))).Replace("-", "").ToLowerInvariant()
                } finally {
                    $fileStream.Dispose()
                    $sha.Dispose()
                }
            }

            $htmlId = [string]$page.HtmlFile
            $baselineHtmlId = [string]$page.BuildBaselineHtmlFileId
            $html = Get-ZipEntryText -Archive $archive -EntryName "Html/$htmlId.html"
            $baselineHtml = Get-ZipEntryText -Archive $archive -EntryName "Html/$baselineHtmlId.html"
            $timelineId = [string]$page.BuildTimelineId
            $timeline = Get-ZipEntryText -Archive $archive -EntryName "Timelines/$timelineId.json"

            $navigation = @()
            foreach ($shape in @($page.SelectNodes(".//*[ClickAction]"))) {
                $action = [string]$shape.ClickAction
                if ([string]::IsNullOrWhiteSpace($action) -or $action -eq "None") { continue }
                $navigation += [pscustomobject]@{
                    shapeType = [string]$shape.LocalName
                    shapeName = Get-NodeText ($shape.SelectSingleNode("Name"))
                    shapeId = Get-NodeText ($shape.SelectSingleNode("ShapeId"))
                    action = $action
                    target = [string]$shape.ClickActionData
                    lockActions = ([string]$shape.LockActions -eq "true")
                    basedOnThemeShapeId = [string]$shape.BasedOnThemeShapeId
                    isThemeControlled = -not [string]::IsNullOrWhiteSpace([string]$shape.BasedOnThemeShapeId)
                }
            }
            $navigationSignature = ($navigation | ForEach-Object {
                "$($_.shapeType)|$($_.shapeName)|$($_.action)|$($_.target)|$($_.lockActions)|$($_.basedOnThemeShapeId)"
            }) -join ";"

            $searchText = @(
                (Get-NodeText $page.Description),
                (Get-NodeText $page.PresenterNotes),
                (Convert-HtmlToText $html),
                (Convert-HtmlToText $baselineHtml)
            ) -join " "

            $textSignals = @(Get-TextSignals $searchText)

            $thumbnailMatchesPrevious = $null -ne $thumbnailHash -and $thumbnailHash -eq $previousHash
            $htmlHash = Get-StringSha256 $html
            $baselineHtmlHash = Get-StringSha256 $baselineHtml
            $timelineHash = Get-StringSha256 $timeline
            $description = Get-NodeText $page.Description
            $presenterNotes = Get-NodeText $page.PresenterNotes

            $packageEquivalentToPrevious = $false
            if ($null -ne $previousPage -and $thumbnailMatchesPrevious) {
                $packageEquivalentToPrevious =
                    $htmlHash -eq $previousPage.htmlSha256 -and
                    $baselineHtmlHash -eq $previousPage.baselineHtmlSha256 -and
                    $timelineHash -eq $previousPage.buildTimelineSha256 -and
                    $navigationSignature -eq $previousPage.navigationSignature -and
                    $description -eq $previousPage.description -and
                    $presenterNotes -eq $previousPage.presenterNotes -and
                    ([string]$page.OriginalUrl) -eq $previousPage.originalUrl
            }

            $flowCriticalReasons = @()
            if ($pageNumber -eq [int]$orderedPages[0].Index) { $flowCriticalReasons += "section-entry" }
            if ($pageNumber -eq [int]$orderedPages[$sectionPageCount - 1].Index) { $flowCriticalReasons += "section-outcome" }
            if (-not [string]::IsNullOrWhiteSpace($timelineId)) { $flowCriticalReasons += "build-timeline" }
            if ($navigation.Count -gt 0) { $flowCriticalReasons += "outbound-navigation" }
            if (-not [string]::IsNullOrWhiteSpace($presenterNotes)) { $flowCriticalReasons += "presenter-narration" }

            $qualityReviewReasons = @()
            if ($thumbnailMatchesPrevious) {
                $qualityReviewReasons += "adjacent-exact-thumbnail-match"
            }
            if (@($textSignals | Where-Object {
                $_ -match "welcome to (the )?new|first[- ]run|get started|sign in"
            }).Count -gt 0) {
                $qualityReviewReasons += "onboarding-or-setup-text"
            }
            if (@($textSignals | Where-Object {
                $_ -match "access denied|something went wrong|no matching|no results|not found|blocked|error"
            }).Count -gt 0) {
                $qualityReviewReasons += "blocked-or-error-text"
            }

            $nextPage = @($orderedPages | Where-Object {
                [int]$_.Index -gt $pageNumber
            } | Select-Object -First 1)

            $pageReport = [pscustomobject]@{
                sectionNumber = $sectionNumber
                sectionId = [string]$section.SectionId
                sectionTitle = [string]$section.Title
                pageNumber = $pageNumber
                pageId = $pageId
                isHidden = ([string]$page.IsHidden -eq "true")
                thumbnailPath = if ($null -ne $thumbnailEntry) { $thumbnailPath } else { $null }
                thumbnailSha256 = $thumbnailHash
                thumbnailMatchesPrevious = $thumbnailMatchesPrevious
                packageEquivalentToPrevious = $packageEquivalentToPrevious
                previousPageId = if ($thumbnailMatchesPrevious) { $previousPage.pageId } else { $null }
                previousPageNumber = if ($thumbnailMatchesPrevious) { $previousPage.pageNumber } else { $null }
                sequencePreviousPageId = if ($null -ne $previousPage) { $previousPage.pageId } else { $null }
                sequencePreviousPageNumber = if ($null -ne $previousPage) { $previousPage.pageNumber } else { $null }
                nextPageId = if ($nextPage.Count -gt 0) { [string]$nextPage[0].PageId } else { $null }
                nextPageNumber = if ($nextPage.Count -gt 0) { [int]$nextPage[0].Index } else { $null }
                htmlSha256 = $htmlHash
                baselineHtmlSha256 = $baselineHtmlHash
                hasBuildTimeline = -not [string]::IsNullOrWhiteSpace($timelineId)
                buildTimelineId = $timelineId
                buildTimelineSha256 = $timelineHash
                navigation = [object[]]$navigation
                navigationSignature = $navigationSignature
                inboundNavigationCount = 0
                inboundLockedNavigationCount = 0
                inboundThemeNavigationCount = 0
                inboundNavigation = [object[]]@()
                flowCriticalReasons = [object[]]$flowCriticalReasons
                textSignals = [object[]]$textSignals
                qualityReviewReasons = [object[]]$qualityReviewReasons
                description = $description
                presenterNotes = $presenterNotes
                originalUrl = [string]$page.OriginalUrl
                htmlFileId = $htmlId
                baselineHtmlFileId = $baselineHtmlId
            }
            $pageReports += $pageReport

            $previousHash = $thumbnailHash
            $previousPage = $pageReport
        }
    }

    $pagesById = @{}
    foreach ($pageReport in $pageReports) {
        $pagesById[$pageReport.pageId] = $pageReport
    }
    foreach ($sourcePage in $pageReports) {
        foreach ($edge in $sourcePage.navigation) {
            if ($edge.action -eq "SpecificPage" -and $pagesById.ContainsKey($edge.target)) {
                $targetPage = $pagesById[$edge.target]
                $targetPage.inboundNavigationCount++
                $targetPage.inboundNavigation = [object[]]@($targetPage.inboundNavigation + [pscustomobject]@{
                    sourcePageId = $sourcePage.pageId
                    sourcePageNumber = $sourcePage.pageNumber
                    shapeId = $edge.shapeId
                    shapeName = $edge.shapeName
                    lockActions = $edge.lockActions
                    isThemeControlled = $edge.isThemeControlled
                })
                if ($edge.lockActions) { $targetPage.inboundLockedNavigationCount++ }
                if ($edge.isThemeControlled) { $targetPage.inboundThemeNavigationCount++ }
                if ($targetPage.flowCriticalReasons -notcontains "inbound-navigation-target") {
                    $targetPage.flowCriticalReasons = [object[]]@($targetPage.flowCriticalReasons + "inbound-navigation-target")
                }
                if ($edge.lockActions -and $targetPage.flowCriticalReasons -notcontains "locked-inbound-navigation") {
                    $targetPage.flowCriticalReasons = [object[]]@($targetPage.flowCriticalReasons + "locked-inbound-navigation")
                }
            }
        }
    }

    $sequenceWindows = @()
    foreach ($sectionGroup in @($pageReports | Group-Object sectionNumber | Sort-Object { [int]$_.Name })) {
        $orderedSectionPages = @($sectionGroup.Group | Sort-Object pageNumber)
        if ($orderedSectionPages.Count -lt 3) { continue }

        for ($index = 0; $index -le $orderedSectionPages.Count - 3; $index++) {
            $previous = $orderedSectionPages[$index]
            $current = $orderedSectionPages[$index + 1]
            $next = $orderedSectionPages[$index + 2]
            $sequenceWindows += [pscustomobject]@{
                sectionNumber = $current.sectionNumber
                sectionTitle = $current.sectionTitle
                previousPageNumber = $previous.pageNumber
                previousPageId = $previous.pageId
                previousThumbnailPath = $previous.thumbnailPath
                currentPageNumber = $current.pageNumber
                currentPageId = $current.pageId
                currentThumbnailPath = $current.thumbnailPath
                nextPageNumber = $next.pageNumber
                nextPageId = $next.pageId
                nextThumbnailPath = $next.thumbnailPath
            }
        }
    }

    $report = [pscustomobject]@{
        projectPath = $projectFile
        inspectionPath = $inspectionFile
        backupPath = $backupPath
        aggressiveCopyPath = $aggressiveCopyPath
        projectTitle = [string]$projectXml.Project.Title
        generatedAt = (Get-Date).ToString("o")
        pageCount = $pageReports.Count
        sections = [object[]]$sectionReports
        pages = [object[]]$pageReports
        sequenceWindows = [object[]]$sequenceWindows
    }

    $reportPath = Join-Path $outputRoot "report.json"
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8

    Write-Output "Refinement package inspection complete."
    Write-Output "Report: $reportPath"
    Write-Output "Thumbnails: $thumbnailRoot"
    if ($backupPath) { Write-Output "Backup: $backupPath" }
    if ($aggressiveCopyPath) { Write-Output "Aggressive copy: $aggressiveCopyPath" }
    Write-Output "Pages: $($pageReports.Count)"
    Write-Output "Ordered three-page sequence windows: $($sequenceWindows.Count)"
    Write-Output "Matching adjacent thumbnails: $(@($pageReports | Where-Object thumbnailMatchesPrevious).Count)"
    Write-Output "Package-equivalent adjacent pages: $(@($pageReports | Where-Object packageEquivalentToPrevious).Count)"
    Write-Output "Presentation-quality review candidates: $(@($pageReports | Where-Object { $_.qualityReviewReasons.Count -gt 0 }).Count)"
    Write-Output "Pages with locked inbound navigation: $(@($pageReports | Where-Object { $_.inboundLockedNavigationCount -gt 0 }).Count)"
    Write-Output "Pages with review signals: $(@($pageReports | Where-Object { $_.textSignals.Count -gt 0 }).Count)"
} finally {
    $archive.Dispose()
}
