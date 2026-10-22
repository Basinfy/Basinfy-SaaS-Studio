---
name: saas-project-stage-detect
description: "Analyze project state, detect stage, identify gaps, recommend next steps. 'Where are we in development?'"
argument-hint: "[optional: role filter like 'programmer' or 'designer']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/saas-project-stage-detect/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/artifact-check.sh), Bash(bash ".claude/scripts/artifact-check.sh"), Bash(bash ./.claude/scripts/artifact-check.sh), Bash(bash .claude/scripts/artifact-check.sh *), Bash(bash ".claude/scripts/artifact-check.sh" *), Bash(bash ./.claude/scripts/artifact-check.sh *)
model: haiku
# Read-only diagnostic skill — no specialist agent delegation needed
---
# Project Stage Detection

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

This skill scans your project to determine its current development stage, completeness
of artifacts, and gaps that need attention. It's especially useful when:
- Starting with an existing project
- Onboarding to a codebase
- Checking what's missing before a milestone
- Understanding "where are we?"

---

## Workflow

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,workflow,automation`

**Automation mode**: Resolve `modes.automation` (`project.local.yaml` →
`project.yaml` → default `collaborative`). Every `AskUserQuestion` call and
every file write follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

Resolved above — use as-is. No block → defaults in
`.claude/docs/config-resolution.md`.

> **Resolve the tier — do not assume it.** The tier decides what counts as a gap
> at all: at `full` every missing doc is one; at `minimal` none of them are,
> because a brief plus an engine is the normal state and code is the expected
> next step. Guessing high tells a jam project it is missing PRDs, design tokens
> and ADRs — the exact "process feels mismatched to my project" experience
> `modes.rigor` exists to prevent.

**`workflow`** (per `.claude/docs/workflow-modes.md`). The tier governs
which absent documents count as gaps (step 3) — below `full`, optional docs are
not flagged.

### 1. Scan Key Directories

**Start with the deterministic pass — it answers "what exists" for every
catalogued artifact in one call:**

```
Bash: bash .claude/scripts/artifact-check.sh
```

Run it exactly as written — from the project root, relative path, no
arguments, no `cd`, no `2>&1`. This skill's permission grant matches that form;
any other asks the user to approve it.

With no `--phase` it reports every phase, so a single call covers the whole
project: per step, `PRESENT` / `ABSENT` / `SHORT` (with `count=` and `min=`) /
`PATTERN_MISS` / `NO_CHECK`. Use it instead of hand-globbing each artifact
below, and treat its `NO_CHECK` total as the honest bound on what existence
checks can tell you.

It reports observations only — this skill still decides what stage those
observations imply, and the tier still governs which absences are gaps at all
(see the workflow-tier note below).

Then analyze what the script cannot: content quality, counts it does not
track, and the judgement calls.

**Design Documentation** (`design/`):
- Count PRD files in `design/prd/*.md`
- Check for product-concept.md (or `design/product-brief.md` at `minimal`), product-pillars.md, features-modules-index.md
- If features-modules-index.md exists, count total systems vs. designed systems
- Analyze completeness (Overview, Detailed Design, Edge Cases, etc.). Read PRDs
  by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit.
- Count content & copy docs in `design/content/`
- Count UX specs in `design/ux/`

**Source Code** (the code root — `src/` Next.js, `Assets/` FastAPI, `Source/` Cloudflare; resolve per `.claude/docs/code-root-resolution.md`):
- Count source files (language-agnostic)
- Identify major systems (directories with 5+ files)
- Check for core/, core business workflow/, ai/, networking/, ui/ directories
- Estimate lines of code (rough scale)
- An unresolved root means none of these ran: report
  `NOT ASSESSED — code root unresolved`, never zero source files — zero files
  reads as a greenfield project, and the source-file rows of the stage table
  cannot be decided without the count

**Production Artifacts** (`production/`):
- Check for active sprint plans. At `workflow: minimal` there are no sprints:
  read the story files' progress through the brief's build order instead, and
  never report a missing sprint plan, milestone or roadmap as a gap
- Look for milestone definitions
- Find roadmap documents

**Prototypes** (`prototypes/`):
- Count prototype directories
- Check for READMEs (documented vs undocumented)
- Assess if prototypes are archived or active

**Architecture Docs** (`docs/architecture/`):
- Count ADRs (Architecture Decision Records)
- Check for overview/index documents

**Tests** (`tests/`):
- Count test files
- Estimate test coverage (rough heuristic)

### 2. Classify Project Stage

Based on scanned artifacts, determine stage. Check `project.stage` in `project.yaml` first (if present); else `production/stage.txt` (legacy fallback) — either is an explicit override from `/saas-gate-check`. Otherwise, auto-detect using these heuristics (check from most-advanced backward):

> **Always run the heuristics, even when a stage is configured — then COMPARE.**
> The configured value is authoritative for what the stage *is*; it is not
> evidence that the artifacts support it. Report both, and when they disagree say
> so explicitly:
>
> > "Configured stage: **Release**. Observed artifacts indicate
> > **Pre-Production** (2 source files, 0 ADRs, no architecture doc, no epics).
> > These disagree — the configured stage may be stale, or work exists outside
> > this repo."
>
> Reading config and reporting it back is not detection. This skill's own
> description promises "analyze project state, detect stage", and a stage
> detector that cannot contradict its input is the one thing it must never be —
> it would report `Release` for a project whose artifacts match its own
> Pre-Production row, four stages below, and say nothing.
>
> **A disagreement makes Stage Confidence CONCERNS** (step 4) — ambiguous
> signals by definition — however complete the artifacts are. One exception: at
> `workflow: minimal` nothing runs `/saas-gate-check`, so the configured stage stays
> where `/saas-start` set it. There, report the observed stage and say the configured
> one is not advanced at this tier; that lag is expected, not a disagreement.

| Stage | Indicators |
|-------|-----------|
| **Concept** | No product concept doc, brainstorming phase |
| **Systems Design** | Product concept exists, systems index missing or incomplete |
| **Technical Setup** | Systems index exists, engine not configured |
| **Pre-Production** | Engine configured, code root has <10 source files |
| **Production** | code root has 10+ source files, active development |
| **Polish** | Explicit only (set by `/saas-gate-check` Production → Polish gate) |
| **Release** | Explicit only (set by `/saas-gate-check` Polish → Release gate) |

### 3. Collaborative Gap Identification

**Surface gaps per the resolved workflow tier:**
- **`full`** — flag every missing doc type (PRDs, design tokens, UX specs, ADRs) as a gap.
- **`standard`** — flag only required docs: missing PRDs for built systems and
  missing critical (Foundation-layer) ADRs. Do NOT flag an absent design tokens unless
  visual-asset stories exist, and do NOT flag non-core UX specs.
- **`minimal`** — a `design/product-brief.md` + engine present is the normal state. Do NOT flag
  absent PRDs, design tokens, UX specs, ADRs, epics or sprint plans as gaps: the brief's build
  order is the plan, and the expected next step is code.

**DO NOT** just list missing files. Instead, **ask clarifying questions** (only
for gaps the tier above says to surface):

- "I see billing code (`<code root>/core business workflow/billing/`) but no `design/prd/billing-system.md`. Was this prototyped first, or should we reverse-document?"
- "You have 15 ADRs but no architecture overview. Should I create one to help new contributors?"
- (`standard`/`full` only) "I see [N] systems under `<code root>/` but no ADRs in `docs/architecture/`. Were those decisions recorded somewhere else, or should we write the critical ones with `/saas-architecture-decision`?"
- (`standard`/`full` only) "No sprint plans in `production/`. Are you tracking work elsewhere (Jira, Trello, etc.)?"
- "I found a product concept but no systems index. Have you decomposed the concept into individual systems yet, or should we run `/saas-map-features`?"
- "Prototypes directory has 3 projects with no READMEs. Were these experiments, or do they need documentation?"

### 4. Generate Stage Report

Use template: `.claude/docs/templates/project-stage-report.md`

**Report structure**:
```markdown
# Project Stage Analysis

**Date**: [date]
**Stage**: [Concept/Systems Design/Technical Setup/Pre-Production/Production/Polish/Release]
**Stage Confidence**: [PASS — clearly detected / CONCERNS — ambiguous signals / NOT ASSESSED — a check the stage depends on did not run / FAIL — critical gaps block progress]

## Completeness Overview
- Design: [X%] ([N] docs, [gaps])
- Code: [X%] ([N] files, [systems])
- Architecture: [X%] ([N] ADRs, [gaps])
- Production: [X%] ([status] — at `minimal`: stories complete in the brief's build order, never "no sprint plan")
- Tests: [X%] ([coverage estimate])

## Gaps Identified
1. [Gap description + clarifying question]
2. [Gap description + clarifying question]

## Recommended Next Steps
[Priority-ordered list based on stage and role]
```

**Stage Confidence — first match wins:** **FAIL** if critical gaps block
progress; else **CONCERNS** if the signals that were gathered are ambiguous —
they fit more than one stage, or the configured and observed stages disagree
(step 2); else **NOT ASSESSED** if a check the stage depends on did not run —
name it (an unresolved code root, two candidate roots included, leaves the
source-file count, and so the table's Production row, undecided); else
**PASS**. NOT ASSESSED outranks PASS — a stage nobody could check is not a
clearly detected one — and ranks below CONCERNS and FAIL, so a known problem is
never buried behind it.

### 5. Role-Filtered Recommendations (Optional)

If user provided a role argument (e.g., `/saas-project-stage-detect programmer`):

**Programmer**:
- Focus on architecture docs, test coverage, missing ADRs
- Code-to-docs gaps

**Designer**:
- Focus on PRD completeness, missing design sections
- Prototype documentation

**Producer**:
- Focus on sprint plans, milestone tracking, roadmap
- Cross-team coordination docs

**General** (no role):
- Holistic view of all gaps
- Highest-priority items across domains

### 6. Request Approval Before Writing

**Collaborative protocol**:
```
I've analyzed your project. Here's what I found:

[Show summary]

Gaps identified:
1. [Gap 1 + question]
2. [Gap 2 + question]

Recommended next steps:
- [Priority 1]
- [Priority 2]
- [Priority 3]

May I write the full stage analysis to production/project-stage-report.md?
```

Wait for user approval before creating the file.

---

## Example Usage

```bash
# General project analysis
/saas-project-stage-detect

# Programmer-focused analysis
/saas-project-stage-detect programmer

# Designer-focused analysis
/saas-project-stage-detect designer
```

---

## Follow-Up Actions

After generating the report, suggest relevant next steps — **only for gaps the
resolved workflow tier surfaces** (step 3). At `standard`/`minimal`, do not
suggest authoring optional docs (e.g. don't suggest `/saas-reverse-document` for an
absent PRD at `minimal`, where code is the expected next step):

- **No `design/product-brief.md` at `minimal`?** → `/saas-reverse-document design <code root>`
  when the code root already holds the application (10 or more source files): it writes
  the brief from what is built. With little or no code, `/saas-brainstorm`.
- **Concept exists but no systems index?** → `/saas-map-features` to decompose into systems
- **Missing design docs?** → `/saas-reverse-document design <code root>/[system]`
- **Missing architecture docs?** → `/saas-architecture-decision` or `/saas-reverse-document architecture`
- **Prototypes need documentation?** → `/saas-reverse-document concept prototypes/[name]`
- **No sprint plan?** → `/saas-sprint-plan` (not at `rigor: minimal`, where the brief's build order is the plan)
- **Approaching milestone?** → `/saas-milestone-review`

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Question First**: Ask about gaps, don't assume
2. **Present Options**: "Should I create X, or is it tracked elsewhere?"
3. **User Decides**: Wait for direction
4. **Show Draft**: Display report summary
5. **Get Approval**: "May I write to production/project-stage-report.md?"

**Never** silently write files. **Always** show findings and ask before creating artifacts.
