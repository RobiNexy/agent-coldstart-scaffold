# TOOLS__tool-registry

- Status: active
- As of: 2026-11-02

## sqlite-cli

- Category: test.run
- State: verified
- Version: 3.45.0
- Provenance: https://sqlite.org/download.html
- License: Public Domain
- Install: `apt-get install sqlite3`
- Invoke: `sqlite3 --version`
- Smoke: `sqlite3 --version`
- Mode: advisory
- Scope: local
- Data: local
- Checksum: package-manager:apt
- Last verified: 2026-11-02

## sqlite-gate

- Category: test.run
- State: verified
- Version: 3.45.0
- Provenance: https://sqlite.org/download.html
- License: Public Domain
- Install: `apt-get install sqlite3`
- Invoke: `sqlite3 --version`
- Smoke: `sqlite3 --version`
- Mode: gate
- Scope: both
- Data: local
- Checksum: package-manager:apt
- Last verified: 2026-11-02
- Decision: [[ADR__use-sqlite-for-tests]]

## candidate-upload-tool

- Category: secure.deps
- State: candidate
- Version: 1.0.0
- Provenance: https://example.com/candidate-upload-tool
- License: MIT
- Install: `tools/install-candidate-upload-tool.sh`
- Invoke: `candidate-upload-tool`
- Mode: advisory
- Scope: local
- Data: uploads
