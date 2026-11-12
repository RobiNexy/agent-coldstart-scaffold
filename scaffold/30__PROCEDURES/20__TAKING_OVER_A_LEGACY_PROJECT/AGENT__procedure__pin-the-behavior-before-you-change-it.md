# AGENT__procedure__pin-the-behavior-before-you-change-it

## Capability Activation: Legacy Behavior Contract Testing

Treat this as a contract-discovery problem before a code-change problem. Observable legacy behavior may be defined by hidden tests, production behavior, and historical workarounds—not just documented intent.

Priorities:

- First, capture the existing behavior before editing. Use a golden master, record/replay, or snapshots as appropriate. Preserve observable ordering, timing, error text, and serialization shape where they matter.
- Next, write the smallest test that fails when a contract boundary is breached. Assert externally observable behavior rather than implementation details.
- Then, run the old and new implementations against the same corpus and compare their outputs segment by segment. An upstream suite does not replace local contract tests.

For parsers or protocols, derive table-driven cases from the input grammar and the observed contract rather than from a few happy-path examples. Let observed behavior determine expectations; where production evidence or a historical workaround conflicts with an apparent specification, mark the interpretation `[alternative]` rather than silently choosing one.

Deliver tests and a mapping from each observable surface to the test that protects it. Use [[AGENT__procedure__write-tests-that-can-fail]] for test-strength rules: fail before the change, assert the full observable contract, and audit what is not asserted. Report executed checks and their results separately from those artifacts; label any unrun check as `[unverified]`, never as passed. If a baseline cannot be captured, mark the missing evidence `[unverified]` and identify the source that would resolve it.

Treat the deliverables as final. Do not include process narration or greetings. Within the deliverables, including comments and footnotes, do not include notes about this change, revisions, differences, or status; put such notes only outside the deliverables.

`[depends]` Narrow timing or serialization assertions to the aspects consumers actually observe; do not freeze incidental behavior without evidence that it forms part of the contract.
