# Skill Test Spec: /saas-perf-profile

## Skill Summary

`/saas-perf-profile` is a static-analysis performance profiler. It takes a system
name or `full` as its scope, records every input it needs as `FOUND` or
`ABSENT` before producing anything, resolves `performance.enforce` from the
config block injected at its top (Phase 0; the block also carries
`automation` and `workflow`), and reads the committed budgets
with `get_effective_yaml_key` for `performance.target_framerate`,
`performance.frame_budget_ms`, `performance.draw_call_limit` and
`performance.memory_ceiling_mb` before falling back to design docs or
`CLAUDE.md` (Phase 2). It analyses source code for CPU, memory, rendering and
I/O hotspot candidates (Phase 3) — it does not ingest runtime profiler exports.
The report rates each budgeted row `OK` / `WARNING` / `OVER`; a metric with no
committed budget is `NOT ASSESSED`, and the summary gives headroom only against a
budget that is set (`no budget set — headroom not assessed` otherwise). The skill asks "May I write this profiling
report to `production/polish/[scope]-report-[date].md`?" before writing (Phase
4), offers implement / cut scope / defer / escalate choices for M- or L-effort
hotspots (Phase 5), and hands off to `/saas-architecture-decision`, `/saas-scope-check`
or `/saas-sprint-plan update` (Phase 6). No director gates are invoked. Verdicts:
COMPLETE, or NOT ASSESSED — NO DATA when every required input is absent. At
`workflow: minimal`, which has no sprints, an accepted optimization goes to the
brief's build order and Phase 6 does not point to `/saas-sprint-plan update`.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLETE, NOT ASSESSED — NO DATA, and the per-metric statuses OK / WARNING / OVER
- [ ] Contains "May I write" language naming `production/polish/[scope]-report-[date].md`
- [ ] Has a next-step handoff (Phase 6: `/saas-architecture-decision`, `/saas-scope-check`, `/saas-sprint-plan update`)

---

## Director Gate Checks

None. Performance profiling is an advisory analysis skill; no gates are invoked
in any review mode.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Budgets committed, core workflow hotspots found

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `performance.target_lcp_ms: 2500`,
  `performance.max_initial_bundle_kb: 200`, `performance.api_p95_latency_ms: 250`;
  `performance.enforce` unset (resolves to `warn`); `modes.automation` unset (collaborative)
- No config key, design doc or `CLAUDE.md` section states an API p99 latency target
- `src/modules/core_workflow/tenant_worker.ts` has a query worker that loops over every
  record and, inside that loop, issues an un-indexed N+1 SQL query to fetch tenant members on
  every page render
- Reworking the query worker into a batch query is a multi-day change

**Input:** `/saas-perf-profile core workflow`

**Expected behavior:**
1. Skill records its inputs: source code FOUND, committed budgets FOUND
2. Phase 0: `performance.enforce` resolves to `warn` — violations are findings, not blockers
3. Phase 2: the `performance.*` keys are read with `get_effective_yaml_key` before any fallback
4. Phase 3: the core workflow query worker functions are listed; the nested loop and un-indexed queries are identified
5. Phase 4: the report's Performance Budgets table uses 2.5s (LCP), 200 KB (initial bundle) and 250 ms (API p95 latency) as budgets, each of those three rows with an OK / WARNING / OVER status; the API p99 latency row has no committed budget and is `NOT ASSESSED`; hotspots and recommendations cite `tenant_worker.ts` with a line number
6. Summary gives the top 3 hotspots, estimated headroom against the three set budgets, `no budget set — headroom not assessed` for API p99 latency, and a recommended next action
7. Skill asks "May I write this profiling report to `production/polish/core workflow-report-[date].md`?"
8. The nested-loop hotspot is rated Fix Effort M or L, so Phase 5 offers: implement, reduce scope via `/saas-scope-check`, defer to Polish, or escalate via `/saas-architecture-decision`
9. Verdict: COMPLETE

**Assertions:**
- [ ] Budgets come from the `performance.*` keys read with `get_effective_yaml_key`, not from design docs or hardcoded fallbacks
- [ ] The nested loop and un-indexed SQL queries are reported as hotspots with a `file:line` location
- [ ] Each optimization recommendation states location, expected gain, risk and approach
- [ ] The LCP, bundle size and API p95 latency rows carry an OK / WARNING / OVER status; the API p99 latency row is `NOT ASSESSED`, not OK
- [ ] No headroom is claimed for API p99 latency; the summary says `no budget set — headroom not assessed`
- [ ] "May I write" names `production/polish/core workflow-report-[date].md` and precedes any write
- [ ] The M/L-effort hotspot triggers the Phase 5 choice (implement / `/saas-scope-check` / defer to Polish / `/saas-architecture-decision`)
- [ ] Verdict is COMPLETE

