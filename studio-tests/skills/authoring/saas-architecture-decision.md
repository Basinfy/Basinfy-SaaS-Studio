# Skill Test Spec: /saas-architecture-decision

## Skill Summary

`/saas-architecture-decision` authors one Architecture Decision Record (ADR). It has
three entry modes: normal authoring (`/saas-architecture-decision [title]`),
`retrofit <path>` (adds missing sections to an existing ADR without touching the
rest), and `accept <ADR-id>` (the only path that moves an ADR from `Proposed` to
`Accepted`). When retrofit asks for a missing Status and the user answers
`Accepted`, it writes `Proposed` and hands the ADR to acceptance mode.

Normal authoring loads stack context first (`docs/stack-reference/[stack]/VERSION.md`,
plus a knowledge-gap warning for MEDIUM/HIGH-risk domains), picks the next ADR
number, checks `docs/registry/architecture.yaml` for binding stances, then
presents its assumptions as a confirm/adjust `AskUserQuestion` (Status is always
`Proposed` and is never asked). It then drafts the whole ADR from its template in
one pass, has the primary stack specialist validate it (Step 5.5), runs the
TD-ADR gate in `full` review mode only (Step 5.6), runs a PRD sync check that
always reports, and asks once — "May I write it?" — before writing
`docs/architecture/adr-[NNNN]-[slug].md`. A separate approval covers the registry
update. The closing output tells the user to run `/saas-architecture-review` in a
fresh session and `/saas-architecture-decision accept ADR-NNNN` when the decision is
settled. Authoring never sets `Accepted` and never unblocks stories.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains status/verdict keywords: `Proposed`, `Accepted`, and the TD-ADR outcomes `CONCERNS` / `REJECT`
- [ ] Contains "May I write" collaborative protocol language (whole-ADR write approval and registry approval)
- [ ] Has a next-step handoff at the end (`/saas-architecture-review`, `accept ADR-NNNN`)
- [ ] Documents gate behavior: stack specialist validation, then TD-ADR in full mode; TD-ADR skipped in lean/solo with a named note
- [ ] Documents that authoring always produces `Proposed` and only acceptance mode sets `Accepted` — retrofit's `Accepted` answer is routed through it
- [ ] Mentions the stack version stamp from `docs/stack-reference/` (Engine Compatibility table)

---

## Director Gate Checks

Review mode comes from the resolved `review_mode` (`modes.review_mode` in
`project.yaml`); `--review full|lean|solo` overrides it for one run.

In `full` mode: after the draft is generated, the primary stack specialist
validates it (Step 5.5), then `technical-director` spawns with gate TD-ADR
(Step 5.6). The two run in that order, not in parallel. On CONCERNS the
concerns are shown verbatim and the user picks `Revise flagged items` /
`Accept and proceed` / `Discuss further`; on REJECT the draft is revised before
the write approval. No verdict changes the ADR's Status.

In `lean` mode: TD-ADR is skipped (it is not a PHASE-GATE). Output notes
"TD-ADR skipped — Lean mode." The stack specialist validation still runs.

In `solo` mode: TD-ADR is skipped. Output notes "TD-ADR skipped — Solo mode."
The stack specialist validation still runs.

In every mode the written ADR has `Status: Proposed`.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — New rendering ADR, full mode, TD-ADR approves

**Fixture:**
- `project.yaml` has `stack.name: Next.js` and `modes.review_mode: full`
- `docs/stack-reference/nextjs/VERSION.md` exists and marks the pinned version HIGH risk; `breaking-changes.md` lists a Rendering change
- `docs/architecture/` contains `adr-0001-*.md` and `adr-0002-*.md`; none covers rendering
- `docs/registry/architecture.yaml` exists with no stance touching rendering
- `design/prd/visual-effects.md` exists; the user confirms it as the PRD driving the decision, and its names match the ADR's Key Interfaces
- The stack specialist finds only minor notes; TD-ADR returns APPROVE

**Input:** `/saas-architecture-decision rendering-approach`

