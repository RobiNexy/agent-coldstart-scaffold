# AGENT__procedure__compaction

Compaction turns the journal (what happened) into memory (what is true now) and removes the raw entries. It is also where the project learns about itself.

## Trigger

- `40__MEMORY/journal/` has more than 20 entries (excluding `SUMMARY__*` files), or
- the user asks to tidy, or
- you notice accumulated knowledge is getting in the way of finding things.

Compaction is itself a task: open and close a journal entry for it.

## Steps

1. Run the knowledge-base checks (below) and fix what they report.
2. Read **all** raw journal entries. This is the one time reading everything is worth it.
3. Route lasting facts out of the journal:
   - Current state, known limitations, important deviations → `project_state_now.md`
   - Unfinished work → `task_board.md` (remove anything done)
   - Decisions → ADRs via [[AGENT__procedure__adr]]
   - Undecided questions → `open_questions_for_human.md`; questions resolved by evidence → remove, write the resolution where it belongs
4. Write one summary file `40__MEMORY/journal/SUMMARY__<first-date>_to_<last-date>.md` (format below).
5. Delete the raw entries you summarized. Git keeps them.
6. Report the statistics to the human.

## Summary format

```markdown
# SUMMARY__2026-10-20_to_2026-11-10

## Key events
- 3–10 bullets: what changed in the project during this period, in behavior terms

## Statistics
- Entries: 22 (Copilot 15, Autopilot 7, Advisor 0)
- Interrupted (Task without Did): 2
- Not verified: 3
- Blocked and asked human: 9 (sudo/system 4, GUI/login 3, credentials 1, taste 1)
- Average attempts before asking: 1.8
- ADRs: proposed 2, accepted 1, rejected 1
- Open questions: +4 / −3

## Observations
- 1–5 bullets on patterns worth the human's attention (recurring blockers, rules that were hard to follow, checks that keep failing)
```

The statistics are the project's instrument for whether this workflow is working. Compute them honestly from the entries; do not estimate.

## Knowledge-base checks

If the scaffold source repository is available, run `bash lint.sh <project-root>` (or `pwsh -File lint.ps1 -TargetDir <project-root>`). Otherwise perform the same checks by hand:

| Check | How |
|---|---|
| Dangling `[[links]]` | For each `[[name]]`, a file `name.md` must exist exactly once in the repository (ignoring `.git`, `node_modules`, build output) |
| Title equals filename | For `TYPE__*.md` and journal files, the first `#` heading equals the stem |
| ADR status valid | Every `ADR__*.md` has exactly one `- Status:` line with an allowed value |
| Rejected ADR naming | `- Status: Rejected` files are named `ADR__rejected__*` |
| Task board references | Every `Q-<id>` in `task_board.md` exists in `open_questions_for_human.md` |
| Incomplete journal entries | Entries with `Task:` but no `Did:` are listed |
| Unknown type prefix | `.md` files named `TYPE__*` use an allowed type |
