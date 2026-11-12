# AGENT__procedure__write-down-the-adr

Read this before creating, accepting, rejecting or superseding an architecture decision record. Template: `templates/decisions/_TEMPLATE__ADR.md` in the scaffold source repository.

## When

Write an ADR when a decision is expensive to reverse, constrains future work, or would otherwise be re-litigated. Do not write one for choices that are obvious, local, or cheap to change.

## Naming

- `ADR__<conclusion>.md`, no serial numbers. The conclusion is what the project *does*: `ADR__use-postgres-for-jsonb`, `ADR__do-not-use-orm`. Not a topic: ~~`ADR__database-choice`~~.
- Keep it under roughly 60 characters. If you cannot, the decision is probably two decisions.
- The title equals the filename stem.

## Status line

The metadata block contains exactly one line matching one of:

```
- Status: Proposed
- Status: Accepted
- Status: Rejected
- Status: Superseded by [[ADR__<new-conclusion>]]
```

This line is checked by `lint`.

## Lifecycle

1. You draft → `Proposed`. Fill Context, Decision, Rationale, Consequences.
2. The human accepts → `Accepted`, set the acceptance date. **Acceptance** means the human has responded to *this specific conclusion* with clear agreement ("accept", "agreed", "go with that", or an unmistakable equivalent). Asking to "change the old decision" or "look into alternatives" is not acceptance. When in doubt, ask: "Shall I mark ADR__x as Accepted?"
3. The human rejects → `Rejected`, **and rename the file** to `ADR__rejected__<conclusion>.md`, updating any references. A rejected proposal's name must not look like something the project does. Rejected ADRs are kept; they stop the same proposal from being re-explored.
4. A new accepted ADR replaces an old one → in the new ADR set `Supersedes: [[ADR__old]]`; in the old ADR set `- Status: Superseded by [[ADR__new]]`. Do not rename the old file. The `Supersedes` field in the new ADR is the authority; the old ADR's status is navigation.

## Frozen content

Once `Accepted`, the Context, Decision, Rationale, Consequences and Revisit-when sections are frozen. Only metadata (status, dates, supersession links) may change. A changed conclusion is a new ADR.

## After any ADR change

Write it in the journal entry's `Touched:` line and, if the decision affects current work, in `project_state_now.md` during compaction.
