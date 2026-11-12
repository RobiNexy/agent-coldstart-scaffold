# AGENT__procedure__find-the-ui-design-language

## Ability Activation — Design Language Extraction and Implementation

Treat this as a two-stage problem: reconstruct a design grammar, then compile that grammar into running configuration. Settle the mode first. Analysis only stops at Stage 1, which must stand alone as a usable account of the system. Analysis plus implementation runs both stages, and the two are bound by an explicit mapping: every line of Stage 2 cites the Stage 1 entry it discharges; every Stage 1 entry is either discharged or explicitly deferred. The characteristic failure is two documents stapled together — an analysis that reads plausibly beside code that looks fine, neither constraining the other.

Concern priority:
- First: falsifiability of each rule — state where it holds and what would break it; a claim that cannot fail is not a finding. Traceability of the mapping. Parameterization — whether the system is driven from one token block, so a single change moves the whole.
- Second: engineering completeness of fallback and edge states; correct handling of medium-specific constraints — cascade and responsive strategy in CSS, box model, line breaking and badness tolerance in LaTeX.
- Actively avoid: magnitudes dressed up as grammar; genre adjectives ("clean", "airy", "premium", "considered") standing in for analysis — if it cannot be restated as a relation between measurable quantities, it is not a finding; code with no antecedent rule; a finished artifact polished enough to hide the system underneath.

Stage 1 — Design language
- Forces before style. Position, size, spacing, measure, leading, baseline are mutually constraining: report a move as a trade, never a lookup. Raising measure without raising leading buys characters per line and spends return-sweep tracking; tightening density buys scannable volume and spends dwell time at the paragraph break.
- Four layers in order: structure → rhythm and hierarchy → signature → limits of validity. Each layer states its rule first, then the instance in this object that evidences it.
- Extract relations, not magnitudes. The ratio, the step, the allocation — not the pixel. Numbers enter only where they are structural (a baseline interval against body leading, a margin ratio against measure), and then as proportion rather than prescription.
- Every signature carries its counter-case. A signature is what the object keeps doing when it could do otherwise; name the condition under which it holds and the condition under which it collapses.
- Analytical spine by medium: UI/UX → information density × visual weight allocation; books and LaTeX → type area, margins and baseline grid in tension; CSS → layout model → cascade intent → responsive strategy. Where none fits, derive the spine from the object's own dominant tension and name the one used.
- Each entry carries an ID, a rule, its evidence in the object, and its validity condition. The IDs are the contract with Stage 2.

Stage 2 — Implementation
- Discharge entries in order. One block may discharge several; cite all of them where the decision is actually made, not in a header comment.
- Tokens first. CSS: custom properties in `:root{}`, consumed downstream, no bare literals left inside component rules. LaTeX: preamble — `geometry`, `fontspec`/`setmainfont`, `\linespread`, `\newcommand` — established before any environment relies on them.
- Every aesthetic decision lands on a replaceable parameter, with the alternative value and its visual cost placed inline where the value is set.
- At least one deliberate departure from the default solution, with intent and price named: performance, compatibility, accessibility, render budget, an accepted overfull box.
- Edge states get dispositions, not silence. CSS: overflow, empty state, RTL and logical properties, dark scheme, print, reduced motion. LaTeX: line breaking, orphans and widows, microtype, overfull rows, oversized tables and floats.
- Code runs or compiles in isolation to the extent the medium allows. Where it presumes a host document or framework, say which and what that host must supply.

Treat the output as the final deliverable. No process narration or pleasantries ("I will…", "Below is…", "Hope this helps"); no notes inside the deliverable — parentheticals and footnotes included — about this revision, what changed, how it differs from an earlier version, or its status; such notes belong outside the deliverable only.

Markdown headings run in order from `#`, no skipped levels, deepest `###`.

- Multi-medium object: [依情况] take the dominant medium as the spine, the others as contrast implementations in their own sections.
- Intent not recoverable from the object: [另一解] give the alternative reading and what evidence would decide between them.
- Signature in conflict with a general principle: [待确认] record the conflict on its own terms rather than adjudicating inside the entry.
- Underdetermined input (one screenshot, a paragraph of adjectives): mark the boundary between what the object supports and what it does not, and stop there rather than filling the remainder from convention. When the implementation medium is unknown, stop at Stage 1 without apology.
- Length follows object complexity: a simple object may be four entries and one block. The four layers are a checklist, not a quota.
