#!/usr/bin/env bash
# =============================================================
# agent-coldstart-scaffold / lint.sh
#
# Purpose: check a project's knowledge base for mechanically detectable errors.
# Requires: bash 3.2+ and POSIX tools (find, grep, sed, awk, sort, uniq, wc).
# Exit codes: 0 no errors / 1 errors found / 2 usage or environment error
# =============================================================
set -uo pipefail

TARGET="."
QUIET=0
errors=0
warnings=0
tmp=""

usage() {
  cat <<'USAGE'
Usage: bash lint.sh [--quiet] [target-dir]

Checks every Markdown file in the target project (default: current directory).

Options:
  --quiet   Print only the final summary.
  -h, --help  Show this help.

Exit codes: 0 no errors, 1 errors found, 2 usage or environment error.
USAGE
}

die() { echo "Error: $*" >&2; [ -n "$tmp" ] && rm -rf "$tmp"; exit 2; }

cleanup() { [ -n "$tmp" ] && rm -rf "$tmp"; }
trap cleanup EXIT

POSITIONAL=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "Error: unknown option: $1 (see --help)" >&2; exit 2 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
[ "${#POSITIONAL[@]}" -le 1 ] || die "At most one target directory argument is accepted"
[ "${#POSITIONAL[@]}" -eq 1 ] && TARGET="${POSITIONAL[0]}"

[ -d "$TARGET" ] || die "Target directory does not exist: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/acs-lint.XXXXXX")" || die "Cannot create a temporary directory"

emit() {
  local level="$1" code="$2" path="$3" message="$4"
  if [ "$QUIET" -eq 0 ]; then
    printf '%-6s %-22s %s: %s\n' "$level" "$code" "$path" "$message"
  fi
  if [ "$level" = "ERROR" ]; then
    errors=$((errors + 1))
  else
    warnings=$((warnings + 1))
  fi
}

err()  { emit "ERROR" "$1" "$2" "$3"; }
warn() { emit "WARN"  "$1" "$2" "$3"; }

# All Markdown files, excluding generated and dependency directories.
find "$TARGET" \
    \( -path "$TARGET/tests/fixtures" -o -name .git -o -name node_modules -o -name dist -o -name build -o -name out \
       -o -name vendor -o -name target -o -name .venv -o -name venv \
       -o -name __pycache__ -o -name .next -o -name coverage \) -prune -o \
    -name '*.md' -type f -print | LC_ALL=C sort > "$tmp/files"

# Every file stem in the repository, for link resolution.
: > "$tmp/stems"
while IFS= read -r file; do
  base="$(basename "$file")"
  printf '%s\n' "${base%.md}" >> "$tmp/stems"
done < "$tmp/files"
LC_ALL=C sort "$tmp/stems" -o "$tmp/stems"
LC_ALL=C sort "$tmp/stems" | uniq -d > "$tmp/duplicates"

