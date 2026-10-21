# Skill Test Spec: /saas-post-launch-monitor

## Skill Summary

`/saas-post-launch-monitor` runs a fix-only mini-sprint for known issues found after the
GA production release: scope → rollback plan → fixes → lightweight QA gate → patch record.
It runs only when the user types it (`disable-model-invocation: true`).

Phase 1 reads `project.stage` (`project.yaml`, fallback `production/stage.txt`)
and requires `Release` or `Polish`; reads the most recent record in
`production/gate-checks/` and **verifies the release gate passed** rather than
inferring it from the stage; and loads bugs from `production/qa/bugs/*.md` with
Status `Open` or `Fixed — Pending Verification`, plus the latest sprint and
security audit. Phase 2 classifies each bug for inclusion (S1/S2, P1, fix under
4 hours, data/config-only and cert requirements go in; architecture changes and
new code paths are deferred to 1.1; S3/S4 only if a trivial config fix) and asks
the user to approve the scope, with `[C] No post-launch monitoring needed` as an exit.

Before any fix, `release-manager` drafts a rollback plan written to
`production/releases/rollback-plan-[version].md`. Code fixes go through
`lead-engineer`, which first returns each fix and the files it would change
while writing nothing; the skill then asks once for the set — "May I apply these
fixes? [BUG-ID → files]" — before any code changes, and `qa-manual-tester` verifies each
fix. Targeted and broader tests run with `commands.test` from `project.yaml`
(unset → `Tests: NOT RUN` per fix, and the broader regression NOT ASSESSED).
Config/data fixes are made directly, after a "May I edit" ask naming the file and
the value change. `qa-lead` decides the QA scope (`/saas-smoke-check`, or the affected
systems' tests in the stack's test root); the patch QA verdict must be PASS or PASS WITH WARNINGS to
proceed — FAIL defers the fix to 1.1 and NOT ASSESSED is never a pass. The patch
record is written to `production/releases/saas-post-launch-monitor-[version].md` after a
"May I write" ask. No director gates are spawned.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Frontmatter sets `disable-model-invocation: true`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PASS, PASS WITH WARNINGS, NOT ASSESSED, FAIL
- [ ] Contains "May I write" language for both the rollback plan and the patch record, and "May I edit" for a direct config/data fix
- [ ] Has a next-step handoff (`/saas-patch-notes`, `/saas-bug-report verify`, `/saas-retrospective [milestone-name]` for the launch milestone)

---

## Director Gate Checks

None of the director-tier agents (product-director, technical-director,
producer, design-system-director) is spawned. The skill spawns working agents —
`release-manager` (rollback plan), `lead-engineer` and `qa-manual-tester` (fixes),
`qa-lead` (patch QA scope) — and checks the existing release-gate record in
`production/gate-checks/`; it does not run `/saas-gate-check` itself.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Scope, rollback plan first, fixes, patch record

**Fixture:**
- `project.yaml` has `project.stage: Release`
- The most recent file in `production/gate-checks/` records a release-gate PASS
- `production/qa/bugs/` holds three Open bugs:
  - `BUG-0010` — S2, P1, code fix estimated at 2 hours
  - `BUG-0011` — S3, a one-value config/data fix
  - `BUG-0012` — S2, fix requires an architecture change

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. Phase 1 confirms Release stage and a passing release gate
2. Phase 2 proposes including BUG-0010 and BUG-0011 and deferring BUG-0012
   ("Fix requires architecture change — defer to 1.1"); `AskUserQuestion` offers
   Approve / Adjust / No post-launch monitoring needed
3. After approval, `release-manager` drafts the rollback plan and the skill asks
   "May I write this rollback plan to `production/releases/rollback-plan-[version].md`?"
   — no fix work starts before it is written
4. `lead-engineer` returns BUG-0010's minimal fix and the files it would change,
   writing nothing; the skill asks "May I apply these fixes? [BUG-0010 → files]",
   and only on yes does `lead-engineer` implement it and run targeted tests with
   `commands.test`; `qa-manual-tester` verifies it. BUG-0011's config
   change is made directly without a programmer agent, after the skill asks
   "May I edit `[config file]` — `[key]`: [old value] → [new value]?"
5. `qa-lead` sets the QA scope; the QA verdict is PASS
6. Skill asks "May I write this patch record to `production/releases/saas-post-launch-monitor-[version].md`?"
7. Record lists BUG-0010 and BUG-0011 under Bugs Fixed and BUG-0012 under Deferred to 1.1 with its reason
8. Next steps offer `/saas-patch-notes`

**Assertions:**
- [ ] BUG-0012 is deferred to 1.1 because it needs an architecture change
- [ ] Scope is approved via `AskUserQuestion` before any work
- [ ] The rollback plan is written before any fix is attempted
- [ ] No code file changes before the one "May I apply these fixes?" ask is approved, and `lead-engineer` writes nothing while proposing
- [ ] BUG-0011 is fixed without spawning `lead-engineer`
- [ ] The config file is not edited before a "May I edit" ask naming the file and the value change is approved
- [ ] "May I write" names `production/releases/saas-post-launch-monitor-[version].md`
- [ ] Next steps include `/saas-patch-notes`

---

### Case 2: Critical Bug That Cannot Be Fixed Safely — Accepted risk, rollback trigger

**Fixture:**
- Release stage; release-gate PASS on record
- `production/qa/bugs/` holds `BUG-0020` — S1 (save-file data loss) whose fix needs
  an architecture change — and `BUG-0021` — S2, P1, 1-hour fix

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. BUG-0020 is S1 but its fix requires an architecture change, so it is proposed
   for deferral to 1.1; BUG-0021 is included
