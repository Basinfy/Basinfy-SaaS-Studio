# /saas-design-system — Phase 1: Parse Arguments & Validate

> Part of `/saas-design-system`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 1. Parse Arguments & Validate

**In this file:**

- `docs.density`
- No system name given: the systems index picks the next one
- Detect retrofit mode
- `workflow` for this system, and `## Summary` at every tier

See `.claude/docs/director-gates.md` for the full check pattern. Individual gate definitions live in `.claude/docs/director-gates/[gate-id].md` — the spawned agent reads its own gate file; do not read it in the parent session.


Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`docs.density`** — it controls per-section *depth*, where `workflow`
controls which sections exist. `modes.rigor` sets both together; set
`docs.density` explicitly to vary depth alone: `terse` (the default, via `rigor: minimal`) = bullet points, 2–5 lines per section,
skip rationale and preambles; `balanced` = paragraphs with light rationale
(`rigor: standard`); `thorough` = full prose with rationale, examples, and alternatives
considered. Apply it to every section you author. Mandated structures (the
Formulas variable table, Given-When-Then acceptance criteria) are correctness
requirements at every density — `terse` trims the surrounding prose, never the
required structure itself.

A system name or retrofit path is **required**. If missing:

1. Check if `design/prd/features-modules-index.md` exists.
2. If it exists: read it, find the highest-priority system with status "Not Started" or equivalent, and use `AskUserQuestion`:
   - Prompt: "The next system in your design order is **[system-name]** ([priority] | [layer]). Start designing it?"
   - Options: `[A] Yes — design [system-name]` / `[B] Pick a different system` / `[C] Stop here`
   - If [A]: proceed with that system name. If [B]: ask which system to design (plain text). If [C]: exit.
3. If no systems index exists, fail with:
   > "Usage: `/saas-design-system <system-name>` — e.g., `/saas-design-system movement`
   > Or to fill gaps in an existing PRD: `/saas-design-system retrofit design/prd/[system-name].md`
   > No systems index found. Run `/saas-map-features` first to map your systems and get the design order."

**Detect retrofit mode:**
If the argument starts with `retrofit` or the argument is a file path to an
existing `.md` file in `design/prd/`, enter **retrofit mode**:

1. Read the existing PRD file. Read it by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings: if `.basinfy/` exists, use `basinfy_search` and `basinfy_read`; otherwise use the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit.
2. Identify which of the 8 **possible** sections are present (scan for section
   headings): Overview / Problem Statement, User Stories / Personas, Detailed Requirements / Rules, Formulas / Data Models,
   Edge Cases, Dependencies, Configuration Parameters, Acceptance Criteria.
   **Which of them are *required* depends on the effective tier** (§1) — at
   `standard` only 5 are, plus Formulas / Data Models for calculation categories, and User Stories / Personas
   and Configuration Parameters are skipped **by design**. Report an absent section as a gap
   only when the tier requires it; otherwise list it as available-to-add. Calling
   all 8 required here reports two by-design-absent sections as gaps on every
   `standard` project.
3. Identify which sections contain only placeholder text (`[To be designed]` or
   equivalent — blank, a single line, or obviously incomplete).
4. Present to the user before doing anything:
   ```
   ## Retrofit: [System Name]
   File: design/prd/[filename].md

   Sections already written (will not be touched):
   ✓ [section name]
   ✓ [section name]

   Missing or incomplete sections (will be authored):
   ✗ [section name] — missing
   ✗ [section name] — placeholder only
   ```
5. Ask: "Shall I fill the [N] missing sections? I will not modify any existing content."
6. If yes: proceed to **Phase 2 (Gather Context)** as normal, but in **Phase 3**
   skip creating the skeleton (file already exists) and in **Phase 4** skip
   sections that are already complete. Only run the section cycle for missing/
   incomplete sections.
7. **Never overwrite existing section content.** Use Edit tool to replace only
   `[To be designed]` placeholders or empty section bodies.

If NOT in retrofit mode, normalize the system name to kebab-case for the
filename (e.g., "billing system" becomes `billing-system`).

**`workflow`** for this system (per `.claude/docs/workflow-modes.md`) — use the
`system_overrides` row for this system if the block lists one, else the project
value.

The resolved tier determines which PRD sections are **required** (applied in §4).
**`## Summary` is required at every tier and is not one of the 8** — §5-pre
authors it unconditionally (*"This runs at every tier"*). The per-tier lists
below do not repeat it, and a PRD checked against a tier list alone would pass
with no Summary, the one section `/saas-review-all-prds` and the tiered-loading
readers depend on. Read every list below as "`## Summary`, plus:".
- `full` — all 8 sections
- `standard` — Overview, Detailed Design, Edge Cases, Dependencies, Acceptance
  Criteria (5 required); **Formulas conditional** — required when the system
  **defines numeric rules**: rates, quotas, thresholds, tier costs, usage limits,
  or any value a pricing or capacity pass would tune. Optional only when the system
  defines no such value. **The `Category` in `features-modules-index.md` is a hint, not
  the test** — `Core Business Workflow`, `Economy` and `Progression` systems almost always
  qualify, and a `Core`, `UI` or `Persistence` system that defines a numeric rule
  qualifies too. If the Detailed Design states a quantity that is not a constant
  of the engine, Formulas is required. **User Stories / Personas and Configuration Parameters skipped**
  unless `workflow_overrides` force them (`configuration: true` forces Configuration Parameters)

  > **Do not gate this on a category token.** A test such as "the category is
  > billing / auth / analytics / workflows" matches tokens `/saas-map-features` does not
  > write — `templates/features-modules-index.md` defines the categories as `Core ·
  > Core Business Workflow · Progression · Economy · Persistence · UI · Audio · Narrative ·
  > Meta` and lists **billing and auth as example systems under `Core Business Workflow`**. A
  > billing system categorised exactly as the template instructs matches none of
  > the four, and Formulas would be dropped for the system most likely to need it.
- `minimal` — a PRD is not required (the product brief replaces it). If invoked
  voluntarily at minimal, author exactly the 5 standard sections (Overview,
  Detailed Design, Edge Cases, Dependencies, Acceptance Criteria) — the
  conditional Formulas rule does NOT re-apply at minimal — and tell the user
  the PRD is optional at this workflow level.

Retrofit mode is unaffected — it fills whatever sections are missing regardless
of tier.

---
