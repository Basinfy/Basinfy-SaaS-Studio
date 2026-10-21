# Skill Test Spec: /saas-prototype

## Skill Summary

`/saas-prototype [concept] [--path html|stack|paper] [--review full|lean|solo]
[--spike]` runs a throwaway concept prototype before PRDs are written. It first
confirms intent with `AskUserQuestion` (Prototype this concept / Skip — concept
already proven / Mid-production spike), forms a falsifiable hypothesis ("If the
user [does X], they will feel [Y] — we will know this is true if [Z]") and asks
for the riskiest assumption. It picks an HTML, Stack or Spec Walkthrough path (architecture table,
recommendation pre-stated), presents a 3–5 bullet plan, asks to record it as a
checkpoint in `production/session-state/active.md`, then asks "May I create the prototype
directory at `prototypes/[concept-name]-concept/` and begin implementation?".
Every prototype file starts with a `PROTOTYPE - NOT FOR PRODUCTION` header in
that file's own comment syntax (`#` in TypeScript and Python, `//` in C#, C++ and
JavaScript, `<!-- -->` in HTML and Markdown), and standards are intentionally
relaxed.

After a one-question-at-a-time debrief, it fills
`.claude/docs/templates/saas-prototype-report.md`, asks to write
`prototypes/[concept-name]-concept/REPORT.md` and add its row to
`prototypes/index.md` (one ask naming both). Verdicts are **PROCEED / PIVOT / KILL**. PIVOT writes a
`PIVOT-NOTE.md`; KILL runs a five-item soundness check and appends to
`prototypes/GRAVEYARD.md`. In `full` review mode `product-director` reviews the
result via **PD-USABILITY-REVIEW** and answers APPROVE / CONCERNS / REJECT: APPROVE keeps
the recommendation; CONCERNS go to the user, who decides (Revise / Accept /
Discuss); REJECT means a PROCEED cannot stand — the user chooses PIVOT or KILL,
and REPORT.md records the director's reason. A NOT ASSESSED answer (the director
lacked an input) is never an approval. `--spike` replaces the
whole flow with a ~4-hour spike that asks before creating its folder, asks
before writing `SPIKE-NOTE.md` and clearing the spike from `active.md`, and has
no CD gate and no PROCEED/PIVOT/KILL.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PROCEED, PIVOT, KILL, NOT ASSESSED (a prototype nobody has played)
- [ ] Contains "May I create" / "May I write" language before creating the prototype directory and the report
- [ ] Has a next-step handoff per verdict (PROCEED → `/saas-design-review`, `/saas-gate-check`, `/saas-map-features`, `/saas-design-system`; PIVOT → `/saas-prototype` or `/saas-brainstorm`; KILL → `/saas-brainstorm`)

---

## Director Gate Checks

- **Full mode**: PD-USABILITY-REVIEW — `product-director` receives the REPORT.md
  content, the hypothesis and the pillars (from `design/prd/product-concept.md`, or
  the pitch and "what they feel" line from `design/product-brief.md`) and returns
  APPROVE / CONCERNS / REJECT, or NOT ASSESSED when it lacked an input.
  APPROVE → the recommendation stands; CONCERNS → shown with the recommendation,
  and the user decides (Revise / Accept / Discuss); REJECT → a PROCEED cannot
  stand: the user chooses PIVOT or KILL, and REPORT.md records the director's
  reason; NOT ASSESSED → never an approval: the missing input is named, and the
  gate is re-run or the review recorded as NOT ASSESSED. If neither document
  exists: "PD-USABILITY-REVIEW skipped — product pillars not yet defined at concept
  prototype stage."
- **Lean mode**: skipped — "PD-USABILITY-REVIEW skipped — Lean mode."
- **Solo mode**: skipped — "PD-USABILITY-REVIEW skipped — Solo mode."
- **Spike mode**: no CD gate and no phase gate, in any review mode.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Engine Prototype, PROCEED

**Fixture:**
- `design/prd/product-concept.md` describes a 2D platformer; `project.yaml` has
  `stack.name: Next.js` and `stack.language: TypeScript`
- `prototypes/` has no `grapple-hook-concept/`
- Review mode: `solo`; `modes.workflow: standard` (pinned: unset resolves to
  minimal, which routes PROCEED to `/saas-create-stories` and `/saas-dev-story` instead of
  the step 7 list — Case 6 covers that route)
