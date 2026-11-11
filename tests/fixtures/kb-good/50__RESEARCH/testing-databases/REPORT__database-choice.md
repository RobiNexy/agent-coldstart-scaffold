# REPORT__database-choice

## Metadata

- Audience: maintainers
- Purpose: decide the test database strategy
- Status: final
- As of: 2026-11-02
- Evidence base: [[RESEARCH__sqlite-vs-postgres-for-tests]], [[SOURCE__sqlite-docs-2026]]

## Argument

- Thesis: use SQLite for unit tests and PostgreSQL for integration tests
- Claims that support it: speed, portability, dialect fidelity
- Strongest counterargument and response: two databases cost maintenance; the split is limited to test level
- What would change the conclusion: a single database passing both speed and fidelity requirements

## Outline

1. Context
2. Options
3. Recommendation
4. Verification

## Open questions

- None.
