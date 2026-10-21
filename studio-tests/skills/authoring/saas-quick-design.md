# Skill Test Spec: /saas-quick-design

## Skill Summary

`/saas-quick-design [brief description of the change]` produces a lightweight Quick
Design Spec for a change too small for a full PRD. It first classifies the
change as **Tuning**, **Tweak**, **Addition** or **New Small System** and
confirms the classification with an `AskUserQuestion` whose option `[F]`
redirects to `/saas-design-system`. A change that introduces a system with
significant cross-system dependencies, needs more than about a week of work, or
alters a system's core rules is redirected to `/saas-design-system` instead (verdict
`REDIRECTED`).

It then scans context (the relevant PRD in `design/prd/`, the systems index if
present, prior specs in `design/quick-specs/` — each named, whether it agrees or
conflicts — and `assets/data/` for Tuning),
drafts the spec in the format for its category, presents it in full with
Approve / Revise / redirect options, and on approval asks "May I write this
Quick Design Spec to `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`?".
Any PRD edit the spec requires is asked for separately, showing old vs. new
text. It ends with a handoff block and verdict `COMPLETE`.

The skill has no director gates and does not resolve `review_mode`; quick specs
bypass `/saas-design-review` and `/saas-review-all-prds` by design.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: `COMPLETE`, `REDIRECTED`
- [ ] Contains "May I write" collaborative protocol language (for the quick spec file, and separately for any PRD update)
- [ ] Has a next-step handoff at the end
- [ ] States that quick specs bypass `/saas-design-review` and `/saas-review-all-prds` by design, and lists when to redirect to the full pipeline
- [ ] Documents the scope check that redirects oversized changes to `/saas-design-system`

---

## Director Gate Checks

None. The skill resolves only `automation` and `workflow` (not `review_mode`),
has no `Agent` tool in `allowed-tools`, and spawns no director or specialist
agent. The review mode setting has no effect on it.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Tweak to an existing system

**Fixture:**
- `design/prd/movement.md` exists and describes dash invincibility in its Detailed Rules
- `design/prd/features-modules-index.md` exists
- `design/quick-specs/api-rate-limit-tuning-[earlier-date].md` tuned the api rate limit in billing and does not touch token quotas

**Input:** `/saas-quick-design make dash invincible on frame 1`

**Expected behavior:**
1. The skill classifies the change as Tweak and asks "I've classified this as **Tweak** — [reason]. Is that correct?" with options `[A]`–`[F]`
2. The context scan reads the relevant section of `design/prd/billing.md`, the systems index and `design/quick-specs/`, and reports "Found PRD at `design/prd/billing.md`. Relevant section: [section]. Prior quick specs for this system: `design/quick-specs/api-rate-limit-tuning-[earlier-date].md` — agrees."
3. It drafts the Tweak/Addition format: Change Summary, Motivation, Design Delta (quoting the current PRD rule), New Rules / Values, Affected Systems, Acceptance Criteria, PRD Update Required?
4. It presents the full draft, then asks with `[A] Approve — write it as shown` / `[B] Revise — I'll describe what to change` / `[C] This grew too large — redirect to /saas-design-system instead`
5. On `[A]`: "May I write this Quick Design Spec to `design/quick-specs/dash-invincibility-tweak-[YYYY-MM-DD].md`?" — on yes, creates `design/quick-specs/` if needed and writes the file
6. Because the spec changes a rule in `movement.md`, it then asks separately "May I update `design/prd/movement.md` — specifically the [section] section?", showing old vs. new text first
7. It prints the handoff block (path, type, system, PRD update status) and "Verdict: **COMPLETE**"

**Assertions:**
- [ ] The classification is confirmed via `AskUserQuestion` before any context scan or drafting
- [ ] The prior rate-limit spec is named in the context report even though it does not conflict
- [ ] The draft uses the Tweak/Addition format, and its Design Delta quotes the current PRD text
- [ ] The full draft is shown before the write approval is asked
- [ ] The file path is `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md` with today's date
- [ ] The PRD edit is asked for separately, after the quick spec is written, with old vs. new text shown
- [ ] The run ends with the handoff block and verdict `COMPLETE`

---

### Case 2: Failure Path — Scope too large; redirected to /saas-design-system

**Fixture:**
- Scenario (a): the request is "redesign the entire billing system"
- Scenario (b): a Tweak is drafted, and at the approval step the user picks `[C] This grew too large — redirect to /saas-design-system instead`

**Input:** (a) `/saas-quick-design redesign the entire billing system` (b) `/saas-quick-design allow combo to cancel into roll`

**Expected behavior:**
1. (a) The change alters a system's core rules, so the skill stops before drafting and redirects to `/saas-design-system` — directly, or via option `[F]` of the classification prompt
2. (b) The skill stops at the approval step
3. In both scenarios: "Verdict: **REDIRECTED** — use `/saas-design-system` for this change."
4. No file is written under `design/quick-specs/`

**Assertions:**
- [ ] (a) The scope excess is detected and the skill stops before drafting
- [ ] (a) The verdict line is printed even when the skill stops before the classification widget, not only via `[F]`
- [ ] The message names `/saas-design-system` as the alternative
- [ ] No quick spec file is written
- [ ] The verdict is `REDIRECTED`, not `COMPLETE`

---

### Case 3: Edge Case — Configuration parameter change outside the documented range

