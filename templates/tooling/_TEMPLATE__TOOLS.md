# TOOLS__tool-registry

- Status: active
- As of: YYYY-MM-DD

One `## <tool-id>` section per tool. Delete this note and every field that does not apply. Keep the lifecycle and gate rules from `AGENT__procedure__you-have-tools-and-rules`.

## example-tool

- Category: analyze.static
- State: verified
- Version: X.Y.Z
- Provenance: https://example.com/official-release
- License: MIT
- Install: `tools/install-example.sh`
- Invoke: `example-tool --check .`
- Smoke: `example-tool --version`
- Mode: advisory
- Scope: local
- Data: downloads
- Checksum: sha256:<64 hex characters>
- Last verified: YYYY-MM-DD
- Notes: Excludes `.env` and local secret files from its workspace.

## example-gate

- Category: test.run
- State: verified
- Version: X.Y.Z
- Provenance: https://example.com/official-release
- License: Apache-2.0
- Install: `tools/install-example-gate.sh`
- Invoke: `example-gate --ci`
- Smoke: `example-gate --version`
- Mode: gate
- Scope: both
- Data: local
- Checksum: package-manager:lockfile
- Last verified: YYYY-MM-DD
- Decision: [[ADR__example-tool-is-a-gate]]
