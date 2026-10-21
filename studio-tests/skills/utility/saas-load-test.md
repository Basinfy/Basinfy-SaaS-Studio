# Skill Test Spec: /saas-load-test

## Skill Summary

`/saas-load-test [duration] [focus]` generates an observation protocol for an
automated load/soak test session — k6/artillery executes scenarios, the skill writes the plan. Duration is
`30m`, `1h`, `2h` or `4h` (default `1h`); focus is `memory`, `stability`,
`balance` or `all` (default `all`). It reads `stack.name` and `performance.*`
from `project.yaml` (falling back to `technical-preferences.md`), the product
concept or brief, the latest usability test and QA plan, then builds timed
checkpoints for the duration and stack-specific memory guidance whose alert
thresholds are relative to the session's own T+0 baseline, in units recorded as
displayed. The stack tool and counter names it gives are not covered by
`docs/stack-reference/`, so they are marked NOT SOURCEABLE — pointers the
tester confirms at T+0, recording the tool actually used.

The protocol document carries a Verdict section with PASS / PASS WITH CONCERNS /
NOT ASSESSED / FAIL for the tester to fill in after the session; a short soak
cannot return PASS. The skill asks "May I write this load test protocol to
`production/qa/saas-load-test-[date]-[duration].md`?" before writing, and never runs
the soak itself. Its run steps end with `/saas-bug-triage sprint`, or `/saas-bug-triage full`
at `workflow: minimal`, which has no sprints. No director gates apply.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PASS, PASS WITH CONCERNS, NOT ASSESSED, FAIL
- [ ] Contains "May I write" collaborative protocol language before writing the protocol
- [ ] Has a next-step handoff (`/saas-bug-triage sprint` after the session, `/saas-bug-triage full` at `workflow: minimal`; `/saas-smoke-check` after fixing a FAIL)

---

## Director Gate Checks

None. `/saas-load-test` is a QA planning utility. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — 2-hour, all-focus soak on Next.js

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `performance.target_framerate: 60` and
  `modes.workflow: standard` (pinned: unset resolves to minimal, which ends the run
  steps with `/saas-bug-triage full`, Case 6)
- `design/prd/product-concept.md` states the intended session length
- The user approves the write

**Input:** `/saas-load-test 2h all`

**Expected behavior:**
1. Skill loads context: stack, performance budgets, concept, latest usability test and QA plan
2. Checkpoints for `2h`: T+0, T+20, T+40, T+60, T+80, T+100, T+120
3. Next.js memory items: the Debugger's memory monitors, Static Memory (unit as
   displayed), Object Count, Orphan Nodes — names marked NOT SOURCEABLE, since
   `docs/stack-reference/nextjs/` does not cover them, for the tester to confirm
   at T+0; alert when memory grows > 20% from T+0 after the first 15 minutes;
   Orphan Nodes must return to its T+0 value after a scene unload
4. Stability items (60 fps target) and balance/fatigue items are both included
5. Protocol document has Pre-Session Setup, Baseline (T+0), a Checkpoint Log per
   checkpoint, Post-Session Analysis, and a Verdict section left for the tester
6. Skill asks "May I write this load test protocol to
   `production/qa/saas-load-test-[date]-2h.md`?"
7. After writing, prints the run steps ending with `/saas-bug-triage sprint`

**Assertions:**
- [ ] Checkpoints are exactly T+0, T+20, T+40, T+60, T+80, T+100, T+120
- [ ] Memory thresholds are relative to T+0, and the unit is recorded as displayed (no unit assumed)
- [ ] The Next.js tool and counter names are marked NOT SOURCEABLE, not presented as verified, and Pre-Session Setup asks for the tool actually used
- [ ] Memory, stability and balance observation items are all present (focus `all`)
- [ ] "May I write" is asked with `production/qa/saas-load-test-[date]-2h.md`
- [ ] The skill issues no verdict itself — the protocol's Verdict section is left for the tester

---

### Case 2: No Arguments — Defaults applied

**Fixture:**
- No arguments provided; stack configured

**Input:** `/saas-load-test`

**Expected behavior:**
1. Duration defaults to `1h`, focus to `all` — no questions are needed to start
2. Checkpoints: T+0, T+15, T+30, T+45, T+60
3. Protocol header records `Duration: 1h` and `Focus: all`
4. Skill asks "May I write this load test protocol to `production/qa/saas-load-test-[date]-1h.md`?"

**Assertions:**
- [ ] Duration `1h` and focus `all` are used when no argument is given
- [ ] Checkpoints are exactly T+0, T+15, T+30, T+45, T+60
- [ ] The output path ends `-1h.md`
- [ ] Nothing is written before the "May I write" approval

---

### Case 3: Narrow Focus on Cloudflare — 4-hour memory soak

**Fixture:**
- `project.yaml` has `stack.name: Cloudflare`

