# Skill Test Spec: /saas-usability-test

## Skill Summary

`/saas-usability-test` has two modes. `new` outputs a blank usability test report template
and stops with Verdict COMPLETE, saving nothing;
`analyze [path]` reads raw notes from a file, cross-references the design
documents, fills the template with structured findings and flags observations
that conflict with design intent. Defects (crashes, latency spikes) go in the
Bugs Encountered table, not under Core Business Workflow Flow → Pain points. The template has these sections: Session Info,
Test Focus, First Impressions, Core Business Workflow Flow (what worked, pain points,
confusion, delight), Bugs Encountered, Feature-Specific Feedback, Quantitative
Data, Overall Assessment, and Top 3 Priorities.

Findings are sorted into four buckets and routed: design changes to
`/saas-propagate-design-change [path]`, balance adjustments to `/saas-pricing-audit
[system]`, bugs to `/saas-bug-report`, polish items to the `production/` backlog. In
`full` review mode the skill spawns `product-director` for gate **PD-USABILITY-REVIEW**;
in `lean` and `solo` it skips the gate with a note. It then asks "May I write
this usability test report to `production/qa/usability tests/usability test-[date]-[tester].md`?".
Verdict is **COMPLETE**.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains "May I write" collaborative protocol language before writing the report
- [ ] Has a next-step handoff (`/saas-design-review` after design changes, `/saas-bug-triage` after bug fixes)

---

## Director Gate Checks

- **Full mode**: PD-USABILITY-REVIEW — `product-director` reviews the report against the
  product pillars and core value proposition (APPROVE / CONCERNS / REJECT, or NOT ASSESSED
  when it lacked an input), after findings are categorised and before the report
  is saved
- **Lean mode**: PD-USABILITY-REVIEW skipped (not a PHASE-GATE); note
  "PD-USABILITY-REVIEW skipped — Lean mode."
- **Solo mode**: PD-USABILITY-REVIEW skipped; note "PD-USABILITY-REVIEW skipped — Solo mode."

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Analyze Notes, Findings Routed by Bucket

**Fixture:**
- `production/qa/notes/session-01.md` holds one tester's notes: "latency
  spikes every time the analytics dashboard loads", "I could not work out how to
  invite team members in onboarding step 2", and "the billing checkout form validation is confusing"
- `design/prd/` holds the onboarding and core workflow PRDs; the onboarding PRD says
  step 2 teaches the invite member flow
- Review mode: `solo`

**Input:** `/saas-usability-test analyze production/qa/notes/session-01.md`

**Expected behavior:**
1. Skill reads the notes and cross-references the design documents
2. Skill fills the template; the latency spike goes in the Bugs Encountered table
3. Phase 3 presents findings in four buckets: the team invite confusion as a design
   change, the form validation as a UX adjustment, the latency spike as a bug
4. Routing: `/saas-propagate-design-change` on the onboarding PRD, `/saas-pricing-audit` for
   core workflow, `/saas-bug-report` for the latency spike
5. Skill notes "PD-USABILITY-REVIEW skipped — Solo mode." and asks "May I write this
   usability test report to `production/qa/usability tests/usability test-[date]-[tester].md`?"
6. On approval the file is written; verdict is COMPLETE

**Assertions:**
- [ ] The latency spike appears in the Bugs Encountered table, not under Core Business Workflow Flow
- [ ] Findings are presented in the four buckets (design, balance, bug, polish)
- [ ] Each bucket is routed to its named skill (`/saas-propagate-design-change`, `/saas-pricing-audit`, `/saas-bug-report`)
- [ ] "May I write" names `production/qa/usability tests/usability test-[date]-[tester].md` before writing
- [ ] Verdict is COMPLETE

---

### Case 2: New Mode — Blank Template Output

**Fixture:**
- Any project state

**Input:** `/saas-usability-test new`

**Expected behavior:**
1. Skill selects `new` mode
2. Skill outputs the blank template with every section heading and its
   bracketed placeholders unfilled
3. No notes file is read and no findings are invented
4. The mode ends after the template: no routing, no director gate, no save
   ask, and the verdict is COMPLETE — blank template output; nothing saved

**Assertions:**
- [ ] Output contains the headings Session Info, Test Focus, First Impressions, Core Business Workflow Flow, Bugs Encountered, Feature-Specific Feedback, Quantitative Data, Overall Assessment and Top 3 Priorities
- [ ] Placeholders (e.g. `[Date]`, `[Name/ID]`) are left unfilled
- [ ] No notes file is read and no findings are fabricated
- [ ] No "May I write" ask and no file written
- [ ] Verdict is COMPLETE

