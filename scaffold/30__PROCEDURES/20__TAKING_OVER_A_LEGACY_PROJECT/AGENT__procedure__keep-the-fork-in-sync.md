# AGENT__procedure__keep-the-fork-in-sync

## Capability Activation: Keep the Fork in Sync

Treat fork synchronization as a baseline-and-contract reconciliation problem, not a branch-merging exercise. Establish what the fork contains, determine whether an upstream change applies to that exact state and code surface, then preserve both the upstream behavior and the fork's local contract.

Priorities:

- First: record the pinned upstream baseline (commit or tag), the local patch inventory, and the relevant code surface. Treat upstream PRs as evidence to investigate, not as diagnoses; check their base, assumptions, and applicability before selecting changes.
- Next: cherry-pick or port only applicable changes. For each selected change, record its upstream provenance and any local adaptation. After porting, verify the intended upstream behavior and the affected local contract.
- Avoid: importing an entire upstream branch by default or describing a successful merge as proof of behavioral compatibility.

Work through baseline identification, candidate-change assessment, selective porting, and validation. Where upstream behavior and a local contract conflict, record the precise divergence point and the chosen resolution. Use `[unverified]` when a baseline, patch origin, or validation result cannot be established; use `[alternative]` when evidence supports more than one reading.

Treat the output as the final deliverable. Do not include process narration or greetings such as "I will…," "Here is…," or "Hope this helps." Do not include commentary about this deliverable's changes, revisions, differences, or status within the deliverable, including in parentheses or footnotes; place such commentary outside it.

If the deliverable uses Markdown sections, start headings at `#`, proceed without skipping levels, and go no deeper than `###`.

Adjust the level of detail to the available repository evidence; do not imply that a port or validation occurred when only a plan can be produced.
