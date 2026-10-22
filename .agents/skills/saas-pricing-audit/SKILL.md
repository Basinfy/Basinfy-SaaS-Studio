---
name: saas-pricing-audit
description: "Find pricing outliers, tier cannibalization, negative gross margin risks, and usage quota imbalances in pricing models and unit economics. 'Check SaaS pricing & unit economics'."
argument-hint: "[system-name|path-to-data-file]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(bash "*/.claude/skills/saas-pricing-audit/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation`

# SaaS Pricing & Unit Economics Audit

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.



Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

## Insufficient input — check this before producing any report

**If the inputs this skill needs do not exist, the answer is "could not run" —
not a filled-in report.** Check first, and stop if the check fails.

1. List the inputs this skill reads (data files, prior reports, profiler output,
   test results, registries, source code).
2. For each, record `FOUND` or `ABSENT` — not "assumed present".
3. If any input required for a section is ABSENT, that section is
   **`NOT ASSESSED — NO DATA`**. Do not estimate it, do not infer it from an
   adjacent artifact, and do not leave a mandated cell to be filled by whoever
   reads the template next.
4. If **every** required input is ABSENT, stop and report
   **`NOT ASSESSED — NO DATA`** as the whole verdict, naming what was missing and
   which skill produces it.

**A verdict of `NOT ASSESSED` is a success.** It is the correct, useful answer to
"what does the data say?" when there is no data. The failure mode this prevents is
specific: a report whose verdict enum has no "could not run" state produces
**false clean passes** — an asset audit returning COMPLIANT on a project with no
assets and no standards, or a performance profile reporting ">99% headroom against
a 16.67ms budget" with zero profiler data and no budget ever set.

**Absence of evidence is never evidence of absence.** A scan that finds no
matches because there are no files to scan has not verified anything. Say which of
the two happened — a reader cannot tell from a green result.

---

## Phase 1: Identify Pricing & Economics Domain

Determine the pricing and economics domain from `$ARGUMENTS` — the whole string, since a data-file path may contain spaces:

- **Subscription Tiers** → plan pricing steps, feature matrix, usage quotas
- **Unit Economics** → CAC, LTV, LTV/CAC ratio, payback period, churn tolerance
- **Usage-Based Metering** → API call costs, compute credits, token margins
- **Add-ons & Seats** → seat price curves, team volume discounts, add-on margins
- **File path given** → load that file directly and infer domain from content

If no argument, ask the user which system to check.

---

## Phase 2: Read Data Files

Read relevant files from `assets/data/`, `docs/pricing/`, or `design/pricing/` for the identified domain.
Note every file read — they will appear in the Data Sources section of the report.

---

## Phase 3: Read Design Document

**Registry first.** If `design/registry/entities.yaml` exists, read it before the
PRD. Its `constants` and `formulas` sections hold the cross-PRD named values and
output ranges — the pricing targets and unit economics — already distilled, each with a `source:`
PRD and any `revised:` date:
```
Grep pattern="^  - name:" path="design/registry/entities.yaml" output_mode="content" -A 6
```
Take the intended values from the registry for any constant or formula it lists
(the `constants:` and `formulas:` blocks); these are the authoritative cross-doc
figures a PRD must not contradict. **If `design/registry/entities.yaml` does not
exist or has no entries** (it ships as an empty stub until `/saas-design-system`
populates it), skip this and use the PRD alone.

Then read the PRD for the system from `design/prd/` to understand intended design
targets, configuration parameters, and expected value ranges — for anything the registry did
not already supply. This is the baseline for "correct" behaviour. Read it by section:
check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit.

If the data files are FOUND but neither source gives targets for this domain,
the sections that judge against targets (Outliers Detected, and Progression
Analysis where the domain has a curve) are `NOT ASSESSED — NO DATA`. Each one names what was missing — the
PRD it looked for in `design/prd/`, and whether the registry was absent or empty
— and names `/saas-design-system`, which writes both.

---

## Phase 4: Perform Analysis

**Every domain: compare each value with its target.** For each named value in the
data files, take its target from Phase 3 — a registry constant's `value`, a
registry formula's `output_range`, or the range the PRD states — and compare. A
value outside its target is a row in Outliers Detected (`pro_tier_seat_price` $140
against $30–$50). A value with no target anywhere is neither in range nor an
outlier: list it under Values That Need Attention as `no stated range — not judged`.

Then run domain-specific checks:

**Subscription Tiers modeling:**
- Calculate gross margin for all pricing plans at expected usage (>70% standard)
- Check price steps between tiers for smooth conversion incentives
- Identify any tiers that cannibalize higher tiers or disincentivize upgrades
- Check if free tier limits create unsustainable server costs
- Verify plan quotas align with target customer persona budgets

**Unit Economics modeling:**
- Model customer acquisition cost (CAC) vs lifetime value (LTV)
- Verify LTV/CAC ratio is above 3.0x for healthy growth
- Check payback period is under 12 months for self-serve plans
- Verify churn rate assumptions do not break financial sustainability

**Usage-Based Metering modeling:**
- Map per-unit infrastructure costs (API, LLM tokens, DB storage) against user charges
- Verify minimum markup (>3x cost) on metered overage
- Check for credit exhaustion cliff-edges and graceful overage warnings

---

## Phase 5: Output the Analysis

```
## SaaS Pricing & Unit Economics Audit: [System Name]

