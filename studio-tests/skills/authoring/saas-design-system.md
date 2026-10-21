# Skill Test Spec: /saas-design-system

## Skill Summary

`/saas-design-system <system-name>` authors a Product Requirement Document for one system at
`design/prd/[system-name].md`. Which sections are required depends on the
resolved `workflow` tier (a `system_overrides` row wins for that system): all 8
at `full` (Overview, User Stories & Personas, Detailed Design, Formulas, Edge Cases,
Dependencies, Configuration Parameters, Acceptance Criteria); 5 plus conditional Formulas at
`standard`; 5 at a voluntary `minimal`. `## Summary` is authored at every tier,
after the other sections.

Each of the five phases is a `references/N-*.md` file the skill reads before doing
that phase and reads again if the conversation is compacted during it.

The skill reads context first (product concept, systems index, entity registry,
dependency PRD sections, stack reference), presents a context summary and a
Technical Feasibility Brief, then asks "May I create the skeleton file at
`design/prd/[system-name].md`?". Each section then runs the cycle Context →
Questions → Options → Decision → Draft → Approval → Write: in `collaborative`
mode the draft and the "Approve the [Section Name] section?" widget appear in
the same response, and the approved section is written immediately with Edit.
Specialist agents are consulted per section, subject to per-section review-mode
checks.

After all sections are written, the CD-PRD-ALIGN gate runs once in `full` mode
only. `retrofit <path>` fills only the missing or placeholder sections of an
existing PRD. The skill never offers `/saas-design-review` inline — it directs the
user to a fresh session.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: `APPROVED`, `CONCERNS`, `BLOCKED`
- [ ] Contains "May I write" / "May I create" collaborative protocol language (skeleton and per-section approval)
- [ ] Has a next-step handoff at the end
- [ ] Documents skeleton-first approach (file created with headers before content, after approval)
- [ ] Documents CD-PRD-ALIGN gate: runs in full mode only; skipped in lean and solo with a named note
- [ ] Documents retrofit mode for existing PRD files

---

## Director Gate Checks

Review mode comes from the resolved `review_mode` (`modes.review_mode` in
`project.yaml`); `--review full|lean|solo` overrides it for one run.

**CD-PRD-ALIGN** (`product-director`) runs once, in Step 5a-bis, after every
section and the Summary are written and the self-check has read the PRD back
from file. It is passed the PRD path, the product pillars, the SaaS UX
target and the PRD's User Stories & Personas section (or a statement that the tier did not
author one). The verdict is recorded in the PRD Status header as
`> **Product Director Review (CD-PRD-ALIGN)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]`.

- `full` → spawned.
- `lean` → skipped (not a PHASE-GATE). Note: "CD-PRD-ALIGN skipped — Lean mode."
- `solo` → skipped. Note: "CD-PRD-ALIGN skipped — Solo mode."

Per-section specialist spawns (not director gates) have their own checks:
`solo` skips them all; `lean` skips them except for Sections D (Formulas) and
H (Acceptance Criteria), Section G (Configuration Parameters) when Section D defines a
formula whose parameters interact, and Visual/UI when the system's interface feedback
is central to it (a `Core Business Workflow` or `UI` system whose events the user interacts with
in the app); `full` spawns them. Every skipped spawn prints the section's note naming
the agent and the mode, e.g. "`product-director` not consulted — Lean mode.
Review manually before production."

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — New core workflow PRD, full mode, full workflow

**Fixture:**
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist; `core workflow` is listed with `Category: Core Business Workflow`
- No `design/prd/billing.md`
- `project.yaml` has `stack.name: Next.js`, `modes.review_mode: full`, `modes.workflow: full`, `modes.automation: collaborative`; `docs/stack-reference/nextjs/` has `VERSION.md` and `modules/database.md` (core workflow maps to the Database domain)
- CD-PRD-ALIGN returns APPROVE

**Input:** `/saas-design-system core workflow`

