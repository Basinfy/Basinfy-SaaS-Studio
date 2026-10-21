# Skill Test Spec: /saas-consistency-check

## Skill Summary

`/saas-consistency-check [full | since-last-review | entity:<name> | item:<name>]`
compares every in-scope PRD in `design/prd/` against the entity registry
(`design/registry/entities.yaml`). It reads the registry once, builds entity,
item, formula and constant lookups, then greps each PRD for each registered name
(`-C 3`) instead of reading whole documents; only conflicts get a targeted
section read. The registry entry's `source:` PRD is the authoritative owner.
In a PRD whose effective tier is `standard` — the project tier, or that
system's `system_overrides` row — only the required PRD sections are compared
(plus Configuration Parameters when `workflow_overrides.configuration_parameters` is true), and the
report says so. Findings are classified 🔴 CONFLICT, ⚠️ STALE REGISTRY or ℹ️ UNVERIFIABLE, and the
report verdict is PASS or CONFLICTS FOUND — or NOT ASSESSED when the registry is
empty, a named entity is not in it, or no PRD is in scope, since a scan of
nothing is not a PASS. Registry corrections are written only
after a "May I update / May I add" ask; afterwards the verdict is COMPLETE, or
BLOCKED while conflicts remain. Every 🔴 CONFLICT is appended to
`docs/consistency-failures.md` after a "May I append" ask, a breadcrumb is appended to
`production/session-state/active.md`, and the skill closes with an
`AskUserQuestion` widget (collaborative and guided modes). No director gates.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PASS, CONFLICTS FOUND, NOT ASSESSED, COMPLETE, BLOCKED
- [ ] The analysis phases (1–5) are read-only
- [ ] Has a next-step handoff at the end
- [ ] Registry writes are preceded by "May I update" / "May I add" language naming `design/registry/entities.yaml`
- [ ] The conflict log write is preceded by "May I append" language naming `docs/consistency-failures.md`

---

## Director Gate Checks

No director gates — this skill spawns no director gate agents. Consistency
checking is a mechanical scan; no creative or technical director review is
required as part of the scan itself.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Registry and 4 PRDs agree

**Fixture:**
- `modes.workflow` resolves to `full`; `modes.automation` resolves to `collaborative`
- `design/registry/entities.yaml` has 3 entities and 2 constants, each with a `source:` PRD
- `design/prd/` contains 4 system PRDs plus `product-concept.md`, `features-modules-index.md` and a `prd-cross-review-[date].md`
- Every value the PRDs state for a registered name matches the registry

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. Skill reads the registry and reports `Registry loaded: 3 entities, 0 items, 0 formulas, 2 constants` and `Scope: full`
2. Skill globs `design/prd/*.md`, excludes `product-concept.md`, `features-modules-index.md` and the cross-review report, and reports the 4 in-scope PRDs before scanning
3. Each registered name is grepped across the in-scope PRDs with 3 lines of context; no PRD is read in full
4. No conflicts or stale entries; the report's Clean Entries line reads `✅ 5 registry entries verified across all PRDs with no conflicts.`
5. Verdict: PASS
6. Nothing is appended to `docs/consistency-failures.md`; the breadcrumb is appended to `production/session-state/active.md`
7. Closes with the `AskUserQuestion` widget (Fix / Run `/saas-design-review` / Stop)

**Assertions:**
- [ ] The in-scope PRD list (4 PRDs, non-system docs excluded) is reported before the scan
- [ ] The scan greps for registered names rather than fully reading each PRD
- [ ] Verdict is PASS when registry and PRDs agree
- [ ] `design/registry/entities.yaml` and `docs/consistency-failures.md` are not written; the only write is the `active.md` breadcrumb
- [ ] The breadcrumb names `docs/consistency-failures.md`, not an invented report file
- [ ] The skill closes with the `AskUserQuestion` widget, not plain text

---

### Case 2: Failure Path — A PRD contradicts a registered constant

