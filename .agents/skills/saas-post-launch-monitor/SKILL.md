---
name: saas-post-launch-monitor
description: "Day-one launch patch — focused fix for known issues found after GA production release. Mini-sprint with QA gate and rollback."
argument-hint: "[scope: known-bugs | cert-feedback | all]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion
model: sonnet
---

# Day-One Patch

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Every shipped product has a post-launch monitoring. Planning it before launch day prevents
chaos. This skill scopes the patch to only what is safe and necessary, gates it
through a lightweight QA pass, and ensures a rollback plan exists before anything
ships. It is a mini-sprint — not a hotfix, not a full sprint.

**When to run:**
- After the GA production release is deployed (production tagged or launch candidate released)
- When known bugs exist that are too risky to address before the GA release
- When cert feedback requires minor fixes post-submission
- When a pre-launch usability test surfaces must-fix issues after the release gate passed

**Post-launch monitoring scope rules:**
- Only P1/P2 bugs that are SAFE to fix quickly
- No new features — this is fix-only
- No refactoring — minimum viable change
- Any fix that requires more than 4 hours of dev time belongs in patch 1.1, not day-one

**Output:** `production/releases/saas-post-launch-monitor-[version].md`

---

## Phase 1: Load Release Context

Read:
- `project.stage` in `project.yaml` (fallback `production/stage.txt`) — confirm project is in Release stage
- The most recent file in `production/gate-checks/` — read the release gate verdict
- `production/qa/bugs/*.md` — load all bugs with Status: Open or Fixed — Pending Verification
- `production/sprints/` most recent — understand what shipped
- `production/security/saas-security-audit-*.md` most recent — check for any open security items

If the resolved stage (project.yaml → stage.txt) is not `Release` or `Polish`:
> "Post-launch monitoring prep is for Release-stage projects. Current stage: [stage]. This skill is not appropriate until you are approaching launch."

**Check the premise, do not assume it.** This whole skill rests on there being a
GA release that already passed a release gate — that premise is what justifies
its lightweight QA pass instead of a full one. So verify it rather than inferring
it from the stage value:

- **No file in `production/gate-checks/`**, or none recording a release-gate
  verdict: report `Release gate: NOT ASSESSED — no gate-check record found`. Do
  not proceed silently. Say plainly that the reduced QA scope below is justified
  by a gate nobody can find, and ask whether to run `/saas-gate-check` first or
  proceed with a full QA pass instead.
- **The most recent record is FAIL, CONCERNS or NOT ASSESSED**: name it and stop.
  A post-launch monitoring on top of a build that never passed its gate is not a day-one
  patch; it is the release gate, arriving late and scoped to the wrong changes.
- `project.stage: Release` on its own does **not** establish this. The stage is a
  claim about where the project is; the gate record is the evidence that it earned
  the position.

---

## Phase 2: Scope the Patch

### Step 2a — Classify open bugs for patch inclusion

For each open bug, evaluate:

| Criterion | Include in day-one? |
|-----------|-------------------|
| S1 or S2 severity | Yes — must include if safe to fix |
| P1 priority | Yes |
| Fix estimated < 4 hours | Yes |
| Fix requires architecture change | No — defer to 1.1 |
| Fix introduces new code paths | No — too risky |
| Fix is data/config only (no code change) | Yes — very low risk |
| Cert feedback requirement | Yes — required for platform approval |
| S3/S4 severity | Only if trivial config fix; otherwise defer |

### Step 2b — Present patch scope to user

Use `AskUserQuestion`:
- Prompt: "Based on open bugs and cert feedback, here is the proposed post-launch monitoring scope. Does this look right?"
- Show: table of included bugs (ID, severity, description, estimated effort)
- Show: table of deferred bugs (ID, severity, reason deferred)
- Options: `[A] Approve this scope` / `[B] Adjust — I want to add or remove items` / `[C] No post-launch monitoring needed`

If [C]: output "No post-launch monitoring required. Proceed to `/saas-launch-checklist`." Stop.

### Step 2c — Check total scope

Sum estimated effort. If total exceeds 1 day of work:
> "⚠️ Patch scope is [N hours] — this exceeds a safe day-one window. Consider deferring lower-priority items to patch 1.1. A bloated post-launch monitoring introduces more risk than it removes."

Use `AskUserQuestion` to confirm proceeding or reduce scope.

---

## Phase 3: Rollback Plan

Before any code is written, define the rollback procedure. This is non-negotiable.

Spawn `release-manager` via `Agent`. Ask them to produce a rollback plan covering:
- How to revert to the previous stable production release build on each target platform
- Platform-specific rollback constraints (some platforms cannot roll back cert builds)
- Who is responsible for triggering the rollback
- What user communication is required if a rollback occurs

Present the rollback plan. Ask: "May I write this rollback plan to `production/releases/rollback-plan-[version].md`?"

Do not proceed to Phase 4 until the rollback plan is written.

---

## Phase 4: Implement Fixes

For each code fix in the approved scope, spawn a focused implementation loop:

1. Spawn `lead-engineer` via `Agent` with:
   - The bug report (exact reproduction steps and root cause if known)
   - The constraint: minimum viable fix only, no cleanup
   - The affected files (from bug report Technical Context section)

   It returns, for each bug, the minimal fix and the files it would change —
   writing nothing.

2. Ask once, for the whole set: "May I apply these fixes? [BUG-ID → files, one
   line each]". No code changes before this approval.

