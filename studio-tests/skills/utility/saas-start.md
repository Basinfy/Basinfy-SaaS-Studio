# Skill Test Spec: /saas-start

## Skill Summary

`/saas-start` is the first-time onboarding skill. Phase 1 reads the project with
`project-state.sh` without printing it (stack, code root and source files,
concept or brief, PRDs, ADRs, other work, and whether `origin` still points at
the template repo); `source_files: unknown` is reported as an unknown code root,
never as no code. Phase 2 asks where the user is with four options (A No idea
yet, B Vague idea, C Clear concept, D Existing work); the stack is not asked
here, `/saas-setup-stack` chooses it.

Phase 3 routes by answer and names only the immediate next step. Phase 4 works
out the stage (A/B/C: `Concept`; D: from the PRD and ADR counts) and the rigor:
kept when `modes.rigor` is set, otherwise inferred from what the user said
(`settings-guidance.md` §3; no signal or no idea → `minimal`). It shows both on
an assumptions card, which names `/saas-settings` for later changes, and asks one
question: `Save them` / `Don't save`. It asks no rigor question. Only an explicit
yes writes: the stage through `set-stage.sh`
(`project.yaml` and the legacy mirror `production/stage.txt`) and an inferred
rigor through `config-set.sh`. Phase 5 asks the automation question unless the
key is set, and writes the pick through `config-set.sh`. `/saas-start` never writes
any of the six knobs `modes.rigor` fronts (`modes.review_mode`,
`modes.workflow`, `docs.density`, `qa.level`, `modes.story_granularity`,
`team.size`) or `production/review-mode.txt`.

Phase 6 prints the path for the rigor (Path D's existing-work path included;
at `minimal` a D user with no brief is told where the brief comes from) and
asks which step to take first; Phase 7 prints a single "Type `[skill]` to
begin." line and starts nothing. A returning user (stack set and a concept or
brief present) skips onboarding. No director gates apply. Verdict: COMPLETE.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec`, no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] States the write rule for every write: the stage and an inferred rigor only after an explicit yes to the save question that names `project.yaml` and `production/stage.txt`; `modes.automation` from the user's pick, and never when the save was declined
- [ ] Has a next-step handoff at the end (Phase 7: "Type `[skill]` to begin.")

---

## Director Gate Checks

None. `/saas-start` is a utility setup skill. No director agents exist yet at the
point this skill runs.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Fresh repo, Path A, rigor inferred

**Fixture:**
- No `project.yaml`, no `production/stage.txt`; `technical-preferences.md`
  holds only placeholders (runs without the Fixture Defaults block)
- No design documents, prototypes or source code; `origin` is the user's own repo
- The user picks `A) No idea yet`, then `Save them`, then `Guided`

**Input:** `/saas-start`

**Expected behavior:**
1. Phase 1 runs `project-state.sh` without printing its rows
2. Phase 2 offers exactly A–D; no stack question is asked
3. Path A names only `/saas-brainstorm open` as the next step and leaves the full path for later
4. Phase 4 shows the card: stage `Concept`, rigor `minimal` with the reason (no
   concept yet), and asks to save them to `project.yaml` and the stage to
   `production/stage.txt`; it asks no rigor question
5. After `Save them`, `set-stage.sh Concept` creates `project.yaml` and writes
   `production/stage.txt`, and `config-set.sh modes.rigor minimal` adds the rigor
6. Phase 5 asks the automation question; `config-set.sh modes.automation guided` runs on the pick
7. Phase 6 prints the minimal 4-step path (`/saas-setup-stack`, `/saas-brainstorm`,
   `/saas-create-stories`, `/saas-dev-story`) and asks which step to take first
8. Phase 7 prints only "Type `[skill]` to begin."; verdict COMPLETE

**Assertions:**
- [ ] Phase 2 offers exactly the four A–D options and no stack choice
- [ ] No rigor question is asked; the inferred `minimal` is on the card with its reason
- [ ] Nothing is written before the explicit `Save them`
- [ ] `project.stage` and `production/stage.txt` are both `Concept`
- [ ] `project.yaml` ends up holding only `project.stage`, `modes.rigor` and `modes.automation` from `/saas-start`: none of the six rigor-fronted knobs, and no `production/review-mode.txt`
- [ ] `project.yaml` has exactly one `modes:` block, holding `rigor` and `automation`
- [ ] Phase 6 prints the minimal 4-step path
- [ ] The next skill is not started; Verdict is COMPLETE

---

### Case 2: Returning User — Onboarding skipped

**Fixture:**
- `project.yaml` has `stack.name: Next.js` and `modes.rigor: minimal`; no explicit `modes.review_mode`
- `design/product-brief.md` exists

**Input:** `/saas-start`

**Expected behavior:**
1. Phase 1 finds the stack set and the brief present
2. The skill skips onboarding and names the stack (Next.js) and the brief
3. Review mode is reported as `solo` (from `modes.rigor: minimal`)
4. The skill points to `/saas-help`

**Assertions:**
- [ ] The A–D starting-point question is not asked
- [ ] The message names the configured stack (Next.js) and the brief path
- [ ] Review mode is reported as `solo`, resolved from rigor
- [ ] No write is made to `project.yaml` or `production/stage.txt`

---

### Case 3: Existing Work on FastAPI — Path D, stage from the files, rigor already set

**Fixture:**
- `project.yaml` has `stack.name: FastAPI`, `modes.rigor: standard` and
  `modes.automation: collaborative`
- Python scripts exist under `app/`; `design/prd/` holds 3 system PRDs;
  no `design/prd/product-concept.md`, no `docs/architecture/`
- The user picks `D) Existing work` and `Save them`

**Input:** `/saas-start`

**Expected behavior:**
1. Phase 1 resolves the code root as `app/` and finds source files there (it
   does not scan `src/` and conclude there is no code)
2. Phase 3 D shares what it found (source files, 3 PRDs, stack FastAPI) and names
   `/saas-project-stage-detect` as the immediate step
3. Phase 4's card shows stage `Systems Design` (PRDs, no ADRs) and rigor
   `standard` as already set
4. After the yes, `set-stage.sh "Systems Design"` writes both files; no rigor write
5. Phase 5 says "Automation is `collaborative`" and asks nothing
6. Phase 6 prints the existing-work path at `standard`: `/saas-project-stage-detect`,
   `/saas-adopt`, `/saas-design-system retrofit`, `/saas-architecture-decision retrofit`,
   `/saas-architecture-review`, `/saas-gate-check`

**Assertions:**
- [ ] Source files are found under `Assets/`, not reported as absent
- [ ] Stage `Systems Design` is written to both `project.yaml` and `production/stage.txt`, after the yes
- [ ] No rigor or automation question is asked, and neither key is rewritten
- [ ] The existing-work path at `standard` includes the PRD, ADR and registry retrofit steps
- [ ] Verdict is COMPLETE

---

### Case 4: Clone Still Wired to the Template Repo — remote note, never run

**Fixture:**
- Fresh project as in Case 1
- `.git/config` has `[remote "origin"]` with url
  `https://github.com/your-org/saas-studio-template.git`
