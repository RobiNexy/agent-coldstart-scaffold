# AGENT__procedure__long-form-writing

A long-form deliverable is an argument a reader can follow and check, not a container for everything you know. The evidence base belongs in `RESEARCH__` and `SOURCE__` files; the report carries only what the reader needs.

## When to run

Run this when writing a report, proposal, design rationale, article, or any document longer than a screen. For a short answer or a procedure, use the relevant procedure instead; `writing-user-manual` covers step-by-step instructions.

## 1. Contract

Before drafting, settle:

- **Audience**: who reads it, and what they already know.
- **Purpose**: what they should decide or do after reading.
- **Length and format**: section structure, word budget, required sections.
- **Evidence standard**: which claims need sources, which may be marked as inference.
- **Deadline**: the point at which a partial draft is better than none.

If the audience or purpose is unknown, ask once with a default. Do not write for "everyone".

## 2. Argument map

Write the argument before the prose:

- Thesis: the one sentence the reader should retain.
- Claims: the 3–7 claims that support it.
- Evidence: for each claim, the `RESEARCH__`/`SOURCE__` records or observations behind it.
- Counterargument: the strongest objection, and the response.
- Implications: what follows if the reader accepts the thesis.
- What would change the conclusion.

If a claim has no evidence and no honest `[inference]` label, remove it or mark it as an open question.

## 3. Outline

Order sections by the reader's path, not by your research chronology. Each section gets one claim as its heading or topic sentence. The outline should be readable on its own: a reader who reads only the headings should see the argument.

Keep background short. Move method details and long source summaries to appendices or link to the research files.

## 4. Draft in passes

Do not polish while drafting. Separate passes:

1. **Structure**: sections, claims, order.
2. **Evidence**: every claim backed, every citation placed.
3. **Prose**: paragraphs, transitions, terminology.
4. **Citation**: locators, access dates, quote accuracy.
5. **Consistency**: numbers, names, versions, tense, cross-references.

A draft that reads well but cannot be checked is not finished.

## 5. Paragraph discipline

- One claim per paragraph.
- First sentence states the claim; the rest supports it.
- Evidence before interpretation; do not let an interpretation masquerade as evidence.
- Define a term the first time it appears; do not assume the reader shares your vocabulary.
- Use lists for parallel items, tables for comparisons, prose for reasoning.

## 6. Citation integrity

- Cite `[[SOURCE__...]]` records, not bare URLs, so the evidence trail stays auditable.
- Distinguish direct quotation, paraphrase, and your own inference. Mark inference `[inference]`.
- Give a locator for every quote: page, section, line, commit, or command.
- Record access dates for web sources.
- Never cite a source you have not read.
- When a claim cannot be sourced, write `[unverified]` and say what would verify it.

## 7. Revision checklist

- Does the opening state the question and the answer?
- Does every section advance the argument?
- Are the strongest counterarguments addressed?
- Are any claims doing more work than their evidence allows?
- Are terms, versions, and numbers consistent?
- Can a reader reproduce the key facts from the citations?
- Is anything included only because it was expensive to find?

## Technical reports

Include versions, environments, commands, and results. Prefer a runnable example or a measured benchmark over an assertion. Link to the relevant ADR, code, or issue. State negative results and abandoned options; they prevent the next reader from repeating the work.

## Output and handoff

- Put the deliverable in a `REPORT__<title>.md` file, or in the project's chosen documentation location using the same title convention.
- Link the report from the `RESEARCH__` file and from the task journal entry.
- If the report changes a durable decision, write or update the ADR and link it.
- Close the task with a journal entry following [[AGENT__procedure__when-ending-the-task]].

## Hard rules

- Never present an unverified claim as sourced.
- Never invent a citation, page number, quote, or access date.
- Never let a polished draft hide a missing evidence base.
- When the same blocker survives two honest attempts, stop and ask.
