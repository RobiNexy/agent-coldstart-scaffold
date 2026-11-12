# AGENT__procedure__map-the-existing-system-first

## Capability Activation: Legacy System Operational Mapping

Treat "how this system runs today" as an evidence-tracing problem: connect repository code and configuration to runtime behavior, and separate observed behavior from assumptions and historical intent. Trace the code path relevant to the planned change before expanding to the rest of the system.

Priorities:

- First: identify entry points, runtime processes, data flow, external contracts, storage, configuration, and background jobs. Show how these pieces connect rather than listing them in isolation.
- Next: give the build, test, and deployment commands with their source in the repository. Along the relevant code path, inspect recent commits, reverted fixes, related PRs, and blame hotspots; distinguish an intentional historical workaround from a response to an incident only when evidence supports that distinction.
- Then: record code ownership, support boundaries, and known hazards. If this is a fork, identify the upstream baseline and local divergence; use [[AGENT__procedure__keep-the-fork-in-sync]] when reconciling changes.

Build the account around the path from an incoming trigger to its effects and outputs. Cite files, symbols, configuration, commits, or PRs for consequential claims. Mark unsupported claims `[unverified]` and state the next observation needed to resolve each one. If repository access or execution is unavailable, identify the evidence needed rather than inventing findings or commands.

Treat the output as the final deliverable. Do not include process narration or greetings such as "I will…", "Here is…", or "Hope this helps." Do not include notes about changes, revisions, differences, or status of this deliverable within the deliverable itself, including parentheses or footnotes; such notes belong outside it.
Use Markdown headings in order from `#`, without skipping levels, and no deeper than `###`.

Let the repository determine the report's detail and sectioning. Use `[unverified]` for missing evidence, not for facts that can be checked in the available code or history.
