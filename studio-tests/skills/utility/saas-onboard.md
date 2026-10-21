# Skill Test Spec: /saas-onboard

## Skill Summary

`/saas-onboard [role|area]` generates an onboarding document for a new contributor or
agent. It reads `CLAUDE.md`, the matching agent definition in `.claude/agents/`
when a role is given, scans the area that role works in (the code root for
programmers, `design/` for designers, `design/content/` for content & copy, `tests/`
for QA, `production/` for production) and reads recent git history.

Before producing anything it lists its inputs as FOUND or ABSENT. A section whose
input is ABSENT is written as `NOT ASSESSED — NO DATA`, and one fed by an
unresolved code root as `NOT ASSESSED — code root unresolved`. The current-state
section names what Phase 2 found by path (for a designer, each existing PRD and
design doc). If every input is ABSENT
the whole verdict is `NOT ASSESSED — NO DATA`, naming what was missing. Otherwise
it fills the `# Onboarding: [Role/Area]` template, presents it, and asks "May I
write this to `production/onboarding/saas-onboard-[role]-[date].md`?". The verdict is
**COMPLETE**, followed by next steps pointing to `/saas-sprint-status` and `/saas-help`. No
director gates apply.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLETE, NOT ASSESSED
- [ ] Contains "May I write" language before saving the onboarding document
- [ ] Has a next-step handoff suggesting `/saas-sprint-status` and `/saas-help`

---

## Director Gate Checks

None. `/saas-onboard` is an orientation utility. It spawns no agents (`Agent` is not
in its allowed tools) and no director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Programmer Role on a Next.js Project

**Fixture:**
- `CLAUDE.md` exists
- `project.yaml` has `stack.name: Next.js`, so the code root is `src/`
- `src/` holds product code; `.claude/agents/backend-engineer.md` exists
- `production/sprints/sprint-005.md` exists; git log has recent commits
- `modes.automation` is unset (defaults to `collaborative`)

**Input:** `/saas-onboard backend-engineer`

**Expected behavior:**
1. Skill reads `CLAUDE.md` and `.claude/agents/backend-engineer.md`
2. Skill scans the code root `src/` for architecture, patterns and key files, and
   reads recent git history
3. Skill generates a document headed `# Onboarding: backend-engineer` with the
   template sections (Project Summary, Your Role, Project Architecture, Current
   Standards and Conventions, Current State of Your Area, Current Sprint Context,
   Key Dependencies, Common Pitfalls, First Tasks, Questions to Ask)
4. Skill presents the document, then asks "May I write this to
   `production/onboarding/saas-onboard-backend-engineer-[date].md`?"
5. On approval it writes the file (creating the directory if needed); verdict is
   COMPLETE, with `/saas-sprint-status` and `/saas-help` as next steps

**Assertions:**
- [ ] The agent definition for the named role is read
- [ ] The code root `src/` is scanned for this programmer role
- [ ] The document uses the `# Onboarding: [Role/Area]` template sections
- [ ] The document is presented before the "May I write" ask naming `production/onboarding/saas-onboard-backend-engineer-[date].md`
- [ ] Verdict is COMPLETE and next steps name `/saas-sprint-status` and `/saas-help`

---

### Case 2: Designer Role — Scans design/, Not the Code Root

**Fixture:**
- `CLAUDE.md` exists; `.claude/agents/lead-product-manager.md` exists
- `design/prd/` holds three system PRDs
- `src/` also holds code

**Input:** `/saas-onboard lead-product-manager`

**Expected behavior:**
1. Skill reads `CLAUDE.md` and `.claude/agents/lead-product-manager.md`
2. Phase 2 takes the designers branch and scans `design/` for existing design
   documents
3. "Current State of Your Area" reflects the three PRDs found
4. Document is presented, "May I write" asked for
   `production/onboarding/saas-onboard-lead-product-manager-[date].md`; verdict COMPLETE

**Assertions:**
- [ ] `design/` is the area scanned for this role
- [ ] The existing PRDs are named in the document's current-state section
- [ ] The file path in the "May I write" ask uses the role name
- [ ] Verdict is COMPLETE

---

### Case 3: Every Input Absent — NOT ASSESSED, No Document

