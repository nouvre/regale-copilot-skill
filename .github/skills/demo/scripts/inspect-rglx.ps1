param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$OutputDirectory
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
    throw "Regale project not found: $ProjectPath"
}

$projectFile = (Resolve-Path -LiteralPath $ProjectPath).Path
if (-not $OutputDirectory) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutputDirectory = Join-Path $env:TEMP "regale-refinement-$stamp"
}

$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$thumbnailRoot = Join-Path $outputRoot "thumbnails"
New-Item -ItemType Directory -Force -Path $thumbnailRoot | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem

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
    $sectionNumber = 0

    foreach ($section in @($projectXml.Project.Sections.Section)) {
        $sectionNumber++
        $previousHash = $null
        $previousPage = $null

        foreach ($page in @($section.Pages.Page | Sort-Object { [int]$_.Index })) {
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
            $searchText = @(
                (Get-NodeText $page.Description),
                (Get-NodeText $page.PresenterNotes),
                (Convert-HtmlToText $html),
                (Convert-HtmlToText $baselineHtml)
            ) -join " "

            $duplicateOfPrevious = $null -ne $thumbnailHash -and $thumbnailHash -eq $previousHash
            $pageReport = [pscustomobject]@{
                sectionNumber = $sectionNumber
                sectionId = [string]$section.SectionId
                sectionTitle = [string]$section.Title
                pageNumber = $pageNumber
                pageId = $pageId
                isHidden = ([string]$page.IsHidden -eq "true")
                thumbnailPath = if ($null -ne $thumbnailEntry) { $thumbnailPath } else { $null }
                thumbnailSha256 = $thumbnailHash
                exactAdjacentDuplicate = $duplicateOfPrevious
                duplicateOfPageId = if ($duplicateOfPrevious) { $previousPage.pageId } else { $null }
                duplicateOfPageNumber = if ($duplicateOfPrevious) { $previousPage.pageNumber } else { $null }
                textSignals = @(Get-TextSignals $searchText)
                description = Get-NodeText $page.Description
                presenterNotes = Get-NodeText $page.PresenterNotes
                originalUrl = [string]$page.OriginalUrl
                htmlFileId = $htmlId
                baselineHtmlFileId = $baselineHtmlId
            }
            $pageReports += $pageReport

            $previousHash = $thumbnailHash
            $previousPage = $pageReport
        }
    }

    $report = [pscustomobject]@{
        projectPath = $projectFile
        projectTitle = [string]$projectXml.Project.Title
        generatedAt = (Get-Date).ToString("o")
        pageCount = $pageReports.Count
        pages = [object[]]$pageReports
    }

    $reportPath = Join-Path $outputRoot "report.json"
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8

    Write-Output "Refinement package inspection complete."
    Write-Output "Report: $reportPath"
    Write-Output "Thumbnails: $thumbnailRoot"
    Write-Output "Pages: $($pageReports.Count)"
    Write-Output "Exact adjacent duplicates: $(@($pageReports | Where-Object exactAdjacentDuplicate).Count)"
    Write-Output "Pages with review signals: $(@($pageReports | Where-Object { $_.textSignals.Count -gt 0 }).Count)"
} finally {
    $archive.Dispose()
}
