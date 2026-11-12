#!/usr/bin/env bash
# =============================================================
# agent-coldstart-scaffold / install.sh
#
# Purpose: install the AI-native workflow scaffold into an existing project.
# Features: idempotent (never overwrites), read-only verification (presence only).
# Requires: bash 3.2+ and common Unix tools.
# Exit codes: 0 success / 1 verification found missing files / 2 usage or environment error
# =============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() { echo "Error: $*" >&2; exit 2; }

# Returns 0 if any parent component of rel_path is a symbolic link.
has_symlink_parent() {
  local rel_path="$1"
  local parent_rel current component
  case "$rel_path" in
    */*) parent_rel="${rel_path%/*}" ;;
    *) return 1 ;;
  esac

  current="$TARGET"
  while [ -n "$parent_rel" ]; do
    component="${parent_rel%%/*}"
    if [ "$parent_rel" = "$component" ]; then
      parent_rel=""
    else
      parent_rel="${parent_rel#*/}"
    fi
    current="${current}/${component}"
    [ -L "$current" ] && return 0
  done
  return 1
}

usage() {
  cat <<'USAGE'
Usage: bash install.sh [options] [target-dir]

The target directory must already exist; it defaults to the current directory.

Options:
  --verify            Only check that asset files are present; write nothing.
  --scaffold-dir DIR  Asset directory (default: scaffold/ beside this script).
  -h, --help          Show this help.

Examples:
  bash install.sh /path/to/project
  bash install.sh --verify /path/to/project
USAGE
}

MODE="install"
SCAFFOLD_DIR="${SCRIPT_DIR}/scaffold"
POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --verify) MODE="verify"; shift ;;
    --scaffold-dir)
      [ "$#" -ge 2 ] || die "--scaffold-dir requires a path argument"
      SCAFFOLD_DIR="$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    --*) die "Unknown option: $1 (see --help)" ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

[ "${#POSITIONAL[@]}" -le 1 ] || die "At most one target directory argument is accepted"
TARGET="."
if [ "${#POSITIONAL[@]}" -eq 1 ]; then
  TARGET="${POSITIONAL[0]}"
fi

[ -d "$SCAFFOLD_DIR" ] || die "Asset directory not found: ${SCAFFOLD_DIR}
  Run this script from inside the unpacked agent-coldstart-scaffold/ directory,
  or pass --scaffold-dir explicitly."

SCAFFOLD_DIR="$(cd "$SCAFFOLD_DIR" && pwd)"
target_arg="$TARGET"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" \
  || die "Target directory does not exist: ${target_arg} (create it first; this script does not create project roots)"

created=0
skipped=0
present=0
missing=0
conflicts=0
total=0

# find runs in a process substitution; NUL separation handles paths with spaces.
while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  dst="${TARGET}/${rel}"
  total=$((total + 1))

  if [ "$MODE" = "install" ]; then
    if has_symlink_parent "$rel"; then
      echo "  CONFLICT ${rel} (parent path is a symbolic link; refusing to write outside the target)" >&2
      conflicts=$((conflicts + 1))
    elif [ -f "$dst" ]; then
      echo "  SKIP    ${rel}"
      skipped=$((skipped + 1))
      if [ "$rel" = ".gitignore" ]; then
        echo "          └ Target already has .gitignore; confirm it covers dependencies, build output and .tools/"
      fi
      if [ "$rel" = "AGENTS.md" ]; then
        echo "          └ AGENTS.md already exists. Add this line to it so agent hosts load the workflow:"
        echo "            Before doing anything in this repository, read \`00__AGENT__START_HERE.md\` and follow it."
      fi
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
      echo "  CONFLICT ${rel} (target path exists but is not a regular file; not overwritten)" >&2
      conflicts=$((conflicts + 1))
    else
      mkdir -p "$(dirname "$dst")" || die "Cannot create target directory: $(dirname "$dst")"
      cp "${SCAFFOLD_DIR}/${rel}" "$dst" || die "Cannot copy asset: ${rel}"
      echo "  OK      ${rel}"
      created=$((created + 1))
    fi
  elif has_symlink_parent "$rel"; then
    echo "  MISSING ${rel} (parent path is a symbolic link)"
    missing=$((missing + 1))
  elif [ -f "$dst" ]; then
    present=$((present + 1))
  else
    echo "  MISSING ${rel}"
    missing=$((missing + 1))
  fi
done < <(cd "$SCAFFOLD_DIR" && find . -type f -print0)

legacy_count=0
check_legacy() {
  local list="${SCRIPT_DIR}/legacy-paths.txt"
  local rel

  if [ -f "$list" ]; then
    while IFS= read -r rel || [ -n "$rel" ]; do
      [ -n "$rel" ] || continue
      rel="${rel%\r}"
      if [ -e "${TARGET}/${rel}" ] || [ -L "${TARGET}/${rel}" ]; then
        echo "  LEGACY  ${rel} (from an older scaffold version; review and remove manually)" >&2
        legacy_count=$((legacy_count + 1))
      fi
    done < "$list"
  fi

  if [ -f "${TARGET}/00__AGENT__START_HERE.md" ] \
    && ! grep -qF 'agent-coldstart-scaffold entry v6' "${TARGET}/00__AGENT__START_HERE.md"; then
    echo "  LEGACY  00__AGENT__START_HERE.md (older entry file; it does not reference the v6 layout. Replace it manually with scaffold/00__AGENT__START_HERE.md)" >&2
    legacy_count=$((legacy_count + 1))
  fi
}

check_legacy

if [ "$MODE" = "install" ]; then
  if [ "$conflicts" -gt 0 ]; then
    if [ "$legacy_count" -gt 0 ]; then
      echo "Legacy paths found: ${legacy_count}. See README \"Upgrading\"." >&2
    fi
    die "Found ${conflicts} target path conflict(s); resolve them and rerun the installer"
  fi

  echo ""
  echo "============================================================"
  echo " Install complete: ${created} file(s) created, ${skipped} existing file(s) skipped"
  echo ""
  echo " No Git repository was initialized. Copy templates/ from the source directory when needed."
  echo "============================================================"
  if [ "$legacy_count" -gt 0 ]; then
    echo "Legacy paths found: ${legacy_count}. See README \"Upgrading\"."
  fi
  exit 0
fi

echo ""
echo "============================================================"
if [ "$missing" -eq 0 ]; then
  echo " Verification passed: ${present}/${total} file(s) present"
  echo "============================================================"
  if [ "$legacy_count" -gt 0 ]; then
    echo "Legacy paths found: ${legacy_count}. See README \"Upgrading\"."
  fi
  exit 0
fi

echo " Verification failed: ${present} present, ${missing} missing"
echo " Fix: rerun bash install.sh '${TARGET}' from the scaffold directory"
echo "============================================================"
if [ "$legacy_count" -gt 0 ]; then
  echo "Legacy paths found: ${legacy_count}. See README \"Upgrading\"."
fi
exit 1
