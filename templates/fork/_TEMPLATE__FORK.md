# FORK__upstream-name

Rename the file and title to `FORK__<upstream-name>`, for example `FORK__clash`, and place it in the design documents directory (`design/` unless the project says otherwise). Keep one record per upstream. The title must equal the filename stem. This record is the authority for the upstream baseline, license obligations, local divergence, and sync policy. Procedure: `AGENT__procedure__fork-an-open-source-project`. Delete sections that do not apply; do not duplicate facts that live in one authoritative place.

## Metadata

- Upstream: https://example.com/owner/repository
- Upstream ref: vX.Y.Z or a full 40-character commit SHA
- Upstream status: active | successor | archived
- Successor: none, or the repository that replaced the upstream
- License: SPDX identifier
- Fork model: patch-stack | periodic-merge | hard-fork | successor-tracking
- Local release: none, or a version such as vX.Y.Z-fork.1
- Last synced: YYYY-MM-DD or never
- Sync cadence: on upstream release | monthly | quarterly | none
- Revisit when: the condition that would make this fork unnecessary or unsafe

## Why this fork

What cannot be achieved by configuration, a plugin, a build-time patch, or an upstream contribution. Name the users or deployments that depend on the fork, and the cost of not forking.

## Upstream baseline and obligations

- Pinned baseline evidence: tag or commit, date, and how it was verified
- Unmodified build and test commands, with results
- License and notice files reviewed: paths and findings
- Redistribution and source-availability obligations, especially GPL/AGPL
- Trademark, naming, or endorsement constraints
- Published artifacts: none, source only, or binaries and installers

## Fork model and Git layout

- `origin`: the fork repository
- `upstream`: the pinned source, read-only; never commit to it
- Integration branch:
- Upstream baseline tags (for example `upstream-vX.Y.Z`):
- Fork release tags (for example `vX.Y.Z-fork.N`):
- Patch branches or commit ranges:
- History policy: rebase, merge, or hard-fork; who may force-push
- Version scheme and how it names the upstream baseline

## Local patch inventory

One row per revertible patch. A local divergence that is not in this table does not exist for the next sync.

| Patch | Local commit | Upstream provenance | Why | Surface | Test | Status |
|---|---|---|---|---|---|---|
| `<patch-id>` | `<commit>` | upstream PR, commit, or none | ... | ... | ... | active |

Status: `active`, `upstreamed`, `obsolete`, or `blocked`.

## Local contracts that must survive

| Surface | Contract | Test | Status |
|---|---|---|---|
| ... | ... | ... | covered |

Status: `covered` or `not covered`. Keep local contract tests separate from the upstream suite.

## Sync log

| Date | From | To | Selected | Excluded | Verification | Result |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | `<old ref>` | `<new ref>` | ... | ... | ... | ... |

## Release and security

- Release command:
- Artifacts, checksums, and signatures:
- License and notice bundle:
- Source availability (GPL/AGPL):
- Upgrade and rollback path from the previous fork release:
- Upstream advisory watch and response owner:
- Security disclosure contact:

## Exit and upstreaming

- Patches intended for upstream, with their upstream links:
- Switch to the successor when:
- Hard-fork permanently when:
- Stop maintaining when:
