# Skill Test Spec: /saas-project-stage-detect

## Skill Summary

`/saas-project-stage-detect [role]` determines the project's development stage and
its gaps. It starts with a deterministic pass (`bash
.claude/scripts/artifact-check.sh`, which reports PRESENT / ABSENT / SHORT /
PATTERN_MISS / NO_CHECK per artifact), then scans `design/`, the code root,
`production/`, `prototypes/`, `docs/architecture/` and `tests/`.

A configured stage (`project.stage` in `project.yaml`, else legacy
`production/stage.txt`) is authoritative for what the stage is, but the skill
always runs its heuristics too and states explicitly when the artifacts
disagree. Heuristics, checked from most advanced backward: Production = code
root has 10+ source files; Pre-Production = stack configured, <10 source files;
Technical Setup = systems index, no stack; Systems Design = concept, no
complete systems index; Concept = no concept doc; Polish and Release are
explicit only. The resolved workflow tier decides which absent documents count
as gaps (none of PRDs/ADRs/sprints at `minimal`). An unresolved code root means
the source files were not counted: `NOT ASSESSED — code root unresolved`, never
zero files.

The report carries **Stage Confidence**, first match wins: FAIL (critical gaps
block progress) → CONCERNS (ambiguous signals — always when the configured and
observed stages disagree) → NOT ASSESSED (a check the stage depends on did not
run, named) → PASS (clearly detected). At `workflow: minimal` the configured
stage is never advanced (no `/saas-gate-check` on that path), so its lag behind the
observed stage is reported but is not a disagreement. The skill shows the
summary, gaps and next steps, then asks "May I write the full stage analysis to
production/project-stage-report.md?". It never writes the stage itself. No
director gates apply.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains all seven stage names: Concept, Systems Design, Technical Setup, Pre-Production, Production, Polish, Release
- [ ] Contains the Stage Confidence values PASS, CONCERNS, NOT ASSESSED and FAIL, with a first-match order
- [ ] Contains "May I write" language before writing `production/project-stage-report.md`
- [ ] Has a next-step handoff (Follow-Up Actions naming `/saas-map-features`, `/saas-reverse-document`, `/saas-architecture-decision`, `/saas-sprint-plan`, `/saas-milestone-review`)

---

## Director Gate Checks

None. `/saas-project-stage-detect` is a diagnostic utility. It spawns no agents
(`Agent` is not in its allowed tools) and no director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Configured Stage Matches the Artifacts

**Fixture:**
- `project.yaml` has `project.stage: Production` and `stack.name: Next.js`
- `src/` has 24 source files; `design/prd/` has 4 PRDs and `features-modules-index.md`,
  one PRD per indexed system
- `docs/architecture/` has `architecture.md` and 5 ADRs; `design/ui/design-tokens.md`
  and the UX specs exist; `tests/unit/` holds tests for each system — no doc type
  the `full` tier flags is missing, so there is no gap to weigh
- `production/sprints/sprint-002.md` exists
- Resolved workflow tier: `full`

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. Skill runs `bash .claude/scripts/artifact-check.sh` before hand-scanning
2. Skill reads the configured stage `Production` from `project.yaml`
3. Skill still runs the heuristics; 24 source files (10+) indicate Production
4. Report states the configured and observed stages agree; Stage Confidence is PASS
5. Skill shows the summary, gaps and next steps, then asks "May I write the full
   stage analysis to production/project-stage-report.md?"

**Assertions:**
- [ ] `artifact-check.sh` is run as the first scan step
- [ ] Detected stage is Production, and the heuristic result is reported alongside the configured one
- [ ] Stage Confidence is PASS
- [ ] "May I write" names `production/project-stage-report.md` and nothing is written before approval
- [ ] Neither `project.yaml` nor `production/stage.txt` is modified

---

### Case 2: No Configured Stage — Inferred From Artifacts, Role Filter Applied

**Fixture:**
- No `project.stage` in `project.yaml` and no `production/stage.txt`
- `stack.name: Next.js`; `src/` has 14 source files
- `design/prd/` has 3 PRDs; `docs/architecture/` has no ADRs
- Resolved workflow tier: `full`

