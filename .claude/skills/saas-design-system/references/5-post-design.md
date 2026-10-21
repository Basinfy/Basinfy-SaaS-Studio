# /saas-design-system — Phase 5: Post-Design Validation

> Part of `/saas-design-system`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 5. Post-Design Validation

**In this file:**

- 5-pre: Author the Summary
- 5a: Self-Check
- 5a-bis: Product Director PRD Alignment Review
- 5b: Update Entity Registry
- 5c: Offer Design Review
- 5d: Update Systems Index
- 5e: Update Session State
- 5f: Suggest Next Steps

After all sections are written:

### 5-pre: Author the Summary

Write `## Summary` and its `> **Quick reference**` line now — after the design
exists, so the summary distils real content rather than intentions. This runs
**at every tier**, including `standard` and a voluntary `minimal` PRD: the
Summary is what lets a later skill scan 20 PRDs and decide which to read in full
(`/saas-create-epics`, `/saas-architecture-review`, `/saas-review-all-prds` all grep it), so a
PRD without it silently forces those consumers back to full reads.

- **Summary body**: 2–3 sentences — what this system is, what it does for the
  user, why it exists in this SaaS product. No jargon; a reader who has not seen the
  PRD should learn whether it is relevant to their task.
- **Quick reference**: `Layer` and `Priority` from the systems index
  (`design/prd/features-modules-index.md`); `Key deps` from the Dependencies section just
  written (system names, or `None`).

Replace the `[To be designed]` Summary placeholder in the skeleton. Then apply
the section cycle's Write step as for any other section.

### 5a: Self-Check

Read back the complete PRD from file (not from conversation memory — the file is
the source of truth). This step needs the whole PRD: read it by section: if `.basinfy/` exists, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise read it in ranges by its headings (found with the Grep tool: pattern `^#`, content mode), since a whole-file
Read over 40 KB is refused. Verify:
- The `## Summary` and its Quick reference are populated (not the placeholder)
- Every section **required at this system's effective tier** has real content
  (not placeholders) — §1: 8 at `full`, 5 + conditional Formulas at `standard`,
  5 at a voluntary `minimal`. Do not verify against a fixed count of 8: below
  `full` that reports a correctly-authored PRD as incomplete
- Formulas reference defined variables
- Edge cases have resolutions
- Dependencies are listed with interfaces
- Acceptance criteria are testable

### 5a-bis: Product Director PRD Alignment Review

**Review mode check** — apply before spawning PD-PRD-ALIGN:
- `solo` → skip. Note: "PD-PRD-ALIGN skipped — Solo mode." Proceed to Step 5b.
- `lean` → skip (not a PHASE-GATE). Note: "PD-PRD-ALIGN skipped — Lean mode." Proceed to Step 5b.
- `full` → spawn as normal.

Before finalizing the PRD, spawn `product-director` via `Agent` using gate **PD-PRD-ALIGN** (`.claude/docs/director-gates/pd-prd-alignment.md`).

Pass: completed PRD file path, product pillars (from `design/prd/product-concept.md` or `design/prd/product-pillars.md`; if there is neither, the pitch and value proposition of `design/product-brief.md`), and the PRD's User Value section — or, when this tier did not author one, say so.

Handle verdict per the standard rules in `director-gates.md`.
On `Revise flagged items`, or to resolve a REJECT, each flagged section runs its
section cycle again — its specialist consulted as that section's review-mode
check says — and is re-approved through its "Approve the [Section Name]
section?" widget before the Edit that writes it; then record `REVISED [date]`.
A `NOT ASSESSED` answer is never an approval: name the missing input, then
supply it and re-run the gate, or record `NOT ASSESSED`.
After resolution, record the verdict in the PRD Status header:
`> **Product Director Review (PD-PRD-ALIGN)**: ALIGNED [date] / DRIFT DETECTED [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]`

---

### 5b: Update Entity Registry

Scan the completed PRD for cross-system facts that should be registered:
- Named entities (database models, API resources, webhooks) with fields or schemas
- Named items with values, weights, or categories
- Named formulas with defined variables and output ranges
- Named constants referenced by value in more than one place

**First check the registry exists** — §2a reads it *"if it exists"*, and this
step needs the same guard. At `standard` and below the file is often
absent, and a grep against a missing path returns nothing, which is
indistinguishable from "no candidate is registered yet":

- **Absent** — say so, and ask whether to create it:
  *"`design/registry/entities.yaml` does not exist. May I create it with these
  [N] entries?"* If the user declines, skip 5b and say the registry was not
  written — do not treat the skip as a clean pass.