**Fixture:**
- `modes.workflow` resolves to `full`
- Registry `constants:` has `monthly_seat_price` value 1.5, `source: design/prd/billing.md`, `referenced_by: [billing.md, subscription.md]`
- `design/prd/billing.md` states `monthly_seat_price = 1.5`
- `design/prd/subscription.md` states `monthly_seat_price = 2.0`
- The registry entry is newer than the last commit to `billing.md` (not stale)

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. The constant scan (3d) greps `monthly_seat_price` and finds 2.0 in `subscription.md`
2. Phase 4 does a targeted read of the conflicting section and uses the registry `source:` to decide `billing.md` is authoritative
3. Report lists `🔴 monthly_seat_price`: Registry (source: billing.md) = 1.5; Conflict in subscription.md = 2.0; Resolution: change `subscription.md` to 1.5
4. Verdict: CONFLICTS FOUND
5. Skill asks "May I append 1 entries to `docs/consistency-failures.md` (creating it if absent)?"; on approval an entry for the conflict is appended (the file is created with its header first if absent), naming `billing.md` vs `subscription.md`
6. No PRD is edited automatically; with the conflict unresolved the final verdict is BLOCKED

**Assertions:**
- [ ] Verdict is CONFLICTS FOUND (not PASS)
- [ ] The conflict entry names both PRDs and shows both values (1.5 and 2.0)
- [ ] The conflict is classified 🔴 CONFLICT, and the resolution targets the non-source PRD (`subscription.md`)
- [ ] A reflexion-log entry is appended to `docs/consistency-failures.md`, only after the "May I append" ask naming it is approved
- [ ] Skill does NOT auto-resolve the conflict — neither PRD is edited without the user choosing to fix it
- [ ] Final verdict is BLOCKED while the conflict is unresolved

---

### Case 3: Stale Registry — The source PRD changed after the registry entry

**Fixture:**
- `modes.workflow` resolves to `full`
- Registry `entities:` has `goblin` with `health: 40`, `source: design/prd/billing.md`
- `design/prd/billing.md` now says goblin health is 50; `git log` shows it changed after the registry entry was written
- No other PRD states a goblin health value

**Input:** `/saas-consistency-check entity:goblin`

**Expected behavior:**
1. Scope is limited to the `goblin` entity across all PRDs; the report shows `Scope: entity:goblin`
2. The mismatch is found in the source PRD itself; Phase 4 checks git history and classifies it ⚠️ STALE REGISTRY, not 🔴 CONFLICT
3. Report lists it under Stale Registry Entries: registry says 40, source PRD now says 50
4. Skill asks: "May I update `design/registry/entities.yaml` to fix the 1 stale entries?"
5. On approval: `health` becomes 50, `revised:` is set to today, and a `# was: 40 before [date]` comment is added; nothing is deleted
6. After writing, verdict is COMPLETE
7. No entry is appended to `docs/consistency-failures.md` (only 🔴 CONFLICT entries are logged)

**Assertions:**
- [ ] The finding is classified ⚠️ STALE REGISTRY, distinct from 🔴 CONFLICT
- [ ] The registry is not written until the "May I update `design/registry/entities.yaml`" ask is approved
- [ ] The approved update sets `revised:` and keeps the old value in a `# was:` comment
- [ ] Verdict after the write is COMPLETE
- [ ] `docs/consistency-failures.md` is not written for a stale-registry finding

---

### Case 4: Edge Case — Empty registry, no PRDs

**Fixture:**
- `modes.workflow` resolves to `full`
- `design/registry/entities.yaml` is the shipped stub with no entries
- `design/prd/` is empty

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. Skill reads the registry and finds no entries
2. Skill outputs: "Entity registry is empty. Run `/saas-design-system` to write PRDs — the registry is populated automatically after each PRD is completed. Nothing to check yet."
3. Verdict: **NOT ASSESSED — entity registry empty**; the skill stops without scanning
4. No file is written — not the registry, not the reflexion log, not the session-state breadcrumb

**Assertions:**
- [ ] Skill outputs the empty-registry message naming `/saas-design-system`
- [ ] Verdict is NOT ASSESSED, naming the empty registry as the reason — never PASS, CONFLICTS FOUND, COMPLETE or BLOCKED, and never no verdict at all (`.claude/rules/skill-authoring.md` obligation 1)
- [ ] No file is written, including `production/session-state/active.md`
- [ ] Skill does NOT crash or produce a partial report

---

### Case 4b: Edge Case — Registry populated, but no PRD in scope

**Fixture:**
- `modes.workflow` resolves to `full`
- `design/registry/entities.yaml` has 3 entities, each with a `source:` PRD
- `design/prd/prd-cross-review-[date].md` exists, and no system PRD has changed since it

**Input:** `/saas-consistency-check since-last-review`

