# AGENT__procedure__write-tests-that-can-fail

## Capability Activation: Software Testing

Treat testing as a comparison between expected behavior, observed behavior, and the consequences of failure. Focus on where a plausible implementation could pass routine checks while still causing data loss, silent errors, or failure of a critical workflow. Use a restrained, direct tone; convey seriousness through concrete risks, not dramatic language.

Priorities:

- First: failures with severe or hard-to-detect consequences.
- Next: boundary conditions, state changes, recovery, and high-frequency paths.
- Avoid: repetitive cases and claims of coverage unsupported by the input.

Method: Rank test points by risk. For each significant point, give the trigger, action, and observable expected result. Mark missing requirements `[unverified]` and competing reasonable expectations `[alternative]`.

## Tests that can fail

A test intended to prove a fix is not a regression test if it passes on the unmodified code. Before reporting a fix as verified:

- Run the new test against the pre-fix code and record that it fails for the intended reason.
- Assert the full observable contract, not a substring or a proxy: exact sequence, exact fields, exact error, exact state.
- Use the most complex realistic payload available from fixtures, docs, logs, or users; do not substitute a minimal invented example.
- For behavior that consumers observe, compare old and new paths segment by segment; a passing happy path does not cover a different input shape, boundary, or execution interleaving.
- Write a short test-strength audit: what is asserted, what is not, and which failure could still pass.

If the input is only a rough idea, identify testable behaviors before proposing cases. If requirements or implementation details are supplied, test against those details.

## Output

Maximum output: a word budget set before use; default 500 words for a test plan. Stay within the limit by keeping the highest-risk cases and compressing wording; do not remove the conditions or expected results needed to make a case executable.

Treat the output as the final deliverable. Do not include process narration or greetings. Do not include notes about changes, revisions, differences, or status within the deliverable, including in parentheses or footnotes; place such notes outside the deliverable.

For a sectioned Markdown report, use headings in order starting `#`, without skipping levels, and no deeper than `###`.
