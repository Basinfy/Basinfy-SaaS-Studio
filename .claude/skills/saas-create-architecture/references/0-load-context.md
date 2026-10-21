# /saas-create-architecture — Phase 0: Load All Context

> Part of `/saas-create-architecture`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 0: Load All Context

**In this file:**

- 0a. Engine Context (Critical)
- 0b. Design Context + Technical Requirements Extraction
- 0c. Existing Architecture Decisions
- 0d. Generate Knowledge Gap Inventory
- 0e. Existing Architecture Document

Before anything else, load the full project context in this order:

### 0a. Engine Context (Critical)

Read the four project-wide engine documents in full — they are small, and every
part of each is used:

1. `docs/engine-reference/[engine]/VERSION.md`
   → Extract: engine name, version, LLM cutoff, post-cutoff risk levels
2. `docs/engine-reference/[engine]/breaking-changes.md`
   → Extract: all HIGH and MEDIUM risk changes
3. `docs/engine-reference/[engine]/deprecated-apis.md`
   → Extract: APIs to avoid
4. `docs/engine-reference/[engine]/current-best-practices.md`
   → Extract: post-cutoff best practices that differ from training data

Then read **only the module docs whose domain this SaaS product actually uses** —
not the whole `modules/` directory:

5. `docs/engine-reference/[engine]/modules/` — glob it to establish what exists,
   then match against the domains present in `design/prd/features-modules-index.md`
   (the same domain vocabulary the ADR template uses: Auth, Database, API,
   Routing, UI, Billing, State, Background Jobs, Core). Read the matching
   modules; skip the rest.
   → Extract: current API patterns per domain

   A product with no real-time collaboration does not need the networking module loaded
   to write its architecture, and loading it costs the same as one that does.
   **If the domain match is ambiguous, read the module** — a missed engine
   constraint is far more expensive here than a redundant read, because this
   phase is where those constraints get baked into the architecture.

If no engine is configured, stop and prompt:
> "No engine is configured. Run `/saas-setup-stack` first. Architecture cannot be
> written without knowing which engine and version you are targeting."

### 0b. Design Context + Technical Requirements Extraction

Load the approved design documents and extract technical requirements from each.
Read each one by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit.

1. `design/prd/product-concept.md` — product pillars, ICP, core value loop
2. `design/prd/features-modules-index.md` — all systems, dependencies, priority tiers

**Check both exist before reading either. Neither is optional here, and both
need an absence branch** — §0a stops for an unconfigured engine, and these two
matter just as much:

- **`features-modules-index.md` absent** — stop:
  > "No systems index found. Run `/saas-map-features` first. An architecture written
  > without it invents layers for systems nobody mapped, and every ADR, epic and
  > story downstream inherits that invention."
  At `minimal` the index is not required (the `workflow` list in SKILL.md) — say so and proceed
  from the brief instead.
- **`product-concept.md` absent** — at `standard`/`full`, stop and point at
  `/saas-brainstorm`. At `minimal`, read `design/product-brief.md` in its place; if that
  is absent too, stop — there is no design record to architect against.
- **Either present but empty or still template placeholders** — treat as absent.
  Present-but-empty is the case that most looks like present.

Do not proceed on a partial read and note it later. This phase is where design
assumptions get baked into ADRs, and an assumption made here is re-derived by
everything downstream rather than re-checked.
3. Project config — `naming.*` and `performance.*` from `project.yaml` (for any
   key absent or empty, fall back to `.claude/docs/technical-preferences.md`);
   allowed libraries and forbidden patterns from
   `.claude/docs/technical-preferences.md` (not migrated to project.yaml)
4. **Every PRD in `docs/specs/` (or `design/prd/`)** — extract technical requirements from the
   sections that carry them, **not from whole files**. Establish the denominator
   first (glob `docs/specs/*.md` or `design/prd/*.md`, count **N**), then:
   ```
   Grep pattern="^## (Detailed Rules|Detailed Design|Formulas|Dependencies|Data Models|Security|Acceptance Criteria)" glob="docs/specs/*.md" output_mode="content" -A 40
   ```
   Overview, Problem Statement, and User Personas are narrative and imply no architecture; the
   scanned set is where rules, schemas, contracts, and cross-system integrations live. Accept
   either `## Detailed Rules` or `## Detailed Design` — the design standard and
   the PRD template disagree on the name and they denote the same section.

   Full-read a PRD when it matched **zero** sections (it predates the template —
   a zero-match means "unstructured", never "no requirements") or when a scanned
   section refers to material outside itself. **Never treat an absent section as
   an absent requirement**: report any PRD that contributed nothing, rather than
   letting it drop silently out of the baseline below.

   For each, extract:
   - Data structures implied by product requirements
   - Performance constraints stated or implied
   - Engine capabilities the system requires
   - Cross-system communication patterns (what talks to what, how)
   - State that must persist (save/load implications)
   - Threading or timing requirements