2. The user approves the scope; the patch proceeds for BUG-0021
3. After the patch record is written, the skill warns: "S1 bugs remain open and were
   not patched. These are accepted risks. Document them in the rollback plan trigger
   conditions — if they occur at scale, rollback may be preferable to a follow-up patch."

**Assertions:**
- [ ] BUG-0020 appears in the deferred table with its reason (architecture change)
- [ ] BUG-0021 is still patched — the S1 does not block the rest of the patch
- [ ] The "S1 bugs remain open" warning is shown after the record is written
- [ ] The warning points to the rollback plan's trigger conditions

---

### Case 3: No Release-Gate Record — NOT ASSESSED, not assumed

**Fixture:**
- `project.yaml` has `project.stage: Release`
- `production/gate-checks/` is empty (no release-gate record)
- Open bugs exist in `production/qa/bugs/`

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. Phase 1 finds no release-gate record
2. Reports `Release gate: NOT ASSESSED — no gate-check record found`
3. States that the reduced QA scope depends on a gate nobody can find
4. Asks whether to run `/saas-gate-check` first or proceed with a full QA pass instead
5. Does not proceed silently to scoping or fixes

**Assertions:**
- [ ] `Release gate: NOT ASSESSED — no gate-check record found` is reported
- [ ] `project.stage: Release` alone is not treated as proof the gate passed
- [ ] User is offered `/saas-gate-check` first or a full QA pass
- [ ] No rollback plan, fix or patch record is produced before the user answers

---

### Case 4: Nothing Worth Patching — User selects "No post-launch monitoring needed"

**Fixture:**
- Release stage; release-gate PASS on record
- `production/qa/bugs/` holds only two S4 cosmetic bugs that need code changes

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. Both S4 bugs are proposed for deferral (S3/S4 only if a trivial config fix)
2. Scope question is asked; user selects `[C] No post-launch monitoring needed`
3. Skill outputs "No post-launch monitoring required. Proceed to `/saas-launch-checklist`." and stops
4. No rollback plan, no agents, no patch record

**Assertions:**
- [ ] Both S4 bugs are listed as deferred, not included
- [ ] On `[C]`, "No post-launch monitoring required. Proceed to `/saas-launch-checklist`." is shown
- [ ] Skill stops without writing any file
- [ ] No `release-manager`, `lead-engineer` or `qa-lead` is spawned

---

### Case 5: Director Gate Check — Patch QA NOT ASSESSED is not a pass

**Fixture:**
- `project.yaml`: `modes.rigor: standard` (so a project with no automated tests gets NOT ASSESSED, not WAIVED)
- Release stage; release-gate PASS on record; one included S2/P1 fix implemented
- `qa-lead` chooses a targeted smoke check; `/saas-smoke-check` returns
  `NOT ASSESSED — no automated tests found`

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. The skill does not treat NOT ASSESSED as PASS or PASS WITH WARNINGS
2. It either obtains a real result (following what the verdict says would make it
   runnable) or defers the fix to 1.1
3. No director-tier agent is spawned at any point and `/saas-gate-check` is not run
4. The patch record, if written, shows the QA verdict and fills "Not assessed" with what could not be checked and why

**Assertions:**
- [ ] NOT ASSESSED does not let the patch proceed as if it passed
- [ ] The fix is either re-verified with a real result or deferred to 1.1
- [ ] No product-director, technical-director, producer or design-system-director is spawned
- [ ] Any written record states the QA verdict and what was not assessed

---

### Case 6: Deferred Bugs With No Sprint Plan — Scheduled into the brief's build order

**Fixture:**
- `project.yaml`: `project.stage: Release`; `modes.rigor: minimal` (workflow `minimal`, no sprints)
- The most recent file in `production/gate-checks/` records a release-gate PASS
- No `production/sprints/` folder; `design/product-brief.md` exists with a build order
- `production/qa/bugs/` holds `BUG-0030` — S2, P1, 1-hour fix — and `BUG-0031` — S2, fix requires an architecture change

**Input:** `/saas-post-launch-monitor`

**Expected behavior:**
1. BUG-0030 is included and BUG-0031 is deferred to 1.1; the user approves the scope and the patch runs to the record
2. The patch record lists BUG-0031 in its "Deferred to 1.1" table
3. The skill tells the user to run `/saas-bug-triage` to schedule the deferred bugs and, because the project has no sprint plan, to put them in the brief's build order rather than a 1.1 sprint

**Assertions:**
- [ ] Every deferred bug is in the record's "Deferred to 1.1" table
- [ ] The skill points to `/saas-bug-triage` for scheduling the deferred bugs
- [ ] With no sprint plan, the destination named is the brief's build order, not a 1.1 sprint
- [ ] No sprint file is created or required

---

## Protocol Compliance

- [ ] Confirms Release/Polish stage and verifies the release-gate record before scoping
- [ ] Loads bugs from `production/qa/bugs/*.md`
- [ ] Gets user approval of the scope before any work
- [ ] Writes the rollback plan before any fix
- [ ] Asks once — "May I apply these fixes?" — before `lead-engineer` changes any code
- [ ] Runs tests with `commands.test`, never a runner line from memory; with the key unset, says so (the broader regression is NOT ASSESSED)
- [ ] Requires PASS or PASS WITH WARNINGS to proceed; FAIL defers the fix; NOT ASSESSED is never a pass
- [ ] Asks "May I write" before the rollback plan and before the patch record, and "May I edit" before a direct config/data change

---

## Coverage Notes

- A stage other than Release/Polish ("Post-launch monitoring prep is for Release-stage
  projects") is not separately tested.
- A most-recent gate record of FAIL, CONCERNS or NOT ASSESSED (name it and stop)
  is not separately tested.
- The >1 day scope warning and the `cert-feedback` scope argument are not separately tested.