---

### Case 3: Observation Conflicts With Design Intent

**Fixture:**
- `design/prd/billing.md` states subscription billing is a core workflow users engage with
  every session
- `production/qa/notes/session-02.md` records that the tester never opened the
  billing modal in 40 minutes
- Review mode: `solo`

**Input:** `/saas-usability-test analyze production/qa/notes/session-02.md`

**Expected behavior:**
1. Skill reads the notes and cross-references `design/prd/billing.md`
2. Skill flags the observation as conflicting with design intent
3. Phase 3 puts it in the "Design changes needed" bucket
4. Routing names `/saas-propagate-design-change` on `design/prd/billing.md`
5. Report saved after the "May I write" ask; verdict COMPLETE

**Assertions:**
- [ ] The billing observation is explicitly flagged as conflicting with the PRD's intent
- [ ] It is categorised as a design change, not a polish item
- [ ] `/saas-propagate-design-change` is suggested on the affected PRD
- [ ] Verdict is COMPLETE after the write

---

### Case 4: Edge Case — Full Review Mode With No Pillars Available

**Fixture:**
- Review mode: `full`
- Neither `design/prd/product-concept.md` nor `design/product-brief.md` exists
- `production/qa/notes/session-03.md` holds usability test notes

**Input:** `/saas-usability-test analyze production/qa/notes/session-03.md`

**Expected behavior:**
1. Skill structures and categorises the findings
2. Skill spawns `product-director` for PD-USABILITY-REVIEW with the report content and
   the hypothesis being tested
3. Because neither pillars source exists, the prompt states "No pillars
   available — assess against the hypothesis alone." rather than omitting pillars
4. The director's assessment is presented before the save ask

**Assertions:**
- [ ] PD-USABILITY-REVIEW is spawned (review mode is `full`)
- [ ] The gate prompt says no pillars are available instead of passing none silently
- [ ] Pillars are not invented by the skill
- [ ] The assessment is shown before "May I write"

---

### Case 5: Director Gate — PD-USABILITY-REVIEW by Review Mode

**Fixture:**
- `design/prd/product-concept.md` exists with pillars
- `production/qa/notes/session-04.md` holds usability test notes
- Run three times: `--review full`, `--review lean`, `--review solo`
- In the full run, `product-director` returns CONCERNS

**Input:** `/saas-usability-test analyze production/qa/notes/session-04.md --review [mode]`

**Expected behavior:**
1. Full: after Phase 3 categorisation, `product-director` is spawned for
   PD-USABILITY-REVIEW with the report content, pillars from `product-concept.md` and the
   hypothesis; its CONCERNS assessment is presented and a
   `## Product Director Assessment` section is added to the report
2. Lean: no director spawned; note "PD-USABILITY-REVIEW skipped — Lean mode."
3. Solo: no director spawned; note "PD-USABILITY-REVIEW skipped — Solo mode."
4. All three runs then ask "May I write" and end with verdict COMPLETE

**Assertions:**
- [ ] In full mode, PD-USABILITY-REVIEW spawns `product-director` before the report is saved
- [ ] On CONCERNS, the report gains a `## Product Director Assessment` section with the verdict and feedback
- [ ] In lean mode, the skip note names PD-USABILITY-REVIEW and Lean mode
- [ ] In solo mode, the skip note names PD-USABILITY-REVIEW and Solo mode
- [ ] No other director gate is spawned in any mode

---

## Protocol Compliance

- [ ] `analyze` reads the notes file and cross-references design documents before filling the template
- [ ] Findings are categorised into design / balance / bug / polish and routed to the named follow-up
- [ ] Applies the review mode before spawning PD-USABILITY-REVIEW and prints the skip note when skipped
- [ ] Presents the director's assessment (full mode) before asking to save
- [ ] Asks "May I write this usability test report to `production/qa/usability tests/usability test-[date]-[tester].md`?" before writing
- [ ] Ends with verdict COMPLETE and next steps (`/saas-design-review`, `/saas-bug-triage`)

---

## Coverage Notes

- A REJECT verdict from PD-USABILITY-REVIEW follows the same path as CONCERNS (an
  assessment section is added) and is not separately tested; APPROVE only adds
  an approval note. NOT ASSESSED (the director lacked an input) adds the section
  naming what was missing and is never read as an approval; not separately tested.
- At `modes.workflow: minimal`, where `design/product-brief.md` replaces
  `product-concept.md`, the brief has no pillars: its one-sentence pitch and "Who
  it's for / what they feel" line are passed in their place; not separately tested.
- Video or screenshot attachments are not tested; the report is text only.
