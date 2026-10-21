# Skill Test Spec: /saas-bug-triage

## Skill Summary

`/saas-bug-triage` turns the open bug backlog into a prioritised, sprint-assigned
action list and writes it to `production/qa/saas-bug-triage-[date].md` after a
"May I write" ask. It runs on the Sonnet model. Modes: `sprint` (assign fixable
bugs to the current sprint, defer the rest), `full` (P1 → current sprint, P2 →
next sprint, P3+ → backlog), `trend` (trend analysis only, no assignment, from
header fields alone); no argument runs `sprint` if a sprint file exists, else `full`.

Bugs are discovered in `production/qa/bugs/*.md`, falling back to
`production/qa/bugs.md`, then a `production/qa/saas-qa-plan-*.md` "Bugs Found" table.
Each bug gets a **severity** (S1 Critical – S4 Low, impact) and a **priority**
(P1 Fix this sprint – P4 Won't fix / Deferred, urgency) — two separate axes, so
the report groups bugs by priority, not severity. A deviation check flags
systemic problems (3+ bugs in one system in a sprint; 2+ S1/S2 in one story; a
bug filed against a Complete story). The verdict is `COMPLETE` when the report is
written, `COMPLETE` with no report when there are no bug files to triage, and
`BLOCKED` when the user declines the write. At `workflow: minimal` there are no
sprints by design: with no sprint file the skill says so and names the P1 bugs as the
next fixes, ahead of the next story in the brief's build order. No director gates apply.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLETE, BLOCKED
- [ ] Contains "May I write" language before writing `production/qa/saas-bug-triage-[date].md`
- [ ] Has a next-step handoff (`/saas-sprint-status` for unassigned S1s; `/saas-smoke-check` after regressions)

---

## Director Gate Checks

None. `/saas-bug-triage` is an operational triage skill. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Sprint mode, 5 bugs grouped by priority

**Fixture:**
- `production/sprints/sprint-004.md` is the newest sprint file and notes spare capacity
- `production/qa/bugs/` contains 5 bug files:
  - `BUG-0001.md` — S1, P1, Audio
  - `BUG-0002.md` — S2, P1, Core Workflow
  - `BUG-0003.md` — S3, P2, UI
  - `BUG-0004.md` — S2, P2, VFX
  - `BUG-0005.md` — S4, P3, Tutorial

**Input:** `/saas-bug-triage`

**Expected behavior:**
1. No argument and a sprint file exists → `sprint` mode
2. Reads the 5 bug files and the newest sprint file
3. Classifies severity and priority separately; P1 bugs are assigned to sprint 4
4. Report has the Triage Summary table (P1: 2, P2: 2, P3: 1, P4: 0),
   "Critical (S1/S2) unfixed count: 3", and separate P1, P2 and P3/P4 tables
5. Presents the report and asks "May I write this triage report to `production/qa/saas-bug-triage-[date].md`?"
6. Writes only after approval

**Assertions:**
- [ ] Mode reported as `sprint`
- [ ] BUG-0001 and BUG-0002 are in the "P1 Bugs — Fix This Sprint" table, assigned to the current sprint
- [ ] BUG-0003 and BUG-0004 are in the P2 table; BUG-0005 is in the P3/P4 table
- [ ] Triage Summary counts and the S1/S2 unfixed count (3) are correct
- [ ] "May I write" names `production/qa/saas-bug-triage-[date].md`, and nothing is written before approval

---

### Case 2: No Bug Files Found — Stops without a report

**Fixture:**
- `production/qa/bugs/` does not exist
- No `production/qa/bugs.md` and no `production/qa/saas-qa-plan-*.md`

**Input:** `/saas-bug-triage`

**Expected behavior:**
1. Step 2a finds no bug source in any of its three locations
2. Skill says: "No bug files found in `production/qa/bugs/`. If bugs are tracked in a
   different location, adjust the glob pattern. If no bugs exist yet, there is nothing to triage."
3. Skill stops — no classification, no triage report, no write — and ends
   `Verdict: COMPLETE — no bug files in production/qa/bugs/; nothing to triage.`

**Assertions:**
- [ ] Output states that no bug files were found in `production/qa/bugs/`
- [ ] Skill stops gracefully rather than erroring
- [ ] No triage tables are produced
- [ ] No "May I write" ask and no file written
- [ ] The stop still ends with a verdict: Verdict: COMPLETE — no bug files, nothing to triage

---

### Case 3: Systemic Issues — Deviation check flags a hot spot and a regression

**Fixture:**
- `production/sprints/sprint-004.md` exists
- `production/qa/bugs/` holds 4 bugs: 3 in the Catalog system filed this sprint,
  and 1 filed against `production/epics/core/story-003.md`, whose `Status: Complete`
- The user approves the write when asked

**Input:** `/saas-bug-triage sprint`

**Expected behavior:**
1. Classifies all 4 bugs
2. "Systemic Issues Flagged" lists "Potential design or implementation quality issue in Catalog"
3. It also flags "Regression in completed story — story should be re-opened in sprint tracking"
4. Trend Analysis names Catalog as the hot spot and counts 1 regression
5. Asks "May I write this triage report to `production/qa/saas-bug-triage-[date].md`?";
   the user approves and the report is written
6. After writing, the skill adds: "Regressions found — consider re-opening the affected
   stories in sprint tracking and running `/saas-smoke-check` to re-gate." Verdict: COMPLETE

**Assertions:**
- [ ] Catalog is flagged as a potential quality issue (3+ bugs in one system)
- [ ] The bug against the Complete story is flagged as a regression
- [ ] Trend Analysis shows Catalog as the hot spot and "Regressions: 1"
- [ ] The report is written only after the "May I write" ask is approved
- [ ] The post-write message recommends `/saas-smoke-check`, and the verdict is COMPLETE

---

### Case 4: Sprint at Capacity — Overflow flagged, Won't Fix asked, write declined

**Fixture:**
- `production/sprints/sprint-004.md` notes the sprint is at full capacity
- `production/qa/bugs/` holds one S2/P1 bug and one S4 bug judged P4 (cosmetic, out of scope)

**Input:** `/saas-bug-triage sprint`

**Expected behavior:**
1. The P1 bug is not auto-assigned to the full sprint; it is flagged
   `Priority overflow — consider pulling from sprint`
2. The S4 bug is surfaced as a P4 candidate with "Are these acceptable as Won't Fix?"
   — it is not marked Won't Fix without the user's answer
3. User declines the report write
4. Verdict is BLOCKED — user declined write; no file is created

**Assertions:**
- [ ] P1 bug carries the `Priority overflow` flag instead of a sprint assignment
- [ ] The Won't Fix question is asked before any bug is dispositioned P4
- [ ] Verdict is BLOCKED when the write is declined
- [ ] `production/qa/saas-bug-triage-[date].md` is not written

---

### Case 5: Director Gate Check — Full mode, no P1 bugs

**Fixture:**
- `modes.workflow: standard` (pinned: unset resolves to minimal, which has no sprints by design)
- No sprint file in `production/sprints/`
- `production/qa/bugs/` holds two bugs, S3/P3 and S4/P3

**Input:** `/saas-bug-triage full`

**Expected behavior:**
1. Notes "No sprint plan found — assigning to backlog only."
2. Both bugs go to the backlog (P3+)
3. Report is written after "May I write" approval
4. With no P1 bugs: "No P1 bugs — build is in good shape for QA hand-off." Verdict: COMPLETE
5. No director agents are spawned; no gate IDs appear

**Assertions:**
- [ ] "No sprint plan found — assigning to backlog only." is stated
- [ ] Both bugs are dispositioned Backlog
- [ ] "No P1 bugs — build is in good shape for QA hand-off." appears with Verdict COMPLETE
- [ ] No director gate is invoked and no gate skip messages appear

---

### Case 6: Minimal workflow — no sprints by design, P1 bugs ahead of the next brief story

**Fixture:**
- `project.yaml`: `modes.workflow: minimal` (pinned: this case tests the `minimal`
  wording, the opposite of Case 5)
- No `production/sprints/` directory
- `design/product-brief.md` lists a build order of three features; the next unbuilt one
  is "Catalog screen"
- `production/qa/bugs/` holds BUG-0001 (S1, P1, Audio), BUG-0002 (S3, P1, UI) and
  BUG-0003 (S4, P3, Tutorial)

**Input:** `/saas-bug-triage` (no argument; no sprint file, so `full` mode)

**Expected behavior:**
1. No sprint file exists, so `full` mode runs
2. Step 2b says there are no sprints by design at `workflow: minimal` — it does not
   print "No sprint plan found — assigning to backlog only."
3. The two P1 bugs are named as the next fixes, ahead of the next story in the
   brief's build order ("Catalog screen")
4. BUG-0003 goes to the backlog; no bug is given a `Sprint:` assignment
5. The report is written after "May I write this triage report to
   `production/qa/saas-bug-triage-[date].md`?"; Verdict: COMPLETE

**Assertions:**
- [ ] The no-sprint note says there are no sprints at `workflow: minimal`, and the "No sprint plan found — assigning to backlog only." wording does not appear
- [ ] BUG-0001 and BUG-0002 are named as the next fixes, before the next story of the brief's build order
- [ ] No bug is assigned to a sprint, and none is flagged `Priority overflow`
- [ ] The report is written only after the "May I write" ask, and the verdict is COMPLETE

---

## Protocol Compliance

- [ ] Discovers bugs in `production/qa/bugs/*.md` before the fallbacks
- [ ] Keeps severity (S1–S4) and priority (P1–P4) as separate classifications
- [ ] Never auto-assigns to a sprint at capacity
- [ ] Never marks a bug Won't Fix without asking the user
- [ ] Asks "May I write" before writing the triage report
- [ ] Verdict is COMPLETE when written (or when there are no bug files to triage), BLOCKED when the write is declined

---

## Coverage Notes

- `trend` mode (header-field Grep only, no bug-body reads, no assignment) is not
  separately tested.
- The consolidated `production/qa/bugs.md` and `qa-plan-*.md` fallbacks are not
  separately tested.
- The "2+ S1/S2 bugs in the same story" deviation flag and the aged-bug
  warning (>2 sprints) are not separately tested.