**Expected behavior:**
1. Step 1 reads `VERSION.md` first and displays the ENGINE KNOWLEDGE GAP WARNING for the Rendering domain
2. Step 2 scans `docs/architecture/` and assigns ADR-0003
3. Step 3a reads the registry before any existing ADR
4. Step 4 presents assumptions (problem, 2–3 alternatives, PRD linkage, dependencies, `Status: Proposed`) as a confirm/adjust `AskUserQuestion`; no ADR is generated until the user confirms
5. Step 5 drafts the full template, including the Engine Compatibility table (stack, domain, knowledge risk, references consulted)
6. `nextjs-specialist` validates the draft; minor notes go into the Risks section
7. `technical-director` then spawns with gate TD-ADR and returns APPROVE
8. PRD sync check prints `PRD sync: checked 1 referenced PRD(s), no naming inconsistencies.` — never silent
9. "ADR draft is complete. May I write it?" — on yes, writes `docs/architecture/adr-0003-rendering-approach.md` with `Status: Proposed`
10. Registry candidates are shown and "May I update `docs/registry/architecture.yaml` with these [N] new stances?" is asked separately
11. Closing output includes the fixed notice to run `/saas-architecture-review` in a fresh session, and "Run `/saas-architecture-decision accept ADR-0003` when the decision is settled"

**Assertions:**
- [ ] `VERSION.md` is read before any other step, and the knowledge-gap warning is shown for the HIGH-risk domain
- [ ] Assumptions are confirmed via `AskUserQuestion` before the ADR is generated; Status is shown as `Proposed`, never asked
- [ ] The stack specialist validation runs before TD-ADR (sequential, not parallel)
- [ ] One "May I write" approval covers the whole ADR; the file is `docs/architecture/adr-0003-rendering-approach.md`
- [ ] The written ADR has `Status: Proposed` even though TD-ADR returned APPROVE
- [ ] The PRD sync check reports the clean result for `visual-effects.md` in one line
- [ ] The registry update has its own approval prompt, separate from the ADR write
- [ ] Closing output contains the fresh-session `/saas-architecture-review` notice and the `accept ADR-0003` command

---

### Case 2: Failure Path — TD-ADR returns CONCERNS

**Fixture:**
- Same as Case 1, but TD-ADR returns CONCERNS: "Alternatives do not address the mobile renderer"
- One point stays unresolved after revision (which renderer to target on mobile)

**Input:** `/saas-architecture-decision rendering-approach`

**Expected behavior:**
1. TD-ADR spawns with the draft, stack version, domain and related ADRs
2. The CONCERNS are shown to the user verbatim with the standard options from `director-gates.md`: `Revise flagged items` / `Accept and proceed` / `Discuss further`
3. The user picks `Revise flagged items`; only then are the Decision or Alternatives sections revised (Step 5.6)
4. The unresolved point is presented as its own `AskUserQuestion` with options from the review plus "Different approach — I'll describe it"
5. The write approval is still asked; nothing is written before it
6. The ADR is written with `Status: Proposed`

**Assertions:**
- [ ] TD-ADR receives the ADR draft/path, stack version and domain as context
- [ ] The CONCERNS are shown verbatim and the user chooses Revise / Accept / Discuss — the draft is not revised before that choice
- [ ] Each unresolved decision is a separate `AskUserQuestion` with a free-text escape option
- [ ] The ADR is written only after the "May I write" approval, with `Status: Proposed`

---

### Case 3: Lean and Solo Modes — TD-ADR skipped; checks that cannot run say so

**Fixture:**
- Scenario (a): `project.yaml` has `modes.review_mode: lean` and `stack.name: Next.js`
- Scenario (b): same project, invoked with `--review solo`
- Scenario (c): invoked with `--review solo` on a project with no stack configured — `stack.name` unset and `.claude/docs/technical-preferences.md` still `[TO BE CONFIGURED]`; at Step 1's prompt the user carries on without running `/saas-setup-stack`
- `design/prd/` holds no PRD, so the ADR's PRD Requirements Addressed names none

**Input:** (a) `/saas-architecture-decision save-format` (b) and (c) `/saas-architecture-decision save-format --review solo`

**Expected behavior:**
1. (a) and (b): the stack specialist validation (Step 5.5) runs
2. (a) Output notes "TD-ADR skipped — Lean mode." and proceeds to the PRD sync check
3. (b) and (c): Output notes "TD-ADR skipped — Solo mode." and proceeds to the PRD sync check
4. (c) No stack specialist is spawned, and the output records `Engine validation: NOT ASSESSED — no stack configured (stack.name unset in project.yaml)`
5. The PRD sync check prints `PRD sync: NOT ASSESSED — [the ADR names no PRDs]`, not the clean one-line result
6. "May I write it?" is still asked before the file is written
7. The ADR is written with `Status: Proposed`

**Assertions:**
- [ ] `technical-director` is not spawned in lean or solo mode
- [ ] The skip note names the gate and the mode ("TD-ADR skipped — Lean mode." / "— Solo mode.")
- [ ] The `--review solo` argument overrides the resolved `review_mode` for the run
- [ ] (a) and (b): the stack specialist validation still runs
- [ ] (c) With no stack configured, the output says stack validation was NOT ASSESSED instead of passing silently
- [ ] With no PRD named, the PRD sync check reports NOT ASSESSED, not a clean result
- [ ] "May I write" is asked before the file is written, and Status is `Proposed`