**Input:** `/saas-load-test 4h memory`

**Expected behavior:**
1. Checkpoints for `4h`: T+0, T+30, T+60, T+90, T+120, T+180, T+240
2. Cloudflare memory items: a memory readout at each checkpoint — `stat memory`,
   marked NOT SOURCEABLE since `docs/stack-reference/cloudflare/` does not cover
   it; record Physical Memory Used and Available (units as displayed)
3. Alert threshold: Physical Memory Used growth > 20% over the full soak,
   against this run's T+0 — no absolute MB threshold
4. Balance/fatigue observation items are not generated (focus is `memory`)
5. Output path `production/qa/saas-load-test-[date]-4h.md`

**Assertions:**
- [ ] Checkpoints are exactly T+0, T+30, T+60, T+90, T+120, T+180, T+240
- [ ] The Cloudflare threshold is a relative > 20% growth, not an absolute size
- [ ] `stat memory` is marked NOT SOURCEABLE, a pointer to confirm rather than a verified command
- [ ] Balance/fatigue items are omitted for focus `memory`
- [ ] "May I write" names the `-4h.md` path

---

### Case 4: No Performance Budgets — "not set", never invented

**Fixture:**
- `project.yaml` has `stack.name: FastAPI` and no `performance` block
- `technical-preferences.md` Performance Budgets are `[TO BE CONFIGURED]`

**Input:** `/saas-load-test 30m memory`

**Expected behavior:**
1. Skill falls back from `project.yaml` to `technical-preferences.md` for budgets
2. Budget notes read `Memory ceiling: not set`, `API p95 latency: not set`,
   `Error rate ceiling: not set` — no number is supplied in their place
3. Checkpoints: T+0, T+10, T+20, T+30
4. FastAPI memory items: a memory profiler, marked NOT SOURCEABLE (not covered by
   `docs/stack-reference/fastapi/`); record Total Reserved Memory, GC Allocated,
   Object Count (units as displayed); alert when GC Allocated grows
   monotonically across 3+ checkpoints
5. Skill asks "May I write" before writing `production/qa/saas-load-test-[date]-30m.md`

**Assertions:**
- [ ] Missing budgets are recorded as "not set", not filled with defaults
- [ ] Checkpoints are exactly T+0, T+10, T+20, T+30
- [ ] The FastAPI threshold is the unit-free monotonic-growth check
- [ ] "May I write" is asked before the file is written

---

### Case 5: Director Gate Check — No gate; soak-test is a planning utility

**Fixture:**
- Engine configured; valid duration and focus provided

**Input:** `/saas-load-test 1h stability`

**Expected behavior:**
1. Skill generates and writes the load test protocol
2. No director agents are spawned
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] The run ends at "Protocol written." with the run steps — no gate verdict, and no soak verdict issued by the skill

---

### Case 6: Minimal workflow — the run steps end with `/saas-bug-triage full`

**Fixture:**
- `project.yaml`: `stack.name: Next.js`, `modes.workflow: minimal` (pinned: Case 1 pins
  `standard`; this case tests the opposite)
- No `production/sprints/` directory; the user approves the write

**Input:** `/saas-load-test 1h all`

**Expected behavior:**
1. The protocol is built and written as in Case 2
2. After writing, "Protocol written." lists the run steps; step 5 reads
   `/saas-bug-triage full`, since `workflow: minimal` has no sprints
3. The closing line still says to run `/saas-smoke-check` again after fixing a FAIL

**Assertions:**
- [ ] The post-session step is `/saas-bug-triage full`, not `/saas-bug-triage sprint`
- [ ] Steps 1–4 and the `/saas-smoke-check` line are unchanged from the `standard` run
- [ ] The workflow is resolved from `project.yaml` and changes only that step

---

## Protocol Compliance

- [ ] Parses `[duration] [focus]`, defaulting to `1h` and `all`
- [ ] Uses the Phase 3 checkpoint table for the chosen duration
- [ ] Memory alert thresholds are ratios or deltas against T+0; units are recorded as displayed
- [ ] Engine tool names not covered by `docs/stack-reference/` are marked NOT SOURCEABLE; a memory tool the tester cannot find leaves the verdict NOT ASSESSED
- [ ] The protocol's Verdict section offers PASS / PASS WITH CONCERNS / NOT ASSESSED / FAIL and states a short soak cannot return PASS
- [ ] Asks "May I write" before creating `production/qa/saas-load-test-[date]-[duration].md`
- [ ] Never attempts to run the soak itself

---

## Coverage Notes

- The `stability` and `balance` focus values follow Case 3's pattern with the
  other observation groups; not separately tested.
- At `rigor: minimal` the skill reads `design/product-brief.md` instead of the
  product concept; not separately tested.
- Executing the protocol is outside this skill's scope — it generates the plan,
  a human runs it.