**Expected behavior:**
1. Phase 2 reads the concept, systems index, entity registry (if present) and dependency PRD sections before asking anything, then presents the "Designing: Core Workflow" context summary and the Technical Feasibility Brief with its `AskUserQuestion`
2. "Ready to start designing core workflow?" is asked
3. "May I create the skeleton file at `design/prd/billing.md`?" — on yes, the skeleton is written with all 8 required sections plus the template's other sections, each holding `[To be designed]`; `production/session-state/active.md` is updated
4. Sections A–H are walked in order; each draft is followed in the same response by "Approve the [Section Name] section?" with `[A] Approve — write it to file` / `[B] Make changes — describe what to fix` / `[C] Start over`
5. Section B consults `product-director`; Section C spawns the Core Workflow row's `lead-product-manager` plus supporting agents in parallel; Section D spawns `database-architect`; Section E `database-architect`; Section H `qa-lead`
6. Each approved section is written immediately by an Edit whose `old_string` includes the section heading; `active.md` is updated after each
7. Visual/Audio and UI Polish & Micro-interactions are treated as required (Core Business Workflow category) — not offered as skippable
8. `## Summary` is authored after the other sections; Step 5a reads the PRD back from file
9. PD-PRD-ALIGN spawns once and returns ALIGNED; the Status header records `ALIGNED [date]`
10. The completion summary directs the user to run `/saas-design-review design/prd/billing.md` in a fresh session

**Assertions:**
- [ ] The skeleton is written only after the "May I create the skeleton file" approval, and contains all 8 required section headers
- [ ] Every section draft is followed in the same response by the "Approve the [Section Name] section?" widget
- [ ] Each section is written individually, immediately after its approval, by an Edit anchored on its heading
- [ ] Section C's specialists come from the routing table's Core Workflow row and are spawned in parallel before drafting
- [ ] PD-PRD-ALIGN spawns once, after all sections and the Summary are written — not per section
- [ ] The verdict is recorded as `> **Product Director Review (PD-PRD-ALIGN)**: ALIGNED [date]`
- [ ] `/saas-design-review` is directed to a fresh session and never offered inline

---

### Case 2: Retrofit Mode — Fill only the incomplete sections at standard tier

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `modes.workflow: standard`, `modes.review_mode: lean`
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist; `catalog` is listed with `Category: Billing` (stack domain Scripting)
- `docs/stack-reference/nextjs/` has `VERSION.md` and `modules/`, but no `modules/scripting.md`
- `design/prd/catalog.md` exists with Overview, Detailed Design and Formulas fully written; its `## Summary` holds only `[To be designed]`
- `## Edge Cases` and `## Acceptance Criteria` contain only `[To be designed]`; `## Dependencies` has an empty body
- The file has no User Stories & Personas or Configuration Parameters section

**Input:** `/saas-design-system retrofit design/prd/catalog.md`

**Expected behavior:**
1. The skill reads the existing PRD and identifies which sections are present, placeholder-only or empty
2. It presents the "Retrofit: Catalog" block: written sections (will not be touched) and missing or incomplete sections (will be authored)
3. User Stories & Personas and Configuration Parameters are listed as available to add, not as gaps, because `standard` does not require them
4. It asks: "Shall I fill the 3 missing sections? I will not modify any existing content."
5. On yes, Phase 2 runs as normal; §2e names the missing module — "no stack reference for `Scripting` under `docs/stack-reference/nextjs/modules/`; feasibility not checked against the pinned stack" — and carries it into §5-pre
6. No skeleton is created; only Edge Cases, Dependencies and Acceptance Criteria run the section cycle, then §5-pre replaces the Summary placeholder
7. Each write replaces only the placeholder or empty body; Overview, Detailed Design and Formulas are not modified

**Assertions:**
- [ ] The retrofit block is shown before any change is made
- [ ] Sections the tier does not require are not reported as gaps
- [ ] The skill asks "Shall I fill the 3 missing sections? I will not modify any existing content."
- [ ] The absent `scripting.md` module is named in the output, not skipped silently as if feasibility had been checked
- [ ] No skeleton is created and complete sections are not re-authored or overwritten
- [ ] Each filled section still goes through the per-section approval before its write

---

### Case 3: Director Gate — CD-PRD-ALIGN returns CONCERNS, REJECT or NOT ASSESSED

**Fixture:**
- `design/prd/product-concept.md` (pillars include "Frictionless Workflow") and `design/prd/features-modules-index.md` exist; `rate_limiting` is listed with `Category: Core Business Workflow`
- `project.yaml` has `modes.review_mode: full` and `modes.workflow: full`
- All eight sections, User Stories & Personas included, and the Summary are written for `design/prd/rate-limiting.md`
- Scenario (a): CD-PRD-ALIGN returns CONCERNS: "Detailed Design's aggressive throttle undercuts the 'Frictionless Workflow' pillar"
- Scenario (b): CD-PRD-ALIGN returns REJECT: "hard rate-limiting lockouts break the user flow, which the 'Frictionless Workflow' pillar rules out"
- Scenario (c): CD-PRD-ALIGN returns NOT ASSESSED — no UX target was available to check the PRD against

