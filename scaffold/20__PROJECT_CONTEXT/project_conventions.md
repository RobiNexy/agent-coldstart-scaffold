# Project conventions

> Record only what is confirmed and not obvious from configuration or code. Empty items are not gates. Items marked "detected" were inferred by the agent and await confirmation.

## Commands

- Install dependencies: unknown
- Run locally: unknown
- Tests: unknown
- Type check: unknown
- Lint / format: unknown
- Build: unknown

## Environments

- How to tell local from test/staging from production (env vars, config files, hostnames): unknown
- Commands or tools that touch non-local environments (treat as high-impact): unknown

## Git

- Branching: unknown (e.g., trunk-based / feature branches)
- Commit style: unknown (e.g., Conventional Commits)
- Does the agent commit without being asked: no

## Collaboration

- Default mode (see [[AGENT__collaboration]]): Autopilot
- Design documents directory: `design/` unless stated otherwise

## External tools

- Registry: `TOOLS__tool-registry.md` in this directory; lifecycle and gate rules in [[AGENT__procedure__you-have-tools-and-rules]].
- Baseline tools (knowledge-base lint, shell, Git, basic search) need no registry entry; third-party tools do.

## Project-specific exceptions

- Code and test layout: follow the existing layout; note only exceptions the agent must know
- Naming or formatting exceptions: none
- Other long-lived conventions: none
