# Skill Test Spec: /saas-reverse-document

## Skill Summary

`/saas-reverse-document <type> <path>` works backwards from existing implementation to
a document. `type` is `design` (a PRD, written to `design/prd/[system-name].md`),
`architecture` (an ADR, written to `docs/architecture/[decision-name].md`) or
`concept` (a concept doc from a prototype). It reads the code, runs a
sufficiency check (stopping when there is too little implementation to infer
from), presents its findings with the questions code cannot answer, drafts the
document, and asks "May I write this to [output path]?".

The `design` output scales with the resolved workflow tier: an 8-section PRD at
`full`, a 5-section PRD at `standard`, a one-page brief at `minimal` (the whole-product `design/product-brief.md` when the path
is the code root, `design/[system-name]-brief.md` for one system).
`architecture` and `concept` outputs are tier-independent. Intent the user did
not confirm is carried into the document marked `INTENT UNKNOWN — inferred from
implementation, not confirmed`, and every document carries a
"Reverse-documented from implementation" provenance banner. No director gates
apply. Verdicts: COMPLETE (document written after approval) or BLOCKED (user
declined the write).

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLETE, BLOCKED
- [ ] Contains "May I write" collaborative protocol language before writing the doc
- [ ] Has a next-step handoff (Phase 8 follow-up list, e.g. `/saas-pricing-audit`)

---

## Director Gate Checks

None. `/saas-reverse-document` is a documentation utility. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Well-Structured Source at `full` — 8-section PRD produced

**Fixture:**
- `project.yaml` resolves `workflow: full`; no `system_overrides` row for credits
- `src/workflow/auth_service.ts` exists (~80 lines) with:
  - `export const MAX_LOGIN_ATTEMPTS: number = 5`
  - `deduct_credits(amount: number)` containing
    `credits = Math.max(credits - amount, 0)`
  - `event credits_changed(new_value: number)`
  - Docstrings on all public methods
- The user answers every `UNCLEAR INTENT AREAS` question and approves the write

**Input:** `/saas-reverse-document design src/workflow/auth_service.ts`

**Expected behavior:**
1. Skill reads the source and passes the Phase 3b sufficiency check
2. Skill presents findings (WORKFLOWS IMPLEMENTED, FORMULAS DISCOVERED,
   UNCLEAR INTENT AREAS) and waits for answers before drafting
3. Skill drafts an 8-section PRD (Overview, User Stories & Personas, Detailed Rules,
   Formulas, Edge Cases, Dependencies, Configuration Parameters, Acceptance Criteria)
4. The Formulas section records the validation expression; Configuration Parameters lists
   `max_login_attempts = 5`
