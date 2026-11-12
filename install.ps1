#requires -Version 7.0
<#
.SYNOPSIS
Installs or verifies the agent-coldstart-scaffold assets using PowerShell 7.

.DESCRIPTION
Copies files from scaffold/ into an existing project directory. Existing files
are never overwritten. -Verify is read-only and checks file presence only.

.PARAMETER TargetDir
Existing project directory. Defaults to the current directory.

.PARAMETER Verify
Only verify that every scaffold asset is present as a file.

.PARAMETER ScaffoldDir
Override the asset directory. Defaults to scaffold/ beside this script.

.EXAMPLE
pwsh -File .\install.ps1 -TargetDir C:\work\my-project

.EXAMPLE
pwsh -File .\install.ps1 -Verify -TargetDir C:\work\my-project
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $TargetDir = '.',

    [switch] $Verify,

    [string] $ScaffoldDir
)

$ErrorActionPreference = 'Stop'

function Stop-Installer {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [int] $ExitCode = 2
    )

    [Console]::Error.WriteLine("Error: $Message")
    exit $ExitCode
}

# Returns $true if any parent of RelativePath is a reparse point (symlink/junction).
function Test-SymlinkAncestor {
    param(
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $RootPath
    )

    $parentRelativePath = Split-Path -Path $RelativePath -Parent
    if ([string]::IsNullOrWhiteSpace($parentRelativePath)) {
        return $false
    }

    $currentPath = $RootPath
    foreach ($part in ($parentRelativePath -split '[\\/]')) {
        if ([string]::IsNullOrEmpty($part)) {
            continue
        }

        $currentPath = Join-Path -Path $currentPath -ChildPath $part
        try {
            $item = Get-Item -LiteralPath $currentPath -Force -ErrorAction Stop
        }
        catch {
            continue
        }

        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            return $true
        }
    }

    return $false
}

if ($PSVersionTable.PSVersion.Major -ne 7) {
    Stop-Installer "PowerShell 7.x (pwsh) is required; current version is $($PSVersionTable.PSVersion). Windows PowerShell 5.1 and other major versions are not supported."
}

if ([string]::IsNullOrWhiteSpace($ScaffoldDir)) {
    $ScaffoldDir = Join-Path -Path $PSScriptRoot -ChildPath 'scaffold'
}
try {
    $scaffoldPath = (Resolve-Path -LiteralPath $ScaffoldDir -ErrorAction Stop).Path
}
catch {
    Stop-Installer "Asset directory not found: $ScaffoldDir"
}
if (-not (Test-Path -LiteralPath $scaffoldPath -PathType Container)) {
    Stop-Installer "Asset path is not a directory: $scaffoldPath"
}

try {
    $targetPath = (Resolve-Path -LiteralPath $TargetDir -ErrorAction Stop).Path
}
catch {
    Stop-Installer "Target directory does not exist: $TargetDir (create it first; this script does not create project roots)"
}
if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
    Stop-Installer "Target path is not a directory: $targetPath"
}

try {
    $assets = @(Get-ChildItem -LiteralPath $scaffoldPath -File -Recurse -Force -ErrorAction Stop |
        Sort-Object -Property FullName)
}
catch {
    Stop-Installer "Cannot read asset directory: $scaffoldPath"
}
if ($assets.Count -eq 0) {
    Stop-Installer "Asset directory is empty: $scaffoldPath"
}

$created = 0
$skipped = 0
$present = 0
$missing = 0
$conflicts = 0
$total = 0
$directorySeparator = [System.IO.Path]::DirectorySeparatorChar.ToString()