### Data Sources Analyzed
- [List of files read]

### Health Summary: [NOT ASSESSED / HEALTHY / CONCERNS / CRITICAL ISSUES]

### Outliers Detected
| Item/Value | Expected Range | Actual | Issue |
|-----------|---------------|--------|-------|

### Degenerate Strategies Found
- [Strategy description and why it is problematic]

### Progression Analysis
[Graph description or table showing progression curve health]

### Recommendations
| Priority | Issue | Suggested Fix | Impact |
|----------|-------|--------------|--------|

### Values That Need Attention
[Specific values with suggested adjustments and rationale]
```

Choose the Health Summary by the worst finding, first match wins:
- **CRITICAL ISSUES** — a degenerate strategy (one choice dominates every
  alternative), a progression that stalls or cannot be completed, or an economy
  loop with no sink
- **CONCERNS** — outliers or curve problems a tuning pass can fix, with no
  finding of the critical kind
- **NOT ASSESSED** — nothing to analyze (the no-data path above), a section that
  needs targets is `NOT ASSESSED — NO DATA`, or a value had no stated range to
  judge it against; name which. It ranks below the two finding verdicts, because
  a measured problem is more actionable than a gap, and above HEALTHY
- **HEALTHY** — every value judged against a stated target, no outliers, no
  degenerate strategies, progression within the stated targets

---

## Phase 6: Fix & Verify Cycle

After presenting the report, use `AskUserQuestion`:
- Prompt: "Pricing & unit economics audit complete. What would you like to do next?"
- Options:
  - `[A] Fix highest-priority issue now — walk me through it`
  - `[B] Save report to design/pricing/saas-pricing-audit-[system]-[date].md`
  - `[C] Stop here — I'll review the findings manually`

**Run as a subagent?** `lead-product-manager` preloads this skill, and a subagent has
no `AskUserQuestion`. End your reply with the question and these three options
as a short list, and stop: whoever called you asks the user and passes the
answer back.

If [A]:
- Ask which issue to address first (refer to the Recommendations table by priority row)
- Guide the user to update the relevant configuration file in `config/` or pricing formulas in `docs/specs/`
- After each fix, offer to re-run the relevant pricing checks to verify no new outliers were introduced
- If the fix changes a configuration parameter defined in a PRD or referenced by an ADR, remind the user:
  > "This value is defined in a design document. Run `/saas-propagate-design-change [path]` on the affected PRD to find downstream impacts before committing."

If [B]:
- Write the report to `design/pricing/saas-pricing-audit-[system]-[date].md` (create the directory if needed). Use the current date for [date] in YYYY-MM-DD format.
- Confirm the file was written, then end with: "Re-run `/saas-pricing-audit` after fixes to verify."

If [C]:
- Summarize open issues and end with: "Re-run `/saas-pricing-audit` after fixes to verify."