**Input:** `/saas-design-system rate_limiting` (reaching Step 5a-bis)

**Expected behavior:**
1. `product-director` is spawned with gate CD-PRD-ALIGN and passed the PRD path, the product pillars, the SaaS UX target and the PRD's User Stories & Personas section
2. (a) The CONCERNS are surfaced via `AskUserQuestion` with the standard options: `Revise flagged items` / `Accept and proceed` / `Discuss further`
3. (a) If "Revise flagged items": Detailed Design runs its section cycle again — its specialists consulted first — and is approved through "Approve the Detailed Design section?" before it is written; the Status header records `REVISED [date]`
4. (a) If "Accept and proceed": the Status header records `CONCERNS (accepted) [date]`
5. (b) The blockers are shown; the flagged section is re-drafted and re-approved the same way before anything else is written, and the Status header records `REVISED [date]`, never `APPROVED`
6. (c) The missing input is named; the user can supply it and re-run the gate, or the Status header records `NOT ASSESSED [date] — [missing input]`, never `APPROVED`
7. Only after the verdict is recorded does the skill continue to the entity registry step (5b)

**Assertions:**
- [ ] CD-PRD-ALIGN receives the completed PRD path, the pillars, the UX target and the User Stories & Personas section
- [ ] (a) CONCERNS are shown to the user with the three standard options, not auto-accepted
- [ ] A revised section re-runs its section cycle and is re-approved before it is written
- [ ] The Status header records `REVISED [date]` or `CONCERNS (accepted) [date]` to match the user's choice
- [ ] (b) After a REJECT, no later step (5b registry, 5d systems index) runs until the flagged section has been revised
- [ ] (c) NOT ASSESSED is never recorded or reported as an approval

---

### Case 4: Lean and Solo Modes — Gate skipped once; specialist spawns follow their own checks

**Fixture:**
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist; the system is `stamina` (`Category: Core Business Workflow`); no `design/prd/stamina.md`
- `project.yaml` has `stack.name: Next.js` and `modes.workflow: full`
- Section D's stamina formula has no knobs that interact; the stamina bar is feedback the user reads to play
- Scenario (a): `modes.review_mode: lean`
- Scenario (b): `modes.review_mode: solo`

**Input:** `/saas-design-system stamina`

**Expected behavior:**
1. (a) Sections B, C, E and G are drafted without specialist spawns, and each prints its note with the mode, e.g. "`product-director` not consulted — Lean mode. Review manually before production."
2. (a) Section D still spawns `database-architect`, Section H `qa-lead`, and Visual/Audio `design-system-director` — stamina's feedback is central to play
3. (a) At Step 5a-bis: "CD-PRD-ALIGN skipped — Lean mode." — printed once, not per section
4. (b) No specialist or director agent is spawned; each section whose spawn was skipped carries its note, e.g. "`product-director` not consulted — Solo mode. Review manually before production."
5. (b) At Step 5a-bis: "CD-PRD-ALIGN skipped — Solo mode."
6. In both scenarios every section still requires the "Approve the [Section Name] section?" approval before it is written

**Assertions:**
- [ ] (a) In lean mode Sections B, C, E and G are drafted without their specialists, while Sections D and H and Visual/Audio still spawn theirs
- [ ] (a) Each lean-skipped spawn prints a "not consulted — Lean mode" note naming its agent — none is skipped silently
- [ ] (a) The CD-PRD-ALIGN skip note appears once, at Step 5a-bis
- [ ] (b) In solo mode no agent is spawned, and each skipped specialist leaves a "not consulted — Solo mode" note
- [ ] (b) The skip note reads "CD-PRD-ALIGN skipped — Solo mode."
- [ ] Per-section user approval is required in both modes

---

### Case 5: Missing Input and Declined Skeleton

**Fixture:**
- `project.yaml` has `modes.workflow: standard` in every scenario — the systems index is required at this tier, so pointing at `/saas-map-features` is correct
- Scenario (a): no argument; `design/prd/features-modules-index.md` lists `stamina` as the highest-priority "Not Started" system (MVP, Core layer)
- Scenario (b): no argument; no systems index
- Scenario (c): `/saas-design-system stamina` with concept and index present; the user declines the skeleton

**Input:** (a) `/saas-design-system` (b) `/saas-design-system` (c) `/saas-design-system stamina`