- **Present but empty** — every list is `[]`, or the only matches are inside
  comment blocks. Treat it as present, register the candidates, but say which
  state you found: *"registry exists and is empty — all [N] entries are new."*
  The shipped template's comments carry fully-formed examples referencing
  `design/prd/catalog.md` with real-looking values (`max_workspace_items: 20`,
  `max_seats_limit: 9999`), so §2a's registry greps return **comment
  lines** on an empty registry — and §2d would then present those invented numbers to the user as
  *"These values are locked."* Match entries under a live `entities:`/`items:`/
  `formulas:`/`constants:` key, never a commented example.
- **Present** — for each candidate, check whether it is already registered:

```
Grep pattern="  - name: [candidate_name]" path="design/registry/entities.yaml"
```

Present a summary:
```
Registry candidates from this PRD:
  NEW (not yet registered):
    - [entity_name] [entity]: [attribute]=[value], [attribute]=[value]
    - [item_name] [item]: [attribute]=[value], [attribute]=[value]
    - [formula_name] [formula]: variables=[list], output=[min–max]
  ALREADY REGISTERED (referenced_by will be updated):
    - [constant_name] [constant]: value=[N] ← matches registry ✅
```

Ask: "May I update `design/registry/entities.yaml` with these [N] new entries
and update `referenced_by` for the existing entries?" (If the file was absent
and the user approved creating it, the wording is *create*, not *update*, and
there are no `referenced_by` arrays to merge.)

If yes: append new entries and update `referenced_by` arrays. Never modify
existing `value` / attribute fields without surfacing it as a conflict first.

After writing, run `bash .claude/scripts/registry.sh validate` and fix every row
about an entry this write added or changed (a DUPLICATE, STATUS or LAYOUT row,
or a PATH_MISSING row for a path it named) before you go on; name rows about
other entries to the user rather than fixing them unasked. If the script is
missing or prints nothing, say the registry check did not run, then re-read the
entries you wrote against the rules in the file's header.

### 5c: Offer Design Review

Present a completion summary:

> **PRD Complete: [System Name]**
> - Sections written: [list]
> - Provisional assumptions: [list any assumptions about undesigned dependencies]
> - Cross-system conflicts found: [list or "none"]

> **To validate this PRD, open a fresh Claude Code session and run:**
> `/saas-design-review design/prd/[system-name].md`
>
> **Never run `/saas-design-review` in the same session as `/saas-design-system`.** The reviewing
> agent must be independent of the authoring context. Running it here would inherit
> the full design history, making independent critique impossible.

**NEVER offer to run `/saas-design-review` inline.** Always direct the user to a fresh window.

### 5d: Update Systems Index

After the PRD is complete (and optionally reviewed):

**First check the systems index exists.** §2a skips it at `minimal` because it is
never written at that tier, and this step needs the same guard as §5b. It
matters most on a `minimal` project with a
`system_overrides` bump, where the effective tier is `standard` or `full` and
nothing else in §5 hints the file may be absent.

- **Absent** — say so in one line (*"no `design/prd/features-modules-index.md` at this
  workflow tier; nothing to update"*) and skip to §5e. Do **not** offer to create
  one: `/saas-map-features` owns that file, and a stub written here would be a systems
  index listing exactly one system.
- **Present** — continue:

- Read the systems index by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit
- Update the target system's row:
  - If design-review was run and verdict is APPROVED: Status → "Approved"
  - If design-review was run and verdict is NEEDS REVISION or MAJOR REVISION NEEDED: Status → "Needs Revision" (that exact string — `/saas-design-review` sets "In Review" only once the revisions are applied)
  - If design-review was skipped: Status → "Designed" (pending review)
  - If the user chose "I'll review it myself first": Status → "Designed"
  - Design Doc: link to `design/prd/[system-name].md`
- Update the Progress Tracker counts

Ask: "May I update the systems index at `design/prd/features-modules-index.md`?"

### 5e: Update Session State

Update `production/session-state/active.md` with:
- Task: [system-name] PRD
- Status: Complete (or In Review if design-review was run)
- File: design/prd/[system-name].md
- Sections: [list the sections actually authored, by name] — **never a fixed
  count**; §5a forbids verifying against `/8`, and the same reasoning applies to
  recording it. Below `full` a correctly-authored PRD has fewer than 8 sections,
  and writing "All 8 written" into session state makes the next reader believe
  a complete PRD is incomplete
- Next: [suggest next system from design order]

### 5f: Suggest Next Steps

Use `AskUserQuestion`:
- "What's next?"
  - Options:
    - "Run `/saas-consistency-check` — verify this PRD's values don't conflict with existing PRDs (recommended before designing the next system)"
    - "Design next system ([next-in-order])" — if undesigned systems remain
    - "Fix review findings" — if design-review flagged issues
    - "Stop here for this session"
    - "Run `/saas-gate-check`" — if enough MVP systems are designed

---
