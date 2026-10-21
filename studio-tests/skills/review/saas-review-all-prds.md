# Skill Test Spec: /saas-review-all-prds

## Skill Summary

`/saas-review-all-prds` is an Opus-tier skill that performs a holistic cross-PRD
review across the system PRDs in `design/prd/`. After loading everything
(Phase 1), it runs two independent reviews in parallel as `lead-product-manager`
sub-agents: Phase 2, Cross-PRD Consistency (dependency bidirectionality, rule
contradictions, stale references, ownership conflicts, formula compatibility,
acceptance-criteria conflicts), and Phase 3, Product Design Holism (competing
activation loops, attention budget, tier cannibalization, unit economic loops,
difficulty curves, pillar alignment, user-fantasy coherence). Phase 4 walks
multi-system scenarios. It produces a PASS / NOT ASSESSED / CONCERNS / FAIL
verdict, and writes `design/prd/prd-cross-review-[YYYY-MM-DD].md` and
systems-index "Needs Revision" statuses only after the user approves.

Each phase is a `references/N-*.md` file the skill reads before doing that phase and
again if the conversation is compacted during it. The argument picks the focus:
`full` (default), `consistency`, `design-theory`, or `since-last-review`, which
takes its scope from `.claude/scripts/review-scope.sh`.

It is invoked after individual PRDs are approved and before architecture work.
It spawns no director gate agents. At `workflow: minimal` it does not apply (no
PRDs), so every fixture below sets `modes.workflow: full`.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥5 phase headings (complex multi-phase skill)
- [ ] Contains verdict keywords: PASS, NOT ASSESSED, CONCERNS, FAIL
- [ ] `allowed-tools` includes Write, so "May I write" language is present (Phase 6 report write)
- [ ] Has a next-step handoff at the end
- [ ] Documents parallel spawning of Phase 2 (Consistency) and Phase 3 (Design Theory)

---

## Director Gate Checks

No director gates — this skill spawns no director gate agents and resolves no
review mode. It IS the holistic review; its only agents are the two
`lead-product-manager` sub-agents for Phases 2 and 3.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Clean PRD set with no conflicts

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` contains `product-concept.md`, `product-pillars.md` (pillars and
  anti-pillars), `features-modules-index.md`, and three system PRDs — `billing.md`,
  `catalog.md`, `notifications.md` — each with every section Phase 1c loads and a
  filled `## Cross-References` table whose rows all resolve
- All PRDs are consistent: no formula contradictions, no competing ownership,
  no stale references, reciprocal dependencies; every system serves a pillar
- Nothing a design-theory check would warn on either: one primary progression
  loop, at most 4 systems active at once, every resource has both a source and a
  sink, compatible scaling curves, compatible user fantasies

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. Skill greps `## Summary` across `design/prd/*.md` and shows a manifest ("Found [N] PRDs. Summaries: …")
2. Skill reads the entity registry, or notes that it is empty and suggests `/saas-consistency-check`
3. Skill loads the review sections and reports "Loaded [N] system PRDs covering [M] systems. Pillars: […]. Anti-pillars: […]."
4. Phase 2 and Phase 3 spawn simultaneously as `lead-product-manager` sub-agents, each
   given the pasted PRD content for its slice (not file paths) and its checklist (2a–2f / 3a–3g)
5. Phase 4 walks 3–5 multi-system scenarios
6. Report shows no blocking issues and no warnings; verdict PASS
7. `AskUserQuestion`: "May I write this review to `design/prd/prd-cross-review-[date].md`?"
8. Closing widget built from project state

**Assertions:**
- [ ] Phase 2 and Phase 3 are spawned in parallel (both `Agent` calls issued before either result is awaited)
- [ ] Sub-agent prompts carry the PRD section content, not just file paths
- [ ] The report states the covered set: `PRDs reviewed: [N] of [M] present` and `Not read: none`, and lists the scenarios walked
- [ ] Verdict is PASS only because there are no blocking issues **and no warnings**, over three readable PRDs — a single warning would make it CONCERNS
- [ ] The report is written only after the user approves, under an ISO-dated name (`prd-cross-review-YYYY-MM-DD.md`)
- [ ] The closing widget offers `/saas-create-architecture` and `/saas-gate-check` (both allowed on PASS)

---

### Case 2: Failure Path — Conflicting rules between two PRDs

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `billing.md` defines a floor: "Minimum seat fee after discount reduction is $10"
- `enterprise-terms.md` states a business rule that bypasses it: "Custom negotiated deals ignore discount floor
  and can reduce seat fee to 0"