**Expected behavior:**
1. (a) `AskUserQuestion`: "The next system in your design order is **stamina** (MVP | Core). Start designing it?" with `[A] Yes — design stamina` / `[B] Pick a different system` / `[C] Stop here`
2. (b) The skill stops with the usage message ("Usage: `/saas-design-system <system-name>` …"), the retrofit example, and "No systems index found. Run `/saas-map-features` first to map your systems and get the design order."
3. (c) The skill stops with: "Verdict: **BLOCKED** — skeleton creation declined. …" and does not proceed to Section A
4. In none of the three scenarios is a PRD file written before an approval

**Assertions:**
- [ ] (a) The next system is proposed from the systems index with the three options
- [ ] (b) The usage message and the `/saas-map-features` pointer are printed; nothing is written
- [ ] (c) Declining the skeleton produces the BLOCKED verdict and stops before Section A
- [ ] No PRD file is created without an approval

---

### Case 6: Minimal Project, One System Raised by `system_overrides`

**Fixture:**
- `project.yaml` has `modes.workflow: minimal`, `modes.review_mode: solo` and `workflow_overrides.system_overrides.core workflow: standard`
- `design/product-brief.md` exists; its MVP features describe core workflow (a discount tier rule and a rate-limit threshold), and its build order lists core workflow first
- No `design/prd/product-concept.md`, no `design/prd/features-modules-index.md`, no `design/prd/billing.md`

**Input:** `/saas-design-system core workflow`

**Expected behavior:**
1. The effective tier for core workflow is `standard` (the override); the project tier is `minimal`
2. §2a takes the `minimal` branch because it keys on the project tier: it reads `design/product-brief.md` and skips the systems-index read, and does not stop with "No product concept found" or "No systems index found"
3. It derives `Category`, `Layer` and `Priority` from the brief once (e.g. `Core Business Workflow`, `Foundation` or `Feature`, `MVP`)
4. The skeleton and the section walk follow `standard`: A, C, D (core workflow defines numeric rules), E, F, H — no User Stories & Personas or Configuration Parameters
5. §5-pre's Quick reference marks the derived values, e.g. "Category: Core Business Workflow (inferred from the brief — no systems index at this tier)"
6. §5d says "no `design/prd/features-modules-index.md` at this workflow tier; nothing to update" and writes no systems index

**Assertions:**
- [ ] The run reads the brief and does not stop for the missing concept or systems index
- [ ] The required section set is `standard`'s (the effective tier) — not the project tier's
- [ ] Category, Layer and Priority are derived from the brief and marked inferred in the Quick reference
- [ ] No systems index is created; §5d reports nothing to update

---

### Case 7: Phase Files Are Read Before Each Phase, and Again After a Compaction

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `modes.workflow: standard`, `modes.review_mode: solo`
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist; `rate_limiting` is listed with `Category: Core Business Workflow`; no `design/prd/rate-limiting.md`
- The skill folder holds `references/1-parse-arguments.md` through `references/5-post-design.md`
- Mid-run, while Section D (Formulas) is being drafted, the conversation is compacted; the user then replies to the open question and the run continues

**Input:** `/saas-design-system rate_limiting`

**Expected behavior:**
1. SKILL.md carries no phase steps itself; before starting each phase the run reads that phase's file: `references/1-parse-arguments.md`, then `2-gather-context.md`, then `3-file-skeleton.md`, then `4-section-design.md`, then `5-post-design.md`
2. No phase's steps are carried out before its file has been read — e.g. no context read or question before `1-parse-arguments.md`, no skeleton ask before `3-file-skeleton.md`, no section cycle before `4-section-design.md`
3. After the compaction the run reads `references/4-section-design.md` again before resuming Section D, as the skill says: "Read it again if the conversation was compacted or resumed during this phase."
4. The run does not re-read the phase files of other phases because of the compaction, and it does not continue Section D from memory of the earlier read
5. The run then reads `references/5-post-design.md` before the Summary and self-check

**Assertions:**
- [ ] The transcript shows a file read of each of the five `references/N-*.md` files, in order, each before that phase's work begins
- [ ] No phase work (context reads, skeleton ask, section drafts, Summary) happens before its phase file is read
- [ ] After the compaction, `references/4-section-design.md` is read again before Section D resumes
- [ ] Settings resolved in SKILL.md (`workflow`, `review_mode`, `automation`, `docs.density`) still apply in the phase files; the run does not ask for them again

---

