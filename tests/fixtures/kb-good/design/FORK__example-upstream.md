# FORK__example-upstream

- Upstream: https://github.com/example/upstream
- Upstream ref: v1.2.3
- Upstream status: active
- Successor: none
- License: GPL-3.0-only
- Fork model: patch-stack
- Local release: none
- Last synced: 2026-11-13
- Sync cadence: on upstream release
- Revisit when: the local patch is accepted upstream

## Why this fork

The example keeps a local patch that is not yet accepted upstream.

## Local patch inventory

| Patch | Local commit | Upstream provenance | Why | Surface | Test | Status |
|---|---|---|---|---|---|---|
| `example-change` | `abc1234` | none | Local deployment constraint | CLI | `go test ./...` | active |
