# Skill Test Spec: /saas-design-tokens

## Skill Summary

`/saas-design-tokens` authors the design tokens at `design/ui/design-tokens.md` in nine
sections: 1 Visual Identity Statement, 2 Mood & Atmosphere, 3 Shape Language,
4 Color System, 5 Character Design Direction, 6 Environment Design Language,
7 UI/App Shell Visual Direction, 8 Asset Standards, 9 Reference Direction.

It first reads `design/prd/product-concept.md` (or `design/product-brief.md` at
`rigor: minimal`) and stops if neither exists. A two-tab `AskUserQuestion`
frames the session: **Scope** (with the option the resolved `workflow` tier
requires marked Recommended) and **References** (free text). Authoring is
progressive: every section's draft comes from a spawned specialist
(`design-system-director`; plus `ux-designer` for section 7 and `ui-motion-designer` for
section 8), is presented to the user, approved, and written to the file
immediately before the next section starts. Sections 2–4 share one
`design-system-director` call, as do 5–6, but their approvals and writes stay one section
at a time. The first write asks "May I create `design/ui/design-tokens.md` from the
design tokens template?"; each section is written only after an approval whose
option names the write (`[A] Lock this in and write it to design/ui/design-tokens.md`).
Only the sections in the chosen scope are authored, and the close names the
sections left out and why.

If the file already exists, the skill builds a section status table from two
Greps (headings and placeholder markers) without reading the document, and
authors only Empty or Placeholder sections.

After the scoped sections are written, Phase 5 runs the AD-DESIGN_TOKENS sign-off in
`full` review mode only and records the verdict in the design tokens's status
header. Phase 6 closes with an `AskUserQuestion` of next steps filtered by
project state.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains gate verdict keywords recorded in the status header: `APPROVED`, `CONCERNS`
- [ ] Contains ask-before-write language: "May I create `design/ui/design-tokens.md` from the design tokens template?" before the file exists, and a per-section approval option that names the write (`Lock this in and write it to design/ui/design-tokens.md`)
- [ ] Documents the AD-DESIGN_TOKENS director gate and its mode behavior
- [ ] Has a next-step handoff (e.g., `/saas-map-features`, `/saas-create-architecture`)

---

## Director Gate Checks

| Gate ID      | Trigger condition                                        | Mode guard |
|--------------|----------------------------------------------------------|------------|
| AD-DESIGN_TOKENS | Phase 5 — after all sections in the Phase 1 scope are written | full only; lean notes "AD-DESIGN_TOKENS skipped — Lean mode.", solo notes "AD-DESIGN_TOKENS skipped — Solo mode." |

The gate is spawned as the agent its definition names
(`.claude/docs/director-gates/ad-design-system-tokens.md`: `design-system-director`) and is passed the
four items that definition lists: the design tokens path, the product pillars and core
fantasy, the platform and performance constraints (`platform.*` and
`performance.*`), and the visual identity anchor. From a one-page brief it passes
the brief's pitch and "what they feel" line as the pillars and fantasy, and its
"Art & audio direction" line as the anchor.

The section-drafting delegation to `design-system-director` (and to `ux-designer` /
`ui-motion-designer`) is not a gate: it is mandatory and runs in every review mode.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Full mode, full workflow, all nine sections, AD-DESIGN_TOKENS approves

**Fixture:**
- No `design/ui/design-tokens.md`
- `design/prd/product-concept.md` exists with pillars and a Visual Identity Anchor section
- `project.yaml` has `modes.review_mode: full` and `modes.workflow: full`
- AD-DESIGN_TOKENS returns APPROVE

**Input:** `/saas-design-tokens`

