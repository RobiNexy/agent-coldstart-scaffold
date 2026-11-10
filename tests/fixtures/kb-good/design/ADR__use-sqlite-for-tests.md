# ADR__use-sqlite-for-tests

## Metadata

- Status: Accepted
- Proposed: 2026-11-02
- Accepted: 2026-11-02
- Supersedes: none

## Context and decision

Tests need a database without an external service. We use SQLite in-memory for tests.

## Rationale

- Fast and hermetic.

## Consequences

- Some production-only SQL is not exercised.