Build a **Technical Requirements Baseline** — a flat list of all extracted
requirements across all PRDs, numbered `TR-[system]-[NNN]`, the TR registry's
ID format. This is the
complete set of what the architecture must cover.

**The IDs come from the TR registry, not from a fresh count.** Stories and ADRs
cite TR-IDs, and `/saas-architecture-review` keeps them permanent in
`docs/architecture/tr-registry.yaml`. A baseline numbered from 001 on a re-run
gives a requirement a different ID from the one stories already cite. So, before
numbering:

- **Registry present with entries:** read `docs/architecture/tr-registry.yaml`.
  A requirement that matches an `active` entry for the same system (same intent,
  wording may differ) keeps that entry's ID. Skip `deprecated` and
  `superseded-by` entries; they were retired on purpose. Every other requirement
  is **provisional**: number it from `bash .claude/scripts/registry.sh next-id tr
  <system>` onwards, so it cannot reuse a registered or retired ID, and mark it
  `(provisional)`. `/saas-architecture-review` registers it and gives the permanent ID.
- **Registry absent, or `requirements: []`:** every ID is provisional. Say so in
  the baseline's header line, so nobody cites them as permanent.

Present it as:

```
## Technical Requirements Baseline
Extracted from [N] PRDs | [X] total requirements | [R] registered, [P] provisional
(TR registry: [read, E entries | absent | empty])

| Req ID | PRD | System | Requirement | Domain |
|--------|-----|--------|-------------|--------|
| TR-auth-001 | auth.md | Auth | Session token verification | Security |
| TR-billing-001 | billing.md | Billing | Stripe webhook handler | Integrations |
| TR-catalog-001 (provisional) | catalog.md | Catalog | Workspace items persistence | Database |
```

This baseline feeds into every subsequent phase. No PRD requirement should be
left without an architectural decision to support it by the end of this session.

### 0c. Existing Architecture Decisions

To learn **what has already been decided and in which domain**, scan the ADR
headers — do not full-read every ADR to produce a list of numbers and domains:
```
Grep pattern="^## (Status|Summary)" glob="docs/architecture/adr-*.md" output_mode="content" -A 4
Grep pattern="\*\*Domain\*\*" glob="docs/architecture/adr-*.md" output_mode="content"
```
`## Summary` (a 2-sentence what-and-why) plus `## Status` and the Engine
Compatibility `Domain` field are exactly "what was decided and its domain". List
the ADRs found, their status, and their domains from the scan. Full-read a
specific ADR only when a new decision this session would collide with it and you
need its reasoning — not to build the inventory. Read it by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings: if `.basinfy/` exists, use `basinfy_search` and `basinfy_read`; otherwise use the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit.

### 0d. Generate Knowledge Gap Inventory

Before proceeding, display a structured summary:

```
## Engine Knowledge Gap Inventory
Engine: [name + version]
LLM Training Covers: up to approximately [version]
Post-Cutoff Versions: [list]

### HIGH RISK Domains (must verify against stack reference before deciding)
- [Domain]: [Key changes]

### MEDIUM RISK Domains (verify key APIs)
- [Domain]: [Key changes]

### LOW RISK Domains (in training data, likely reliable)
- [Domain]: [no significant post-cutoff changes]

### Systems from PRD that touch HIGH/MEDIUM risk domains:
- [PRD system name] → [domain] → [risk level]
```

Use `AskUserQuestion`:
- Prompt: "One or more engine domains are HIGH RISK — the LLM's knowledge may be unreliable for these areas. Architectural recommendations in these domains should be cross-referenced with the engine docs before being acted on. How would you like to proceed?"
- Options:
  - `[A] Proceed — flag HIGH RISK domains throughout the output`
  - `[B] Let me check the stack reference first — pause here`
  - `[C] Show me which domains are HIGH RISK and why`

### 0e. Existing Architecture Document

Glob `docs/architecture/architecture.md`. If it exists, this run updates it —
it never replaces it unasked. Read its `## Document Status` block and its `##`
headings, then use `AskUserQuestion`:
- Prompt: "An architecture document already exists (v[N], [last updated]). What should this run do?"
- Options: `[A] Update chosen sections in place` / `[B] Rewrite the whole document — replaces the existing file` / `[C] Stop`

On `[A]`, ask which sections. Phases 1–6 author only those and say which they
skipped; Phase 7 replaces just those sections and raises `Version` to N+1,
leaving every other section as it is. `[B]` runs the full walkthrough, and
Phase 7's ask says it replaces the existing file.

A focus-area argument (`layers`, `data-flow`, `api-boundaries`, `adr-audit`)
is `[A]` with that one section chosen: it runs only its phase (1, 3, 4 or 5),
and Phase 7 writes that section. Phase 7b still runs on the updated document —
an update is reviewed like a first draft, at the review modes that review one. With no existing document there is nothing to
update — say so, and offer the full walkthrough instead.

---