- The user picks `B) Vague idea` with the hint "a small weekend puzzler", then `Save them`

**Input:** `/saas-start`

**Expected behavior:**
1. `origin_url` matches the template repo case-insensitively
2. Path B names `/saas-brainstorm a small weekend puzzler` as the immediate step
3. The card infers rigor `minimal` from "weekend" and "small"
4. After the Phase 6 path, the skill adds once that `origin` still points at the
   template repo, suggests `git remote rename origin template` then
   `git remote add origin <your repo URL>`, and says to skip `UPGRADING.md`'s own
   `git remote add template` step since that remote now exists
5. The commands are suggested only; no git command is run

**Assertions:**
- [ ] The template-origin note appears exactly once, after the path
- [ ] Both suggested commands are given as written above
- [ ] The note says to skip `UPGRADING.md`'s `git remote add template` step after the rename, and why
- [ ] No git command is executed
- [ ] The card's rigor is `minimal`, with the user's words as the reason

---

### Case 5: Director Gate Check — No gate; start is a utility setup skill

**Fixture:**
- Fresh project and answers as in Case 1

**Input:** `/saas-start`

**Expected behavior:**
1. The skill completes the onboarding flow through Phase 7
2. No director agent is handed any work
3. No gate IDs (CD-*, TD-*, AD-*, PR-*) appear in the output

**Assertions:**
- [ ] No director gate runs
- [ ] No gate skip messages appear (gates are absent, not suppressed)
- [ ] The skill reaches COMPLETE without any gate verdict

---

### Case 6: Path D With Rigor Unset — inferred from the description, not asked

**Fixture:**
- `project.yaml` has `stack.name: Next.js` and no `modes` block
- `src/` holds TypeScript files; `design/prd/` holds 4 system PRDs; no
  `docs/architecture/`
- The user picks `D) Existing work` and says "a commercial B2B SaaS product with
  one clear core loop", then picks `Save them`, then `Collaborative`

**Input:** `/saas-start`

**Expected behavior:**
1. Phase 3 D names `/saas-project-stage-detect` as the immediate step and prints no tiered path yet
2. The card shows stage `Systems Design` and rigor `standard`, with the user's
   words ("commercial", "B2B SaaS") as the reason, and the line naming `/saas-settings`