**Expected behavior:**
1. Phase 0 reads the product concept and extracts title, pitch, pillars, the Visual Identity Anchor and platform
2. Phase 1 asks one `AskUserQuestion` with a Scope tab (Full bible marked Recommended, because `full` requires all 9 sections) and a free-text References tab, and notes the anchor it found
3. Section 1: `design-system-director` drafts it; the user picks from `[A] Lock this in and write it to design/ui/design-tokens.md` / `[B] Revise the one-liner` / `[C] Revise a supporting principle` / `[D] Describe my own direction`; after "May I create `design/ui/design-tokens.md` from the design tokens template?", the file is created from `.claude/docs/templates/saas-design-tokens.md` and the approved section replaces Section 1's `[To be designed]` line
4. Sections 2–4: one `design-system-director` call returns three labelled blocks; Section 2 is presented, approved with the option that names the write, and written before Section 3 is presented, and so on
5. Sections 5–6: one `design-system-director` call; presented, approved and written one at a time
6. Section 7: `design-system-director` and `ux-designer` spawn in parallel; Section 8: `design-system-director` and `ui-motion-designer` spawn in parallel; Section 9: `design-system-director`
7. Phase 5: AD-DESIGN_TOKENS spawns after the ninth section is written, with the design tokens path, the pillars and core value proposition, the platform and performance constraints, and the visual identity anchor
8. The status header records `> **Art Director Sign-Off (AD-DESIGN_TOKENS)**: APPROVED [date]`
9. Phase 6: `AskUserQuestion` of next steps that always includes `/saas-create-architecture` and "Stop here"

**Assertions:**
- [ ] The Scope tab marks "Full bible — all 9 sections" as Recommended and says why
- [ ] Every section's content comes from a spawned specialist, never from the orchestrator's own drafting
- [ ] Sections 2–4 come from a single `design-system-director` call but are presented, approved and written one section at a time
- [ ] No section is written before an approval whose option names the write (`Lock this in and write it to design/ui/design-tokens.md`), and each is written immediately after it
- [ ] The file is created from `.claude/docs/templates/saas-design-tokens.md` only after "May I create `design/ui/design-tokens.md` from the design tokens template?" — an ask that names the file — so its nine `## N. Name` headings are the ones retrofit mode (Case 4) reads
- [ ] AD-DESIGN_TOKENS spawns only after all nine sections are written, as `design-system-director` (the agent its gate definition names)
- [ ] AD-DESIGN_TOKENS is passed all four context items: the design tokens path, the pillars and core value proposition, the platform and performance constraints, and the visual identity anchor
- [ ] The APPROVE verdict is recorded in the design tokens's status header line
- [ ] The closing options include `/saas-create-architecture` and "Stop here"

---

### Case 2: AD-DESIGN_TOKENS Returns CONCERNS or NOT ASSESSED

**Fixture:**
- All nine sections have been written to `design/ui/design-tokens.md`
- `project.yaml` has `modes.review_mode: full` and `modes.workflow: full`
- Scenario (a): AD-DESIGN_TOKENS returns CONCERNS: "Color System does not match the Mood & Atmosphere targets for core workflow"
- Scenario (b): AD-DESIGN_TOKENS returns NOT ASSESSED — no platform or performance constraints were available to check the asset standards against

**Input:** `/saas-design-tokens` (reaching Phase 5)

**Expected behavior:**
1. (a) The CONCERNS are surfaced to the user via `AskUserQuestion` with the standard options from `director-gates.md`: `Revise flagged items` / `Accept and proceed` / `Discuss further`
2. (a) If "Accept and proceed": the status header records `CONCERNS (accepted) [date]`
3. (a) If "Revise flagged items": `design-system-director` — the Color System's own specialist — re-drafts Section 4; it is shown to the user and approved with the option that names the write before it is written; the status header then records `REVISED [date]`
4. (b) The missing input is named, and the status header records `NOT ASSESSED [date] — [missing input]`, never `APPROVED`
5. Phase 6 runs only after the verdict is recorded