### Case 8: Populated Registry and Numbered-Heading Dependency PRDs — Block-form greps find the facts

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `modes.workflow: standard`, `modes.review_mode: solo`
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist; `rate_limiting` is listed with `Category: Core Business Workflow` and `Depends on: core workflow`
- `design/registry/entities.yaml` has a live `constants:` list with two entries:
  - `- name: retry_backoff_base` with `value: 40` and `source: design/prd/billing.md` (owned by core workflow)
  - `- name: rate_limit_burst` with `value: 25`, `source: design/prd/rate-limiting.md`, and a block-form `referenced_by:` list (the key on one line, `- design/prd/billing.md` on the next)
- The same file's header comments hold an example entry for `max_seats_limit: 9999` referencing `design/prd/catalog.md`
- `design/prd/billing.md` exists with numbered headings: `## 1. Overview`, `## 3. Detailed Design`, `## 4. Formulas`, `## 5. Edge Cases`, `## 6. Dependencies`, `## 7. Configuration Parameters`; its Formulas section uses `retry_backoff_base` and its Configuration Parameters section lists it
- No `design/prd/rate-limiting.md`

**Input:** `/saas-design-system rate_limiting`

**Expected behavior:**
1. Registry lookups use two greps: one for `source: design/prd/rate-limiting.md` with trailing context (`-A 6`) and one for `design/prd/rate-limiting.md` with leading context (`-B 8`); the `-B 8` match reaches the owning entry above the `referenced_by` path, so `rate_limit_burst` is found as owned by rate limiting and `retry_backoff_base` as a fact rate limiting must respect
2. A single-line `referenced_by.*rate-limiting` pattern is not relied on, because the list is block-form
3. For the dependency PRD `billing.md`, the run greps `^## ([0-9]+\. )?(Dependencies|Formulas|Edge Cases|Configuration Parameters)` so the numbered headings `## 4. Formulas`, `## 5. Edge Cases`, `## 6. Dependencies` and `## 7. Configuration Parameters` all match; the whole PRD is not read
4. The context summary's "Known cross-system facts (from registry)" lists `rate_limit_burst=25` and `retry_backoff_base=40` with their owning PRDs, marked locked
5. The commented `max_seats_limit: 9999` example is not listed as a known fact

**Assertions:**
- [ ] The registry is searched for `source: design/prd/rate-limiting.md` and for the path with `-B 8` context, not only with a one-line `referenced_by` pattern
- [ ] `rate_limit_burst` (found through its `source:` and its block-form `referenced_by:`) and `retry_backoff_base` appear under Known cross-system facts with their values and owners
- [ ] The dependency PRD's sections are found despite their `N.` heading numbers — all four of Dependencies, Formulas, Edge Cases and Configuration Parameters are read
- [ ] `billing.md` is read by section, not whole
- [ ] The commented `max_seats_limit` example is not presented as a locked value

---

## Protocol Compliance

- [ ] Reads context before asking anything; stops with the `/saas-brainstorm` or `/saas-map-features` message when the product concept or systems index is missing on a `standard`/`full` project (a `minimal` project reads the brief instead, even for a system `system_overrides` raises)
- [ ] The skeleton is created only after "May I create the skeleton file at `design/prd/[system-name].md`?"
- [ ] In collaborative mode every section draft is followed by its approval widget, and no section is written without approval
- [ ] Sections are written incrementally, and `production/session-state/active.md` is updated after each
- [ ] Specialist spawns follow the per-section review-mode checks; every skipped spawn leaves a "not consulted" note naming the agent and the mode, in lean as in solo
- [ ] CD-PRD-ALIGN runs once in full mode after all sections; lean and solo print a skip note naming the gate and mode
- [ ] `/saas-design-review` is directed to a fresh session and never run or offered inline
- [ ] Reads each phase's `references/N-*.md` file before doing that phase, and again after a compaction or resume during it
- [ ] Ends with a next-step `AskUserQuestion` and Recommended Next Steps (`/saas-consistency-check`, `/saas-map-features next`, `/saas-design-review` in a fresh session)

---

## Coverage Notes

- `guided` and `autonomous` automation modes (write without the per-section
  widget; `log_decision` in autonomous) are not fixture-tested.
- A voluntary PRD on a `minimal` project with no override (the 5 standard
  sections from `design/product-brief.md`, Formulas never pulled back in) is not
  fixture-tested; Case 6 covers a `minimal` project whose system an override
  raises. The no-argument prompt on a `minimal` project, where no systems index
  exists by design, is not tested either.
- The registry conflict check after Sections C and D, and the Step 5b entity
  registry update, are not individually tested.
- The Step 5d systems index update and the context-window (≥70%) notice are not
  tested.
- Recovery and resume after an interrupted session is not tested.