**Fixture:**
- `design/prd/tenant-limits.md` has a Configuration Parameters entry `max_export_concurrency` with documented range 3–5
- `config/limits.json` holds `max_export_concurrency: 5`
- An earlier quick spec, `design/quick-specs/export-concurrency-tuning-[earlier-date].md`, previously set `max_export_concurrency` to 5

**Input:** `/saas-quick-design increase export concurrency from 5 to 6 units`

**Expected behavior:**
1. The skill classifies the change as Configuration Parameter Tuning and confirms it
2. The context scan also checks `config/` for the data file holding the value, and names the prior quick spec that touched this parameter, marked as conflicting — it set the value this change replaces
3. The draft uses the Tuning format: a single Change table (Parameter, Old Value, New Value, Rationale), a Configuration Parameter Mapping, and Acceptance Criteria
4. The Configuration Parameter Mapping states the new value is outside the documented range and explains why the range should be extended
5. The acceptance criteria reference reading the value from `config/[file]`

**Assertions:**
- [ ] `config/` is checked for the data file because the change is Tuning
- [ ] The prior quick spec touching `max_export_concurrency` is reported, not silently contradicted
- [ ] The draft uses the single-table Tuning format, not the Tweak/Addition sections
- [ ] The Configuration Parameter Mapping says the value is outside the documented range and explains the extension

---

### Case 4: Edge Case — No argument and no systems index

**Fixture:**
- No `design/prd/features-modules-index.md`
- `design/quick-specs/` may or may not exist

**Input:** `/saas-quick-design` (no argument)

**Expected behavior:**
1. The skill asks the user to describe the change with a plain-text prompt
2. It does not show the classification widget, pick a change, or write anything until the user has described the change
3. After the description, it classifies and confirms as usual
4. The context scan notes "No systems index found — skipping dependency tier check." and continues

**Assertions:**
- [ ] With no argument, the skill asks for a description in plain text rather than guessing a change
- [ ] Classification happens only after the user describes the change
- [ ] The missing systems index is noted with the documented line, and the run continues
- [ ] No file is written before the approval step

---

### Case 5: No Director Gates — Review mode has no effect

**Fixture:**
- The change is within scope (an Addition: "add coupon discount validation to checkout")
- `design/prd/billing.md` exists (a PRD written voluntarily at this tier) and describes the checkout flow
- `project.yaml` has `modes.review_mode: full` and `modes.workflow: minimal`

**Input:** `/saas-quick-design add coupon discount validation to checkout`

**Expected behavior:**
1. The skill runs its normal flow; `review_mode` is not among the keys it resolves, and nothing branches on it
2. No agent of any kind is spawned (the skill has no `Agent` tool)
3. The spec is drafted, approved and written after "May I write"
4. The Pipeline Notes state that quick specs bypass `/saas-design-review` and `/saas-review-all-prds` by design, and list when to redirect to `/saas-design-system`
5. At `workflow: minimal`, the handoff says to go straight to `/saas-dev-story` rather than `/saas-story-readiness`

**Assertions:**
- [ ] No director gate or other agent is spawned
- [ ] `modes.review_mode: full` does not change the skill's behavior
- [ ] The output explains that quick specs bypass `/saas-design-review` and `/saas-review-all-prds`, and names `/saas-design-system` for larger changes
- [ ] The handoff points to `/saas-dev-story` directly at `workflow: minimal`

---

### Case 6: Edge Case — No PRD for the system (the default tier)

**Fixture:**
- `project.yaml` has `modes.rigor: minimal`; `design/prd/` holds no system PRD
- `design/product-brief.md` describes the jump; `production/epics/movement/story-002-jump.md` implements it with a jump height of 5

**Input:** `/saas-quick-design increase jump height from 5 to 6 units`

**Expected behavior:**
1. Classified as Tuning and confirmed
2. The context scan finds no PRD and reports "No PRD for movement — using the brief and `production/epics/movement/story-002-jump.md`"
3. The spec is drafted with `design/product-brief.md` as its PRD Reference, shown, and written after "May I write"
4. No PRD update is proposed (there is no PRD to update); the handoff goes to `/saas-dev-story`

**Assertions:**
- [ ] The skill does not stop, and does not redirect to `/saas-design-system`, because there is no PRD
- [ ] The report names the brief and the story it used in place of a PRD
- [ ] The spec's PRD Reference is `design/product-brief.md`
- [ ] Nothing is written before the "May I write" approval

---

## Protocol Compliance

- [ ] The change is classified and confirmed before drafting; oversized changes redirect to `/saas-design-system`
- [ ] The spec format matches the confirmed category (Tuning table; Tweak/Addition sections; New Small System trimmed PRD)
- [ ] The full draft is shown before the "May I write" ask
- [ ] "May I write this Quick Design Spec to `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`?" is asked before writing
- [ ] PRD edits are asked for separately, with old vs. new text, and never made without approval
- [ ] No director gates; review mode is not read
- [ ] Ends with the handoff block and next steps (`/saas-story-readiness`, or `/saas-dev-story` at `minimal`)

---

## Coverage Notes

- The New Small System format (Overview, Core Rules, Configuration Parameters, Acceptance
  Criteria, Systems Index) is not fixture-tested.
- The `[B] Revise` loop at the approval step is not individually tested.
- `guided` and `autonomous` automation modes are not tested.
- The scope threshold is a judgment call; the skill's category definitions and
  redirect list are the authoritative definition and are not tested by
  counting hours.