- In the debrief the user reports the hypothesis CONFIRMED and answers PROCEED

**Input:** `/saas-prototype grapple-hook traversal`

**Expected behavior:**
1. `AskUserQuestion` confirms intent; user picks "Prototype this concept"
2. Skill states a falsifiable hypothesis in the If / feel / know-if form and asks
   for the riskiest assumption
3. Path widget pre-states an Engine recommendation (traversal feel is the
   hypothesis)
4. Plan is presented and confirmed, with the ask naming
   `production/session-state/active.md`; the checkpoint is written there
5. Skill asks "May I create the prototype directory at
   `prototypes/grapple-hook-concept/` and begin implementation?"; every TypeScript
   file it writes starts with `# PROTOTYPE - NOT FOR PRODUCTION` (TypeScript
   comments use `#`; a `//` header would not parse)
6. Debrief questions are asked one at a time; report drafted from
   `.claude/docs/templates/saas-prototype-report.md`; "May I write this report to
   `prototypes/grapple-hook-concept/REPORT.md` and add its row to
   `prototypes/index.md`?"; a row is appended to `prototypes/index.md`
7. Note "PD-USABILITY-REVIEW skipped — Solo mode."; PROCEED routes to `/saas-design-review`,
   `/saas-gate-check`, `/saas-design-tokens`, `/saas-map-features`, `/saas-design-system`, `/saas-review-all-prds`

**Assertions:**
- [ ] The hypothesis is falsifiable, with a measurable signal
- [ ] Engine is recommended in the path prompt before the user chooses
- [ ] The directory ask names `prototypes/grapple-hook-concept/` and comes before any prototype file is written
- [ ] Every prototype script carries the `PROTOTYPE - NOT FOR PRODUCTION` header as a `#` comment, never `//`; no file is written under the code root
- [ ] REPORT.md is written only after its ask, that ask also names `prototypes/index.md`, and the index gains a row with verdict PROCEED
- [ ] PROCEED next steps include `/saas-map-features` and `/saas-design-system`

---

### Case 2: PIVOT — Carry-Forward Note Written

**Fixture:**
- A spec walkthrough prototype of `billing-tiers` has just been debriefed
- User answers PIVOT: the tier matrix was clear, the usage add-on calculation was not
- Review mode: `solo`

**Input:** `/saas-prototype billing-tiers --path paper`

**Expected behavior:**
1. Spec Walkthrough path writes `prototypes/billing-tiers-concept/spec.md` and
   `interaction-log.md` after the directory ask
2. REPORT.md is written after its ask with verdict PIVOT
3. Skill asks, one at a time: "What specifically worked in this prototype that
   we should preserve…?" and "What is the single most important thing to change?"
4. Skill asks "May I write this to `prototypes/billing-tiers-concept/PIVOT-NOTE.md`?"
5. The note holds the original hypothesis, what to keep, what to change and the
   revised hypothesis; next steps are `/saas-prototype [revised-concept]` or
   `/saas-brainstorm [hint]`

**Assertions:**
- [ ] `--path paper` is honoured and produces `spec.md` and `interaction-log.md`
- [ ] The two carry-forward questions are asked separately
- [ ] "May I write" names `PIVOT-NOTE.md` before it is written
- [ ] The note contains a revised hypothesis
- [ ] Next steps offer `/saas-prototype` for the revised concept or `/saas-brainstorm`

---

### Case 3: KILL — Soundness Check and Graveyard Entry

**Fixture:**
- An HTML prototype of `realtime-presence` has been debriefed
- User answers KILL; the debrief shows testers never understood the core
  action after 2 usability tests, no engaging moment was observed, and the concept only
  worked when the developer explained it

**Input:** `/saas-prototype realtime-presence --path html`

**Expected behavior:**
1. REPORT.md is written after its ask with verdict KILL
2. Skill runs the five-item KILL checklist; 3 items apply, so the verdict is sound
3. Skill asks "May I append this concept to `prototypes/GRAVEYARD.md`?"
4. The entry has Kill reason, What worked, What failed and Next time, with a
   specific kill reason (not "it was boring")
5. Next step: `/saas-brainstorm open` or `/saas-brainstorm [new-hint]`

