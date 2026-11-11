#requires -Version 7.0
<#
.SYNOPSIS
Checks a project's knowledge base for mechanically detectable errors.

.DESCRIPTION
Scans every Markdown file in the target project and reports dangling or
ambiguous [[links]], title/filename mismatches, invalid ADR status lines,
orphan question references, incomplete journal entries and similar issues.

.PARAMETER TargetDir
Project directory to scan. Defaults to the current directory.

.PARAMETER Quiet
Print only the final summary.

.EXAMPLE
pwsh -File .\lint.ps1 -TargetDir C:\work\my-project
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $TargetDir = '.',

    [switch] $Quiet
)

$ErrorActionPreference = 'Stop'

function Stop-Lint {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [int] $ExitCode = 2
    )
    [Console]::Error.WriteLine("Error: $Message")
    exit $ExitCode
}

if ($PSVersionTable.PSVersion.Major -ne 7) {
    Stop-Lint "PowerShell 7.x (pwsh) is required; current version is $($PSVersionTable.PSVersion)."
}

try {
    $targetPath = (Resolve-Path -LiteralPath $TargetDir -ErrorAction Stop).Path
}
catch {
    Stop-Lint "Target directory does not exist: $TargetDir"
}
if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
    Stop-Lint "Target path is not a directory: $targetPath"
}

$excluded = @(
    '.git', 'node_modules', 'dist', 'build', 'out', 'vendor', 'target',
    '.venv', 'venv', '__pycache__', '.next', 'coverage'
)
$allowedTypes = @(
    'AGENT', 'ADR', 'FEATURE', 'API', 'DATA', 'OPS',
    'SEQUENCE', 'STATE', 'DATAFLOW', 'MODULE', 'SUMMARY',
    'SOURCE', 'RESEARCH', 'REPORT'
)

$script:errors = 0
$script:warnings = 0

function Write-Finding {
    param(
        [Parameter(Mandatory)] [string] $Level,
        [Parameter(Mandatory)] [string] $Code,
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Message
    )
    if (-not $Quiet) {
        Write-Host ('{0,-6} {1,-22} {2}: {3}' -f $Level, $Code, $Path, $Message)
    }
    if ($Level -eq 'ERROR') { $script:errors++ } else { $script:warnings++ }
}

function Get-RelativeDisplay {
    param([Parameter(Mandatory)] [string] $FullName)
    return [System.IO.Path]::GetRelativePath($targetPath, $FullName).Replace('\', '/')
}

function Test-Excluded {
    param([Parameter(Mandatory)] [string] $RelativePath)
    if ($RelativePath.StartsWith('tests/fixtures/')) { return $true }
    foreach ($part in ($RelativePath -split '/')) {
        if ($excluded -contains $part) { return $true }
    }
    return $false
}

function Get-BareLinks {
    param([Parameter(Mandatory)] [string] $FullName)

    $result = [System.Collections.Generic.List[string]]::new()
    $fence = 0
    foreach ($line in (Get-Content -LiteralPath $FullName)) {
        $trimmed = $line.TrimStart()
        if ($trimmed -match '^`+') {
            $runLength = $Matches[0].Length
            $rest = $trimmed.Substring($runLength)
            if ($fence -eq 0) {
                $fence = $runLength
                continue
            }
            if ($runLength -ge $fence -and $rest.Trim().Length -eq 0) {
                $fence = 0
                continue
            }
        }
        if ($fence -ne 0) { continue }
        $cleaned = $line -replace '`[^`]*`', ''
        foreach ($m in [regex]::Matches($cleaned, '\[\[([^\]]*)\]\]')) {
            $target = $m.Groups[1].Value.Split('|')[0].Trim()
            if ($target.Length -gt 0) { $result.Add($target) }
        }
    }
    return $result
}

try {
    $allFiles = @(Get-ChildItem -LiteralPath $targetPath -Filter '*.md' -File -Recurse -Force -ErrorAction Stop)
}
catch {
    Stop-Lint "Cannot scan target directory: $targetPath"
}

$files = @($allFiles | Where-Object {
    -not (Test-Excluded -RelativePath (Get-RelativeDisplay -FullName $_.FullName))
})

$stems = [System.Collections.Generic.List[string]]::new()
foreach ($file in $files) {
    $stems.Add([System.IO.Path]::GetFileNameWithoutExtension($file.Name))
}
$duplicateStems = @($stems | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })

