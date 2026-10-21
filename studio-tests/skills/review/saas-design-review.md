# Skill Test Spec: /saas-design-review

## Skill Summary

`/saas-design-review` reviews one product design document (PRD) against the project's
design standard (Overview, User Stories & Personas, Detailed Rules, Formulas, Edge
Cases, Dependencies, Configuration Parameters, Acceptance Criteria). Which sections are
REQUIRED depends on the workflow tier resolved for that system: all 8 at
`full`; 5 at `standard` (plus Formulas when the system defines numeric rules).
It gathers section presence with `.claude/scripts/prd-structure-check.sh`,
validates the declared dependency graph, checks internal consistency,
implementability and cross-system fit, and produces a verdict of APPROVED,
NEEDS REVISION, MAJOR REVISION NEEDED, or NOT ASSESSED.

The review mode sets its depth: `full` adds a parallel adversarial specialist
review plus a `product-director` senior synthesis (Phase 3b); `lean` runs all
phases without agents; `solo` runs Phases 1–4 only with no next-step prompt.
Phase 4 writes nothing. In Phase 5 it can update `design/prd/features-modules-index.md`
and append to `design/prd/reviews/[doc-name]-review-log.md`, each only after the
user approves via `AskUserQuestion`.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings or numbered steps
- [ ] Contains verdict keywords: APPROVED, NEEDS REVISION, MAJOR REVISION NEEDED, NOT ASSESSED
- [ ] `allowed-tools` includes Write/Edit, so "May I" write-approval language is present (systems-index update, review-log append)
- [ ] Output format is documented (review template shown in skill body)

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Complete PRD, all 8 sections present

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/light-manipulation.md` exists with all 8 sections populated with
  substantive content (the Detailed Rules section is titled `## Detailed Design`)
- Formulas section defines at least one formula with named variables
- Acceptance Criteria section contains at least 3 testable criteria
- Every system named in its Dependencies section has a PRD in `design/prd/`
- No prior review log exists for this document

**Input:** `/saas-design-review design/prd/light-manipulation.md --review lean`

**Expected behavior:**
1. Freshness check (`review-receipts.sh check …`) finds no receipt → full review
2. Skill reads the target document in full and reads CLAUDE.md
3. Skill runs `bash .claude/scripts/prd-structure-check.sh design/prd/light-manipulation.md`
4. Skill Globs `design/prd/` for each declared dependency
5. Skill checks internal consistency, implementability and cross-system fit
6. No agents are spawned (lean)
7. Skill outputs the Phase 4 review, ending with the verdict
8. On APPROVED, one multi-select `AskUserQuestion` offers the two tracking
   updates; only the selected ones are written; then a final closing widget

**Assertions:**
- [ ] Skill reads the target file before producing any output
- [ ] Section presence comes from `prd-structure-check.sh`, and `## Detailed Design` is accepted as the Detailed Rules section (not flagged missing)
- [ ] Output includes "Completeness: 8/8" (N is 8 because the tier is `full`)
- [ ] Output includes a "Dependency Graph" section listing each declared dependency with whether its PRD exists
- [ ] Output includes "Required Before Implementation", "Recommended Revisions" and "Scope Signal" sections, and "Re-review: No — first review"
- [ ] Output ends with `### Verdict:` APPROVED when all REQUIRED sections are present and no blocking issue is found
- [ ] No file is written before the tracking-records widget, and only the options the user selects are written
- [ ] If the review-log option is selected, the appended entry has a `Review mode:` line and the `review-receipts.sh hash` output for the document, the skill file and the related PRDs it read

---

### Case 2: Failure Path — Incomplete PRD (4/8 sections at `full`)

