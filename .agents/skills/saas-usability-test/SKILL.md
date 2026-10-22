---
name: saas-usability-test
description: "Structured usability test report template, or turn existing usability test notes into structured feedback."
argument-hint: "[new|analyze path-to-notes] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-usability-test/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run. No
block → defaults in `.claude/docs/config-resolution.md`.

# Usability test Report

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.



## Phase 1: Parse Arguments


See `.claude/docs/director-gates.md` for the full check pattern. Individual gate definitions live in `.claude/docs/director-gates/[gate-id].md` — the spawned agent reads its own gate file; do not read it in the parent session.


Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

Determine the mode:

- `new` → generate a blank usability test report template. This mode ends after
  Phase 2A: a blank template has nothing to route, review or save.
- `analyze [path]` → read raw notes and fill in the template with structured findings
- No argument → ask via `AskUserQuestion`: `[A] New blank template` /
  `[B] Analyze notes — I'll give you the path`

---

## Phase 2A: New Template Mode

Generate this template and output it to the user:

```markdown
# Usability test Report

## Session Info
- **Date**: [Date]
- **Build**: [Version/Commit]
- **Duration**: [Time played]
- **Tester**: [Name/ID]
- **Platform**: [PC/Console/Mobile]
- **Input Method**: [Desktop Web / Mobile Responsive / Tablet]
- **Session Type**: [First time / Returning / Targeted test]

## Test Focus
[What specific features or flows were being tested]

## First Impressions (First 5 minutes)
- **Understood the goal?** [Yes/No/Partially]
- **Understood the controls?** [Yes/No/Partially]
- **Emotional response**: [Engaged/Confused/Bored/Frustrated/Excited]
- **Notes**: [Observations]

## Core Business Workflow Flow
### What worked well
- [Observation 1]

### Pain points
- [Issue 1 -- Severity: High/Medium/Low]

### Confusion points
- [Where the user was confused and why]

### Moments of delight
- [What surprised or pleased the user]

## Bugs Encountered
| # | Description | Severity | Reproducible |
|---|-------------|----------|-------------|

## Feature-Specific Feedback
### [Feature 1]
- **Understood purpose?** [Yes/No]
- **Found engaging?** [Yes/No]
- **Suggestions**: [Tester suggestions]

## Quantitative Data (if available)
- **Deaths**: [Count and locations]
- **Time per area**: [Breakdown]
- **Items used**: [What and when]
- **Features discovered vs missed**: [List]

## Overall Assessment
- **Would play again?** [Yes/No/Maybe]
- **Difficulty**: [Too Easy / Just Right / Too Hard]
- **Pacing**: [Too Slow / Good / Too Fast]
- **Session length preference**: [Shorter / Good / Longer]

## Top 3 Priorities from this session
1. [Most important finding]
2. [Second priority]
3. [Third priority]
```

In `new` mode, stop here with: Verdict: **COMPLETE** — blank template output; nothing saved.

---

## Phase 2B: Analyze Mode

Read the raw notes at the provided path. Cross-reference with existing design documents, reading each by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit. Fill in the template above with structured findings. Flag any usability test observations that conflict with design intent.

An observation that describes a defect — a crash, a latency spike, an unhandled exception,
something that plainly breaks rather than behaves poorly — goes in the **Bugs
Encountered** table, not under Core Business Workflow Flow → Pain points, and is routed as a
bug in Phase 3. Pain points are for how the application feels to use.

---

## Phase 3: Action Routing

Categorize all findings into four buckets:

- **Design changes needed** — friction points, user confusion, broken workflows, observations that conflict with the PRD's intended experience
- **Pricing / quota adjustments** — quotas or pricing limits feel wrong, tier thresholds too strict or too loose
- **Bug reports** — clear implementation defects that are reproducible
- **Polish items** — not blocking progress, but friction or feel issues for later

Present the categorized list, then route:

- **Design changes:** "Run `/saas-propagate-design-change [path]` on the affected design document to find downstream impacts before making changes."
- **Pricing / quota adjustments:** "Run `/saas-pricing-audit [system]` to verify the pricing and quota economics before adjusting tiers."
- **Bugs:** "Use `/saas-bug-report` to formally track these."
- **Polish items:** "Add to the polish backlog in `production/` when the team reaches that phase."

---

## Phase 3b: Product Director User Experience Review

**Review mode check** — apply before spawning PD-USABILITY-REVIEW:
- `solo` → skip. Note: "PD-USABILITY-REVIEW skipped — Solo mode." Proceed to Phase 4 (save the report).
- `lean` → skip (not a PHASE-GATE). Note: "PD-USABILITY-REVIEW skipped — Lean mode." Proceed to Phase 4 (save the report).
- `full` → spawn as normal.

After categorising findings, spawn `product-director` via `Agent` using gate **PD-USABILITY-REVIEW** (`.claude/director-gates/pd-usability-review.md`).

Pass: the structured report content, product pillars and core value proposition (from
`design/prd/product-concept.md`), the specific hypothesis being tested. **If
`product-concept.md` does not exist** — expected at `minimal`, where
`design/product-brief.md` replaces it — the brief has no pillars: pass its
one-sentence pitch and its "Who it's for / what they feel" line instead, and say
they stand in for pillars. If neither document exists, say so in the prompt:
*"No pillars available — assess against the hypothesis alone."* A director gate
handed silence about pillars will invent them.

Present the product director's assessment before saving the report. If CONCERNS or REJECT, add a `## Product Director Assessment` section to the report capturing the verdict and feedback. If APPROVE, note the approval in the report. If NOT ASSESSED (the director lacked an input — `.claude/docs/director-gates.md`), add the same section naming what was missing; it is not an approval.

---

## Phase 4: Save Report

Ask: "May I write this usability test report to `production/qa/usability tests/usability test-[date]-[tester].md`?"

If yes, write the file, creating the directory if needed.

---

## Phase 5: Next Steps

Verdict: **COMPLETE** — usability test report generated.

- Act on the highest-priority finding category first.
- After addressing design changes: re-run `/saas-design-review` on the updated PRD.
- After fixing bugs: re-run `/saas-bug-triage` to update priorities.
