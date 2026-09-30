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

.PARAMETER ShowVersion
Print the version from scaffold/agent-knowledge/scaffold-version.txt.

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

    [string] $ScaffoldDir,

    [switch] $ShowVersion
)

$ErrorActionPreference = 'Stop'
$versionRelativePath = 'agent-knowledge/scaffold-version.txt'

function Stop-Installer {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [int] $ExitCode = 2
    )

    [Console]::Error.WriteLine("错误: $Message")
    exit $ExitCode
}

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
    Stop-Installer "需要 PowerShell 7.x（pwsh）；当前版本为 $($PSVersionTable.PSVersion)。Windows PowerShell 5.1 和其他主版本不受支持。"
}
if ($Verify -and $ShowVersion) {
    Stop-Installer '-Verify 与 -ShowVersion 不能同时使用。'
}

if ([string]::IsNullOrWhiteSpace($ScaffoldDir)) {
    $ScaffoldDir = Join-Path -Path $PSScriptRoot -ChildPath 'scaffold'
}
try {
    $scaffoldPath = (Resolve-Path -LiteralPath $ScaffoldDir -ErrorAction Stop).Path
}
catch {
    Stop-Installer "未找到资产目录: $ScaffoldDir"
}
if (-not (Test-Path -LiteralPath $scaffoldPath -PathType Container)) {
    Stop-Installer "资产路径不是目录: $scaffoldPath"
}

$versionFile = Join-Path -Path $scaffoldPath -ChildPath $versionRelativePath
$scaffoldVersion = 'unknown'
if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
    $versionLine = Get-Content -LiteralPath $versionFile -TotalCount 1
    if (-not [string]::IsNullOrWhiteSpace($versionLine)) {
        $scaffoldVersion = $versionLine.Trim()
    }
}
if ($ShowVersion) {
    Write-Output "agent-coldstart-scaffold installer $scaffoldVersion (PowerShell 7.x)"
    exit 0
}

try {
    $targetPath = (Resolve-Path -LiteralPath $TargetDir -ErrorAction Stop).Path
}
catch {
    Stop-Installer "目标目录不存在: $TargetDir（请先创建，本脚本不代建项目根目录）"
}
if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
    Stop-Installer "目标路径不是目录: $targetPath"
}

try {
    $assets = @(Get-ChildItem -LiteralPath $scaffoldPath -File -Recurse -Force -ErrorAction Stop |
        Sort-Object -Property FullName)
}
catch {
    Stop-Installer "无法读取资产目录: $scaffoldPath"
}
if ($assets.Count -eq 0) {
    Stop-Installer "资产目录为空: $scaffoldPath"
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
    $normalizedRelativePath = $relativePath.Replace($directorySeparator, '/')
    $destination = Join-Path -Path $targetPath -ChildPath $relativePath
    $total++

    $hasSymlinkParent = Test-SymlinkAncestor -RelativePath $relativePath -RootPath $targetPath
    if ($Verify) {
        if ($hasSymlinkParent) {
            Write-Host "  MISSING $relativePath（父路径是符号链接）"
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
        [Console]::Error.WriteLine("  CONFLICT $relativePath（父路径是符号链接，拒绝写出目标目录）")
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
                Write-Host '          └ 目标已有 .gitignore，请人工确认包含所需条目'
            }
        }
        else {
            [Console]::Error.WriteLine("  CONFLICT $relativePath（目标路径存在但不是普通文件，未覆盖）")
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

        if ($normalizedRelativePath -eq $versionRelativePath) {
            $installedAt = (Get-Date).ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
            $lineEnding = [System.Environment]::NewLine
            $encoding = [System.Text.UTF8Encoding]::new($false)
            [System.IO.File]::AppendAllText(
                $destination,
                "installed-at: $installedAt$lineEnding",
                $encoding
            )
        }
    }
    catch {
        Stop-Installer "无法安装资产 '$relativePath': $($_.Exception.Message)"
    }

    Write-Host "  OK      $relativePath"
    $created++
}

if (-not $Verify) {
    if ($conflicts -gt 0) {
        Stop-Installer "发现 $conflicts 个目标路径冲突；请先处理冲突后重跑安装器"
    }

    $gitCommand = Get-Command -Name git -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -ne $gitCommand) {
        $isGitWorktree = $false
        try {
            & $gitCommand.Source -C $targetPath rev-parse --is-inside-work-tree *> $null
            $isGitWorktree = ($LASTEXITCODE -eq 0)
        }
        catch {
            $isGitWorktree = $false
        }

        if (-not $isGitWorktree) {
            try {
                & $gitCommand.Source -C $targetPath init -q
                if ($LASTEXITCODE -ne 0) {
                    Stop-Installer "无法在目标目录初始化 git 仓库: $targetPath"
                }
                Write-Host '  OK      git 仓库已初始化'
            }
            catch {
                Stop-Installer "无法在目标目录初始化 git 仓库: $($_.Exception.Message)"
            }
        }
    }

    Write-Host ''
    Write-Host '============================================================'
    Write-Host " 安装完成: 新建 $created 个文件, 跳过 $skipped 个已存在文件"
    Write-Host ' 下一步: 将 agent-bootstrap-instruction.md 的内容发给你的 Agent'
    Write-Host ' 脚手架目录可删除；校验或补齐时重新下载并重跑安装器。'
    Write-Host '============================================================'
    exit 0
}

Write-Host ''
Write-Host '============================================================'
if ($missing -eq 0) {
    Write-Host " 校验通过: $present/$total 文件就位 ✓"
    $targetVersionFile = Join-Path -Path $targetPath -ChildPath $versionRelativePath
    if ((Test-Path -LiteralPath $versionFile -PathType Leaf) -and
        (Test-Path -LiteralPath $targetVersionFile -PathType Leaf)) {
        $installedVersion = 'unknown'
        $installedVersionLine = Get-Content -LiteralPath $targetVersionFile -TotalCount 1
        if (-not [string]::IsNullOrWhiteSpace($installedVersionLine)) {
            $installedVersion = $installedVersionLine.Trim()
        }
        if ($scaffoldVersion -ne $installedVersion) {
            Write-Host " 版本提示: 当前资产 $scaffoldVersion, 项目记录的首次安装版本为 $installedVersion"
            Write-Host '           安装器只补齐缺失文件，不覆盖已有文件；版本戳保留首次安装版本。'
        }
    }
    Write-Host '============================================================'
    exit 0
}

Write-Host " 校验失败: $present 就位, $missing 缺失 ✗"
Write-Host " 修复方法: pwsh -File `"$PSCommandPath`" -TargetDir `"$targetPath`""
Write-Host '============================================================'
exit 1
