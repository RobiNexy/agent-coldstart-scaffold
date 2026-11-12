# AGENT__procedure__check-before-you-ship

Read this when touching deployment, infrastructure, data migrations, or anything on the path to production, and during [[AGENT__procedure__first-day-on-the-project]] for projects meant to ship. If the change alters a public API, schema, configuration, wire format, or stored data, also read [[AGENT__procedure__change-it-without-breaking-callers]]. This is a checklist for *noticing gaps*, not a form to fill. Report gaps; fix only what the task asks for or the human approves.

## Before any change on the path to production

- Which environment does this touch? Say it explicitly.
- Blast radius: who or what is affected if it goes wrong?
- Rollback: how is this undone, and have you confirmed that works?
- Verification: how will you know it worked, from evidence rather than absence of errors?

If any answer is "unknown", stop and ask before acting.

Before closing a readiness review, check `secure.deps` and `secure.secrets` in `20__PROJECT_CONTEXT/TOOLS__tool-registry.md`. If either is absent, record the gap in `open_questions_for_human.md`; do not install a scanner unasked. The registry lifecycle is in [[AGENT__procedure__you-have-tools-and-rules]].

## Gaps worth flagging (write to `open_questions_for_human.md` as `Q-prod-<topic>`)

| Area | Minimum worth having |
|---|---|
| Environments | Separate local / staging / production configuration; no shared databases or credentials |
| Secrets | Not in the repository; injected at runtime; rotation possible |
| CI | Tests, type check, lint run on every push; a red build blocks deploys |
| Deploy | Repeatable command or pipeline; the deployed version is identifiable |
| Data | Migrations are versioned, forward-only or with tested down paths; backups exist and restore has been tried once |
| Observability | Errors are logged with context; a human is notified when production fails |
| Dependencies | A way to see and apply security updates |
| Access | Who can deploy and who can read production data is known and minimal |

## Rules that apply regardless of mode

- Deploying, migrating production data, changing DNS/certificates/billing, and sending to real users are authorization-required actions.
- Never test against production data unless the human explicitly says so.
- Write an `OPS__<procedure>.md` runbook only for operations that are repeated or error-prone.
