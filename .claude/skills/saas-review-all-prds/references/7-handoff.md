# /saas-review-all-prds — Phase 7: Handoff

> Part of `/saas-review-all-prds`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 7: Handoff

After all file writes are complete, use `AskUserQuestion` for a closing widget.

Before building options, check project state:
- Are there any Warning-level items that are simple edits (flagged with "30-second edit", "brief addition", or similar)? → offer inline quick-fix option
- Are any PRDs in the "Flagged for Revision" table? → offer /saas-design-review option for each
- Read features-modules-index.md for the next system with Status: Not Started → offer /saas-design-system option
- Is the verdict PASS or CONCERNS on a review that ran both passes? → offer /saas-gate-check or /saas-create-architecture. A focus run (`consistency` or `design-theory`) checked one pass, so it never offers either

Build the option list dynamically — only include options that apply:

**Option pool:**
- `[_] Apply quick fix: [W-XX description] in [prd-name].md — [effort estimate]` (one option per simple-edit warning; only for Warning-level, not Blocking)
- `[_] Run /saas-design-review [flagged-prd-path] — address flagged warnings` (one per flagged PRD, if any)
- `[_] Run /saas-design-system [next-system] — next in design order` (always include, name the actual system)
- `[_] Run /saas-create-architecture — begin architecture (verdict is PASS/CONCERNS)` (include only if the verdict is PASS or CONCERNS on a review that ran both passes — never on FAIL, NOT ASSESSED or a focus run)
- `[_] Run /saas-gate-check — validate Systems Design phase gate` (include if verdict is PASS on a review that ran both passes)
- `[_] Stop here`

Assign letters A, B, C… only to included options. Mark the most pipeline-advancing option as `(recommended)`.

In collaborative and guided modes, never end the skill with plain text — always
close with this widget. In autonomous mode, print the verdict and recommended
next step, then record via `log_decision` (no widget).

---
