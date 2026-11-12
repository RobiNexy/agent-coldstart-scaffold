# Upgrading an installed project

This is the agent-facing upgrade procedure for a project that already contains the scaffold. Humans: see the README section "升级".

The installer only adds missing files and never overwrites. An upgrade therefore has two parts: let the installer add new assets, then merge changed assets by hand.

## Before you start

- Resolve the target project root. Ask if the host provides no root or several candidates.
- Verify the source as `AGENT__bootstrap-instruction.md` requires: a Git origin matching the URL the user provided, or a user-confirmed official release archive.
- Read `VERSION` in the source root. That value is the target version.
- Run `git status --short` in the target. Never overwrite or discard changes you did not make.
- If the target is not a Git repository, ask the user to back it up first.

## 1. Detect the installed version

The first line of the target `00__AGENT__START_HERE.md` carries the version marker:

```text
<!-- agent-coldstart-scaffold entry v7.0.0 -->
```

The version in that marker is the installed version.

- Marker missing or unreadable: the project predates v6, or the entry was replaced. Follow "Pre-v6" below; ask if unsure.
- Installed equals target: run step 5 and report "already current".
- Installed is newer than target: the source is older than the project. Stop and ask.

## 2. Build the change list

List every file the source ships and compare it with the target:

```bash
src=/path/to/verified/source
target=/path/to/project
while IFS= read -r -d '' f; do
  rel="${f#./}"
  if [ ! -e "$target/$rel" ]; then
    printf 'NEW  %s\n' "$rel"
  elif ! cmp -s "$src/scaffold/$rel" "$target/$rel"; then
    printf 'DIFF %s\n' "$rel"
  fi
done < <(cd "$src/scaffold" && find . -type f -print0)
```

Classify every `DIFF` file before touching it. In a full clone, the content installed by version `v<installed>` is available at that tag:

```bash
git -C "$src" show "v<installed>:scaffold/<path>" | cmp -s - "$target/<path>" \
  && echo "unchanged since install" || echo "locally modified"
```

| Category | Action |
|---|---|
| `NEW` | The installer adds it. |
| `DIFF`, unchanged since install | Safe to replace with the new version after telling the user. |
| `DIFF`, locally modified | Merge by hand. Read both sides; never blindly overwrite. |
| Present only in the target | Project content, or an asset removed by a newer version. Do not delete without explicit approval. |

## 3. Apply

1. Run `bash "$src/install.sh" "$target"` (Windows: `pwsh -File "$src/install.ps1" -TargetDir "$target"`). It adds `NEW` files and skips everything that exists.
2. Apply the version notes in step 4 in order, oldest first.
3. Replace files marked "unchanged since install".
4. Merge upstream changes into files marked "locally modified".
5. Remove legacy paths only after migrating their content, and only with approval. `legacy-paths.txt` lists what older versions left behind.

The entry file is special. Keep the user's edits, but update the marker line and any instructions that changed. If the entry is unmodified, replacing it wholesale is fine.

## 4. Version notes

Apply every section between the installed and target versions.

### 6.0.0 → 6.1.0

- New root files: `VERSION` and `UPGRADING.md`. They belong to the scaffold source repository; the installer does not copy them into the project.
- New installed procedures:
  - `30__PROCEDURES/AGENT__procedure__formal-problem-solving.md`
  - `30__PROCEDURES/AGENT__procedure__cicd-pipeline.md`
  - `30__PROCEDURES/AGENT__procedure__docker-configuration.md`
  - `30__PROCEDURES/AGENT__procedure__git-discipline.md`
  - `30__PROCEDURES/AGENT__procedure__writing-user-manual.md`
  - `30__PROCEDURES/AGENT__procedure__go-engineering.md`
  - `30__PROCEDURES/AGENT__procedure__rust-engineering.md`
  - `30__PROCEDURES/AGENT__procedure__c-cpp-engineering.md`
  - `30__PROCEDURES/AGENT__procedure__latex-authoring.md`
  - `30__PROCEDURES/AGENT__procedure__design-language.md`
  - `30__PROCEDURES/AGENT__procedure__paper-reading.md`
