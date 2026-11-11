# AGENT__procedure__writing-user-manual

## Capability Activation: Writing a User Manual

Treat the task as an execution problem, not a product-description problem. The reader is standing in front of the thing, at a particular moment, doing it now — and will abandon the manual the moment a step stops making literal sense. The core failure mode is organizing by product internals (menus, modules, parameters, architecture) instead of by the task the reader is trying to finish, and then writing steps as summary prose that reads fine and stalls in practice.

Concern priority:

- First: every step executable as written, each followed by a result the reader can actually observe; prerequisites stated up front (what to have in hand, what state to begin from); the most likely wrong turn identified together with how to notice it and how to back out.
- Second: skimmability — sections named after reader goals, each self-contained and readable without the ones before it; the first-run path kept distinct from later reference lookup.
- Actively avoid: internal mechanism and design rationale inside procedure text; completeness for its own sake (every parameter, every variant, every supported case).

How to expand:

1. Open by naming the goals the reader arrives with, then order sections by those goals — shortest path to a working result first, advanced operations later.
2. Within each section: prerequisites → numbered steps → common deviation → completion state and how to verify it → how to undo or recover. One action per step; split any step containing "and". Where a step's outcome is invisible, say so rather than inventing a confirmation.
3. Reproduce interface labels, button names, and error strings verbatim in the product's own wording and language. Never paraphrase or localize them — the reader is matching characters on a screen.
4. Warnings sit immediately before the step they protect, not in a front-matter block that gets skipped.
5. Where behavior differs by version, platform, or model, mark the divergence at the point of divergence, not in a global note.
6. Troubleshooting is derived from the failure modes of the steps you just wrote, keyed by the symptom the reader can see. Do not organize it by internal cause, and do not pad it with failures no step in this manual can produce.

The product is the final deliverable. No "I will…", "Below is…", "Hope this helps", and no process narration or opening pleasantries; no statements about this revision, its changes, differences, or status inside the product (including parentheticals and footnotes) — such notes go outside it.

Markdown headings run in order from `#`, no skipped levels, deepest `###`.

[依情况] Reader prior experience sets how much terminology gets explained inline and whether a getting-started section survives at all — for experienced operators, drop the onboarding prose and spend the space on exception handling.

[另一解] When two routes reach the same state, designate one as the default and note the alternative in a single clause; do not present them as equals and leave the reader to choose.

[待确认] Product information that is missing or unverifiable is marked as such, naming the specific gap (exact label, limit, timing, model difference) — never filled in from plausibility. A fabricated step costs the reader more than a stated hole.
