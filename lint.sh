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

# Accepted ADR stems, for tool gate decisions.
: > "$tmp/adr-accepted"
while IFS= read -r file; do
  base="$(basename "$file")"
  stem="${base%.md}"
  case "$stem" in
    ADR__*)
      if grep -qE '^- Status: Accepted$' "$file"; then
        printf '%s\n' "$stem" >> "$tmp/adr-accepted"
      fi
      ;;
  esac
done < "$tmp/files"

check_tool_field() {
  local entry_file="$1" display="$2" entry_name="$3" pattern="$4" label="$5" count
  count="$(grep -cE "$pattern" "$entry_file" || true)"
  [ -n "$count" ] || count=0
  if [ "$count" -ne 1 ]; then
    err "L14-tools-registry" "$display" "tool '${entry_name}': expected exactly one ${label}"
  fi
}

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
    case " AGENT ADR FEATURE API DATA OPS SEQUENCE STATE DATAFLOW MODULE SUMMARY SOURCE RESEARCH REPORT TASK TOOLS " in
      *" $type "*) ;;
      *) warn "L8-unknown-type" "$display" "unknown type prefix '$type' (see allowed types in 00__AGENT__START_HERE.md)" ;;
    esac
  fi

  # L10: research records carry a question, a status and an as-of date.
  case "$stem" in
    RESEARCH__*)
      question_count="$(grep -cE '^- Question: .+' "$file" || true)"
      status_count="$(grep -cE '^- Status: (active|concluded|superseded)$' "$file" || true)"
      asof_count="$(grep -cE '^- As of: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$file" || true)"
      [ -n "$question_count" ] || question_count=0
      [ -n "$status_count" ] || status_count=0
      [ -n "$asof_count" ] || asof_count=0
      if [ "$question_count" -ne 1 ] || [ "$status_count" -ne 1 ] || [ "$asof_count" -ne 1 ]; then
        err "L10-research-metadata" "$display" "expected exactly one '- Question:', one '- Status: active|concluded|superseded' and one '- As of: YYYY-MM-DD'"
      fi
      ;;
  esac

  # L11: source records carry a type, a citation or URL, and an access date.
  case "$stem" in
    SOURCE__*)
      type_count="$(grep -cE '^- Type: (paper|documentation|source-code|benchmark|article|book|talk|other)$' "$file" || true)"
      citation_count="$(grep -cE '^- (Citation|URL): .+' "$file" || true)"
      accessed_count="$(grep -cE '^- Accessed: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$file" || true)"
      [ -n "$type_count" ] || type_count=0
      [ -n "$citation_count" ] || citation_count=0
      [ -n "$accessed_count" ] || accessed_count=0
      if [ "$type_count" -ne 1 ] || [ "$citation_count" -lt 1 ] || [ "$accessed_count" -ne 1 ]; then
        err "L11-source-metadata" "$display" "expected one valid '- Type:', at least one '- Citation:' or '- URL:', and one '- Accessed: YYYY-MM-DD'"
      fi
      ;;
  esac

  # L12: active task claims carry owner, branch, scope and start date.
  case "$stem" in
    TASK__*)
      status_count="$(grep -cE '^- Status: (active|blocked|done)$' "$file" || true)"
      owner_count="$(grep -cE '^- Owner: .+' "$file" || true)"
      branch_count="$(grep -cE '^- Branch: .+' "$file" || true)"
      scope_count="$(grep -cE '^- Scope: .+' "$file" || true)"
      started_count="$(grep -cE '^- Started: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$file" || true)"
      [ -n "$status_count" ] || status_count=0
      [ -n "$owner_count" ] || owner_count=0
      [ -n "$branch_count" ] || branch_count=0
      [ -n "$scope_count" ] || scope_count=0
      [ -n "$started_count" ] || started_count=0
      if [ "$status_count" -ne 1 ] || [ "$owner_count" -ne 1 ] || [ "$branch_count" -ne 1 ] || [ "$scope_count" -ne 1 ] || [ "$started_count" -ne 1 ]; then
        err "L12-task-claim" "$display" "expected exactly one '- Status: active|blocked|done', '- Owner:', '- Branch:', '- Scope:' and '- Started: YYYY-MM-DD'"
      fi
      ;;
  esac

  # L14 / L15: tool registry schema and gate decisions.
  case "$stem" in
    TOOLS__*)
      status_count="$(grep -cE '^- Status: (active|retired)$' "$file" || true)"
      asof_count="$(grep -cE '^- As of: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$file" || true)"
      [ -n "$status_count" ] || status_count=0
      [ -n "$asof_count" ] || asof_count=0
      if [ "$status_count" -ne 1 ] || [ "$asof_count" -ne 1 ]; then
        err "L14-tools-registry" "$display" "expected exactly one '- Status: active|retired' and one '- As of: YYYY-MM-DD'"
      fi

      headings="$(grep -E '^## ' "$file" | sed 's/^## //' || true)"
      if [ -n "$headings" ]; then
        duplicates="$(printf '%s\n' "$headings" | LC_ALL=C sort | uniq -d || true)"
        if [ -n "$duplicates" ]; then
          while IFS= read -r duplicate; do
            [ -n "$duplicate" ] || continue
            err "L14-tools-registry" "$display" "duplicate tool entry '${duplicate}'"
          done <<EOF