---

### Case 4: Edge Case — Proposed decision contradicts a registered stance

**Fixture:**
- `docs/registry/architecture.yaml` records an interface contract: `billing_event_delivery → webhook event dispatcher (ADR-0003)`
- ADR-0003 is Accepted
- The user states the proposal when invoking the skill, before Step 1: the decision is to deliver billing events by direct method calls

**Input:** `/saas-architecture-decision billing-events-pipeline`, with that description in the same message

**Expected behavior:**
1. Step 3a reads the registry before opening any existing ADR, and presents the relevant stances as locked constraints under "Existing Architectural Stances (must not contradict)"
2. Still in Step 3a — right after the stances, before Step 4's assumptions prompt — the skill surfaces the conflict: "⚠️ Conflict: This ADR proposes [X], but ADR-0003 established that [Y]…"
3. It offers three options: (1) align with the existing stance, (2) supersede ADR-0003 with an explicit replacement, (3) explain why this case is an exception
4. It does not proceed to Step 4 until the conflict is resolved or accepted as an intentional exception
5. If the user chooses to supersede: at the registry step the old entry is set to `status: "superseded_by: ADR-[NNNN]"` (quoted) and the new entry is added — the existing entry is not otherwise modified

**Assertions:**
- [ ] The registry is read before any existing ADR file
- [ ] The conflict warning names ADR-0003 and offers exactly the three options above
- [ ] The confirm/adjust assumptions prompt (Step 4) does not appear until the conflict is resolved
- [ ] On supersede, the old registry entry is marked `superseded_by`, not edited or deleted

---

### Case 5: Acceptance Mode — Status moves to Accepted only through `accept`

**Fixture:**
- `docs/architecture/adr-0005-tenant-isolation.md` exists with `Status: Proposed`
- Scenario (a): its `## ADR Dependencies` lists `Depends On: ADR-0002`, and ADR-0002 is `Proposed`
- Scenario (b): its only dependency is ADR-0001, which is `Accepted`; three files under `production/epics/*/story-*.md` name `ADR-0005` and are Blocked — two in the header form `/saas-create-stories` writes (`> **Status**: Blocked`), one as `**Status:** Blocked`
- `modes.automation` is `autonomous`

**Input:** `/saas-architecture-decision accept ADR-0005`

**Expected behavior:**
1. The skill globs `docs/architecture/adr-0005-*.md` and reads the single match
2. (a) It refuses and names the blocker: ADR-0005 depends on ADR-0002, which is still Proposed; no file is edited
3. (b) It finds the stories to unblock before asking, then asks "Accept ADR-0005 — [title]? …" with the count ("3 stories become Ready"), options `[A] Yes — accept it` / `[B] Not yet — leave it Proposed`
4. (b) The prompt fires even though automation is `autonomous`
5. (b) On yes: edits `## Status` to `Accepted`, leaves an existing `## Date` unchanged (adding one only if absent), moves the three stories from `Blocked` to `Ready`, and reports the ADR and each story that moved

**Assertions:**
- [ ] (a) Acceptance is refused when a dependency is not `Accepted`, naming ADR-0002; nothing is written
- [ ] (b) The confirmation prompt states how many stories will become Ready
- [ ] (b) The confirmation prompt appears in `autonomous` automation mode
- [ ] (b) Status becomes `Accepted` and the three stories move to `Ready` only after the user confirms
- [ ] Stories are matched only under `production/epics/`
- [ ] (b) All three stories are found — the Blocked grep matches `> **Status**: Blocked` and `**Status:** Blocked`, not only the literal `Status: Blocked`

---

### Case 5b: Acceptance Mode — a story that names the ADR only as a successor is left out

**Fixture:**
- `docs/architecture/adr-0005-tenant-isolation.md` exists with `Status: Proposed`
  and a `## ADR Dependencies` section whose only dependency, ADR-0001, is `Accepted`
- Three stories under `production/epics/` are `> **Status**: Blocked`:
  - `story-001.md`: blocked because ADR-0005 is Proposed
  - `story-002.md`: blocked with "BLOCKED: ADR-0003 is Superseded — point the
    story at ADR-0005 (edit its ADR field …) before implementing"; ADR-0005 is
    named only as the successor of ADR-0003
  - `story-003.md`: blocked for an unrelated reason that names no ADR-0005
- The user answers `[A] Yes — accept it`

**Input:** `/saas-architecture-decision accept ADR-0005`