**Assertions:**
- [ ] (a) CONCERNS are shown to the user with the three standard options, not auto-accepted
- [ ] (a) "Accept and proceed" records `CONCERNS (accepted) [date]` in the status header
- [ ] (a) The flagged section is re-drafted by its specialist, not by the orchestrator, and approved before it is written; the header records `REVISED [date]`
- [ ] (b) NOT ASSESSED is recorded as such, naming the missing input — not as an approval
- [ ] Phase 6 next steps are not presented before the verdict is recorded

---

### Case 3: Lean Mode, Standard Workflow — Core sections only, gate skipped

**Fixture:**
- No existing design tokens
- `design/prd/product-concept.md` exists
- `project.yaml` has `modes.review_mode: lean` and `modes.workflow: standard`
- User picks the Recommended scope

**Input:** `/saas-design-tokens`

**Expected behavior:**
1. The Scope tab marks "Visual identity core (sections 1–4 only)" as Recommended and says "Sections 1–4 are what `standard` requires; 5–9 are available if you want them."
2. Sections 1–4 are drafted by `design-system-director`, each approved and written before the next
3. Phases 3 and 4 (sections 5–9) are not run, because they are outside the chosen scope
4. Phase 5 does not spawn AD-DESIGN_TOKENS and prints "AD-DESIGN_TOKENS skipped — Lean mode."
5. Phase 6 first names sections 5–9 as not authored this run (outside the chosen scope), then presents next steps

**Assertions:**
- [ ] The Scope recommendation is sections 1–4, with the `standard` explanation
- [ ] Only sections 1–4 are authored
- [ ] The close names sections 5–9 as not authored and says why, so the four-section bible does not read as complete
- [ ] AD-DESIGN_TOKENS is not spawned in lean mode, and the skip note reads "AD-DESIGN_TOKENS skipped — Lean mode."
- [ ] Per-section user approval is still required before each write

---

### Case 4: Existing Design Tokens Spec — Retrofit of incomplete sections only

**Fixture:**
- `design/ui/design-tokens.md` exists with sections 1–4 fully written
- Section 5's heading is followed by `[To be designed]`
- Sections 6–9 have headings with nothing between them
- `design/prd/product-concept.md` exists; `project.yaml` has `modes.workflow: full` and `modes.review_mode: full`
- At the Scope tab the user picks `Resume — fill in missing sections`
- AD-DESIGN_TOKENS returns APPROVE

**Input:** `/saas-design-tokens`

**Expected behavior:**
1. Phase 0 Globs `design/ui/design-tokens.md` and finds it
2. The skill runs two Greps — `^## ` headings and placeholder markers (`[To be designed]`, `[TBD]`, `[To be written]`, `TODO`) — and does not read the whole document; an ambiguous section is read by line range only
3. It builds a status table (sections 1–4 Complete, 5 Placeholder, 6–9 Empty) and says: "Found existing design tokens at `design/ui/design-tokens.md`. 4 sections are complete, 5 need content. I'll work on the incomplete sections only — existing content will not be touched."
4. Only sections 5–9 are authored, approved and written; sections 1–4 are not re-authored or rewritten
5. After the ninth section is written, Phase 5 spawns AD-DESIGN_TOKENS — a retrofit still ends in the sign-off in `full` review mode — and the status header records `APPROVED [date]`
6. Phase 6 names sections 1–4 as not authored this run (already complete)

**Assertions:**
- [ ] Section status comes from the two Greps, not from a full read of the file
- [ ] The retrofit message states the complete and incomplete counts and that existing content will not be touched
- [ ] Only Empty and Placeholder sections are authored; Complete sections are left unchanged
- [ ] The status table rows use the section names the skill authors (e.g., `Mood & Atmosphere`, `Shape Language`, `Reference Direction`)
- [ ] AD-DESIGN_TOKENS runs after the retrofitted sections are written, as it does after a fresh run

---

### Case 5: Solo Mode and Missing Concept

**Fixture:**
- Scenario (a): no `design/prd/product-concept.md`; `design/product-brief.md` exists; `project.yaml` has `modes.review_mode: solo` and `modes.workflow: minimal`
- Scenario (b): neither `design/prd/product-concept.md` nor `design/product-brief.md` exists

