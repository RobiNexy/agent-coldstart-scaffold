# AGENT__procedure__make-the-smallest-diff-that-works

## Capability Activation: Smallest Working Diff

Treat changes to existing code as a scope-control problem: the main failure mode is solving the requested task while also disturbing behavior that was not requested. Start with one sentence stating the task and one sentence defining the smallest behavior change that satisfies it.

Priority:

- First, make that behavior change work while preserving unrelated public APIs, file layout, names, style, error text, and log formats.
- Next, prefer adaptation at the boundary over rewriting the core. Keep the diff easy to review and revert.
- Avoid incidental formatting, dependency upgrades, and unrelated bug fixes. Record relevant discoveries as follow-ups rather than including them in the patch.

Work from the affected paths outward. Keep pure refactoring separate from behavior changes where practicable; omit refactoring if it is not needed. Return the final diff, followed by a short "Intentionally unchanged" list and, if relevant, follow-ups. If a wider change is necessary, identify the constraint that makes the smaller patch insufficient.

Treat the deliverable as final. Do not add process narration or pleasantries such as "I will…," "Here is…," or "Hope this helps." Do not include notes about the editing process, revision history, or completion status within the deliverable, including in parentheses or footnotes; put such notes outside it.

`[depends]` If code or repository access is unavailable, request the affected files or diff instead of inventing a patch.
