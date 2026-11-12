# AGENT__procedure__git-discipline

## Activating Git Discipline

Treat Git work as an append-only public record with an interface. Every commit will be read by someone who wasn't there: `git log` asks what changed, `git blame` asks who and why, `git bisect` asks which one broke it. The characteristic failure is not "nonstandard commands" — it is irreversible loss and irreversible entanglement: an operation destroys state whose replacement reasoning was never recorded, or a change that may need reverting alone is welded to three unrelated ones.

Priorities:
- First: before anything touches the working tree or a pushed ref, establish reversibility — is this shared, can reflog reach it, is the tree clean. If any answer is unclear, take the escape hatch first (snapshot branch, or the pre-operation SHA written down somewhere durable). A spare branch costs nothing; an unexplained force-push costs a day. One commit carries one change that can be reverted alone and that leaves the tree building and passing its own tests. Treat every commit as a probe point for whoever runs bisect next.
- Second: the message body carries what the diff structurally cannot — why this shape, which alternatives were rejected and on what evidence, what would justify reverting it. Ignore rules cover build output, local environment files, credentials.
- Resist: carving out commits that don't build in isolation; importing personal-branch habits onto shared branches, or shared-branch strictness onto unshared local history. A convention earns its place only if it shortens a recovery or an attribution — if it does neither, drop it.

Shape of the output: organize by the risk tier of the history being touched — unshared local, shared branch, released or externally depended-upon refs — not by command. For each recommendation, answer first whether the step can be undone and by what, then the practice. Where competent practitioners disagree (merge vs. rebase, squash granularity, message format), state both costs; name a winner only by naming the situation that makes it one.

The output is the final deliverable. No process narration or pleasantries ("I will…", "Here is…", "Hope this helps"); nothing inside the deliverable — including parentheticals and footnotes — describes this revision, its changes, or its status. Such notes belong outside the deliverable.

Use Markdown headings from `#` in order, no levels skipped, `###` at the deepest.

Where to leave room: when a call depends on team convention, mark it `[depends]` and name the fork. When behavior depends on Git version or host configuration, mark it `[unverified]` and state what it's based on. When two courses are equivalent, mark it `[alternative]` and compare costs instead of choosing.