**Expected behavior:**
1. The dependency check passes
2. The Blocked-story grep returns all three files; only `story-001.md` names
   ADR-0005 as the reason it is blocked. `story-002.md` is left out because it
   names ADR-0005 only as the successor to point at: it is still governed by
   ADR-0003, and accepting ADR-0005 does not re-point it
3. The confirmation prompt says "1 story becomes Ready", not 2 or 3
4. On yes: `## Status` becomes `Accepted`; only `story-001.md` moves from
   `Blocked` to `Ready`; the report lists the ADR and that one story

**Assertions:**
- [ ] The stories-to-unblock count in the prompt is 1
- [ ] `story-002.md` stays `Blocked`, unedited, and is not in the report of what moved
- [ ] `story-003.md` stays `Blocked`, unedited
- [ ] `story-001.md` becomes `Ready` only after the user confirms

---

### Case 6: Retrofit — Missing Status answered `Accepted`

**Fixture:**
- `docs/architecture/adr-0004-api-routing.md` exists with Context, Decision, Consequences, Engine Compatibility and PRD Requirements Addressed, but no `## Status` and no `## ADR Dependencies`
- ADR-0001 is `Accepted`
- One file under `production/epics/*/story-*.md` names `ADR-0004` and has `> **Status**: Blocked`

**Input:** `/saas-architecture-decision retrofit docs/architecture/adr-0004-api-routing.md`

**Expected behavior:**
1. The retrofit block lists Status (BLOCKING), ADR Dependencies (HIGH) and Date (MEDIUM — the fixture has no `## Date` and no `## Last Verified`) as missing, then asks "Shall I add the 3 missing sections? I will not modify any existing content."
2. Asked for the current status, the user answers "Accepted" — the decision is already in force; asked for dependencies, the user answers "Depends On: ADR-0001"
3. The skill appends `## Status` as `Proposed`, the ADR Dependencies section and `## Date` (today, noted as the retrofit date); no existing section changes
4. It then runs acceptance mode on ADR-0004: the dependency check passes (ADR-0001 is Accepted), the blocked story is found, and "Accept ADR-0004 — [title]? …" is asked with "1 story becomes Ready"
5. On yes: `## Status` becomes `Accepted`, the `## Date` the retrofit added is kept, and the story moves from `Blocked` to `Ready`

**Assertions:**
- [ ] Only the missing sections are appended; existing sections are untouched
- [ ] The retrofit answer `Accepted` is never written straight into `## Status`; `Accepted` appears only after acceptance mode's dependency check and confirmation
- [ ] The confirmation prompt names the story count, as in Case 5
- [ ] Variant — the user declines "Shall I add the 3 missing sections?": no section is written, `## Date` included

---

## Protocol Compliance

- [ ] Engine context (`VERSION.md`) is loaded first and stamped into the Engine Compatibility table
- [ ] Assumptions are confirmed via `AskUserQuestion` before the ADR is generated
- [ ] "May I write" is asked once for the whole ADR before writing; the registry update has its own approval
- [ ] TD-ADR runs only in full mode; lean/solo print a skip note naming the gate and mode
- [ ] TD-ADR CONCERNS are shown verbatim with `Revise flagged items` / `Accept and proceed` / `Discuss further`, never revised without the user's choice
- [ ] A TD-ADR `NOT ASSESSED` answer names the missing input and is never presented as an approval
- [ ] Authoring always writes `Status: Proposed`; `Accepted` is set only by acceptance mode after its dependency check and explicit user confirmation — directly through `accept`, or when retrofit hands it an `Accepted` answer
- [ ] Engine validation and the PRD sync check each report `NOT ASSESSED` when they cannot run, never a silent pass
- [ ] Authoring does not unblock stories; it lists the stories still waiting on the ADR
- [ ] Ends with next-step handoff: `/saas-architecture-review` in a fresh session, and `/saas-architecture-decision accept ADR-NNNN`

---

## Coverage Notes

- Retrofit is fixture-tested only for a missing Status answered `Accepted`
  (Case 6); the other answers (`Proposed`, `Deprecated`, `Superseded`) and the
  retrofit of Engine Compatibility and PRD Requirements Addressed are not.
- The acceptance-mode refusals for a missing `## Status`, an absent or `UNKNOWN`
  dependency section, and an already-Accepted or Superseded ADR are not
  individually fixture-tested.
- Of the PRD sync check's three outcomes, the one-line clean result (Case 1)
  and `NOT ASSESSED` (Case 3) are tested; the warning block and its
  three-option write approval are not.
- `team.size` and `docs.density` variations are not tested.
- ADR numbering is not independently fixture-tested beyond Case 1.
