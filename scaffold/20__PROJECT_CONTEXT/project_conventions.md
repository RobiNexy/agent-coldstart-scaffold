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

## Fork and upstream

- Applies only when this project derives from another repository.
- Fork record: `FORK__<upstream>.md`; procedure: [[AGENT__procedure__fork-an-open-source-project]].
- `upstream` is read-only; `origin` is the fork.
- Release identity names the upstream baseline, for example `v1.2.3-fork.1`.
- License and notice obligations: unknown

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