- The installed procedures are new files, so the installer adds them. The entry gains a corresponding row in its "When you are about to…" table; merge that row into the existing entry without discarding local edits.
- The entry marker changes from `v6` to `v6.1.0`. Update that one comment line; no other entry change is required.
- No installed asset was removed and no directory was renamed.

### 6.1.0 → 6.2.0

- New installed assets:
  - `50__RESEARCH/.gitkeep`
  - `50__RESEARCH/sources/.gitkeep`
  - `30__PROCEDURES/AGENT__procedure__research.md`
  - `30__PROCEDURES/AGENT__procedure__long-form-writing.md`
- New knowledge types: `SOURCE`, `RESEARCH` and `REPORT`. Merge the updated allowed-types line, the `50__RESEARCH/` row and the two procedure rows into the existing entry.
- `lint` now reports `L10-research-metadata` and `L11-source-metadata`. Run it after the merge.
- Templates under `templates/research/` belong to the source repository; copy one into the project when needed.
- The entry marker changes to `v6.2.0`.
- No installed asset was removed and no directory was renamed.

### 6.2.0 → 6.3.0

- New installed assets:
  - `40__MEMORY/tasks/.gitkeep`
  - `30__PROCEDURES/AGENT__procedure__parallel-work.md`
- New knowledge type: `TASK`. Merge the updated allowed-types line, the `40__MEMORY/tasks/` row and the parallel-work row into the entry.
- `40__MEMORY/task_board.md` changes its single-writer note to name the integrator and the claims directory. Merge that note; do not discard local board content.
- `lint` now reports `L12-task-claim` and `L13-task-board-reference`. Run it after the merge.
- `templates/tasks/_TEMPLATE__TASK.md` belongs to the source repository; copy it when needed.
- The entry marker changes to `v6.3.0`.
- No installed asset was removed and no directory was renamed.

### 6.3.0 → 6.4.0

- New installed assets:
  - `20__PROJECT_CONTEXT/TOOLS__tool-registry.md`
  - `30__PROCEDURES/AGENT__procedure__tooling.md`
- New knowledge type: `TOOLS`. Merge the updated allowed-types line, the `20__PROJECT_CONTEXT/TOOLS__tool-registry.md` row and the tooling procedure row into the entry.
- `20__PROJECT_CONTEXT/project_conventions.md` gains an "External tools" section. Merge it into the existing file; the installer will not overwrite that file.
- `lint` now reports `L14-tools-registry` and `L15-tools-gate`. Run it after the merge. The empty default registry must pass.
- `templates/tooling/_TEMPLATE__TOOLS.md` belongs to the source repository; copy it when a tool entry needs a starting point.
- `scaffold/.gitignore` now ignores `.tools/`. If the target has its own `.gitignore`, add `.tools/` there instead; the installer will not overwrite it.
- The entry marker changes to `v6.4.0`.
- No installed asset was removed and no directory was renamed.

### 6.4.0 → 6.5.0

- The entry gains a mandatory `Begin` step: list `30__PROCEDURES/` and read every procedure whose filename matches the task. Merge it into the existing entry; the trigger table becomes an index, not a substitute for the directory listing.
- `10__ALWAYS_LOAD/AGENT__rules.md` gains the matching rule. Merge it into the existing file.
- `30__PROCEDURES/AGENT__procedure__task_end.md` adds the `Procedures` journal field to the start/close templates and the field table. Merge it.
- The entry marker changes to `v6.5.0`.
- No installed asset was removed and no directory was renamed.

### 6.5.0 → 7.0.0

This release renames procedure files. It is a breaking change for `[[links]]` and for scripts that reference procedure paths.

