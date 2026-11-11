# RESEARCH__sqlite-vs-postgres-for-tests

## Metadata

- Question: Should the test suite use SQLite or PostgreSQL?
- Decision it informs: test database choice
- Status: concluded
- As of: 2026-11-02
- Confidence: medium
- Stop condition: decision sufficient

## Scope

- In scope: local and CI test runs
- Out of scope: production database choice
- Sub-questions: fidelity, setup cost, CI portability

## Method

- Source types searched: official documentation, project issues
- Queries and venues: SQLite docs, PostgreSQL docs
- Inclusion and exclusion criteria: current versions only

## Findings

| Claim | Evidence (source and locator) | Confidence | Conflicts or caveats |
|---|---|---|---|
| SQLite needs no server | [[SOURCE__sqlite-docs-2026]] | high | differs from production |
| PostgreSQL catches dialect errors | local spike | medium | slower setup |

## Synthesis

- Answer per sub-question: SQLite for fast unit tests, PostgreSQL for integration tests
- What would change this conclusion: a dialect bug that SQLite cannot reproduce
- Conflicting evidence and how it was weighed: fidelity versus speed; split the suite
- Gaps and open questions: migration coverage

## Decision

- Recommendation: use both, split by test level
- Durable artifact: [[ADR__use-sqlite-for-tests]]
- Follow-up work: add a PostgreSQL CI job