**Assertions:**
- [ ] The KILL checklist is applied, with the 2+ rule deciding soundness
- [ ] "May I append" names `prototypes/GRAVEYARD.md` before writing
- [ ] The graveyard entry has all four fields and a specific kill reason
- [ ] Next steps route to `/saas-brainstorm`

---

### Case 4: Spike Mode — No Debrief, No Gate, No PROCEED/PIVOT/KILL

**Fixture:**
- Project is in Production
- Review mode: `full`; `modes.workflow: standard` (pinned: unset resolves to minimal,
  whose spike note and `active.md` wording Case 7 covers)
- `production/sprints/sprint-004.md` is the current sprint and `active.md` shows it

**Input:** `/saas-prototype streaming-csv-parser --spike`

**Expected behavior:**
1. Skill skips Phases 1–9 and runs Spike Mode
2. Asks for the spike question in plain text: "Can we [do X] using [approach Y]?"
3. Path widget as in Phase 3; scope limited to 2–3 bullets; ~4-hour cap
4. Asks "May I create `prototypes/streaming-csv-parser-spike-[date]/` and build the
   spike there?" before writing any spike file
5. Asks "Did the spike answer the question? YES or NO, and why in one sentence."
6. Asks once, naming both files, "May I write
   `prototypes/streaming-csv-parser-spike-[date]/SPIKE-NOTE.md` and clear the spike from
   `production/session-state/active.md`?"; then writes the note (question, result
   YES / NO / PARTIAL, what to do next) and updates `active.md`
7. The note's "what to do next" offers: add to the current sprint / investigate
   further / abandon the idea. `active.md` is cleared back to the current sprint state

**Assertions:**
- [ ] The intent widget and hypothesis/debrief phases are skipped
- [ ] The spike folder is created only after its ask
- [ ] `SPIKE-NOTE.md` and `active.md` are written only after an ask that names both
- [ ] Output is `SPIKE-NOTE.md` in a `-spike-[date]` folder, not a REPORT.md
- [ ] No PD-USABILITY-REVIEW spawn or skip note, even though review mode is `full`
- [ ] No PROCEED / PIVOT / KILL verdict is issued
- [ ] At `standard`, the note's next-step options say "add to current sprint", and `active.md` returns to the current sprint state

---

### Case 5: Director Gate — PD-USABILITY-REVIEW by Review Mode and Pillars

**Fixture:**
- A concept prototype has been built and REPORT.md written with a PROCEED
  recommendation
- Run A: `--review full`, `design/prd/product-concept.md` exists with pillars;
  `product-director` returns REJECT — the core value proposition is not present; the user,
  asked PIVOT or KILL, picks PIVOT
- Run B: `--review full`, neither `product-concept.md` nor `design/product-brief.md` exists
- Run C: `--review lean`

**Input:** `/saas-prototype [concept] --review [mode]`

**Expected behavior:**
1. Run A: `product-director` is spawned for PD-USABILITY-REVIEW with the REPORT.md
   content, hypothesis and pillars. Its REJECT means the PROCEED recommendation
   cannot stand: the skill asks the user to choose PIVOT or KILL (it does not pick
   for them), the user picks PIVOT, and after an ask naming REPORT.md and
   `prototypes/index.md` the report records the director's verdict and reason and
   the final PIVOT recommendation; Phase 9 then runs the PIVOT route
2. Run B: no spawn; note "PD-USABILITY-REVIEW skipped — product pillars not yet defined at
   concept prototype stage."
3. Run C: no spawn; note "PD-USABILITY-REVIEW skipped — Lean mode."

**Assertions:**
- [ ] Run A spawns `product-director` for PD-USABILITY-REVIEW after REPORT.md is written
- [ ] Run A: the director's verdict is read as one of APPROVE / CONCERNS / REJECT, not as a PROCEED / PIVOT / KILL of its own
- [ ] Run A: after the REJECT, PROCEED is not kept; the user is asked to choose PIVOT or KILL
- [ ] Run A's final recommendation is the user's PIVOT, and REPORT.md records it with the director's reason
- [ ] Run B skips with the "product pillars not yet defined" note instead of spawning without pillars
- [ ] Run C skips with the Lean-mode note
- [ ] No other director gate is spawned

---

### Case 6: NOT ASSESSED (Unevaluated) and the `workflow: minimal` PROCEED Route

