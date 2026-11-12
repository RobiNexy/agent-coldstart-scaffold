# AGENT__procedure__fix-the-cause-not-the-symptom

## Capability Activation: Bug Diagnosis and Systemic Risk

Treat debugging as a causal-tracing and failure-surface problem, not a local patching exercise. Trace the observed symptom backward through the execution path to the earliest plausible fault, then look outward for other paths that share the same faulty assumption.

Priorities:

- First: establish what the evidence supports, identify the root cause, and distinguish it from downstream symptoms.
- Next: map the impact across callers, data flows, states, and edge cases; propose a fix at the level where the faulty assumption originates.
- Then: look for adjacent bugs suggested by the same pattern, especially paths where the failure has not yet been reported. Avoid speculative findings without a plausible failure path.

## Failure-surface matrix

Before the first edit, write this table in the journal:

| Surface | Input shape | Expected behavior | Minimal test | Status |
|---|---|---|---|---|

- Enumerate every surface that shares the faulty assumption: formats, callers, codecs, versions, platforms, configuration paths, and the boundaries between them.
- Start the matrix from the inventory produced by [[AGENT__procedure__know-what-else-uses-it]], not from the suspected surface; every inventoried item gets a row or a reason for exclusion.
- Derive the input shapes from each surface's actual contract — its grammar, protocol, call sites, data formats, and the consumers that observe it — rather than from a single happy-path example. State why each row is in scope.
- Each row needs a runnable minimal test and one status: `pending`, `covered`, or `not covered`.
- `pending` is not a result. Run every row before reporting. `not covered` must name the reason and appears in the final report as residual risk.
- A fix is not complete while any affected surface is `pending` or silently omitted. Do not generalize a passing happy path to surfaces that were never exercised.

The final deliverable lists covered and not covered surfaces explicitly.

When the behavior is not pinned by tests, use [[AGENT__procedure__pin-the-behavior-before-you-change-it]]. When the faulty assumption is shared across surfaces, use [[AGENT__procedure__know-what-else-uses-it]]. Before reporting verified, use [[AGENT__procedure__write-tests-that-can-fail]]; a test that passes before the fix is not a regression test.

Approach: Use the supplied code, logs, reproduction steps, and expected behavior to build a causal chain. For each finding, give the relevant location, trigger, effect, and a way to verify it. Separate confirmed findings from hypotheses; mark missing evidence as [待确认] and competing explanations as [另一解]. Suggest regression tests that cover both the reported failure and the shared failure pattern.

Treat the output as the final deliverable. Do not include process narration or greetings. Do not include notes about changes, revisions, differences, or status within the deliverable, including in parentheses or footnotes; place such notes outside the deliverable.

For a sectioned Markdown report, use headings in order starting at `#`, without skipping levels, and no deeper than `###`.

Adjust the depth of investigation to the available evidence. If the input is too limited to establish a cause, identify the most useful next observation rather than presenting a guess as a diagnosis.
