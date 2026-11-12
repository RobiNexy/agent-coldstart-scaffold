# AGENT__procedure__when-ending-the-task

The journal is the write-first memory layer. Entries are mechanical: fixed fields, no judgment about whether the task "deserves" one. Judgment happens later in [[AGENT__procedure__tidy-the-journal]].

## Where and what name

One file per task in `40__MEMORY/journal/`, named:

```
YYYY-MM-DD-HHMM__<short-topic-in-kebab-case>.md
```

Example: `2026-11-10-1430__fix-login-redirect-loop.md`. Date first so `ls` is a timeline; the topic says what happened so nobody has to open it.

## Open at task start (non-trivial tasks)

When a task will take more than a few minutes or touches more than one file, create the entry first with only:

```markdown
# 2026-11-10-1430__fix-login-redirect-loop

- Mode: Copilot
- Task: Stop the OAuth callback from redirecting forever when `state` is missing
- Procedures: pending
```

Before writing the entry, list `30__PROCEDURES/` and open the procedures that match the task. Replace `Procedures: pending` with `[[link]] — one-line reason` entries, or `none` only for pure documentation or a single trivial local edit.

An entry with `Task:` but no `Did:` tells the next session that this task was interrupted.

## Close at task end

Append the remaining fields. Omit empty fields. Keep the whole entry under ~150 words. Bullets, not paragraphs.

```markdown
- Procedures: [[AGENT__procedure__turn-the-problem-into-math]] — correctness bug; [[AGENT__procedure__git-discipline]] — commit handling
- Did: Fixed the callback to fail fast when `state` is missing; added a regression test
- Verified: `pnpm test auth` → 42 passed; `pnpm typecheck` → clean
- Blocked: Needed sudo to restart local nginx; 2 attempts, then asked the human, who ran it
- Touched: [[FEATURE__oauth-login]], Q-session-store
- Next: Consider the same guard for the password-reset callback
```

Field meanings:

| Field | Purpose | Rule |
|---|---|---|
| Mode | Research and tuning | Copilot / Autopilot / Advisor |
| Task | Crash recovery | One line, written at start |
| Procedures | Audit trail | Procedures read from `30__PROCEDURES/` as `[[links]]` with a one-line reason. `none` only for pure documentation or a single trivial local edit. Replace `pending` before closing; do not omit. |
| Did | Next session | 1–3 lines of behavior, not a diff |
| Verified | Honesty anchor | Only commands actually run, with results; otherwise `not verified: <reason>` |
| Blocked | Collaboration tuning | Where, how many attempts, what the human did |
| Touched | Compaction routing | `[[links]]` and `Q-` IDs |
| Next | Next session | One line or omit |

The `Procedures` line is the triage record. If a procedure's filename matches the task type, reading it is mandatory; do not write `none` to avoid the work.

Never edit an entry after closing it. Corrections are new entries.

## Also at task end

- Remove finished items from `40__MEMORY/task_board.md`; add follow-ups worth keeping across sessions.
- If a blocking question arose and was not answered, make sure it is in `open_questions_for_human.md` (you should have written it when it arose).
- Print the end-of-task report ([[AGENT__communication]]); it has the same content as the entry.
- Do not update `project_state_now.md` unless leaving it stale would mislead the very next session.

## If context is running out mid-task

Close the entry with whatever is true: `Did:` what is actually finished, `Next:` what is half-done and where. Do that before anything else.