- The two PRDs are otherwise complete and valid; `product-pillars.md` defines the
  pillars and `features-modules-index.md` lists both systems

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. Phase 2 detects the floor/ceiling contradiction
2. Report prints a `🔴 Rule Contradiction` entry quoting both rules and asking which PRD is authoritative
3. The issue sits under Consistency Issues → Blocking; both PRDs appear in "PRDs Flagged for Revision"
4. Verdict: FAIL, with "If FAIL — required actions before re-running"
5. After the report write question, a second `AskUserQuestion` offers to mark the flagged PRDs `Needs Revision` in `features-modules-index.md`

**Assertions:**
- [ ] Verdict is FAIL (not PASS, CONCERNS or NOT ASSESSED)
- [ ] Both PRD filenames are named in the conflict entry
- [ ] The specific contradicting rules are quoted (not a vague "conflict found")
- [ ] The issue is classified as Blocking (🔴), and both PRDs are in the flagged table with Priority Blocking
- [ ] Skill does NOT decide which PRD is right and does NOT edit either PRD
- [ ] If the user approves the systems-index update, the status is written as exactly `Needs Revision` with no parenthetical
- [ ] The closing widget offers neither `/saas-create-architecture` nor `/saas-gate-check` (verdict is FAIL)

---

### Case 3: Partial Path — Cross-reference to a PRD that does not exist

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds `product-pillars.md`, `features-modules-index.md` and two consistent
  system PRDs, `notifications.md` and `catalog.md`
- `notifications.md`'s `## Cross-References` table has a row whose Target PRD is
  `system-b.md`; no `design/prd/system-b.md` exists
- `features-modules-index.md` lists system-b as the next system with Status: Not Started
- Nothing else would warn

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. Phase 2's stale-reference check (2c) confirms each Cross-References row's
   Target PRD exists, and finds `system-b.md` missing
2. Because `features-modules-index.md` lists system-b, the reference is a dependency on
   planned work: a `⚠️ Stale Reference` Warning naming `notifications.md` and the
   missing target, to re-check when that PRD is written
3. No other issues found; verdict CONCERNS (warnings, nothing blocking)
4. Closing widget includes `/saas-design-system system-b` (next in design order)

**Assertions:**
- [ ] The finding names `notifications.md` and the missing `system-b.md`
- [ ] It is reported under Warnings (⚠️), not Blocking — because the systems index lists system-b as planned
- [ ] Verdict is CONCERNS — not FAIL for a reference to planned work, and not an unqualified PASS
- [ ] The closing widget offers `/saas-design-system system-b`, and offers `/saas-create-architecture` but not `/saas-gate-check` (which requires PASS)
- [ ] Skill does NOT skip or silently ignore the missing target

**Case 3b — the target is in neither place:** the same fixture, except
`features-modules-index.md` has no entry for system-b. Nothing will ever define it.

**Assertions (3b):**
- [ ] The reference is reported as 🔴 Blocking, and `notifications.md` appears in "PRDs Flagged for Revision" with Priority Blocking
- [ ] Verdict is FAIL, and the closing widget offers neither `/saas-create-architecture` nor `/saas-gate-check`

---

