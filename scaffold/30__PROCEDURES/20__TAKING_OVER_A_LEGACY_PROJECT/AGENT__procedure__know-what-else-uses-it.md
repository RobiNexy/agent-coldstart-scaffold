# AGENT__procedure__know-what-else-uses-it

## Capability Activation: Cross-Surface Compatibility Review

Treat changes to APIs, CLIs, configuration, schemas, wire formats, error codes, and shared parsers as a caller–contract–migration problem. Use one table to trace each affected surface from its consumers through its compatibility promise and test coverage.

Priorities:

- First, enumerate callers and consumers using repository search (including grep and imports), generated clients, documentation, tests, and external services. Start from the interface, registry, factory or import graph that enumerates implementations, then add call sites found by search; do not start from the symptom. Segment findings by version, platform, and configuration where behavior may differ.
- Next, state what may change, what must remain compatible, and how old clients, data, and configuration continue to work or migrate.
- Then, give each surface a minimal test and mark its coverage `covered` or `not covered`. If the same mistaken assumption recurs across surfaces, prefer a shared-layer fix; if behavior differs locally, record the reason for the fork.

Use the table as the main output. Include evidence for identified consumers and mark unavailable evidence `[unverified]` rather than treating an unsearched surface as unused. When a public contract is involved, route the change to [[AGENT__procedure__change-it-without-breaking-callers]].

Treat the artifact as the final deliverable. Do not include process narration or greetings such as "I will…," "Here is…," or "Hope this helps." Do not include notes about this artifact's edits, revisions, differences, or status anywhere within it, including parentheses and footnotes; such notes belong outside the artifact.

`[depends]` Add version, platform, or configuration rows only where they can change the compatibility conclusion or test. `[alternative]` Where two consumer behaviors are plausible, identify the distinguishing test or evidence.