**Input:** `/saas-project-stage-detect programmer`

**Expected behavior:**
1. Skill finds no configured stage and auto-detects from the heuristics
2. 14 source files (10+) → stage Production
3. The programmer role focuses recommendations on architecture docs, test
   coverage and missing ADRs
4. The missing ADRs are surfaced as a gap with a clarifying question, and
   `/saas-architecture-decision` or `/saas-reverse-document architecture` is suggested
5. Skill asks before writing the report; no stage value is written anywhere

**Assertions:**
- [ ] Inferred stage is Production, based on the 10+ source-file rule
- [ ] Recommendations focus on architecture docs, tests and ADRs for the programmer role
- [ ] The ADR gap is phrased with a clarifying question, not only listed
- [ ] No stage value is written to `project.yaml` or `production/stage.txt`

---

### Case 3: Configured Stage Contradicted by the Artifacts

**Fixture:**
- `project.yaml` has `project.stage: Release`
- `stack.name: Next.js`; `src/` has 2 source files; no ADRs, no architecture
  doc, no epics
- Resolved workflow tier: `full`

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. Skill reads the configured stage `Release`
2. Heuristics indicate Pre-Production (stack configured, fewer than 10 source
   files)
3. Skill reports both and says explicitly that they disagree — the configured
   stage may be stale, or work exists outside this repo
4. The configured value is not silently replaced, and the disagreement is not
   hidden behind a confident result

**Assertions:**
- [ ] Output names both the configured stage (Release) and the observed stage (Pre-Production)
- [ ] The disagreement is stated explicitly
- [ ] Stage Confidence is CONCERNS (ambiguous signals), or FAIL if critical gaps are also found — never PASS
- [ ] The configured stage is neither silently overridden nor rewritten in any file

---

### Case 4: Minimal Workflow Tier — Absent Docs Are Not Gaps

**Fixture:**
- Resolved workflow tier: `minimal`
- `project.yaml` has `project.stage: Concept`, as `/saas-start` wrote it — nothing on
  the minimal path runs `/saas-gate-check`, so it has never advanced
- `design/product-brief.md` exists; `stack.name: Next.js`; `src/` has 5 source files
- No PRDs, no design tokens, no ADRs, no epics, no sprint plans

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. Skill uses the resolved tier `minimal` rather than assuming one
2. It treats a brief plus an stack as the normal state
3. It does NOT flag absent PRDs, design tokens, UX specs, ADRs, epics or sprint
   plans as gaps
4. It does not suggest `/saas-reverse-document` for an absent PRD or `/saas-sprint-plan`
5. The Production line reports stories through the brief's build order, never
   "no sprint plan"
6. The heuristics observe Pre-Production (stack configured, fewer than 10 source
   files); the configured Concept is reported as not advanced at this tier — an
   expected lag, not a disagreement — so it does not by itself make Stage
   Confidence CONCERNS

**Assertions:**
- [ ] No absent PRD, design tokens, ADR, epic or sprint plan is listed as a gap
- [ ] `/saas-reverse-document` is not suggested for an absent PRD (this fixture has a brief; Case 7 covers the missing brief), and `/saas-sprint-plan` is not suggested
- [ ] The Production completeness line refers to the brief's build order
- [ ] The configured Concept stage is not reported as a disagreement with the observed stage
- [ ] Report is still offered behind the "May I write" ask

---

### Case 5: Director Gate Check — None; Declined Write Leaves No File

**Fixture:**
- Any project state
- Any review mode
- User declines the "May I write" ask

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. Skill completes detection and shows the summary
2. No director or other agent is spawned; no gate IDs appear
3. Skill asks "May I write the full stage analysis to
   production/project-stage-report.md?"
4. User declines; no file is created

**Assertions:**
- [ ] No director gate is invoked and no gate skip message appears
- [ ] No subagent is spawned
- [ ] The summary is shown before the write ask
- [ ] After a decline, `production/project-stage-report.md` is not created

---

### Case 6: Unresolved Code Root — NOT ASSESSED, not a greenfield project

**Fixture:**
- No `project.stage`, no `production/stage.txt`
- `project.yaml` has no `stack.name`; `.claude/docs/technical-preferences.md`
  reads `[TO BE CONFIGURED]`