**Expected behavior:**
1. Skill reads the registry and reports what it loaded
2. The `since-last-review` filter finds zero changed PRDs; the in-scope list is empty
3. Verdict: **NOT ASSESSED — no PRDs in scope**, naming `since-last-review` as the
   filter that produced zero; the skill stops without scanning

**Assertions:**
- [ ] Verdict is NOT ASSESSED, never PASS — nothing was compared
- [ ] The output names the filter that produced the empty scope
- [ ] No PRD is scanned and no conflict log entry is written

---

### Case 4c: Edge Case — Named entity is not in the registry

**Fixture:**
- `modes.workflow` resolves to `full`
- `design/registry/entities.yaml` has entities `user_account` and `workspace_admin`
- `design/prd/` contains 3 system PRDs; one mentions a `workspace_member`

**Input:** `/saas-consistency-check entity:workspace_member`

**Expected behavior:**
1. Skill reads the registry and reports what it loaded, `Scope: entity:workspace_member`
2. `workspace_member` has no registry entry
3. Verdict: **NOT ASSESSED — `workspace_member` is not in the registry**, listing the
   closest registered names (`workspace_admin`); the skill stops without scanning

**Assertions:**
- [ ] Verdict is NOT ASSESSED naming the unregistered entity — never PASS
- [ ] The closest registered names are listed
- [ ] No PRD is scanned and nothing is written

---

### Case 5: Director Gate — No gate spawned in full review mode

**Fixture:**
- `project.yaml`: `modes.review_mode: full`, `modes.workflow: full`
- `design/registry/entities.yaml` has entries
- `design/prd/` contains ≥2 PRDs

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. Skill loads the registry and runs the consistency scan
2. The review mode plays no part: the skill's config block resolves only `automation`, `workflow` and `system_overrides`
3. No director gate agents are spawned at any point
4. Report and verdict are produced normally

**Assertions:**
- [ ] No director gate agents are spawned (no CD-, TD-, PR-, AD- prefixed gates)
- [ ] The skill does not resolve or read the review mode — its config block asks only for `automation`, `workflow` and `system_overrides`
- [ ] Output contains no "Gate: [GATE-ID]" or gate-skipped entries
- [ ] Review mode `full` has no effect on this skill's behavior

---

### Case 6: Standard Workflow — Only the required PRD sections are compared

**Fixture:**
- `modes.workflow` resolves to `standard`
- Registry `constants:` has `monthly_seat_price` value 1.5, `source: design/prd/billing.md`
- `design/prd/billing.md` `## Detailed Design` states `monthly_seat_price = 1.5`
- `design/prd/subscription.md` states `monthly_seat_price = 2.0` only in its `## Configuration Parameters` section, which `standard` does not require; no required section of `subscription.md` states a value for it

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. Only hits inside the sections `standard` requires are compared
2. The `subscription.md` value in `## Configuration Parameters` is not compared: no 🔴 CONFLICT is raised for it and nothing is appended to `docs/consistency-failures.md`
3. The report's Scope line says the check covered the required sections only, and lists the `subscription.md` Configuration Parameters mention as not checked at this tier
4. Verdict: PASS — the required sections agree with the registry

**Assertions:**
- [ ] The Configuration Parameters value is not reported as a 🔴 CONFLICT at `standard`
- [ ] The report states the required-sections-only scope and names the mention it did not check — the narrower scan is not silent
- [ ] Verdict is PASS

---

### Case 6b: Standard Workflow — A per-system override makes one PRD `full`

**Fixture:**
- `modes.workflow` resolves to `standard`; `project.yaml` has
  `workflow_overrides.system_overrides.subscription: full`
- Registry `constants:` has `monthly_seat_price` value 1.5, `source: design/prd/billing.md`
- `design/prd/billing.md` `## Detailed Design` states `monthly_seat_price = 1.5`
- `design/prd/subscription.md` states `monthly_seat_price = 2.0` only in its `## Configuration Parameters` section

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. The config block lists `system_overrides: subscription=full`, so `subscription.md`'s effective tier is `full` and every one of its sections is compared; `billing.md` stays at `standard`
2. The `subscription.md` Configuration Parameters value is compared and raised as `🔴 monthly_seat_price` (registry 1.5, `subscription.md` 2.0)
3. The report's Scope line names `subscription.md` as checked at `full`
4. Verdict: CONFLICTS FOUND