3. On yes, hand each approved fix back to `lead-engineer` (a new `Agent` call
   carrying its plan) to implement it and run targeted tests with `commands.test`
   from `project.yaml`, narrowed to the affected suite where the runner allows —
   never a runner line written from memory. If `commands.test` is unset, say so
   and record `Tests: NOT RUN — commands.test unset` for that bug.

4. Spawn `qa-manual-tester` via `Agent` to verify: does the bug reproduce after the fix?

For config/data-only fixes: make the change directly (no programmer agent needed). First ask, naming the file and the change: "May I edit `[config file]` — `[key]`: [old value] → [new value]?" Confirm the value changed and re-run any relevant smoke test.

---

## Phase 5: Patch QA Gate

This is a lightweight QA pass — not a full `/saas-team-qa`. The patch is already QA-approved from the release gate; we are only re-verifying the changed areas.

Spawn `qa-lead` via `Agent` with:
- List of all changed files
- List of bugs fixed (with verification status from Phase 4)
- The smoke check scope for the affected systems

Ask qa-lead to determine: **Is a targeted smoke check sufficient, or do any fixes touch systems that require a broader regression?**

Run the required QA scope:
- **Targeted smoke check** — run `/saas-smoke-check` (it takes no system argument)
- **Broader regression** — run the affected systems' tests in the engine's test root (`tests/unit/` and `tests/integration/` Next.js, `Assets/Tests/` FastAPI, `Source/<Module>/Private/Tests/` Cloudflare — `.claude/docs/directory-structure.md`) with `commands.test` from `project.yaml`, narrowed to the affected suites where the runner allows — never a runner line written from memory. If `commands.test` is unset, the broader regression is NOT ASSESSED; say so.

QA verdict must be PASS or PASS WITH WARNINGS before proceeding. If FAIL: scope the failing fix out of the post-launch monitoring and defer to 1.1.

**If the QA verdict is `NOT ASSESSED`, that is not a pass.** `/saas-smoke-check` returns
it when the suite never ran — no build, no runner, or a result nobody confirmed.
Do not proceed on it and do not re-read it as PASS WITH WARNINGS: the warnings
value means somebody looked and saw something minor, and this means nobody looked.
Either obtain the result (the verdict names what would make it runnable) or defer
the fix to 1.1. A post-launch monitoring ships to every user who buys the application on day
one, which is the worst possible audience for an unverified change.

---

## Phase 6: Generate Patch Record

```markdown
# Day-One Patch: [Product Name] v[version]

**Date prepared**: [date]
**Target release**: [launch date or "day of launch"]
**Base build**: [GA production release tag or commit]
**Patch build**: [patch tag or commit]

---

## Patch Notes (Internal)

### Bugs Fixed
| BUG-ID | Severity | Description | Fix summary |
|--------|----------|-------------|-------------|
| BUG-NNNN | S[1-4] | [description] | [one-line fix] |

### Deferred to 1.1
| BUG-ID | Severity | Description | Reason deferred |
|--------|----------|-------------|-----------------|
| BUG-NNNN | S[1-4] | [description] | [reason] |

---

## QA Sign-Off

**QA scope**: [Targeted smoke / Broader regression]
**Verdict**: [PASS / PASS WITH WARNINGS / NOT ASSESSED]
**QA lead**: qa-lead agent
**Date**: [date]
**Warnings (if any)**: [list or "None"]
**Not assessed (if any)**: [what could not be checked, and why — or "None"]

---

## Rollback Plan

See: `production/releases/rollback-plan-[version].md`

**Trigger condition**: If [N] or more S1 bugs are reported within [X] hours of launch, execute rollback.
**Rollback owner**: [user / delivery-producer]

---

## Approvals Required Before Deploy

- [ ] lead-engineer: all fixes reviewed
- [ ] qa-lead: QA gate PASS confirmed
- [ ] delivery-producer: deployment timing approved
- [ ] release-manager: platform submission confirmed

---

## User-Facing Patch Notes

[Draft for customer-success-ops to review before publishing]

[list user-facing changes in plain language]
```

Ask: "May I write this patch record to `production/releases/saas-post-launch-monitor-[version].md`?"

---

## Phase 7: Next Steps

After the patch record is written:

1. Run `/saas-patch-notes` to generate the user-facing version of the patch notes
2. Run `/saas-bug-report verify [BUG-ID]` for each fixed bug after the patch is live
3. Run `/saas-bug-report close [BUG-ID]` for each verified fix
4. Schedule a post-launch review 48–72 hours after launch using `/saas-retrospective [milestone-name]` for the launch milestone in `production/milestones/`

**If any S1 bugs remain open after the patch:**
> "⚠️ S1 bugs remain open and were not patched. These are accepted risks. Document them in the rollback plan trigger conditions — if they occur at scale, rollback may be preferable to a follow-up patch."

Use `AskUserQuestion`:
- Prompt: "Post-launch monitoring complete. What's next?"
- Options:
  - `[A] Run /saas-patch-notes — generate user-facing patch notes`
  - `[B] Run /saas-bug-report to log any issues found post-deploy`
  - `[C] Stop here`

---

## Collaborative Protocol

- **Scope discipline is everything** — resist scope creep; every addition increases risk
- **Rollback plan first, always** — a patch without a rollback plan is irresponsible
- **Deferred is not forgotten** — every deferred bug is listed in the record's
  "Deferred to 1.1" table; run `/saas-bug-triage` afterwards to schedule them into the 1.1 sprint
  (if the project has no sprint plan, as on the default minimal workflow, into the brief's build order)
- **User communication is part of the patch** — `/saas-patch-notes` is a required output, not optional
