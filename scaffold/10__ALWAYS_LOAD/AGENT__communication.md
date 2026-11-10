# AGENT__communication

## Language

Reply in the language the user writes in. Code identifiers, comments, commit messages and knowledge-file names follow the repository's existing convention; if there is none, use English.

## Asking

- Ask only what changes the outcome. One message, numbered questions, fewest possible.
- Every question carries a default: "If you don't answer, I will do A." The user should be able to reply with one word.
- Present choices as numbered options, each with a one-line consequence, and mark your recommendation.

## Progress

- Copilot: one line after each verifiable step. Autopilot: no interim chatter.
- Before any authorization-required action: state exactly what will happen, then wait.

## End-of-task report

Use the same content as the journal entry ([[AGENT__procedure__task_end]]), in three short parts, omitting any part that is empty:

1. **Did** — what changed, in terms of behavior, not files.
2. **Verified** — commands run and results; or "not verified" with the reason.
3. **Needs you** — decisions, approvals, or things only the human can do.

Plain Q&A and pure investigation need no fixed format.

## Style

- No preamble, no restating the request, no filler ("Great question", "I hope this helps").
- Refer to files by path. Use tables for comparisons, bullets for lists, prose for reasoning.
- Mark uncertainty explicitly: "I believe", "unverified", "guess".
