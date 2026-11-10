# AGENT__bootstrap-instruction

When a user sends the URL of this repository in a project agent session, treat it as an installation request unless they state another purpose. Use only the exact URL the user provided (`ACS_REPOSITORY_URL`); never guess or substitute a repository address. The target is the project workspace explicitly selected by the host, not the scaffold source directory.

## Target directory

Prefer the workspace root explicitly provided by the agent host. If that path is a Git worktree, run `git -C <path> rev-parse --show-toplevel` and use its output. If the host provides no root, resolve the repository root from the current directory only when the current directory is inside a Git worktree; for a non-Git project, do not assume the current shell directory is the root — obtain an explicit workspace root from the host first. Ask first when the host specifies nothing or several candidates exist. An empty directory explicitly chosen by the host is also acceptable.

Inspect the target contents and `git status --short` (if it is a Git worktree) and preserve every existing change. The installer never runs `git init`, changes business code, or creates commits.

## Fetch and verify the source

Assign the repository URL from the user's message to `ACS_REPOSITORY_URL`. If a source directory already exists, put its path in `ACS_SOURCE_DIR`; a Git clone must have an `origin` that exactly matches that URL. A non-Git source is acceptable only when the user explicitly confirms it is an official release archive downloaded from this repository's Releases, and provides its release version. Do not trust a directory just because of its name.

The commands below let the agent set `ACS_TARGET_DIR` from the host path; Git projects are then resolved to their repository root. When no path is provided, resolve automatically only if the current directory is inside a Git worktree. Prefer an explicitly provided source directory; otherwise clone into a temporary directory and clean up only the temporary directory created by this run.

### Unix / Bash

```bash
set -euo pipefail
: "${ACS_REPOSITORY_URL:?Set ACS_REPOSITORY_URL to the repository link from the user message}"

target="${ACS_TARGET_DIR:-}"
if [ -z "$target" ]; then
  target="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -n "$target" ] || { echo 'Could not determine the target workspace root; obtain an explicit path from the agent host first.' >&2; exit 2; }
[ -d "$target" ] || { echo "Target directory does not exist: $target" >&2; exit 2; }
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
  [ "$source_root" = "$src" ] || { echo 'Source path is not the repository root.' >&2; exit 2; }
  origin="$(git -C "$src" remote get-url origin)"
  normalize_repo_url() { local value="$1"; value="${value%/}"; value="${value%.git}"; printf '%s' "$value"; }
  [ "$(normalize_repo_url "$origin")" = "$(normalize_repo_url "$ACS_REPOSITORY_URL")" ] || { echo 'Source origin does not match the URL provided by the user.' >&2; exit 2; }
  source_version="$(git -C "$src" rev-parse HEAD)"
  if [ -n "$(git -C "$src" status --porcelain --untracked-files=normal)" ]; then source_version="$source_version (working tree modified)"; fi
else
  [ "${ACS_TRUSTED_RELEASE_ARCHIVE:-}" = 1 ] && [ -n "${ACS_SOURCE_VERSION:-}" ] || {
    echo 'Non-Git sources require user confirmation that they came from an official release, plus ACS_TRUSTED_RELEASE_ARCHIVE=1 and ACS_SOURCE_VERSION.' >&2
    exit 2
  }
  source_version="$ACS_SOURCE_VERSION"
fi

if ! bash "$src/install.sh" --verify "$target"; then
  bash "$src/install.sh" "$target"
  bash "$src/install.sh" --verify "$target"
fi
printf 'Target: %s\nSource version: %s\n' "$target" "$source_version"
```

### Windows / PowerShell 7