**Assertions:**
- [ ] The Configuration Parameters value in `subscription.md` is compared, because its effective tier is `full` — the project tier alone would have skipped it (Case 6)
- [ ] The report names the PRD whose effective tier differs from the project's
- [ ] Verdict is CONFLICTS FOUND, not PASS

---

### Case 7: Registry Changed Since Phase 1 — re-read, then anchor each Edit on the current text

**Fixture:**
- `modes.workflow` resolves to `full`
- Registry at the start of the run: `entities:` has `user_account` (`rate_limit: 40`,
  `source: design/prd/billing.md`) and `team_account`; `items:` has `plan_tier_basic`
- `design/prd/billing.md` says user_account rate_limit is 50 (changed after the registry
  entry was written: stale); `plan_tier_pro` appears with a stated quota in both
  `billing.md` and `subscription.md` and is not in the registry
- Between the Phase 1 read and the writes, another session edits
  `design/registry/entities.yaml`: it adds an `enterprise_account` entity after `team_account`, adds
  a `plan_tier_enterprise` item after `plan_tier_basic`, and changes the `referenced_by`
  list on `user_account`
- The user approves both asks: the stale-entry update and the new-entry add

**Input:** `/saas-consistency-check`

**Expected behavior:**
1. The scan reports one ⚠️ STALE REGISTRY entry (`user_account`) and one unregistered
   cross-PRD item (`plan_tier_pro`)
2. Before the update Edit, the skill reads the current
   `design/registry/entities.yaml`, finds the `user_account` entry in it, and anchors
   the Edit on the entry's current text (the changed `referenced_by` included),
   not on what Phase 1 saw
3. Before the add Edit, it reads the file again and appends `plan_tier_pro` after
   the last existing entry of the `items:` section, which is now `plan_tier_enterprise`
4. The other session's changes survive: `enterprise_account`, `plan_tier_enterprise` and the new
   `referenced_by` are all still in the file

**Assertions:**
- [ ] A Read of `design/registry/entities.yaml` happens before each registry Edit, not only in Phase 1
- [ ] The Edit that updates `user_account` is anchored on the entry as it reads at that moment, and it succeeds without overwriting the other session's `referenced_by` change
- [ ] `plan_tier_pro` is appended after `plan_tier_enterprise`, the last existing `items:` entry, not after `plan_tier_basic`
- [ ] `enterprise_account`, `plan_tier_enterprise` and the changed `referenced_by` are present after the run: the registry is never rewritten whole from the Phase 1 copy
- [ ] Each registry write still waits for its own "May I update" / "May I add" approval

---

## Protocol Compliance

- [ ] Reads the registry before each registry edit (it re-reads it per edit, so Case 3 reads it twice, and Case 7 shows a concurrent change surviving), then greps PRDs; full-section reads happen only for conflicts
- [ ] The report is shown in full before any registry write ask
- [ ] Report verdict is PASS, CONFLICTS FOUND or NOT ASSESSED (empty registry, unregistered name, or no PRD in scope — never PASS over nothing compared); post-correction verdict is COMPLETE or BLOCKED
- [ ] Applies each PRD's effective tier (the resolved `modes.workflow`, or that system's `system_overrides` row): at `standard`, compares the required PRD sections only (plus Configuration Parameters when `workflow_overrides.configuration_parameters` is true) and says so in the report
- [ ] No director gates — the review mode is not an input
- [ ] Registry writes are gated by "May I update" / "May I add"; entries are never deleted (`status: deprecated` instead)
- [ ] Every 🔴 CONFLICT is appended to `docs/consistency-failures.md` after a "May I append" ask that names it
- [ ] Closes with `AskUserQuestion` in collaborative and guided modes; in autonomous mode prints findings and records via `log_decision`

---

## Coverage Notes

- This skill checks registered facts across PRDs. Deep design theory analysis
  (pillar drift, pricing cannibalization) is handled by `/saas-review-all-prds`.
- Facts that are not in the registry are not compared; two PRDs that disagree on
  an unregistered value are not detected. Phase 6 offers to register names that
  appear in more than one PRD.
- `since-last-review` is tested only on its empty-scope path (Case 4b), not on a
  run that finds changed PRDs.
- `modes.workflow: minimal` is not tested separately: a minimal project normally
  has no PRDs, and an empty scope ends NOT ASSESSED as in Cases 4 and 4b.