---

### Case 2: No Committed Budget — Budget rows are NOT ASSESSED

**Fixture:**
- `project.yaml` has `stack.name: nextjs` and no `performance` block
- No design doc and no `CLAUDE.md` section states an LCP, bundle size or API latency target
- `src/` contains service handlers with query workers

**Input:** `/saas-perf-profile full`

**Expected behavior:**
1. `get_effective_yaml_key` returns nothing for the four budget keys; the design-doc and `CLAUDE.md` fallback finds no target either
2. Source code is FOUND, so Phase 3 analysis still runs and hotspots are reported
3. Every row of the Performance Budgets table is `NOT ASSESSED` — none is measured against the template's `[16.67ms]` placeholder
4. The summary does not claim headroom against a budget nobody set: it says `no budget set — headroom not assessed`
5. Skill asks "May I write this profiling report to `production/polish/full-report-[date].md`?"; the `NOT ASSESSED` rows stay in the file offered for writing

**Assertions:**
- [ ] No budget row shows OK, WARNING or OVER; each is `NOT ASSESSED`
- [ ] The `[16.67ms]` placeholder is never used as a budget, and no headroom figure is claimed
- [ ] Hotspot analysis still runs and is reported
- [ ] The `NOT ASSESSED` rows are kept in the report offered for writing, not edited out

---

### Case 3: Nothing to Profile — Whole verdict NOT ASSESSED — NO DATA

**Fixture:**
- Fresh project: `project.yaml` has `stack.name: nextjs` and no `performance` block, and the code root `src/` is absent
- No design docs exist
- No profiler output exists anywhere

**Input:** `/saas-perf-profile full`

**Expected behavior:**
1. Skill lists its inputs and records each: source code ABSENT, budgets ABSENT, profiler output ABSENT
2. Every required input is ABSENT, so the skill stops before Phase 3
3. Skill reports `NOT ASSESSED — NO DATA` as the whole verdict, naming what was missing and which skill produces it
4. No report template is filled in and nothing is offered for writing

**Assertions:**
- [ ] Each input is recorded as FOUND or ABSENT, not assumed present
- [ ] The whole verdict is `NOT ASSESSED — NO DATA`, not COMPLETE
- [ ] Output names each missing input and which skill produces it
- [ ] No filled-in report, no headroom figure, and no "May I write" prompt

---

### Case 4: Local Enforcement Override `block` — Violations are blockers

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `performance.enforce: warn`, `performance.max_initial_bundle_kb: 200`, the other budgets set
- `project.local.yaml`: `performance.enforce: block`, so the resolved block at the top of the skill shows `block`
- `src/modules/dashboard/dashboard_renderer.ts` imports an un-treeshaken heavy reporting library, exceeding bundle budget
- `modes.automation` unset (collaborative)

**Input:** `/saas-perf-profile dashboard`

**Expected behavior:**
1. Phase 0 uses `block` from the resolved config block at the top of the skill, not the `warn` a fresh read of `project.yaml` would give
2. The initial bundle size estimate for the dashboard scope exceeds 200 KB; the Bundle size row is OVER
3. The report states explicitly that the violation is a blocker — release-stopping — and that `/saas-gate-check` will FAIL the Polish gate on it
4. A recommendation (e.g., dynamic imports / code-splitting) is given with its expected gain
5. Skill asks "May I write" before writing `production/polish/dashboard-report-[date].md`

**Assertions:**
- [ ] The local `block` applies, not the committed `warn` — `performance.enforce` comes from the resolved block
- [ ] The Bundle size row is OVER against the 200 KB budget
- [ ] The report states the violation is a blocker and that `/saas-gate-check` will FAIL the Polish gate on it
- [ ] "May I write" precedes any write

---

