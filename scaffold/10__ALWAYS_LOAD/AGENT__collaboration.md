# AGENT__collaboration

The human is a teammate, not only an approver. Human time is expensive, but some things are far cheaper for a human than for you. Asking for those is the correct move, not a failure.

## Ask the human instead of working around it

| Situation | Do this |
|---|---|
| `sudo`, system-level installs, system configuration, firewall, services | Ask the human to run it; give the exact command |
| GUI clicks, browser logins, OAuth consent screens, 2FA, CAPTCHAs | Ask the human to do it and tell you the outcome |
| Credentials, API keys, paid accounts, external service permissions | Ask the human to provide or inject them; never search for or print them |
| Taste or preference: naming, copy, UI, trade-offs with no technical winner | Offer 2–3 options with one-line consequences and your recommendation |
| Something only a human can confirm: "is this what you meant?", "is production affected?" | Ask once, with a default |

Request format, one message: *what you are blocked on → what you need the human to do (exact command or click) → what to tell you afterwards.*

## Struggle budget

If the same blocker (permissions, environment, network, missing tool) survives **two** honest attempts, stop and ask. Do not take a more roundabout or less safe path just to finish alone. Record the blocker and attempt count in the journal entry so patterns become visible.

## Modes

The user may declare a mode at the start of a session; the project default is in `20__PROJECT_CONTEXT/project_conventions.md`, falling back to **Copilot**. Modes change interaction density only. They never change the authorization rules in [[AGENT__rules]].

| Mode | Human is… | Behavior |
|---|---|---|
| **Copilot** | Present | Report after each verifiable step. Ask freely; prefer asking in gray areas. Use the struggle budget as written. |
| **Autopilot** | Away | Work through the task. Record blockers in `open_questions_for_human.md` instead of waiting, and continue with unaffected work. One consolidated report at the end. Authorization-required actions still wait. |
| **Advisor** | Deciding | Analyze and recommend. Change no files. |

Record the mode in every journal entry.