# Strip fenced code blocks (tracking backtick-run length so nested fences work)
# and inline code spans, then print bare [[links]].
extract_links() {
  awk '
    {
      line = $0
      sub(/^[[:space:]]*/, "", line)
      if (line ~ /^`+/) {
        n = 0
        while (substr(line, n + 1, 1) == "`") n++
        rest = substr(line, n + 1)
        if (fence == 0) { fence = n; next }
        if (n >= fence && rest ~ /^[[:space:]]*$/) { fence = 0; next }
      }
      if (fence == 0) print
    }' "$1" \
    | sed 's/`[^`]*`//g' \
    | grep -oE '\[\[[^]]*\]\]' \
    | sed -e 's/^\[\[//' -e 's/\]\]$//' -e 's/|.*$//' \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

while IFS= read -r file; do
  display="${file#"$TARGET"/}"
  base="$(basename "$file")"
  stem="${base%.md}"

  # The scaffold repository keeps full-install fixtures; they are linted as their own targets.
  case "$display" in
    tests/fixtures/*) continue ;;
  esac

  case "$base" in
    _TEMPLATE__*) continue ;;
  esac

  # L1 / L2: dangling and ambiguous links.
  links="$(extract_links "$file" || true)"
  if [ -n "$links" ]; then
    while IFS= read -r link; do
      [ -n "$link" ] || continue
      count="$(grep -Fxc -- "$link" "$tmp/stems" || true)"
      [ -n "$count" ] || count=0
      if [ "$count" -eq 0 ]; then
        err "L1-dangling-link" "$display" "[[${link}]] does not resolve to any .md file"
      elif [ "$count" -gt 1 ]; then
        err "L2-ambiguous-link" "$display" "[[${link}]] matches ${count} .md files"
      fi
    done <<EOF
$links
EOF
  fi

  # L3: title equals filename stem for TYPE files and journal entries.
  if printf '%s' "$stem" | grep -qE '^[A-Z][A-Z0-9]*__.+$' \
    || printf '%s' "$stem" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}__.+$'; then
    title="$(grep -m1 '^# ' "$file" || true)"
    title="${title#\# }"
    if [ "$title" != "$stem" ]; then
      err "L3-title-mismatch" "$display" "first heading is '$title', expected '$stem'"
    fi
  fi

  # L4 / L5: ADR status validity and rejected-ADR naming.
  case "$stem" in
    ADR__*)
      allowed_count="$(grep -cE '^- Status: (Proposed|Accepted|Rejected|Superseded by \[\[ADR__[^]]+\]\])$' "$file" || true)"
      status_count="$(grep -cE '^- Status:' "$file" || true)"
      [ -n "$allowed_count" ] || allowed_count=0
      [ -n "$status_count" ] || status_count=0
      if [ "$status_count" -ne 1 ] || [ "$allowed_count" -ne 1 ]; then
        err "L4-adr-status" "$display" "expected exactly one valid '- Status:' line, found ${status_count} status line(s), ${allowed_count} valid"
      fi
      if grep -qE '^- Status: Rejected$' "$file"; then
        case "$stem" in
          ADR__rejected__*) ;;
          *) err "L5-rejected-name" "$display" "Rejected ADR must be named ADR__rejected__*" ;;
        esac
      fi
      case "$stem" in
        ADR__rejected__*)
          if ! grep -qE '^- Status: Rejected$' "$file"; then
            err "L5-rejected-name" "$display" "ADR__rejected__* must have '- Status: Rejected'"
          fi
          ;;
      esac
      ;;
  esac

  # L8: unknown type prefix.
  type="$(printf '%s' "$stem" | sed -nE 's/^([0-9]{2}__)?([A-Z][A-Z0-9]*)__.*/\2/p')"
  if [ -n "$type" ]; then
    case " AGENT ADR FEATURE API DATA OPS SEQUENCE STATE DATAFLOW MODULE SUMMARY " in
      *" $type "*) ;;
      *) warn "L8-unknown-type" "$display" "unknown type prefix '$type' (see allowed types in 00__AGENT__START_HERE.md)" ;;
    esac
  fi
done < "$tmp/files"

# L6: task-board question references must exist in open questions.
board="40__MEMORY/task_board.md"
questions="40__MEMORY/open_questions_for_human.md"
if [ -f "$TARGET/$board" ] && [ -f "$TARGET/$questions" ]; then
  refs="$(grep -oE 'Q-[A-Za-z0-9][A-Za-z0-9-]*' "$TARGET/$board" || true)"
  if [ -n "$refs" ]; then
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      if ! grep -Fq -- "$ref" "$TARGET/$questions"; then
        err "L6-orphan-question" "$board" "$ref is not listed in $questions"
      fi
    done <<EOF
$refs
EOF
  fi
fi

# L7 / L9: journal completeness and size.
journal="40__MEMORY/journal"
if [ -d "$TARGET/$journal" ]; then
  raw_count=0
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    base="$(basename "$file")"
    case "$base" in
      SUMMARY__*) continue ;;
    esac
    raw_count=$((raw_count + 1))
    if grep -qE '^- Task:' "$file" && ! grep -qE '^- Did:' "$file"; then
      warn "L7-incomplete-journal" "${file#"$TARGET"/}" "entry has 'Task:' but no 'Did:' (interrupted or still open)"
    fi
  done <<EOF
$(find "$TARGET/$journal" -maxdepth 1 -name '*.md' -type f -print)
EOF
  if [ "$raw_count" -gt 20 ]; then
    warn "L9-journal-count" "$journal" "${raw_count} raw entries; consider compaction (see AGENT__procedure__compaction.md)"
  fi
fi

echo "lint: ${errors} errors, ${warnings} warnings"
[ "$errors" -eq 0 ]