- Both `src/` and `Assets/` exist, each holding source files (ambiguous tree)
- `design/prd/product-concept.md` and `design/prd/features-modules-index.md` exist, with a
  PRD for every indexed system; `docs/architecture/` holds the Foundation-layer
  ADRs — nothing the `standard` tier flags is missing
- Resolved workflow tier: `standard`

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. The code root cannot be resolved (no stack, two candidate roots), so the
   source-file count does not run
2. The Source Code section reads `NOT ASSESSED — code root unresolved` — not
   "0 source files", and the project is not called greenfield
3. Without the count the Production row (10+ source files) can be neither ruled
   in nor out — the rows below it would say Technical Setup (systems index, no
   stack) — so the report says which check did not run instead of settling
   silently on the lower stage
4. No stage is configured and there are no gaps, so nothing ranks above it:
   Stage Confidence is **NOT ASSESSED**, naming the unresolved code root. The
   two candidate roots are the reason the check could not run, not an
   ambiguous signal (CONCERNS)

**Assertions:**
- [ ] No source-file count of zero is reported; the Source Code line is `NOT ASSESSED — code root unresolved`
- [ ] The code root is not assumed to be `src/`
- [ ] Stage Confidence is NOT ASSESSED and names the check that did not run — not PASS
- [ ] The report is still offered behind the "May I write" ask

---

### Case 7: Minimal Workflow, No Product Brief — The follow-up depends on how much code exists

**Fixture:**
- Resolved workflow tier: `minimal`
- No `project.stage` and no `production/stage.txt`; `stack.name: Next.js` (code root `src/`)
- No `design/product-brief.md`, no `design/prd/` files, no sprint plans
- Scenario (a): `src/` has 14 source files
- Scenario (b): `src/` has 3 source files

**Input:** `/saas-project-stage-detect`

**Expected behavior:**
1. Skill uses the resolved tier `minimal`; the absent PRDs, ADRs, epics and sprint plans are still not gaps
2. The absent `design/product-brief.md` is reported, and the Follow-Up Actions address it
3. (a) The code root already holds the product (10 or more source files), so the follow-up is `/saas-reverse-document design src/` — the brief is written from what is built — and not `/saas-brainstorm`
4. (b) With little code the follow-up is `/saas-brainstorm`, not `/saas-reverse-document`
5. In both, `/saas-sprint-plan` is not suggested; the report is offered behind the "May I write" ask

**Assertions:**
- [ ] The missing product brief is reported at `minimal`
- [ ] (a) `/saas-reverse-document design <code root>` is suggested, naming the resolved code root (`src/`), and `/saas-brainstorm` is not
- [ ] (b) `/saas-brainstorm` is suggested and `/saas-reverse-document` is not
- [ ] The suggestion in both scenarios is conditioned on the source-file count (10 or more), as counted in the resolved code root
- [ ] No PRD, ADR, epic or sprint-plan gap is reported, and `/saas-sprint-plan` is not suggested

---

## Protocol Compliance

- [ ] Runs `artifact-check.sh` before hand-scanning artifacts
- [ ] Reads `project.stage` (then `production/stage.txt`) when present, and always runs the heuristics as well
- [ ] States explicitly when configured and observed stages disagree
- [ ] Surfaces gaps only as the resolved workflow tier allows, each with a clarifying question
- [ ] Reports Stage Confidence as PASS / CONCERNS / NOT ASSESSED / FAIL, first match FAIL → CONCERNS → NOT ASSESSED → PASS; a configured/observed disagreement is CONCERNS
- [ ] Reports an unresolved code root as `NOT ASSESSED — code root unresolved`, never as zero source files
- [ ] Asks "May I write" before writing `production/project-stage-report.md`; never writes a stage value

---

## Coverage Notes

- Concept (no concept doc) and Technical Setup (systems index, no stack) follow
  the same heuristic table and are not separately fixture-tested.
- Polish and Release are explicit-only stages; they can only come from a
  configured value, which Case 3 covers.
- The `standard` tier (flag missing PRDs for built systems and critical ADRs
  only) is not separately tested.