**Fixture:**
- Run A: the prototype was built this session but nobody has evaluated it yet
- Run B: a PROCEED recommendation, `project.yaml` has `modes.workflow: minimal`

**Input:** `/saas-prototype [concept]`

**Expected behavior:**
1. Run A: with no user test evidence yet, PROCEED/PIVOT/KILL are all unreachable; the
   skill reports NOT ASSESSED and stops rather than guessing, naming "evaluate it,
   then run `/saas-prototype [same concept]` again" as the next step
2. Run B: Phase 9's PROCEED route offers `/saas-create-stories` (from the brief) then
   `/saas-dev-story` on the first story, not the PRD/`/saas-map-features`/`/saas-design-tokens` path

**Assertions:**
- [ ] Run A's verdict is NOT ASSESSED, not a guessed PROCEED/PIVOT/KILL
- [ ] Run A's report and `prototypes/index.md` row both read NOT ASSESSED until a usability test happens
- [ ] Run B's recommended path is the `workflow: minimal` route (`/saas-create-stories`, `/saas-dev-story`), not the `standard`/`full` PRD pipeline

---

### Case 7: Spike Mode at `workflow: minimal` — the build order, not a sprint

**Fixture:**
- `project.yaml`: `modes.workflow: minimal` (pinned: this case tests the `minimal`
  wording, the opposite of Case 4); review mode `full`
- No `production/sprints/` directory. `design/product-brief.md` lists a build order; the
  story in progress is `production/epics/core/story-002.md` (`Status: In Progress`),
  and `production/session-state/active.md` names it as the current task
- The user answers YES to the spike question

**Input:** `/saas-prototype streaming-csv-parser --spike`

**Expected behavior:**
1. The spike runs as in Case 4, with the same asks: the spike folder, then one ask
   naming `SPIKE-NOTE.md` and `active.md`
2. `SPIKE-NOTE.md` holds the question tested, the result (YES / NO / PARTIAL) and
   what to do next: add the workflow to the brief's build order / investigate
   further / abandon the idea. It does not offer "add to current sprint"
3. `active.md` is updated to clear the spike and return to the story in progress
   (story-002), not to a sprint state
4. No CD gate and no PROCEED / PIVOT / KILL

**Assertions:**
- [ ] The note's next-step options name the brief's build order instead of the current sprint
- [ ] After the write, `active.md` names story-002 as the current task and no sprint
- [ ] The spike folder and the note-and-`active.md` write each follow an ask that names the files
- [ ] No sprint file is created or referenced
- [ ] No PD-USABILITY-REVIEW spawn or skip note and no PROCEED / PIVOT / KILL verdict is issued

---

## Protocol Compliance

- [ ] Confirms intent with `AskUserQuestion` before building (unless `--spike`)
- [ ] Forms a falsifiable hypothesis and stops if the concept is too vague to form one
- [ ] Presents the plan and gets confirmation before building
- [ ] Asks before creating `prototypes/[concept-name]-concept/` and before writing REPORT.md (with its `prototypes/index.md` row), PIVOT-NOTE.md or GRAVEYARD.md
- [ ] In spike mode, asks before creating the spike folder and before writing `SPIKE-NOTE.md` and `active.md`
- [ ] Keeps prototype files under `prototypes/`, each with the `PROTOTYPE - NOT FOR PRODUCTION` header in its own comment syntax
- [ ] Applies the review mode before PD-USABILITY-REVIEW and prints the skip note when skipped
- [ ] Ends with the per-verdict next steps

---

## Coverage Notes

- "Skip — concept already proven" (records the evidence, suggests `/saas-map-features`
  or `/saas-design-system`, and stops) is not tested.
- A concept too vague to form a hypothesis (skill stops and asks the user to
  narrow it) is covered only by protocol compliance.
- Reading a prior `PIVOT-NOTE.md` on the next run to seed the revised hypothesis
  is not tested.
- The stack-path multi-turn fix loop and the 2-hour sunk-cost rule need a live
  run to verify.
- PD-USABILITY-REVIEW APPROVE (the recommendation stands), CONCERNS (the user decides:
  Revise / Accept / Discuss), REJECT on a PIVOT or KILL recommendation (it
  stands) and NOT ASSESSED (never an approval) are not separately tested.