**Input:** `/saas-design-tokens`

**Expected behavior:**
1. (a) Phase 0 reads the one-page brief (working title, pitch, "what they feel" line, "Art & audio direction" line) in place of the concept
2. (a) Before the Scope question, the skill says no design tokens is required at `minimal` and offers sections 1–4 rather than defaulting to all 9
3. (a) `design-system-director` is still spawned to draft each authored section — the solo review mode skips the sign-off, not the authoring delegation
4. (a) Phase 5 prints "AD-DESIGN_TOKENS skipped — Solo mode." and no gate agent is spawned; on "May I record the skipped sign-off in `design/ui/design-tokens.md`'s header?" answered yes, the status header records `> **Art Director Sign-Off (AD-DESIGN_TOKENS)**: SKIPPED [date] — solo mode`
5. (a) Phase 6, at `workflow: minimal`, offers `/saas-create-stories`, `/saas-dev-story [next story]` and Stop here — not `/saas-create-architecture` or the PRD/`/saas-map-features` pool
6. (b) The skill stops with: "No product concept found. Run `/saas-brainstorm` first — the design tokens is authored after the product concept is approved." No file is created and no agent is spawned

**Assertions:**
- [ ] (a) The product brief is used when the product concept is absent
- [ ] (a) The skill states no design tokens is required at `minimal` before asking the Scope question
- [ ] (a) `design-system-director` still drafts the sections in solo mode
- [ ] (a) AD-DESIGN_TOKENS is not spawned; the skip note reads "AD-DESIGN_TOKENS skipped — Solo mode.", and the header records the SKIPPED sign-off line with the mode and date
- [ ] (a) The Phase 6 option pool is the `workflow: minimal` set, not the `standard`/`full` PRD pool
- [ ] (b) The skill stops with the `/saas-brainstorm` message and writes nothing

---

## Protocol Compliance

- [ ] Reads the product concept (or product brief) before authoring; stops with the `/saas-brainstorm` message if neither exists
- [ ] Every section is drafted by a specialist agent; the orchestrator never drafts content itself
- [ ] Each section is presented, approved and written one at a time — approvals and writes are never batched
- [ ] The file is created only after the "May I create `design/ui/design-tokens.md`…" ask, and each section is written only after an approval option that names the write
- [ ] Only the sections in the chosen scope are authored, and the close names every section left out and why
- [ ] Conflicts between `design-system-director` and `ux-designer` or `ui-motion-designer` are surfaced to the user, never silently resolved
- [ ] AD-DESIGN_TOKENS runs only in full mode, after the scoped sections are written; lean and solo print a skip note naming the gate and mode
- [ ] Ends with an `AskUserQuestion` of next steps filtered by project state — at `standard`/`full` always including `/saas-create-architecture` and "Stop here"; at `workflow: minimal`, `/saas-create-stories` or `/saas-dev-story [next story]` plus Stop here

---

## Coverage Notes

- An AD-DESIGN_TOKENS REJECT verdict is not separately tested; per the standard
  verdict rules the skill surfaces the blockers and does not advance until they
  are resolved, the flagged sections re-drafted by their specialist and
  re-approved as in Case 2 (a).
- At `workflow: standard` the design tokens is required only when visual asset
  stories exist. That condition is not fixture-tested; Case 3 covers only the
  `standard` scope recommendation.
- The Section 7 (`design-system-director` vs `ux-designer`) and Section 8
  (`design-system-director` vs `ui-motion-designer`) conflict handling is covered only by
  Protocol Compliance, not by a dedicated fixture.
- The "Asset standards only (section 8)" scope option is not fixture-tested
  (Case 4 covers "Resume").
- `docs.density` depth variations and `guided` / `autonomous` automation modes
  are not tested.
- The Phase 6 option filtering (skip `/saas-map-features` when
  `design/prd/features-modules-index.md` exists, etc.) is not individually tested.