- Rename the installed procedures and update every reference:

  | Old | New |
  |---|---|
  | `AGENT__procedure__adr.md` | `AGENT__procedure__write-down-the-adr.md` |
  | `AGENT__procedure__compaction.md` | `AGENT__procedure__tidy-the-journal.md` |
  | `AGENT__procedure__design-language.md` | `AGENT__procedure__find-the-ui-design-language.md` |
  | `AGENT__procedure__first_session.md` | `AGENT__procedure__first-day-on-the-project.md` |
  | `AGENT__procedure__formal-problem-solving.md` | `AGENT__procedure__turn-the-problem-into-math.md` |
  | `AGENT__procedure__paper-reading.md` | `AGENT__procedure__read-the-paper.md` |
  | `AGENT__procedure__parallel-work.md` | `AGENT__procedure__coworkers-are-working-in-parallel-dont-mess-it-up.md` |
  | `AGENT__procedure__production_readiness.md` | `AGENT__procedure__check-before-you-ship.md` |
  | `AGENT__procedure__research.md` | `AGENT__procedure__go-find-evidence-and-do-some-research.md` |
  | `AGENT__procedure__task_end.md` | `AGENT__procedure__when-ending-the-task.md` |
  | `AGENT__procedure__tooling.md` | `AGENT__procedure__you-have-tools-and-rules.md` |

- Merge the new entry: step 3 lists `30__PROCEDURES/`, step 4 writes a `Task type → procedure` triage. Behavior/correctness work must read `turn-the-problem-into-math`; commit/branch work must read `git-discipline`.
- Merge the matching `AGENT__rules.md` bullet.
- Merge the `when-ending-the-task` journal field: `Procedures: [[link]] — one-line reason`, or `none` only for pure documentation or a single trivial local edit.
- Delete the old procedure files only after all links and path references are migrated. `legacy-paths.txt` lists them; the installer will warn until they are removed.
- The entry marker changes to `v7.0.0`.
- Renamed files are not automatically deleted by the installer.

### Pre-v6 (v4.x, v5.x) → 6.x

Use the README section "升级" as a checklist:

- [ ] Rerun the installer; note every `LEGACY` line and `Legacy paths found: N`.
- [ ] Move `project_state_now.md`, `task_board.md` and `open_questions_for_human.md` from `20__EDIT_BEFORE_SESSION_END/` into `40__MEMORY/`.
- [ ] Move project purpose, glossary and coding conventions from `10__ALWAYS_LOAD_FIRST/` into `20__PROJECT_CONTEXT/`.
- [ ] Replace `00__AGENT__START_HERE.md` with the new entry, preserving project-specific edits.
- [ ] Confirm the new entry can read `10__ALWAYS_LOAD/` and that its links resolve.
- [ ] Delete `10__ALWAYS_LOAD_FIRST/`, `20__EDIT_BEFORE_SESSION_END/` and the v4.1 entry and rule files only after migration is complete.
- [ ] Rerun `--verify` and `lint`.

## 5. Verify

Run all of these and report the actual output:

```bash
bash "$src/install.sh" --verify "$target"
bash "$src/lint.sh" "$target"
words=$(cat "$target/10__ALWAYS_LOAD/"*.md "$target/00__AGENT__START_HERE.md" | wc -w | tr -d ' ')
printf 'always-loaded words: %s (limit 3000)\n' "$words"
```

- `--verify` must report every asset present.
- `lint` must report `0 errors`. Triage warnings; do not silence them by deleting content.
- The word count must stay at or below 3000.
- Open the target entry and confirm its links resolve.

A check that cannot run is reported as such, never as passed.

## 6. Close

- Write one journal entry for this task, following [[AGENT__procedure__when-ending-the-task]]. Name the files added, merged and removed.
- Report to the user: target path, installed → target version, files added/merged/removed, verification output, and anything still awaiting a decision.
- Do not commit unless the user asked or the project conventions say to.

## Hard rules

- Never overwrite a locally modified file without showing the user what would be lost.
- Never delete a legacy directory whose content has not been migrated.
- Never call an upgrade successful when a check did not run.
- If the same blocker survives two honest attempts, stop and ask.