$duplicates
EOF
        fi
      fi

      rm -rf "$tmp/tools"
      mkdir -p "$tmp/tools"
      awk -v dir="$tmp/tools" '
        /^## / {
          n++
          file = dir "/entry-" n
          print > file
          next
        }
        file != "" { print >> file }
      ' "$file"

      for entry_file in "$tmp/tools"/*; do
        [ -f "$entry_file" ] || continue
        entry_name="$(head -n 1 "$entry_file" | sed 's/^##[[:space:]]*//')"
        if [ -z "$entry_name" ]; then
          err "L14-tools-registry" "$display" "empty tool heading"
          continue
        fi
        if ! printf '%s' "$entry_name" | grep -qE '^[a-z][a-z0-9-]*$'; then
          err "L14-tools-registry" "$display" "tool '${entry_name}': id must match ^[a-z][a-z0-9-]*$"
        fi

        check_tool_field "$entry_file" "$display" "$entry_name" '^- Category: [a-z][a-z0-9]*(\.[a-z][a-z0-9]*)?$' "'- Category:' with a dotted lowercase identifier"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- State: (candidate|declared|installed|verified|retired)$' "'- State:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Version: .+$' "'- Version:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Provenance: .+$' "'- Provenance:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- License: .+$' "'- License:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Install: .+$' "'- Install:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Invoke: .+$' "'- Invoke:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Mode: (advisory|gate)$' "'- Mode:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Scope: (local|ci|both)$' "'- Scope:'"
        check_tool_field "$entry_file" "$display" "$entry_name" '^- Data: (local|downloads|uploads)$' "'- Data:'"

        version="$(sed -nE 's/^- Version: (.*)$/\1/p' "$entry_file" | head -n 1)"
        case "$version" in
          latest|stable|current|main|master|HEAD|'*'|'^'*|'~'*|'>'*|'<'*|*.[xX]|[xX].*|*' '*)
            err "L14-tools-registry" "$display" "tool '${entry_name}': '- Version:' must be exact, not '${version}'"
            ;;
        esac

        state="$(sed -nE 's/^- State: (candidate|declared|installed|verified|retired)$/\1/p' "$entry_file" | head -n 1)"
        mode="$(sed -nE 's/^- Mode: (advisory|gate)$/\1/p' "$entry_file" | head -n 1)"
        data_class="$(sed -nE 's/^- Data: (local|downloads|uploads)$/\1/p' "$entry_file" | head -n 1)"

        if [ "$state" = "installed" ] || [ "$state" = "verified" ]; then
          check_tool_field "$entry_file" "$display" "$entry_name" '^- Checksum: (sha256:[0-9a-fA-F]{64}|package-manager:.+)$' "'- Checksum:' (sha256 or package-manager)"
        fi
        if [ "$state" = "verified" ]; then
          check_tool_field "$entry_file" "$display" "$entry_name" '^- Smoke: .+$' "'- Smoke:'"
          check_tool_field "$entry_file" "$display" "$entry_name" '^- Last verified: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "'- Last verified: YYYY-MM-DD'"
        fi

        decision_count="$(grep -cE '^- Decision: .+' "$entry_file" || true)"
        [ -n "$decision_count" ] || decision_count=0

        if [ "$mode" = "gate" ] && [ "$state" != "verified" ]; then
          err "L15-tools-gate" "$display" "tool '${entry_name}': Mode: gate requires State: verified (found '${state:-missing}')"
        fi
        if [ "$state" = "retired" ] && [ "$mode" = "gate" ]; then
          err "L15-tools-gate" "$display" "tool '${entry_name}': retired tools must not be Mode: gate"
        fi
        if { [ "$mode" = "gate" ] || { [ "$data_class" = "uploads" ] && [ "$state" != "candidate" ]; }; } && [ "$decision_count" -eq 0 ]; then
          err "L15-tools-gate" "$display" "tool '${entry_name}': Mode: gate and declared Data: uploads require a Decision: [[ADR__...]] link"
        fi
        if [ "$decision_count" -gt 0 ]; then
          accepted=0
          decision_links="$(grep -E '^- Decision:' "$entry_file" | grep -oE '\[\[ADR__[^]]+\]\]' | sed -e 's/^\[\[//' -e 's/\]\]$//' -e 's/|.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' || true)"
          if [ -n "$decision_links" ]; then
            while IFS= read -r link; do
              [ -n "$link" ] || continue
              if grep -Fxq -- "$link" "$tmp/adr-accepted"; then
                accepted=$((accepted + 1))
              fi
            done <<EOF
$decision_links
EOF
          fi
          if [ "$accepted" -eq 0 ]; then
            err "L15-tools-gate" "$display" "tool '${entry_name}': Decision must link at least one Accepted ADR"
          fi
        fi
      done
      rm -rf "$tmp/tools"
      ;;
  esac
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

# L13: every TASK__<id> named on the board has a claim file.
tasks_dir="40__MEMORY/tasks"
if [ -f "$TARGET/$board" ] && [ -d "$TARGET/$tasks_dir" ]; then
  refs="$(grep -oE 'TASK__[A-Za-z0-9][A-Za-z0-9-]*' "$TARGET/$board" || true)"
  if [ -n "$refs" ]; then
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      if [ ! -f "$TARGET/$tasks_dir/${ref}.md" ]; then
        err "L13-task-board-reference" "$board" "$ref has no claim file in $tasks_dir/"
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
    warn "L9-journal-count" "$journal" "${raw_count} raw entries; consider compaction (see AGENT__procedure__tidy-the-journal.md)"
  fi
fi

echo "lint: ${errors} errors, ${warnings} warnings"
[ "$errors" -eq 0 ]
