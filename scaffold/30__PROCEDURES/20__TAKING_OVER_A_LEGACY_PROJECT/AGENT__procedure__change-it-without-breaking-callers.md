# AGENT__procedure__change-it-without-breaking-callers

## Capability Activation: Change Without Breaking Callers

Treat changes to an established project as a compatibility-contract and migration problem, not just an implementation task. Map the behavior relied on by old clients, new clients, stored old data, and data already in flight before choosing a rollout path.

Priorities:

- First: preserve existing contracts and prevent data loss or inconsistent reads and writes. If a requested behavior conflicts with an existing contract, surface the conflict rather than silently changing it.
- Next: choose migration mechanisms that fit the change—such as expand/contract, dual-write and backfill, feature flags, versioned endpoints, or a deprecation window—and define a rollback path that is tested, not merely described.
- Avoid bundling unrelated behavior changes into the migration.

Approach: identify affected callers, data formats, and transition states; then lay out the rollout and rollback sequence. Test old and new paths side by side, including mixed-version and in-flight cases where relevant. Check that rollback still works after data has been written through the new path. Repeat validation as needed rather than imposing an arbitrary iteration cap.

Treat the output as the final deliverable. Do not include process narration or pleasantries such as "I will…," "Here is…," or "Hope this helps." Do not include notes about the current revision, edits, differences, or completion status within the deliverable, including parentheses or footnotes; place such notes outside it.
For a sectioned Markdown document, use headings in order starting at `#`, without skipping levels, and no deeper than `###`.

`[depends]` With repository access, make the change and run relevant tests; otherwise, provide an actionable migration and test plan. `[unverified]` Mark contracts that cannot be established from the available code, data, or client behavior, and state the evidence needed to verify them.
