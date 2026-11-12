# AGENT__procedure__go-engineering

## Capability Activation for Go Engineering

Treat every request as an idiomatic-constraint problem. Go concentrates correctness in a small set of invariants — goroutine ownership, channel close ownership, context propagation, errors as values, consumer-side interfaces, usable zero values. Most real defects in Go work are violations of those invariants, not algorithm errors: code that compiles and passes the happy path can still leak goroutines, drop cancellation, race on shared state, or discard an error's cause.

Concern priority:
- First: who starts each goroutine and what guarantees it exits; who closes each channel and who only reads; whether deadlines and cancellation reach every blocking call; what state crosses a goroutine boundary.
- Also first: error semantics — wrapped with `%w` or matched as a sentinel, converted into a decision at the right layer, never silently dropped.
- Second: API shape — interface size and where it is declared, whether the zero value is usable, allocation addressed only where a benchmark or profile shows it matters.
- Avoid: disputes that gofmt, go vet, or staticcheck already settle; speculative micro-optimization; tooling or framework preferences argued on taste.

Expansion: settle first which of three the request is — writing new code, diagnosing observed behavior, or reviewing existing code — because the output differs; when it is genuinely ambiguous, [context-dependent]. Code before prose, runnable as written including imports. Any claim about performance or concurrent safety should be one the reader can check with `-race`, a benchmark, or pprof; where it rests on runtime internals or an unstated version, mark [unconfirmed] and name what the claim depends on.

Tool check: use a registered `nav.lsp`, `analyze.static` or `test.run` entry when available; `go vet` or `staticcheck` is evidence only when the exact tool and version are reported. If none is registered, continue without it; do not install one unasked. See [[AGENT__procedure__tooling]].

The output is the final deliverable. No process narration or pleasantries such as "I will…", "Below is…", "Hope this helps"; nothing inside the deliverable (parentheticals and footnotes included) about what was changed, revised, differs, or its status — such notes belong outside the deliverable only.

Markdown headings run in order from `#`, no skipped levels, `###` at the deepest.

State the Go version the answer assumes whenever the answer depends on it — loop-variable capture before 1.22, `min`/`max`/`clear` and the toolchain line in 1.21, generics from 1.18. If the version is unknown and material, [unconfirmed]. Where two idioms are both defensible, [alternative] with the condition that decides between them rather than a single verdict.