### Case 4: Edge Case — Fewer than two system PRDs

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` contains `features-modules-index.md` and a single system PRD, `billing.md`

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. Skill loads what exists and counts the system PRDs
2. Fewer than 2 → skill stops with: "Cross-PRD review requires at least 2 system
   PRDs. Write more PRDs first, then re-run `/saas-review-all-prds`."
3. No review phase runs and no report is offered

**Assertions:**
- [ ] Skill outputs the "requires at least 2 system PRDs" stop message
- [ ] Neither Phase 2 nor Phase 3 sub-agent is spawned
- [ ] No verdict of PASS is produced for the single document
- [ ] No report write is offered and no file is written

---

### Case 5: Director Gate — none spawned, whatever the review mode

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds the Case 1 set: concept, pillars, systems index and three
  consistent system PRDs
- 5a: `modes.review_mode: full`; 5b: `modes.review_mode: solo`

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. The resolved config block requests only `automation`, `workflow` and
   `system_overrides` — review mode is not consulted
2. In both 5a and 5b, the same two `lead-product-manager` sub-agents run Phases 2 and 3
3. No director gate agent is spawned; the verdict is produced normally

**Assertions:**
- [ ] No director gate agents (CD-, TD-, PR-, AD-, LP- prefixed gates) are spawned in either mode
- [ ] Review mode changes nothing: under `solo` the two `lead-product-manager` sub-agents still run
- [ ] Output contains no "Gate: [GATE-ID]" or "[GATE-ID] skipped" entries
- [ ] The skill produces a verdict in both modes
- [ ] The only `Agent` spawns in the run are the Phase 2 and Phase 3 `lead-product-manager` sub-agents

---

### Case 6: NOT ASSESSED — fewer than two readable PRDs

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds `product-pillars.md`, `features-modules-index.md` and two system PRDs:
  `billing.md`, complete, and `catalog.md`, which has the template's headings but
  only placeholder text under them

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. Two system PRDs exist, so the "requires at least 2 system PRDs" stop does not fire
2. `catalog.md` is present but empty — not reviewable — so only one PRD can be
   compared, and a clean result would mean only that nothing was compared
3. Verdict NOT ASSESSED; "If NOT ASSESSED — what could not be reviewed, and why"
   names `catalog.md` as placeholder-only and says a cross-review needs two
   readable PRDs
4. The report states `PRDs reviewed: 1 of 2 present`

**Assertions:**
- [ ] Verdict is NOT ASSESSED — not PASS, although no contradiction was found
- [ ] The report names `catalog.md` as present but not reviewable, and states `PRDs reviewed: 1 of 2 present`
- [ ] A PRD that could not be read at all would be named on the report's `Not read:` line under every verdict, and is a NOT ASSESSED trigger like an empty one
- [ ] The closing widget offers neither `/saas-create-architecture` nor `/saas-gate-check`

---

### Case 7: Phase files are read on demand, and again after a compaction

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds the Case 1 set: concept, pillars, systems index and three consistent system PRDs
- The skill folder holds `references/1-load.md` through `references/7-handoff.md`
- The conversation is compacted while Phase 4 (scenario walkthrough) is under way, then the run continues

**Input:** `/saas-review-all-prds`

**Expected behavior:**
1. SKILL.md holds no phase steps; before Phase 1 the run reads `references/1-load.md`, and it does not scan `## Summary` lines or load PRD sections before that read
2. Phases 2 and 3 are spawned in parallel as `lead-product-manager` sub-agents, and the main run reads `references/2-consistency.md` and `references/3-design-holism.md` before it passes each sub-agent its checklist (2a–2f, 3a–3g)
3. `references/4-scenarios.md`, `5-report.md`, `6-write.md` and `7-handoff.md` are each read before that phase's work: no scenario before the first, no verdict or report before `5-report.md`, no write question before `6-write.md`, no closing widget before `7-handoff.md`
4. After the compaction the run reads `references/4-scenarios.md` again before it continues the walkthrough, as the skill says: "Read it again if the conversation was compacted or resumed during this phase."

**Assertions:**
- [ ] The transcript shows a read of each of the seven `references/N-*.md` files, each before that phase's work begins
- [ ] No phase work (summary scan, checklist hand-off, scenarios, verdict, write question, closing widget) happens before its phase file is read
- [ ] After the compaction, `references/4-scenarios.md` is read again before the walkthrough resumes
- [ ] The Phase 2 and Phase 3 sub-agents are still spawned in parallel with the checklist items from the phase files

---

### Case 8: `since-last-review` — scope comes from the script, not from reasoning over git

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds `product-pillars.md`, `features-modules-index.md`, a committed `prd-cross-review-2025-01-15.md`, and four system PRDs: `billing.md`, `catalog.md`, `notifications.md`, `enterprise-terms.md`
- Only `billing.md` has been modified since that report was committed; its `## Dependencies` section names `catalog.md`
- `notifications.md` and `enterprise-terms.md` are unchanged and no changed PRD names them
- `.claude/scripts/review-scope.sh` prints `PRIOR_REVIEW: design/prd/prd-cross-review-2025-01-15.md`, `CHANGED:` with `design/prd/billing.md`, and a `DEPS` line `billing.md -> catalog.md`

**Input:** `/saas-review-all-prds since-last-review`

**Expected behavior:**
1. After the manifest, the run executes `bash .claude/scripts/review-scope.sh` rather than working out the changed set from `git log` or `git diff` itself
2. Scope is the `CHANGED` set plus the PRDs named on the `DEPS` lines: `billing.md` and `catalog.md`; the run shows the user which PRDs are in scope before any full read
3. Only those two PRDs get the Phase 1c section load; `notifications.md` and `enterprise-terms.md` are not loaded, and no second dependency-expansion pass is made
4. The report states `PRDs reviewed: 2 of 4 present`
5. Phases 2 and 3 run over the two in-scope PRDs as usual