5. The provenance banner ("Reverse-documented from implementation … from
   `src/workflow/auth_service.ts`") sits directly under the title
6. Skill asks "May I write this to `design/prd/auth-service.md`?"
7. File written on approval; verdict is COMPLETE

**Assertions:**
- [ ] Findings are presented and answered before any draft is shown
- [ ] All 8 PRD sections are present (tier resolved as `full`)
- [ ] The validation expression appears in Formulas; `max_login_attempts = 5` appears as a Configuration Parameter
- [ ] The provenance banner appears directly under the title
- [ ] "May I write" names the path under `design/prd/`
- [ ] Verdict is COMPLETE

---

### Case 2: Unanswered Intent — INTENT UNKNOWN carried into the draft

**Fixture:**
- `project.yaml` resolves `workflow: full`
- `src/workflow/analytics_aggregator.ts` exists (~120 lines) with:
  - A queued/processing/completed state machine
  - Inline constants with use sites: `if batch_size > 150:`, `rate_limit = 3.5`
  - No arithmetic expression that computes a workflow value from inputs
  - No comments or docstrings
- The user replies "just draft it" without answering the intent questions, then
  approves the write

**Input:** `/saas-reverse-document design src/workflow/analytics_aggregator.ts`

**Expected behavior:**
1. Sufficiency check passes (workflows and tuning values found)
2. Findings list the state machine under WORKFLOWS IMPLEMENTED, the two
   constants as values, and `FORMULAS DISCOVERED: none found in the source`
3. UNCLEAR INTENT AREAS asks what the constants represent (e.g. whether 150 is
   a batch threshold and in what units)
4. Because the questions go unanswered, the draft carries each one verbatim as
   an open question marked `INTENT UNKNOWN — inferred from implementation, not
   confirmed` — it does not present an inferred intent as settled
5. No formula is invented to fill the Formulas section
6. Skill asks "May I write this to `design/prd/analytics-aggregator.md`?"; verdict COMPLETE
   on approval

**Assertions:**
- [ ] `FORMULAS DISCOVERED` reads `none found in the source` (heading kept, not omitted)
- [ ] Each unanswered question appears in the document marked `INTENT UNKNOWN — inferred from implementation, not confirmed`
- [ ] No formula or design intent absent from the code appears in the draft
- [ ] "May I write" is asked before the file is written
- [ ] Verdict is COMPLETE

---

### Case 3: Architecture Type on Interdependent Files — tier-independent ADR

**Fixture:**
- `project.yaml` resolves `workflow: minimal`
- `src/core/core workflow/` holds `payment_gateway.ts` and `transaction_resolver.ts`;
  `payment_gateway.ts` calls `transaction_resolver.ts` through an injected reference
- The user answers the architecture questions and approves the write

**Input:** `/saas-reverse-document architecture src/core/core workflow/`

**Expected behavior:**
1. Skill reads every file under the directory path
2. Phase 2 architecture analysis maps the dependency and coupling between the
   two files (payment_service → ledger_recorder)
3. Phase 3 asks architecture-intent questions (e.g. why the resolver is
   injected) rather than only describing the code
4. Draft uses the `architecture-doc-from-code.md` template — the `minimal` tier
   does NOT turn it into a one-page brief
5. Skill asks "May I write this to `docs/architecture/[decision-name].md`?";
   verdict COMPLETE on approval

**Assertions:**
- [ ] Both files are analyzed, and the payment_service → ledger_recorder dependency is documented
- [ ] Output is an ADR at `docs/architecture/`, not `design/prd/` or a `-brief.md`
- [ ] The `minimal` tier does not change the architecture output
- [ ] Verdict is COMPLETE

---

### Case 4: Thin Source — Sufficiency check stops the run

**Fixture:**
- `src/workflow/subscription_service.ts` exists with only
  `export class SubscriptionService {}` and an empty `constructor()` —
  no workflows, no formulas, no tuning values (under 20 non-boilerplate lines)

**Input:** `/saas-reverse-document design src/workflow/subscription_service.ts`

**Expected behavior:**
1. Skill reads the file; Phase 3b counts 0 workflows, 0 formulas, 0 values
2. Skill stops with: "`src/workflow/subscription_service.ts` does not contain enough
   implementation to reverse-document. Found: 0 workflows, 0 formulas, 0 tuning
   values. …"
3. Skill points to `/saas-design-system [name]` as the skill that captures a design
   that exists only in the user's head
4. No findings are presented, no draft is produced, no file is written

**Assertions:**
- [ ] The stop message names the path and the three counts (all 0)
- [ ] `/saas-design-system` is suggested — not a fabricated skeleton
- [ ] No write tool is called
- [ ] No verdict is issued (the run stops before Phase 4)

---

### Case 5: Director Gate Check — No gate; declined write is BLOCKED

**Fixture:**
- Same source as Case 1; the user declines at the "May I write" prompt

**Input:** `/saas-reverse-document design src/workflow/auth_service.ts`

**Expected behavior:**
1. Skill analyzes, presents findings, and drafts the document
2. No director agents are spawned; no gate IDs appear in output
3. User declines the write; no file is created

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is BLOCKED (user declined write) — no gate verdict involved

---

### Case 6: Default Tier — a single system becomes a one-page brief

**Fixture:**
- `project.yaml` sets no `modes.rigor` and no `modes.workflow`, so the resolved
  tier is `minimal` — the default; no `system_overrides`
- Same source as Case 1 (`src/workflow/auth_service.ts`)
- The user answers every `UNCLEAR INTENT AREAS` question and approves the write

**Input:** `/saas-reverse-document design src/workflow/auth_service.ts`

**Expected behavior:**
1. The tier resolves to `minimal` from the config block, not assumed
2. Findings are presented and answered before any draft
3. The draft is a one-page product brief in the `.claude/docs/templates/product-brief.md`
   format — not a PRD — for this one system
4. The provenance banner sits directly under the title
5. Skill asks "May I write this to `design/auth-service-brief.md`?" — not
   `design/prd/` and not `design/product-brief.md`, which is the whole-product brief
6. File written on approval; verdict COMPLETE

**Assertions:**
- [ ] The output is a brief in the product-brief format, not an 8- or 5-section PRD
- [ ] The path is `design/[system-name]-brief.md`
- [ ] The provenance banner appears under the title
- [ ] Verdict is COMPLETE

---

### Case 7: Minimal Tier, Path Is the Code Root — the whole-product brief

**Fixture:**
- `project.yaml`: `stack.name: Next.js` (code root `src/`); `modes.rigor: minimal` (workflow `minimal`); no `system_overrides`
- `src/` holds a small finished product: `src/workflow/auth_service.ts` (as in Case 1), `src/workflow/analytics_aggregator.ts` (as in Case 2) and `src/server.ts` that starts the product loop — 14 source files in all
- No `design/product-brief.md` exists
- The user answers every `UNCLEAR INTENT AREAS` question and approves the write

**Input:** `/saas-reverse-document design src/`

**Expected behavior:**
1. The tier resolves to `minimal` from the config block; the path is the code root itself, so the target is the whole product, not one system
2. Findings are presented and answered before any draft
3. The draft is a one-page product brief in the `.claude/docs/templates/product-brief.md` format covering the whole product (pitch, core loop, what is built), not a PRD and not a brief for one system
4. The provenance banner sits directly under the title
5. Skill asks "May I write this to `design/product-brief.md`?" — not `design/prd/`, and not a `design/[system-name]-brief.md` path
6. File written on approval; verdict COMPLETE

**Assertions:**
- [ ] The output is a one-page brief in the product-brief format covering the whole product
- [ ] The path is `design/product-brief.md`, not `design/[system-name]-brief.md` and not under `design/prd/`
- [ ] The provenance banner appears under the title, and any intent the user did not confirm is marked `INTENT UNKNOWN — inferred from implementation, not confirmed`
- [ ] "May I write" names `design/product-brief.md` and is asked before the file is written
- [ ] Verdict is COMPLETE

**Case 7b — a path inside the code root:** the same fixture with `/saas-reverse-document design src/workflow/auth_service.ts`.

**Assertions (7b):**
- [ ] The brief is written to `design/auth-service-brief.md` (Case 6), never to `design/product-brief.md`

---

## Protocol Compliance

- [ ] Reads the source before generating any content
- [ ] Stops at the Phase 3b sufficiency check when workflows, formulas and values all count zero
- [ ] Waits for answers to the intent questions; unanswered ones are carried as `INTENT UNKNOWN`
- [ ] `design` output matches the resolved tier (8 sections at `full`, 5 at `standard`, brief at `minimal` — `design/product-brief.md` when the path is the code root, `design/[system-name]-brief.md` for one system)
- [ ] Emits the provenance banner under the title of every document it writes
- [ ] Asks "May I write" before creating any output file
- [ ] Verdict is COMPLETE (written) or BLOCKED (write declined)

---

## Coverage Notes

- The `standard` tier (5-section PRD without User Stories & Personas and Configuration Parameters)
  follows Case 1's flow with a different section set; not separately
  fixture-tested. The `minimal` brief is Case 6 for one system and Case 7 for
  the whole product.
- The `concept` type (prototype → `prototypes/[name]/CONCEPT.md` or
  `design/concepts/[name].md`) is not separately tested.
- `guided` and `autonomous` automation modes change the write prompt per
  `automation-modes.md`; only `collaborative` is tested here.
