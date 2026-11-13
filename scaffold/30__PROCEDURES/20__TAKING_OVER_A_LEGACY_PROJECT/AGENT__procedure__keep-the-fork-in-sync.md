# AGENT__procedure__keep-the-fork-in-sync

## Capability Activation: Keep the Fork in Sync

Treat fork synchronization as a baseline-and-contract reconciliation problem, not a branch-merging exercise. The input is the fork record, the target upstream ref, and the current patch inventory; the output is a new pinned baseline, an updated patch inventory, and evidence that both upstream behavior and the fork's local contracts still hold.

Priorities:

- First: read `FORK__<upstream>` and confirm the upstream URL, pinned baseline, fork model, license, and patch inventory. If the record is missing or stale, stop and create or update it with [[AGENT__procedure__fork-an-open-source-project]]. Treat upstream PRs, releases, and advisories as evidence to investigate, not as diagnoses; check their base, assumptions, license, and applicability.
- Next: classify the candidate upstream changes (security, bug fix, feature, refactor, CI/build, dependency, license or notice) and the local patches (needed, upstreamed, obsolete, conflicting). Select security and correctness fixes first; defer refactors and features unless the fork needs them. Do not import an entire upstream branch by default.
- Then: choose the integration method named by the fork model. Rebase a small patch stack onto the new upstream tag; merge upstream into a shared fork history when the patches are numerous or the fork has its own consumers; use `git range-diff` and `git cherry-pick -x` (or equivalent) so provenance survives. Follow [[AGENT__procedure__git-discipline]] before rewriting or force-pushing any branch others use.
- Then: port only applicable changes. For each one, record the upstream ref, the local adaptation, the affected surfaces, and the test that protects the contract. When upstream behavior and a local contract conflict, write the precise divergence point and the chosen resolution in `FORK__` or an ADR; do not silently pick one.
- Then: validate the new baseline with the upstream suite, the fork's contract tests, and a build/release smoke test. A clean merge is not behavioral compatibility; an upstream test suite does not replace local contract tests. Check that license and notice files did not change unexpectedly; a license change is a stop-and-ask event.
- Finally: update `FORK__` with the new pinned ref, last-synced date, patch statuses, and any new obligations; update release and migration notes. Record excluded changes and residual risks rather than implying full parity. Read [[AGENT__procedure__check-before-you-ship]] before publishing the result.

Use `[unverified]` when a baseline, patch origin, or validation result cannot be established; use `[alternative]` when evidence supports more than one reading. If the upstream is archived or replaced by a successor, record that state and sync from the named successor; do not describe a successor as the same upstream.

Treat the output as the final deliverable. Do not include process narration or greetings such as "I will…," "Here is…," or "Hope this helps." Do not include commentary about this deliverable's changes, revisions, differences, or status within the deliverable, including in parentheses or footnotes; place such commentary outside it.

If the deliverable uses Markdown sections, start headings at `#`, proceed without skipping levels, and go no deeper than `###`.

Adjust the level of detail to the available repository evidence; do not imply that a port or validation occurred when only a plan can be produced.