**Assertions:**
- [ ] `bash .claude/scripts/review-scope.sh` is run, and its `CHANGED` and `DEPS` lists are used as the scope as printed
- [ ] The run does not derive the changed set with its own git history search
- [ ] `catalog.md` is in scope although it did not change, because `billing.md` declares it as a dependency
- [ ] The unchanged, undeclared PRDs are not loaded and are not counted as reviewed: the report says `PRDs reviewed: 2 of 4 present`
- [ ] The scope is shown to the user before the full section reads

**Case 8b — no prior review:** the same fixture with no `prd-cross-review-*.md` file. The script prints `PRIOR_REVIEW: NONE (full review required)`.

**Assertions (8b):**
- [ ] The run falls back to `full` mode and says a full review is required because no prior review exists
- [ ] All four system PRDs are loaded and reviewed (`PRDs reviewed: 4 of 4 present`)

---

### Case 9: Focus modes — one pass runs, and the report says which did not

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/` holds the Case 1 set: concept, pillars, systems index and three consistent system PRDs, with no conflicts and nothing a design-theory check would warn on

**Case 9a — `/saas-review-all-prds consistency`**

**Expected behavior:**
1. Phase 1 loads everything as usual; only the Phase 2 (Cross-PRD Consistency) `lead-product-manager` sub-agent is spawned, with checklist 2a–2f
2. No Phase 3 (Product Design Holism) sub-agent is spawned
3. The report's `Focus:` line reads "consistency only — design theory not run", and the session extract's `Phases not run:` line names design theory, rather than reporting it as clean
4. The verdict is for the pass that ran, labelled: `PASS (consistency only — design theory not run)` — not NOT ASSESSED, since the user asked for one pass
5. The closing widget offers neither `/saas-gate-check` nor `/saas-create-architecture`: a one-pass review is not the full review either needs

**Assertions (9a):**
- [ ] Exactly one `Agent` spawn: the Phase 2 consistency sub-agent
- [ ] The design-theory phase is named as not run — never omitted silently, never reported as having found nothing
- [ ] The verdict is `PASS (consistency only — design theory not run)`: labelled, never an unqualified PASS, and not NOT ASSESSED
- [ ] Neither `/saas-gate-check` nor `/saas-create-architecture` is offered
- [ ] The session extract's `Phases not run:` line names design theory

**Case 9b — `/saas-review-all-prds design-theory`**

**Expected behavior:** the mirror of 9a. Only the Phase 3 sub-agent is spawned (checklist 3a–3g), Phase 4 and the report still follow, and the consistency pass is named as not run.

**Assertions (9b):**
- [ ] Exactly one `Agent` spawn: the Phase 3 design-theory sub-agent
- [ ] The `Focus:` line names consistency as not run, the verdict is `PASS (design theory only — consistency not run)`, and the session extract's `Phases not run:` line names consistency
- [ ] Neither `/saas-gate-check` nor `/saas-create-architecture` is offered

---

## Protocol Compliance

- [ ] Reads each phase's `references/N-*.md` file before doing that phase, and again after a compaction or resume during it
- [ ] Phase 2 (Consistency) and Phase 3 (Design Theory) spawned in parallel — not sequentially
- [ ] The full analysis is shown before any write is requested
- [ ] Does NOT write the report or update `features-modules-index.md` without `AskUserQuestion` approval
- [ ] Verdict is one of exactly: PASS, NOT ASSESSED, CONCERNS, FAIL
- [ ] Every issue cites the PRD, section and text involved
- [ ] Ends with an `AskUserQuestion` handoff built from the verdict: FAIL or NOT ASSESSED → neither `/saas-create-architecture` nor `/saas-gate-check`; CONCERNS → `/saas-create-architecture` only; PASS → both

---

## Coverage Notes

- Economic loop analysis (3d, source/sink loops) is not fixture-tested. Case 2
  exercises Phase 2's rule-contradiction check — a different checklist, run by
  the other sub-agent — so it says nothing about 3d.
- The design theory phase (Phase 3) checks, including tier cannibalization detection
  and cognitive overload, are not individually fixture-tested.
- Case 6 covers the fewer-than-two-readable-PRDs trigger, through a
  present-but-empty PRD. The NOT ASSESSED triggers for undefined pillars and for
  a sub-agent that returns no report are not fixture-tested.
- Case 8 covers `since-last-review` with and without a prior review; a prior
  review whose changed PRDs name no dependencies is not tested separately.
  Case 9 covers the `consistency` and `design-theory` focus modes.