**Fixture:**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/auth-service.md` has Overview, User Stories & Personas, Detailed
  Rules and Dependencies only; Formulas, Edge Cases, Configuration Parameters and
  Acceptance Criteria are absent

**Input:** `/saas-design-review design/prd/auth-service.md --review lean`

**Expected behavior:**
1. `prd-structure-check.sh` reports the 4 sections in its `ABSENT:` list
2. All 4 are REQUIRED at `full`, so each blocks approval
3. Skill outputs "Completeness: 4/8" and names each missing section
4. Verdict is a revision verdict, never APPROVED
5. Phase 5 offers `[A] Revise the PRD now` / `[B] Stop here`; "Accept as-is" is
   offered only when all items are advisory, which they are not here

**Assertions:**
- [ ] Output shows "4/8" in the completeness section (not a higher number)
- [ ] Output explicitly names each missing section (Formulas, Edge Cases, Configuration Parameters, Acceptance Criteria) as REQUIRED
- [ ] Verdict is NEEDS REVISION or MAJOR REVISION NEEDED — never APPROVED while a REQUIRED section is missing, and not NOT ASSESSED (the document was read)
- [ ] Output does not suggest the document is implementation-ready
- [ ] "Accept as-is and move on" is not offered, because the missing sections are blocking
- [ ] No file is written except after an explicit Phase 5 choice: `[A] Revise the PRD now`, "May I update `design/prd/features-modules-index.md`…", or "May I append this review summary…"
- [ ] The systems-index prompt offers `Needs Revision` or `In Review` — never `Approved` on this revision verdict — and the review-log entry records the revision verdict, not an approval

---

### Case 3: Partial Path — `standard` tier, numeric rules with no Formulas section

**Fixture:**
- `project.yaml` sets `modes.workflow: standard`
- PRD has Overview, User Stories & Personas, `## Detailed Design`, Edge Cases,
  Dependencies, Configuration Parameters and Acceptance Criteria; no Formulas section
- Detailed Design states numeric rules ("consume 2 tokens per API call", "overage costs $0.05 per thousand requests") but no formula defines them
- Acceptance Criteria are vague ("fast response" rather than measurable p95 < 200ms)

**Input:** `/saas-design-review design/prd/token-metering.md --review lean`

