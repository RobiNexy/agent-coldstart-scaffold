# AGENT__procedure__coworkers-are-working-in-parallel-dont-mess-it-up

Parallel work is a write-set problem, not a throughput problem. Two sessions are safe only when they do not write the same file and do not depend on each other's uncommitted changes. Git is the coordination mechanism; no locks or daemons are needed.

## When to parallelize

Parallelize when:

- tasks touch disjoint files or modules;
- each task can be verified independently;
- interfaces between the tasks are already agreed;
- an integration owner is available.

Do not parallelize when tasks edit the same file, when a shared schema or interface is still unsettled, when a task takes less than roughly an hour, or when ownership is unclear. Serial work is cheaper than a merge conflict that nobody owns.

## 1. Partition by write set

For each task, list the files or globs it will write. If two tasks overlap, merge them or serialize them. Reading the same file is fine; writing it is not.

Agree on interfaces before branching: function signatures, API shapes, data formats, migration order. An interface that changes mid-flight turns two independent tasks into one distributed edit.

## 2. Set up isolation

One session, one worktree, one branch:

```bash
git worktree add ../<repo>-<task> -b task/<id> <base-commit>
```

- Put the worktree **outside** the project root. A worktree inside the root is scanned by `lint` as a second knowledge base and produces duplicate-stem errors.
- Record the base commit in the task file. Rebase or merge from it before handoff.
- Never let two sessions share a worktree or a branch.
- Clean up the worktree after integration: `git worktree remove <path>`.

## 3. Claim before editing

Create `40__MEMORY/tasks/TASK__<id>.md` from `templates/tasks/_TEMPLATE__TASK.md` before the first edit. Required fields:

- `Status`: `active`, `blocked`, or `done`
- `Owner`: the session label, branch, or agent name that owns the task
- `Branch`: the branch being written
- `Scope`: files or globs the session may write
- `Started`: date

Update the status when it changes. A claim without an owner, or an active claim whose branch is gone, is stale; the integrator resolves it.

`40__MEMORY/task_board.md` remains the backlog and priority list. Only the integrator session updates it. Active claims are the files under `40__MEMORY/tasks/`.

## 4. Write ownership

| Kind | Files | Writer |
|---|---|---|
| Exclusive | Files inside the task's `Scope` | The owning session |
| Shared | Entry, rules, project conventions, `project_state_now.md`, `task_board.md`, `open_questions_for_human.md`, accepted ADRs | Integrator only |
| Append-only | Journal entries, `SOURCE__` records | Each session, unique filenames |
| Single-owner documents | `RESEARCH__`, `REPORT__`, `FEATURE__`, `ADR__` | One session per document |

If a task needs to change a shared file, send the proposed change to the integrator instead of editing the file. If two tasks need the same shared change, make it once, before branching.

## 5. Sync and handoff

- Rebase or merge the base branch before handoff; never force-push a shared branch.
- Write a journal entry with `Mode`, `Task`, `Did`, `Verified`, `Next`, plus the branch and commit. In parallel mode, suffix the journal filename with the owner: `YYYY-MM-DD-HHMM__<topic>--<owner>.md`.
- Fill the task's `Handoff` section: last commit, what is verified, what remains, blockers.
- Keep commits single-purpose; the integrator will replay them one at a time.

## 6. Integrate

One integrator session owns the merge queue:

1. Merge or rebase one branch at a time onto the base branch.
2. Run the relevant tests and `lint` after each merge, not once at the end.
3. Resolve conflicts in the integration worktree. Never resolve by discarding another session's work.
4. Mark the task `done`, remove its board item, and clean up the worktree.
5. Run a final full check on the merged result.

Do not let each session update shared memory or run compaction. The integrator distills once, after the merge queue is empty.

## Research in parallel

- Partition by sub-question or source set.
- `SOURCE__` records are append-only and uniquely named; two sessions must not edit the same source file.
- One synthesis owner per `RESEARCH__` file. Other sessions contribute evidence, not concurrent edits.
- One owner per `REPORT__`; reviewers comment through the integrator or a separate task.

## Failure modes

- **Nested worktree**: worktree inside the project root makes `lint` see duplicate knowledge files.
- **Stale claim**: `Status: active` with no branch, no recent commit, or no owner.
- **Duplicate work**: two sessions solve the same task because nobody claimed it first.
- **Shared-file conflict**: two sessions edit the board, state, or questions file.
- **Big-bang merge**: all branches merged at the end, so failures cannot be attributed.
- **Agent identity**: `Owner` is a task/branch label, not a model name; do not rely on session identity surviving a restart.

## Cost

Start with two or three sessions. Measure integration time and conflict rate. If integration takes longer than the work it separates, serialize. Parallelism pays only when the write sets are genuinely disjoint.

## Hard rules

- Never edit a file outside your task's `Scope` without handing the change to the integrator.
- Never force-push a shared branch or rewrite another session's commits.
- Never merge a branch whose task file is not `active` or whose verification is missing.
- Never report a merged result as verified without running the checks on the merged tree.
- If the same blocker survives two honest attempts, stop and ask.