### Case 5: Enforcement Level `off` in Full Review Mode — Informational only, no gates

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `modes.review_mode: full`, `modes.workflow: standard` (pinned: unset resolves to `minimal`, which has no sprints, so Phase 6 would name the brief's build order instead of `/saas-sprint-plan update`), `performance.enforce: off`, all budgets set
- `src/` contains an API route handler whose estimated latency exceeds `performance.api_p95_latency_ms`

**Input:** `/saas-perf-profile full`

**Expected behavior:**
1. No director gate is invoked, whatever the review mode
2. The estimated API p95 latency is still reported in the Performance Budgets table
3. Because budgets are informational under `off`, the over-budget latency is not raised as a violation finding or as a recommendation to fix
4. Skill asks "May I write" before writing the report
5. Output ends with the Phase 6 next steps: `/saas-architecture-decision`, `/saas-scope-check [feature]`, `/saas-sprint-plan update`

**Assertions:**
- [ ] No director gate is invoked in any review mode
- [ ] The estimated API p95 latency still appears in the budget table
- [ ] The over-budget metric is not raised as a violation finding or a fix recommendation
- [ ] "May I write" precedes any write
- [ ] Next steps name `/saas-architecture-decision`, `/saas-scope-check` and `/saas-sprint-plan update`

---

### Case 6: `workflow` — where an accepted optimization goes

**Fixture:**
- As Case 1: budgets committed, `tenant_worker.ts` has the nested loop and
  per-frame raycast, and the nested-loop hotspot is rated Fix Effort M or L
- `modes.rigor: minimal`, so `modes.workflow` resolves to `minimal` (no sprints)
- The user picks A for the nested-loop hotspot
- Variant: `modes.workflow: standard` (pinned: it is the tier that has sprints)

**Input:** `/saas-perf-profile core workflow`

**Expected behavior:**
1. Phase 5 runs because a hotspot is M or L, and option A reads "Implement the
   optimization" with, at `minimal`, the note that there are no sprints and the
   work is added to the brief's build order
2. After the user picks A at `minimal`, the optimization is directed to the
   brief's build order, not to a sprint
3. Phase 6's scheduling line says to add the optimizations to the brief's build
   order instead of running `/saas-sprint-plan update`; `/saas-sprint-plan` is not named
   as the way to schedule
4. Variant at `standard`: option A offers to proceed with the fix now or
   schedule it, and Phase 6 names `/saas-sprint-plan update`
5. Verdict: COMPLETE in both runs

**Assertions:**
- [ ] At `minimal`, option A and Phase 6 both point to the brief's build order
- [ ] At `minimal`, `/saas-sprint-plan update` is not recommended
- [ ] Variant at `standard`: Phase 6 names `/saas-sprint-plan update` and option A does not mention the build order
- [ ] The other Phase 5 options (`/saas-scope-check`, defer to Polish, `/saas-architecture-decision`) and the Phase 6 lines for `/saas-architecture-decision` and `/saas-scope-check [feature]` are the same in both runs
- [ ] Verdict is COMPLETE

---

### Case 7: Session Started in a Subfolder — budgets are still read from the project root

**Fixture:**
- `project.yaml` at the project root: `stack.name: nextjs`,
  `performance.target_lcp_ms: 2500`, `performance.max_initial_bundle_kb: 200`,
  `performance.api_p95_latency_ms: 250`
- The session's working directory is `src/modules/` (a subfolder), not the root
- `src/modules/core_workflow/tenant_worker.ts` has a query worker with a nested loop

**Input:** `/saas-perf-profile core workflow`

**Expected behavior:**
1. Phase 2 runs the `get_effective_yaml_key` reads as commands that
   first change to the project root and load `.claude/hooks/yaml-helper.sh`
   from there
2. All keys return their committed values; none comes back empty because
   the helper or `project.yaml` was not found from the subfolder
3. The Performance Budgets table uses 2500 ms, 200 KB and 250 ms; those
   rows are not `NOT ASSESSED`

**Assertions:**
- [ ] The budget read runs with the helper from the project root, not from the current subfolder
- [ ] The values are the committed ones, not empty
- [ ] No budget row is `NOT ASSESSED` because of the working directory: a budget set in `project.yaml` is never reported as unset
- [ ] The nested loop is still found and reported with a `file:line` location

---

## Protocol Compliance

- [ ] Records each input as FOUND or ABSENT before producing any report
- [ ] Reads the four `performance.*` budget keys with `get_effective_yaml_key` before falling back to design docs or `CLAUDE.md`
- [ ] A metric with no committed budget is `NOT ASSESSED` — never measured against the `[16.67ms]` placeholder — and the summary claims headroom only against a budget that is set
- [ ] Applies `performance.enforce` from the resolved block: `warn` → findings, `block` → blockers, `off` → informational
- [ ] Asks "May I write" naming `production/polish/[scope]-report-[date].md` before writing, and keeps `NOT ASSESSED` sections in the written file
- [ ] No director gates are invoked
- [ ] Ends with the Phase 6 next-step handoff; the scheduling line depends on `workflow` (`/saas-sprint-plan update` at `standard`/`full`, the brief's build order at `minimal`)

---

## Coverage Notes

- An unrecognized `performance.enforce` value (surfaced to the user, then
  treated as `warn`) is not tested here.
- The skill is static analysis only; confirming a hotspot with runtime
  profiling is listed under the report's "Requires Investigation" section and is
  not exercised by these cases.
- Deferring M/L hotspots under Phase 5 choice C records them under
  `### Deferred to Polish`; that recording is not asserted separately.