3. The save question offers only `Save them` / `Don't save`; no rigor question
   is asked
4. After `Save them`, `modes.rigor: standard` is written with the stage
5. Phase 6 prints the existing-work path at `standard`, including
   `/saas-design-system retrofit`, `/saas-architecture-decision retrofit` and
   `/saas-architecture-review`

**Assertions:**
- [ ] No tiered path is printed before the rigor is known
- [ ] No rigor question is asked; the card names `/saas-settings` as the way to change it
- [ ] The written rigor is the inferred `standard`
- [ ] None of the six rigor-fronted knobs is written; the file holds one `modes:` block

---

### Case 7: Existing `modes:` Block — rigor and automation go into it, never a second one

**Fixture:**
- `project.yaml` has `stack.name: Next.js` and an existing block `modes:` with
  only `review_mode: lean` under it; `modes.rigor` and `modes.automation` are
  unset (runs without the Fixture Defaults block, since it tests how the keys
  are added)
- No `design/product-brief.md` and no concept, so this is not a returning user
- The user picks `A) No idea yet`, `Save them`, then `Guided`

**Input:** `/saas-start`

**Expected behavior:**
1. `set-stage.sh Concept` adds the `project:` block to the existing file
2. `config-set.sh modes.rigor minimal` and `config-set.sh modes.automation guided`
   add both keys under the existing `modes:` block
3. `review_mode: lean` is left as the user had it

**Assertions:**
- [ ] The finished `project.yaml` has exactly one `modes:` key, holding `review_mode`, `rigor` and `automation`
- [ ] The existing `review_mode: lean` is unchanged and `/saas-start` writes none of the other rigor-fronted knobs
- [ ] There is one save question for the stage and rigor, and the automation pick needs no further ask

---

### Case 8: Path D at `minimal` With No Brief — names where the brief comes from

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `modes.rigor: minimal` and
  `modes.automation: collaborative`
- `src/` holds 14 TypeScript files; `design/prd/` holds 2 system PRDs; no
  `docs/architecture/`; no `design/product-brief.md` and no
  `design/prd/product-concept.md`
- The user picks `D) Existing work` and `Save them`

**Input:** `/saas-start`

**Expected behavior:**
1. Phase 1 finds the stack set but no concept or brief, so the A–D question is asked
2. Phase 3 D names `/saas-project-stage-detect` as the immediate step
3. The card shows `Systems Design` and rigor `minimal` as already set; Phase 5 asks nothing
4. Phase 6 prints the existing-work path at `minimal`: `/saas-project-stage-detect`,
   `/saas-adopt`, then the brief's source, with no PRD, ADR or registry retrofit
5. With no brief and 10 or more source files, the brief's source is
   `/saas-reverse-document design src/`; `/saas-brainstorm` is not offered as the source

**Assertions:**
- [ ] The minimal path lists `/saas-project-stage-detect` and `/saas-adopt`, and no `/saas-design-system retrofit`, `/saas-architecture-decision retrofit` or `/saas-architecture-review`
- [ ] With no `design/product-brief.md`, the path names `/saas-reverse-document design src/` as the brief's source, with the code root filled in
- [ ] `/saas-brainstorm` is not named as the brief's source
- [ ] Variant — `src/` holds only 4 source files: the brief's source is `/saas-brainstorm`, and `/saas-reverse-document` is not named
- [ ] Variant — `design/product-brief.md` exists: this is the returning-user skip

---

## Protocol Compliance

- [ ] Reads the project with `project-state.sh` before the first question, without printing it
- [ ] Asks the starting-point question with options A–D; leaves the stack to `/saas-setup-stack`
- [ ] Never writes any of the six rigor-fronted knobs (`modes.review_mode`, `modes.workflow`, `docs.density`, `qa.level`, `modes.story_granularity`, `team.size`) or `production/review-mode.txt`
- [ ] Shows the stage and rigor on a card and writes them only on an explicit yes; asks no rigor question
- [ ] Skips the automation question when the key is set
- [ ] Writes through `set-stage.sh` and `config-set.sh`, never by editing YAML by hand
- [ ] Prints the existing-work path only in Phase 6, after the rigor is known
- [ ] Never starts the next skill; a completed run (not the returning-user skip, which ends at its `/saas-help` pointer) ends with "Type `[skill]` to begin." and Verdict COMPLETE

---

## Coverage Notes

- Path C (clear concept, `Formalize it first` vs `Jump straight in`) is not
  separately tested.
- The `standard` and `full` paths for a new product follow Case 1 with the longer
  pipeline; not separately tested.
- The edge cases "picks D but project is empty" / "picks A but code exists" are
  not separately tested.
- `Don't save` (nothing written, the values kept for the run and reported as not
  saved, and no automation write) is not separately tested.
