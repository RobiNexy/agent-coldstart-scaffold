# Agent 启动指引

用户在项目 Agent 会话中发送本仓库链接时，默认视为安装请求，除非用户说明其他目的。只使用用户发来的确切链接（`ACS_REPOSITORY_URL`）；不要猜测或替换仓库地址。目标是宿主明确选定的项目工作区，不是脚手架源码目录。

## 目标目录

优先使用 Agent 宿主明确提供的工作区根目录。若该路径属于 Git 工作区，运行 `git -C <路径> rev-parse --show-toplevel` 并使用其返回值。宿主未提供根目录时，只有当前目录属于 Git 工作区才可从当前目录解析仓库根目录；非 Git 项目不得把当前 shell 目录自动当成根目录，需先从宿主取得明确的工作区根路径。宿主未指定或有多个候选时先询问。空目录若由宿主明确选为工作区，也可作为目标。

检查目标目录内容及 `git status --short`（若为 Git 工作区），保留所有既有改动。安装器不会运行 `git init`、改业务代码或创建提交。

## 获取并验证源码

把用户消息中的仓库 URL 赋给 `ACS_REPOSITORY_URL`。若已有源码目录，将其路径放入 `ACS_SOURCE_DIR`；Git 克隆必须确认顶层目录的 `origin` 与该 URL 完全一致。非 Git 源码只可用于用户明确确认来自该仓库官方 Releases 的发行包，并提供其 Release 版本。不要仅凭目录名信任源码。

以下命令由 Agent 根据宿主路径设置 `ACS_TARGET_DIR`；Git 项目会再解析到仓库根目录。未提供路径时，只有当前目录位于 Git 工作区才自动解析。源码优先复用显式提供的目录，否则在系统临时目录克隆，并在退出时只清理本次创建的临时目录。

### Unix / Bash

```bash
set -euo pipefail
: "${ACS_REPOSITORY_URL:?请使用用户消息中提供的仓库链接}"

target="${ACS_TARGET_DIR:-}"
if [ -z "$target" ]; then
  target="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -n "$target" ] || { echo '未能确定目标工作区根目录；先从 Agent 宿主取得明确路径。' >&2; exit 2; }
[ -d "$target" ] || { echo "目标目录不存在：$target" >&2; exit 2; }
target="$(cd "$target" && pwd)"
if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  target="$(git -C "$target" rev-parse --show-toplevel)"
fi

temp_source=""
cleanup() { if [ -n "$temp_source" ]; then rm -rf -- "$temp_source"; fi; }
trap cleanup EXIT
src="${ACS_SOURCE_DIR:-}"
if [ -z "$src" ]; then
  temp_source="$(mktemp -d "${TMPDIR:-/tmp}/acs.XXXXXX")"
  src="$temp_source/repo"
  git clone --depth 1 "$ACS_REPOSITORY_URL" "$src"
fi
src="$(cd "$src" && pwd)"
if git -C "$src" rev-parse --show-toplevel >/dev/null 2>&1; then
  source_root="$(git -C "$src" rev-parse --show-toplevel)"
  [ "$source_root" = "$src" ] || { echo '源码路径不是仓库根目录。' >&2; exit 2; }
  origin="$(git -C "$src" remote get-url origin)"
  normalize_repo_url() { local value="$1"; value="${value%/}"; value="${value%.git}"; printf '%s' "$value"; }
  [ "$(normalize_repo_url "$origin")" = "$(normalize_repo_url "$ACS_REPOSITORY_URL")" ] || { echo '源码 origin 与用户提供的链接不一致。' >&2; exit 2; }
  source_version="$(git -C "$src" rev-parse HEAD)"
  if [ -n "$(git -C "$src" status --porcelain --untracked-files=normal)" ]; then source_version="$source_version (working tree modified)"; fi
else
  [ "${ACS_TRUSTED_RELEASE_ARCHIVE:-}" = 1 ] && [ -n "${ACS_SOURCE_VERSION:-}" ] || {
    echo '非 Git 源码须由用户确认来自官方 Release，并设置 ACS_TRUSTED_RELEASE_ARCHIVE=1 与 ACS_SOURCE_VERSION。' >&2
    exit 2
  }
  source_version="$ACS_SOURCE_VERSION"
fi

if ! bash "$src/install.sh" --verify "$target"; then
  bash "$src/install.sh" "$target"
  bash "$src/install.sh" --verify "$target"
fi
printf '目标：%s\n源码版本：%s\n' "$target" "$source_version"
```

### Windows / PowerShell 7