foreach ($file in $files) {
    $display = Get-RelativeDisplay -FullName $file.FullName
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if ($file.Name.StartsWith('_TEMPLATE__')) { continue }

    # L1 / L2: dangling and ambiguous links.
    foreach ($link in (Get-BareLinks -FullName $file.FullName)) {
        $hits = @($stems | Where-Object { [string]::Equals($_, $link, [System.StringComparison]::Ordinal) })
        if ($hits.Count -eq 0) {
            Write-Finding 'ERROR' 'L1-dangling-link' $display "[[$link]] does not resolve to any .md file"
        }
        elseif ($hits.Count -gt 1) {
            Write-Finding 'ERROR' 'L2-ambiguous-link' $display "[[$link]] matches $($hits.Count) .md files"
        }
    }

    # L3: title equals filename stem for TYPE files and journal entries.
    $isType = $stem -match '^[A-Z][A-Z0-9]*__.+$'
    $isJournal = $stem -match '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}__.+$'
    if ($isType -or $isJournal) {
        $titleLine = $null
        foreach ($line in (Get-Content -LiteralPath $file.FullName)) {
            if ($line -match '^# ') { $titleLine = $line; break }
        }
        $title = if ($null -ne $titleLine) { $titleLine.Substring(2) } else { '' }
        if (-not [string]::Equals($title, $stem, [System.StringComparison]::Ordinal)) {
            Write-Finding 'ERROR' 'L3-title-mismatch' $display "first heading is '$title', expected '$stem'"
        }
    }

    # L4 / L5: ADR status validity and rejected-ADR naming.
    if ($stem.StartsWith('ADR__')) {
        $statusPattern = '^- Status: (Proposed|Accepted|Rejected|Superseded by \[\[ADR__[^\]]+\]\])$'
        $lines = @(Get-Content -LiteralPath $file.FullName)
        $statusCount = @($lines | Where-Object { $_ -match '^- Status:' }).Count
        $allowedCount = @($lines | Where-Object { $_ -match $statusPattern }).Count
        if ($statusCount -ne 1 -or $allowedCount -ne 1) {
            Write-Finding 'ERROR' 'L4-adr-status' $display "expected exactly one valid '- Status:' line, found $statusCount status line(s), $allowedCount valid"
        }
        $isRejectedStatus = @($lines | Where-Object { $_ -match '^- Status: Rejected$' }).Count -gt 0
        $isRejectedName = $stem.StartsWith('ADR__rejected__')
        if ($isRejectedStatus -and -not $isRejectedName) {
            Write-Finding 'ERROR' 'L5-rejected-name' $display 'Rejected ADR must be named ADR__rejected__*'
        }
        if ($isRejectedName -and -not $isRejectedStatus) {
            Write-Finding 'ERROR' 'L5-rejected-name' $display "ADR__rejected__* must have '- Status: Rejected'"
        }
    }

    # L8: unknown type prefix.
    $typeMatch = [regex]::Match($stem, '^([0-9]{2}__)?([A-Z][A-Z0-9]*)__')
    if ($typeMatch.Success) {
        $type = $typeMatch.Groups[2].Value
        if ($allowedTypes -notcontains $type) {
            Write-Finding 'WARN' 'L8-unknown-type' $display "unknown type prefix '$type' (see allowed types in 00__AGENT__START_HERE.md)"
        }
    }

    # L10: research records carry a question, a status and an as-of date.
    if ($stem.StartsWith('RESEARCH__')) {
        $lines = @(Get-Content -LiteralPath $file.FullName)
        $questionCount = @($lines | Where-Object { $_ -match '^- Question: .+' }).Count
        $statusCount = @($lines | Where-Object { $_ -match '^- Status: (active|concluded|superseded)$' }).Count
        $asOfCount = @($lines | Where-Object { $_ -match '^- As of: [0-9]{4}-[0-9]{2}-[0-9]{2}$' }).Count
        if ($questionCount -ne 1 -or $statusCount -ne 1 -or $asOfCount -ne 1) {
            Write-Finding 'ERROR' 'L10-research-metadata' $display "expected exactly one '- Question:', one '- Status: active|concluded|superseded' and one '- As of: YYYY-MM-DD'"
        }
    }

    # L11: source records carry a type, a citation or URL, and an access date.
    if ($stem.StartsWith('SOURCE__')) {
        $lines = @(Get-Content -LiteralPath $file.FullName)
        $typeCount = @($lines | Where-Object { $_ -match '^- Type: (paper|documentation|source-code|benchmark|article|book|talk|other)$' }).Count
        $citationCount = @($lines | Where-Object { $_ -match '^- (Citation|URL): .+' }).Count
        $accessedCount = @($lines | Where-Object { $_ -match '^- Accessed: [0-9]{4}-[0-9]{2}-[0-9]{2}$' }).Count
        if ($typeCount -ne 1 -or $citationCount -lt 1 -or $accessedCount -ne 1) {
            Write-Finding 'ERROR' 'L11-source-metadata' $display "expected one valid '- Type:', at least one '- Citation:' or '- URL:', and one '- Accessed: YYYY-MM-DD'"
        }
    }
}

