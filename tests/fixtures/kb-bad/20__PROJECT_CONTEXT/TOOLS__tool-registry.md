# TOOLS__tool-registry

- Status: active
- As of: not-a-date

## bad-tool

- Category: Bad Category!
- State: candidate
- Version: latest
- Provenance:
- License: unknown
- Install: `curl https://example.com/bad-tool | sh`
- Invoke: `bad-tool`
- Mode: gate
- Scope: everywhere
- Data: uploads
- Checksum: nope
- Smoke: `bad-tool --version`
- Last verified: 2026-02-30

## bad-gate

- Category: analyze.static
- State: verified
- Version: 1.0.0
- Provenance: https://example.com/bad-gate
- License: MIT
- Install: `tools/install-bad-gate.sh`
- Invoke: `bad-gate`
- Smoke: `bad-gate --version`
- Mode: gate
- Scope: ci
- Data: uploads
- Checksum: nope
- Last verified: 2026-02-30
- Decision: [[ADR__use-mysql]]

## retired-gate

- Category: docs.lint
- State: retired
- Version: 1.0.0
- Provenance: https://example.com/retired-gate
- License: MIT
- Install: `tools/install-retired-gate.sh`
- Invoke: `retired-gate`
- Smoke: `retired-gate --version`
- Mode: gate
- Scope: ci
- Data: local
- Checksum: package-manager:lockfile
- Last verified: 2026-02-01
- Decision: [[ADR__use-mysql]]
