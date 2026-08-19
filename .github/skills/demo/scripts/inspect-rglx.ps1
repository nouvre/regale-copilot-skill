param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$OutputDirectory,

    [switch]$CreateBackup
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
    throw "Regale project not found: $ProjectPath"
}

$projectFile = (Resolve-Path -LiteralPath $ProjectPath).Path
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
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
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectFile)
    $backupName = "$projectName.pre-refine-$stamp.rglx"
    $backupPath = Join-Path $projectDirectory $backupName

    try {
        Copy-Item -LiteralPath $projectFile -Destination $backupPath -ErrorAction Stop
    } catch {
        $documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        $fallbackDirectory = Join-Path $documents "Regale Backups"
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

$archive = [System.IO.Compression.ZipFile]::OpenRead($projectFile)
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
                    action = $action
                    target = [string]$shape.ClickActionData
                }
            }
            $navigationSignature = ($navigation | ForEach-Object {
                "$($_.shapeType)|$($_.shapeName)|$($_.action)|$($_.target)"
            }) -join ";"

            $searchText = @(
                (Get-NodeText $page.Description),
                (Get-NodeText $page.PresenterNotes),
                (Convert-HtmlToText $html),
                (Convert-HtmlToText $baselineHtml)
            ) -join " "

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
                htmlSha256 = $htmlHash
                baselineHtmlSha256 = $baselineHtmlHash
                hasBuildTimeline = -not [string]::IsNullOrWhiteSpace($timelineId)
                buildTimelineId = $timelineId
                buildTimelineSha256 = $timelineHash
                navigation = [object[]]$navigation
                navigationSignature = $navigationSignature
                inboundNavigationCount = 0
                flowCriticalReasons = [object[]]$flowCriticalReasons
                textSignals = @(Get-TextSignals $searchText)
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
                if ($targetPage.flowCriticalReasons -notcontains "inbound-navigation-target") {
                    $targetPage.flowCriticalReasons = [object[]]@($targetPage.flowCriticalReasons + "inbound-navigation-target")
                }
            }
        }
    }

    $report = [pscustomobject]@{
        projectPath = $projectFile
        backupPath = $backupPath
        projectTitle = [string]$projectXml.Project.Title
        generatedAt = (Get-Date).ToString("o")
        pageCount = $pageReports.Count
        sections = [object[]]$sectionReports
        pages = [object[]]$pageReports
    }

    $reportPath = Join-Path $outputRoot "report.json"
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8

    Write-Output "Refinement package inspection complete."
    Write-Output "Report: $reportPath"
    Write-Output "Thumbnails: $thumbnailRoot"
    if ($backupPath) { Write-Output "Backup: $backupPath" }
    Write-Output "Pages: $($pageReports.Count)"
    Write-Output "Matching adjacent thumbnails: $(@($pageReports | Where-Object thumbnailMatchesPrevious).Count)"
    Write-Output "Package-equivalent adjacent pages: $(@($pageReports | Where-Object packageEquivalentToPrevious).Count)"
    Write-Output "Pages with review signals: $(@($pageReports | Where-Object { $_.textSignals.Count -gt 0 }).Count)"
} finally {
    $archive.Dispose()
}