```powershell
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:ACS_REPOSITORY_URL)) { throw '请使用用户消息中提供的仓库链接设置 ACS_REPOSITORY_URL。' }

$target = $env:ACS_TARGET_DIR
if ([string]::IsNullOrWhiteSpace($target)) {
    $gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $gitCommand) {
        $candidateOutput = & $gitCommand.Source -C (Get-Location).Path rev-parse --show-toplevel 2>$null
        $gitExit = $LASTEXITCODE
        if ($gitExit -eq 0) { $target = ($candidateOutput | Select-Object -First 1).Trim() }
    }
}
if ([string]::IsNullOrWhiteSpace($target)) { throw '未能确定目标工作区根目录；先从 Agent 宿主取得明确路径。' }
if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "目标目录不存在：$target" }
$target = (Resolve-Path -LiteralPath $target).Path
if ($null -eq $gitCommand) { $gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1 }
if ($null -ne $gitCommand) {
    $candidateOutput = & $gitCommand.Source -C $target rev-parse --show-toplevel 2>$null
    $gitExit = $LASTEXITCODE
    if ($gitExit -eq 0) { $target = ($candidateOutput | Select-Object -First 1).Trim() }
}

$tempSource = $null
try {
    $src = $env:ACS_SOURCE_DIR
    if ([string]::IsNullOrWhiteSpace($src)) {
        if ($null -eq $gitCommand) { throw '未安装 Git；请提供已确认来源的官方 Release 解压目录。' }
        $tempSource = Join-Path $env:TEMP ("acs-" + [guid]::NewGuid().ToString('N'))
        $src = $tempSource
        & $gitCommand.Source clone --depth 1 $env:ACS_REPOSITORY_URL $src
        if ($LASTEXITCODE -ne 0) { throw '克隆失败；请检查 Git、网络和仓库链接。' }
    }
    $src = (Resolve-Path -LiteralPath $src).Path
    $sourceRoot = $null
    $sourceGitExit = 1
    if ($null -ne $gitCommand) {
        $sourceRootOutput = & $gitCommand.Source -C $src rev-parse --show-toplevel 2>$null
        $sourceGitExit = $LASTEXITCODE
        if ($sourceGitExit -eq 0) { $sourceRoot = ($sourceRootOutput | Select-Object -First 1).Trim() }
    }
    if ($null -ne $gitCommand -and $sourceGitExit -eq 0) {
        if ([System.IO.Path]::GetFullPath($sourceRoot) -ne [System.IO.Path]::GetFullPath($src)) { throw '源码路径不是仓库根目录。' }
        $origin = (& $gitCommand.Source -C $src remote get-url origin)
        $originExit = $LASTEXITCODE
        $normalizedOrigin = $origin.Trim().TrimEnd('/') -replace '\.git$', ''
        $normalizedProvidedUrl = $env:ACS_REPOSITORY_URL.Trim().TrimEnd('/') -replace '\.git$', ''
        if ($originExit -ne 0 -or $normalizedOrigin -ine $normalizedProvidedUrl) { throw '源码 origin 与用户提供的链接不一致。' }
        $sourceVersion = (& $gitCommand.Source -C $src rev-parse HEAD).Trim()
        $sourceStatus = & $gitCommand.Source -C $src status --porcelain --untracked-files=normal
        if ($LASTEXITCODE -ne 0) { throw '无法读取源码工作区状态。' }
        if (-not [string]::IsNullOrWhiteSpace(($sourceStatus -join "`n"))) { $sourceVersion += ' (working tree modified)' }
    }
    else {
        if ($env:ACS_TRUSTED_RELEASE_ARCHIVE -ne '1' -or [string]::IsNullOrWhiteSpace($env:ACS_SOURCE_VERSION)) {
            throw '非 Git 源码须由用户确认来自官方 Release，并设置 ACS_TRUSTED_RELEASE_ARCHIVE=1 与 ACS_SOURCE_VERSION。'
        }
        $sourceVersion = $env:ACS_SOURCE_VERSION
    }

    & pwsh -File (Join-Path $src 'install.ps1') -Verify -TargetDir $target
    if ($LASTEXITCODE -ne 0) {
        & pwsh -File (Join-Path $src 'install.ps1') -TargetDir $target
        if ($LASTEXITCODE -ne 0) { throw '安装失败，请检查上方错误。' }
        & pwsh -File (Join-Path $src 'install.ps1') -Verify -TargetDir $target
        if ($LASTEXITCODE -ne 0) { throw '校验失败，请检查缺失资产。' }
    }
    Write-Output "目标：$target`n源码版本：$sourceVersion"
}
finally {
    if ($null -ne $tempSource -and (Test-Path -LiteralPath $tempSource)) {
        Remove-Item -LiteralPath $tempSource -Recurse -Force
    }
}
```

安装通过后，读取项目根目录的 `00__AGENT_START_HERE.md`，按其中规则继续。初始化只安装和验证工作流，不填猜测信息、不修改业务代码、不创建提交。汇报目标路径、源码版本及校验结果；若阻塞，说明具体原因。临时源码会自动清理；以后需要模板时重新获取或显式保留源码目录。
