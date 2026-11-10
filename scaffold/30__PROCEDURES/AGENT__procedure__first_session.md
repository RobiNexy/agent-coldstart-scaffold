# AGENT__procedure__first_session

Run this when `20__PROJECT_CONTEXT/project_conventions.md` still says "unknown" for the test command, or when the user asks to set up the workflow. Keep it short: three questions at most, no interviews.

1. **Detect, don't ask, what can be detected.** Look at `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `justfile`, CI configuration, `docker-compose*`, `.env.example`. Draft the Commands and Environments sections of `project_conventions.md`, marking each inferred value `(detected)`.
2. **Draft, don't fill, the purpose.** If a README or similar exists, draft `project_purpose_and_boundary.md` from it, marking everything `Unconfirmed`. Do not write it until the user confirms.
3. **Ask at most three questions, each with a default:**
   - Which environments exist and how do I tell them apart? (default: local only)
   - Default collaboration mode? (default: Copilot)
   - May I commit on my own? (default: no)
4. Write confirmed answers into `project_conventions.md` and, if confirmed, `project_purpose_and_boundary.md`.
5. If the project is meant to go to production, run through [[AGENT__procedure__production_readiness]] and record gaps in `open_questions_for_human.md` — do not fix them unasked.
6. Close with a journal entry.

Do not create directories, move code, or install tools during this procedure.
