# AGENT__procedure__research

Research is decision support. The output is not a bibliography; it is a defensible answer to a question that changes a decision. Keep the evidence trail under `50__RESEARCH/` so the next session can audit it without repeating the search.

## When to run

Run this procedure when:

- a decision depends on evidence you do not have;
- the domain is unfamiliar and vocabulary is the first obstacle;
- several options must be compared on facts rather than taste;
- an existing decision needs its premises re-checked.

For a single fact lookup, answer directly and cite the source. When the user asks for "some research" without naming a decision, propose the decision and a time box before searching. When they only want a reading list, produce a reading list and say that is what it is.

## 1. Contract

Write the contract before searching, in `RESEARCH__<question>.md`:

- **Question**: one answerable sentence, not a topic.
- **Decision it informs**: what changes if the answer changes.
- **Evidence standard**: what would count as enough, and what would not.
- **Stop condition**: decision sufficient, saturation, time box, or diminishing returns.
- **Time box**: the point at which you report partial findings as partial.

If the decision or standard is genuinely unknown, ask once. Otherwise state a default and proceed.

## 2. Map the question

Split the question into sub-questions that can be answered independently. For each, name the source types that could answer it: papers, official documentation, source code, benchmarks, issue trackers, changelogs, experts. Record the queries and venues you actually used, including failed searches that looked promising.

Decide inclusion and exclusion before reading: date range, versions, languages, primary versus secondary sources, vendor material. Changing the criteria later is allowed; record why.

## 3. Acquire sources

Create one `SOURCE__<id>.md` per source, following `templates/research/_TEMPLATE__SOURCE.md`. Keep the library append-only: correct a record with a note, not by rewriting what was read.

- Prefer primary sources: the paper, the official documentation, the source code, the benchmark you ran.
- For every source, record provenance, version or edition, access date, method, and known limitations.
- Quote only what matters, with a locator. Paraphrase the rest.
- A source you did not read is not evidence. Mark it `[unread]` or omit it.

## 4. Extract evidence

Build a claim-evidence table in the `RESEARCH__` file. One claim per row:

| Claim | Evidence (source and locator) | Confidence | Conflicts or caveats |
|---|---|---|---|

- Separate what the source says from what you conclude. Own inferences are `[inference]`.
- Record conflicts instead of averaging them away. If two credible sources disagree, the disagreement is a finding.
- Note the conditions under which a claim holds: version, platform, scale, population, method.

## 5. Synthesize

Answer each sub-question, then the main question. State confidence and the evidence that would change it. A useful synthesis contains:

- the answer, in one paragraph;
- the strongest evidence for it;
- the strongest evidence against it, and why it does not overturn the answer;
- gaps that remain, and whether they matter for the decision;
- what would change the conclusion.

Do not manufacture balance. When the evidence is one-sided, say so. When it is insufficient, say that instead of picking the least bad option silently.

## 6. Decide and hand off

- Record the recommendation and the decision it supports in the `RESEARCH__` file.
- If the decision is durable, write an ADR or update the relevant `FEATURE__`/`DATA__`/`OPS__` document; link it from the research file.
- If the deliverable is long-form, follow [[AGENT__procedure__long-form-writing]] and produce a `REPORT__` that cites the research and sources.
- Close the task with a journal entry. The research file persists; it is not deleted by compaction.

## Stop rules

Stop when any of these is true:

- the decision can be made at the required confidence;
- new sources no longer change the answer or the confidence;
- the time box expired: report what is known and what is missing;
- further search costs more than the decision is worth.

Stopping is a finding. Write why you stopped.

## Profiles

### Academic

Check peer review status, venue, sample, method, and whether the result has been replicated. Use citation chasing in both directions: what the paper cites, and who cites it. Distinguish a preprint from a published version. Prefer the published version when they differ.

### Technical

Prefer official documentation, source code, release notes, and reproducible measurements. State versions and environments. When a claim about performance or behavior matters, run a spike or benchmark and record the command and result. Negative results are evidence; keep them.

## Failure modes

- A reading list with no synthesis.
- False balance between unequal evidence.
- Citing a summary of a source instead of the source.
- Recency bias: newer is not automatically better.
- Searching only for confirmation.
- Scope creep: answering questions nobody decided to ask.

## Hard rules

- Every factual claim in the synthesis points to a `SOURCE__` record or is marked `[unverified]`.
- Never present a guess as a source's claim.
- Never delete a source record because it turned out to be wrong; add a note explaining why.
- When the same blocker survives two honest attempts, stop and ask.
