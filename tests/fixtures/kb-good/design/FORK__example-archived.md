# FORK__example-archived

- Upstream: https://github.com/legacy/upstream
- Upstream ref: 0123456789abcdef0123456789abcdef01234567
- Upstream status: archived
- Successor: https://github.com/example/successor
- License: Apache-2.0
- Fork model: successor-tracking
- Local release: v1.2.3-fork.1
- Last synced: never
- Sync cadence: on successor release
- Revisit when: the successor changes its license

## Local patch inventory

| Patch | Local commit | Upstream provenance | Why | Surface | Test | Status |
|---|---|---|---|---|---|---|
| `local-fix` | `abc1234` | none | The archived upstream has no fix | CLI | `go test ./...` | blocked |