# L6: task-board question references must exist in open questions.
$boardPath = Join-Path -Path $targetPath -ChildPath '40__MEMORY/task_board.md'
$questionsPath = Join-Path -Path $targetPath -ChildPath '40__MEMORY/open_questions_for_human.md'
if ((Test-Path -LiteralPath $boardPath -PathType Leaf) -and (Test-Path -LiteralPath $questionsPath -PathType Leaf)) {
    $boardContent = Get-Content -LiteralPath $boardPath -Raw
    $questionContent = Get-Content -LiteralPath $questionsPath -Raw
    foreach ($m in [regex]::Matches($boardContent, 'Q-[A-Za-z0-9][A-Za-z0-9-]*')) {
        if (-not $questionContent.Contains($m.Value)) {
            Write-Finding 'ERROR' 'L6-orphan-question' '40__MEMORY/task_board.md' "$($m.Value) is not listed in 40__MEMORY/open_questions_for_human.md"
        }
    }
}

# L7 / L9: journal completeness and size.
$journalPath = Join-Path -Path $targetPath -ChildPath '40__MEMORY/journal'
if (Test-Path -LiteralPath $journalPath -PathType Container) {
    $rawCount = 0
    $entries = @(Get-ChildItem -LiteralPath $journalPath -Filter '*.md' -File -Force)
    foreach ($entry in $entries) {
        if ($entry.Name.StartsWith('SUMMARY__')) { continue }
        $rawCount++
        $content = Get-Content -LiteralPath $entry.FullName -Raw
        if ($content -match '(?m)^- Task:' -and $content -notmatch '(?m)^- Did:') {
            Write-Finding 'WARN' 'L7-incomplete-journal' (Get-RelativeDisplay -FullName $entry.FullName) "entry has 'Task:' but no 'Did:' (interrupted or still open)"
        }
    }
    if ($rawCount -gt 20) {
        Write-Finding 'WARN' 'L9-journal-count' '40__MEMORY/journal' "$rawCount raw entries; consider compaction (see AGENT__procedure__compaction.md)"
    }
}

Write-Host "lint: $($script:errors) errors, $($script:warnings) warnings"
if ($script:errors -eq 0) { exit 0 } else { exit 1 }