**Fixture:**
- `CLAUDE.md` does not exist
- `.claude/agents/` does not exist, so no agent definition can be read
- `tests/` does not exist; the directory is not a git repository

**Input:** `/saas-onboard qa-manual-tester`

**Expected behavior:**
1. Skill lists its inputs and records each as ABSENT
2. Because every required input is ABSENT, it stops and reports
   `NOT ASSESSED — NO DATA` as the whole verdict
3. The report names what was missing and what produces it: `/saas-test-setup` for
   `tests/`; `CLAUDE.md` and `.claude/agents/` come with the framework itself —
   no skill creates them — so they are reported as missing from the install,
   not attributed to a skill
4. No onboarding document is generated and no file is written

**Assertions:**
- [ ] Inputs are recorded as FOUND or ABSENT before any report is produced
- [ ] Verdict is `NOT ASSESSED — NO DATA`, not COMPLETE
- [ ] The missing inputs are named; `tests/` points to `/saas-test-setup`
- [ ] No skill is named as the producer of `CLAUDE.md` or `.claude/agents/` — none creates them
- [ ] No template is filled in and no "May I write" ask appears

---

### Case 4: Edge Case — Programmer Role With an Unresolved Code Root

**Fixture:**
- `CLAUDE.md` exists; `.claude/agents/backend-engineer.md` exists
- `project.yaml` has no `stack.name`, technical-preferences has
  `[TO BE CONFIGURED]`, and both `src/` and `Assets/` exist (ambiguous tree)

**Input:** `/saas-onboard backend-engineer`

**Expected behavior:**
1. Skill tries to resolve the code root and finds it unresolved (two candidate
   roots, no stack set)
2. It does not default to `src/`
3. The code-dependent sections (Project Architecture, Key Files) are written as
   `NOT ASSESSED — code root unresolved` rather than filled from a guess — the
   code exists, so this is not a missing-data case
4. Sections backed by found inputs (Project Summary, Your Role, Current
   Standards and Conventions) are still produced; the document is presented
   before the "May I write" ask

**Assertions:**
- [ ] The code root is not assumed to be `src/`
- [ ] Architecture/key-file content is marked `NOT ASSESSED — code root unresolved`, not `NO DATA`
- [ ] Sections with found inputs are still generated
- [ ] "May I write" is asked before any file is written

---

### Case 5: Director Gate Check — None; No Agents Spawned

**Fixture:**
- Any project state with `CLAUDE.md` present
- Any review mode

**Input:** `/saas-onboard producer`

**Expected behavior:**
1. Skill scans `production/` for the current sprint and milestone
2. No agent of any kind is spawned; no gate IDs appear in output
3. Document is presented, then "May I write this to
   `production/onboarding/saas-onboard-producer-[date].md`?" is asked
4. Verdict is COMPLETE

**Assertions:**
- [ ] No director gate is invoked and no gate skip message appears
- [ ] No subagent is spawned
- [ ] `production/` is the area scanned for this role
- [ ] Verdict is COMPLETE after the write ask

---

## Protocol Compliance

- [ ] Reads `CLAUDE.md` and, when a role is given, its agent definition before generating
- [ ] Scans only the area that matches the role
- [ ] Records each input as FOUND or ABSENT; ABSENT-backed sections read `NOT ASSESSED — NO DATA`
- [ ] Presents the document before asking "May I write" to `production/onboarding/saas-onboard-[role]-[date].md`
- [ ] Ends with verdict COMPLETE and the `/saas-sprint-status` / `/saas-help` next steps — or, when every input is absent, stops at `NOT ASSESSED — NO DATA` naming what produces each missing input

---

## Coverage Notes

- A call with no role argument (`/saas-onboard`) takes Phase 2's general-orientation
  branch (the top level of `design/`, `docs/architecture/`, `production/` and
  the code root, plus `active.md`, and a note that a role would focus the next
  pass); it is not separately tested.
- `content` (`design/content/`) and QA with an existing `tests/` directory
  follow the same branch pattern as Cases 1 and 2 and are not separately tested.
- `modes.automation: autonomous` (log and proceed instead of asking) is not
  tested here.