foreach ($asset in $assets) {
    $relativePath = [System.IO.Path]::GetRelativePath($scaffoldPath, $asset.FullName)
    $relativePath = $relativePath.Replace('/', $directorySeparator)
    $destination = Join-Path -Path $targetPath -ChildPath $relativePath
    $total++

    $hasSymlinkParent = Test-SymlinkAncestor -RelativePath $relativePath -RootPath $targetPath
    if ($Verify) {
        if ($hasSymlinkParent) {
            Write-Host "  MISSING $relativePath (parent path is a symbolic link)"
            $missing++
        }
        elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
            $present++
        }
        else {
            Write-Host "  MISSING $relativePath"
            $missing++
        }
        continue
    }

    if ($hasSymlinkParent) {
        [Console]::Error.WriteLine("  CONFLICT $relativePath (parent path is a symbolic link; refusing to write outside the target)")
        $conflicts++
        continue
    }

    $existingItem = $null
    try {
        $existingItem = Get-Item -LiteralPath $destination -Force -ErrorAction Stop
    }
    catch {
        # A missing target is expected; copy it below.
    }

    if ($null -ne $existingItem) {
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            Write-Host "  SKIP    $relativePath"
            $skipped++
            if ($relativePath -eq '.gitignore') {
                Write-Host '          └ Target already has .gitignore; confirm it covers dependencies, build output and .tools/'
            }
            if ($relativePath -eq 'AGENTS.md') {
                Write-Host '          └ AGENTS.md already exists. Add this line to it so agent hosts load the workflow:'
                Write-Host '            Before doing anything in this repository, read `00__AGENT__START_HERE.md` and follow it.'
            }
        }
        else {
            [Console]::Error.WriteLine("  CONFLICT $relativePath (target path exists but is not a regular file; not overwritten)")
            $conflicts++
        }
        continue
    }

    $destinationParent = Split-Path -Path $destination -Parent
    try {
        if (-not (Test-Path -LiteralPath $destinationParent -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationParent -Force -ErrorAction Stop
        }
        Copy-Item -LiteralPath $asset.FullName -Destination $destination -ErrorAction Stop
    }
    catch {
        Stop-Installer "Cannot install asset '$relativePath': $($_.Exception.Message)"
    }

    Write-Host "  OK      $relativePath"
    $created++
}

$legacyCount = 0
$legacyListPath = Join-Path -Path $PSScriptRoot -ChildPath 'legacy-paths.txt'
if (Test-Path -LiteralPath $legacyListPath -PathType Leaf) {
    foreach ($entry in Get-Content -LiteralPath $legacyListPath) {
        $relative = $entry.Trim().TrimEnd('/', '\')
        if ([string]::IsNullOrEmpty($relative)) {
            continue
        }
        if (Test-Path -LiteralPath (Join-Path -Path $targetPath -ChildPath $relative)) {
            [Console]::Error.WriteLine("  LEGACY  $relative (from an older scaffold version; review and remove manually)")
            $legacyCount++
        }
    }
}

$entryPath = Join-Path -Path $targetPath -ChildPath '00__AGENT__START_HERE.md'
if (Test-Path -LiteralPath $entryPath -PathType Leaf) {
    $entryContent = Get-Content -LiteralPath $entryPath -Raw
    if (-not $entryContent.Contains('agent-coldstart-scaffold entry v')) {
        [Console]::Error.WriteLine('  LEGACY  00__AGENT__START_HERE.md (older entry file; it does not reference the current v6+ layout. Replace it manually with scaffold/00__AGENT__START_HERE.md)')
        $legacyCount++
    }
}

if (-not $Verify) {
    if ($conflicts -gt 0) {
        if ($legacyCount -gt 0) {
            [Console]::Error.WriteLine("Legacy paths found: $legacyCount. See README ""Upgrading"".")
        }
        Stop-Installer "Found $conflicts target path conflict(s); resolve them and rerun the installer"
    }

    Write-Host ''
    Write-Host '============================================================'
    Write-Host " Install complete: $created file(s) created, $skipped existing file(s) skipped"
    Write-Host ' No Git repository was initialized. Copy templates/ from the source directory when needed.'
    Write-Host '============================================================'
    if ($legacyCount -gt 0) {
        Write-Host "Legacy paths found: $legacyCount. See README ""Upgrading""."
    }
    exit 0
}

Write-Host ''
Write-Host '============================================================'
if ($missing -eq 0) {
    Write-Host " Verification passed: $present/$total file(s) present"
    Write-Host '============================================================'
    if ($legacyCount -gt 0) {
        Write-Host "Legacy paths found: $legacyCount. See README ""Upgrading""."
    }
    exit 0
}

Write-Host " Verification failed: $present present, $missing missing"
Write-Host " Fix: rerun pwsh -File `"$PSCommandPath`" -TargetDir `"$targetPath`""
Write-Host '============================================================'
if ($legacyCount -gt 0) {
    Write-Host "Legacy paths found: $legacyCount. See README ""Upgrading""."
}
exit 1