**Expected behavior:**
1. Skill marks Formulas REQUIRED at `standard` because the system defines
   numeric rules (the system's `Category` alone never clears it)
2. N = 6 (5 standard sections + Formulas); Completeness shows 5/6, not a /8 count
3. Skill flags the vague acceptance criteria as an implementability issue
4. Verdict is a revision verdict

**Assertions:**
- [ ] Output identifies the missing Formulas section as REQUIRED (not advisory) because numeric rules are present
- [ ] Completeness is reported against the `standard` count ("5/6"), not "7/8"
- [ ] Output flags the vague acceptance criteria as an implementability gap, quoting each one — the main review does this itself, since no `qa-lead` runs in `lean`
- [ ] Verdict is NEEDS REVISION or MAJOR REVISION NEEDED, never APPROVED

---

### Case 4: Edge Case — File not found

**Fixture:**
- The path provided does not exist in the project

**Input:** `/saas-design-review design/prd/nonexistent.md --review lean`

(`lean`, so Phase 5 runs. In `solo` — what the review mode resolves to when
`project.yaml` sets neither `modes.review_mode` nor `modes.rigor` — Phase 5 never
runs and the last assertion below would test nothing.)

**Expected behavior:**
1. Freshness check reports no receipt; skill attempts to read the file
2. File not found
3. Skill outputs `### Verdict: NOT ASSESSED`, naming the missing document and
   the skill that produces it (`/saas-design-system`)
4. Skill does NOT produce a quality verdict or any tracking write
5. Phase 5 skips the tracking widgets and goes to the final closing widget,
   leading with `/saas-design-system`

**Assertions:**
- [ ] Verdict is NOT ASSESSED — not APPROVED, NEEDS REVISION or MAJOR REVISION NEEDED
- [ ] Output names the missing file and which skill produces it
- [ ] Phase 5 runs, and offers neither a `features-modules-index.md` status update nor a review-log entry — in particular it never offers to mark the system Approved

---

### Case 5: Review mode — specialist delegation in `full`, none in `lean` / `solo`

**Fixture (all sub-cases):**
- `project.yaml` sets `modes.workflow: full`
- `design/prd/light-manipulation.md` exists with all 8 sections, including
  formulas and core workflow stats

**Case 5a — full:** `/saas-design-review design/prd/light-manipulation.md --review full`

**Expected behavior:**
1. Before spawning, skill prints "Full review: spawning specialist agents in parallel…"
2. Skill spawns the relevant specialists in parallel as real `Agent` calls —
   `lead-product-manager` (any workflow system) and `database-architect` (formulas) at minimum here
3. After the specialists return, skill spawns `product-director` as senior
   reviewer; its synthesis becomes the final verdict
4. Findings are source-tagged; disagreements are listed, not silently resolved

**Assertions (5a):**
- [ ] The notice is printed before any agent is spawned
- [ ] Specialists are spawned in parallel via `Agent` (not simulated in-session)
- [ ] `product-director` is spawned only after the specialists respond, and output has a "Senior Verdict [product-director]" section
- [ ] "Specialists consulted:" lists the agents actually spawned, and every finding carries a source tag such as `[lead-product-manager]`
- [ ] Specialist disagreements appear under "Specialist Disagreements"
- [ ] The `### Verdict:` line carries exactly one of this skill's words — APPROVED, NEEDS REVISION or MAJOR REVISION NEEDED — taken from the product-director's synthesis; never a director-gate word such as READY, CONCERNS, NOT READY, APPROVE or REJECT
- [ ] No director-gate IDs appear ("Gate: CD-…" etc.) — the senior review is a direct spawn, not a gate from `director-gates.md`

**Case 5b — lean via the legacy flag:** `/saas-design-review design/prd/light-manipulation.md --depth lean`

**Assertions (5b):**
- [ ] `--depth lean` is treated as `--review lean`, and the skill says once that the flag was renamed
- [ ] No `Agent` call is made; the review runs in-session
- [ ] Phase 5's next-step widgets still run

**Case 5c — solo:** `/saas-design-review design/prd/light-manipulation.md --review solo`

**Assertions (5c):**
- [ ] No `Agent` call is made
- [ ] Only Phases 1–4 run: no Phase 5 next-step prompt, so no systems-index or review-log write is offered

---

### Case 6: Review mode from the resolved config — no flag

**Fixture:**
- `project.yaml` sets `modes.workflow: full` and `modes.review_mode: lean`
- `design/prd/light-manipulation.md` exists with all 8 sections

**Input:** `/saas-design-review design/prd/light-manipulation.md`

**Expected behavior:**
1. No `--review` flag, so the skill takes `review_mode: lean` from the resolved
   config block at the top of the skill
2. The review runs in-session with no `Agent` call
3. Phase 5's widgets run — which `solo`, the `rigor: minimal` default, would have skipped

**Assertions:**
- [ ] The review mode comes from the resolved config block when no flag is given (`review_mode: lean (project.yaml)`)
- [ ] No `Agent` call is made, and Phase 5's next-step widgets run — so the run is `lean`, not the `solo` default
- [ ] Variant — the same fixture with `--review solo` on the input: the flag wins over the config, and no Phase 5 widget runs

---

## Protocol Compliance

- [ ] Writes nothing during the review itself (Phase 4)
- [ ] Every write (systems-index status, review-log append) happens only after an `AskUserQuestion` approval
- [ ] Presents complete findings before the verdict line
- [ ] Outside `solo`, closes with an `AskUserQuestion` next-step widget rather than plain text (collaborative/guided modes)

---

## Coverage Notes

- Cross-system consistency across many PRDs is covered by the `/saas-review-all-prds`
  spec; this spec checks only one document's dependency references.
- The freshness receipt paths (byte-identical re-review offering the prior
  verdict; a shallower logged review when a deeper one is asked for;
  cross-document change only) are not fixture-tested here.
- The entity-registry grep path (registry lists this system) is not tested; the
  fixtures above use the fallback of reading the PRDs named in Dependencies.
- The `minimal` tier (no PRD expected; standard sections checked advisorily) is
  not tested.
- Performance and edge cases involving very large PRD files are not in scope.
