---
name: saas-architecture-review
description: "Traceability matrix mapping PRD requirements to ADRs. Finds gaps, cross-ADR conflicts, stack compatibility. PASS/CONCERNS/NOT ASSESSED/FAIL."
argument-hint: "[focus: full | coverage | consistency | engine | rtm | single-prd path/to/prd.md]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-architecture-review/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/review-receipts.sh check *), Bash(bash .claude/scripts/review-receipts.sh hash *), Bash(bash .claude/scripts/adr-dep-graph.sh*), Bash(bash .claude/scripts/registry.sh validate*)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation,workflow`

# Architecture Review

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

The architecture review validates that the complete body of architectural decisions
covers all product design requirements, is internally consistent, and correctly targets
the project's pinned engine version. It is the quality gate between Technical Setup
and Pre-Production.

**Argument modes:**
- **No argument / `full`**: Full review — all phases
- **`coverage`**: Traceability only — which PRD requirements have no ADR
- **`consistency`**: Cross-ADR conflict detection only
- **`engine`**: Stack compatibility audit only
- **`single-prd [path]`**: Review architecture coverage for one specific PRD
- **`rtm`**: Requirements Traceability Matrix — extends the standard matrix
  to include story file paths and test file paths; outputs
  `docs/architecture/requirements-traceability.md` with the full
  PRD requirement → ADR → Story → Test chain. Use in Production phase when
  stories and tests exist.

---

Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`workflow`** (see `.claude/docs/workflow-modes.md`):
- `full` — full traceability matrix across all PRDs and all ADRs.
- `standard` — reduced scope: architecture doc + critical ADRs only.
- `minimal` — not applicable (no architecture doc required).

## Phase 1: Load Everything

**Read `references/1-load.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 2: Extract Technical Requirements from Every PRD

**Read `references/2-extract-requirements.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 3: Build the Traceability Matrix

**Read `references/3-traceability.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 4: Cross-ADR Conflict Detection

**Read `references/4-conflicts.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 5: Engine Compatibility Cross-Check

**Read `references/5-engine.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 6: Architecture Document Coverage

**Read `references/6-document-coverage.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 7: Output the Review Report

**Read `references/7-report.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 8: Write and Update Traceability Index

**Read `references/8-write.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Phase 9: Handoff

**Read `references/9-handoff.md` now and follow it** — this phase's steps are in that file, not here. Read it again if the conversation was compacted or resumed during this phase.

## Error Recovery Protocol

**First, verify the artifact.** If the return contract named a path, check the
path exists before treating the phase as done — **a named artifact that is not
on disk is a failed phase, however fluent the response reads.** An agent can
burn a full phase and return a plausible preamble having written nothing, which
is neither BLOCKED nor an error nor "fails to complete", so the trigger below
never fires. Resume it naming the unmet contract; the context is
usually still there.

If any spawned agent returns BLOCKED, errors, or fails to complete: **surface it
immediately, don't proceed past a dependency it blocks, and always produce a
partial report** (retry scope here = fewer PRDs / single-system). Full procedure:
`.claude/docs/error-recovery-protocol.md`.

---

## Collaborative Protocol

**Applies in `collaborative` mode (the default).** For `guided` and
`autonomous` modes, see `.claude/docs/automation-modes.md` — the rules below
describe what collaborative mode requires, not universal behavior.

1. **Read silently** — do not narrate every file read
2. **Show the matrix** — present the full traceability matrix before any write
   approval; let the user see the state
3. **Don't guess** — if a requirement is ambiguous, ask: "Is [X] a technical
   requirement or a design preference?"
4. **Draft before approval** — always show the content that will be written (the
   report, the updated ADR section, the systems-index row) inline in the conversation
   before requesting approval. Never ask to write something the user has not yet seen.
5. **Use `AskUserQuestion` for write approvals** — plain text "May I?" is not
   sufficient. Use the structured tool with labeled options [A]/[B]/[C] so the
   user can choose between "write now", "show full draft first", and "not yet".
   Multi-file changesets must list every file and what changes, then ask once
   with grouped options — not a separate plain-text question per file.
6. **Non-blocking** — the verdict is advisory; the user decides whether to continue
   despite CONCERNS or even FAIL findings