```powershell
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:ACS_REPOSITORY_URL)) { throw 'Set ACS_REPOSITORY_URL to the repository link from the user message.' }

$target = $env:ACS_TARGET_DIR
if ([string]::IsNullOrWhiteSpace($target)) {
    $gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $gitCommand) {
        $candidateOutput = & $gitCommand.Source -C (Get-Location).Path rev-parse --show-toplevel 2>$null
        $gitExit = $LASTEXITCODE
        if ($gitExit -eq 0) { $target = ($candidateOutput | Select-Object -First 1).Trim() }
    }
}
if ([string]::IsNullOrWhiteSpace($target)) { throw 'Could not determine the target workspace root; obtain an explicit path from the agent host first.' }
if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "Target directory does not exist: $target" }
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
        if ($null -eq $gitCommand) { throw 'Git is not installed; provide an official release archive directory whose origin the user has confirmed.' }
        $tempSource = Join-Path $env:TEMP ("acs-" + [guid]::NewGuid().ToString('N'))
        $src = $tempSource
        & $gitCommand.Source clone --depth 1 $env:ACS_REPOSITORY_URL $src
        if ($LASTEXITCODE -ne 0) { throw 'Clone failed; check Git, the network and the repository URL.' }
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
        if ([System.IO.Path]::GetFullPath($sourceRoot) -ne [System.IO.Path]::GetFullPath($src)) { throw 'Source path is not the repository root.' }
        $origin = (& $gitCommand.Source -C $src remote get-url origin)
        $originExit = $LASTEXITCODE
        $normalizedOrigin = $origin.Trim().TrimEnd('/') -replace '\.git$', ''
        $normalizedProvidedUrl = $env:ACS_REPOSITORY_URL.Trim().TrimEnd('/') -replace '\.git$', ''
        if ($originExit -ne 0 -or $normalizedOrigin -ine $normalizedProvidedUrl) { throw 'Source origin does not match the URL provided by the user.' }
        $sourceVersion = (& $gitCommand.Source -C $src rev-parse HEAD).Trim()
        $sourceStatus = & $gitCommand.Source -C $src status --porcelain --untracked-files=normal
        if ($LASTEXITCODE -ne 0) { throw 'Cannot read the source worktree status.' }
        if (-not [string]::IsNullOrWhiteSpace(($sourceStatus -join "`n"))) { $sourceVersion += ' (working tree modified)' }
    }
    else {
        if ($env:ACS_TRUSTED_RELEASE_ARCHIVE -ne '1' -or [string]::IsNullOrWhiteSpace($env:ACS_SOURCE_VERSION)) {
            throw 'Non-Git sources require user confirmation that they came from an official release, plus ACS_TRUSTED_RELEASE_ARCHIVE=1 and ACS_SOURCE_VERSION.'
        }
        $sourceVersion = $env:ACS_SOURCE_VERSION
    }

    & pwsh -File (Join-Path $src 'install.ps1') -Verify -TargetDir $target
    if ($LASTEXITCODE -ne 0) {
        & pwsh -File (Join-Path $src 'install.ps1') -TargetDir $target
        if ($LASTEXITCODE -ne 0) { throw 'Installation failed; check the errors above.' }
        & pwsh -File (Join-Path $src 'install.ps1') -Verify -TargetDir $target
        if ($LASTEXITCODE -ne 0) { throw 'Verification failed; check for missing assets.' }
    }
    Write-Output "Target: $target`nSource version: $sourceVersion"
}
finally {
    if ($null -ne $tempSource -and (Test-Path -LiteralPath $tempSource)) {
        Remove-Item -LiteralPath $tempSource -Recurse -Force
    }
}
```

After installation passes, read `00__AGENT__START_HERE.md` in the project root and follow it. If `20__PROJECT_CONTEXT/project_conventions.md` still says "unknown" for the test command, follow `30__PROCEDURES/AGENT__procedure__first_session.md` — but only draft and ask; write nothing the human has not confirmed. Initialization installs and verifies the workflow; it does not guess project facts, change business code, or create commits. Report the target path, source version, verification result, and any `LEGACY` lines the installer printed. Temporary sources are removed automatically; keep `ACS_SOURCE_DIR` if templates or `lint.sh` will be needed later.

If the installer skipped an existing `AGENTS.md`, tell the user the one line to add to it. If the host reads a different file (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`), suggest adding the same line there; do not create those files unasked.
