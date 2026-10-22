# /saas-review-all-prds — Phase 5: Output the Review Report

> Part of `/saas-review-all-prds`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Output the Review Report

**In this file:**

- The report template
- `NOT ASSESSED` and where it ranks

```
## Cross-PRD Review Report
Date: [date]
PRDs Reviewed: [N] of [M] present
Not read: [each PRD that could not be read or is present but empty, by file name — or "none"]
Focus: [full / consistency only — design theory not run / design theory only — consistency not run]
Systems Covered: [list]

---

### Consistency Issues

#### Blocking (must resolve before architecture begins)
🔴 [Issue title]
[What PRDs are involved, what the contradiction is, what needs to change]

#### Warnings (should resolve, but won't block)
⚠️  [Issue title]
[What PRDs are involved, what the concern is]

---

### Product Design Issues

#### Blocking
🔴 [Issue title]
[What the problem is, which PRDs are involved, design recommendation]

#### Warnings
⚠️  [Issue title]
[What the concern is, which PRDs are affected, recommendation]

---

### Cross-System Scenario Issues

Scenarios walked: [N]
[List scenario names]

#### Blockers
🔴 [Scenario name] — [Systems involved]
[Step where failure occurs, nature of the failure mode, what must be resolved]

#### Warnings
⚠️  [Scenario name] — [Systems involved]
[What the unintended outcome is, recommendation]

#### Info
ℹ️  [Scenario name] — [Systems involved]
[Minor ordering ambiguity or note]

---

### PRDs Flagged for Revision

| PRD | Reason | Type | Priority |
|-----|--------|------|----------|
| [system-a].md | Rule contradiction with [system-b].md | Consistency | Blocking |
| [system-b].md | Rule contradiction with [system-a].md | Consistency | Blocking |
| [system-c].md | Stale reference to nonexistent workflow | Consistency | Blocking |
| [system-d].md | No pillar alignment | Design Theory | Warning |

---

### Verdict: [PASS / NOT ASSESSED / CONCERNS / FAIL]

PASS: No blocking issues and no warnings.
NOT ASSESSED: One or more review phases could not run — named below.
CONCERNS: Warnings present that should be resolved, but nothing blocking.
FAIL: One or more blocking issues must be resolved before architecture begins.

### If NOT ASSESSED — what could not be reviewed, and why:
[Name each phase that did not run and the input it needed, and each PRD that could not be read or is present but empty, by file name]

### If FAIL — required actions before re-running:
[Specific list of what must change in which PRD]
```

**`NOT ASSESSED` — a cross-review is only as wide as what it could read.** Rank:
**above PASS**, **below CONCERNS and FAIL**. This skill's whole value is
comparing systems *against each other*, so it is unusually easy for it to look
thorough while covering a fraction of the surface. Emit it when any of:

- **Fewer than two PRDs were readable.** Contradiction-hunting across one document
  is not a cross-review; a clean result there means only that nothing was
  compared. This is the single most important trigger in this skill.
- **A whole review phase did not run** — consistency, design theory, economy,
  pillar drift — when it should have. A pass the focus argument left out is not
  this trigger: the user asked for it. Give the verdict for the pass that ran,
  labelled — `PASS (consistency only — design theory not run)` — and fill the
  `Focus:` line. A parallel phase that returned nothing has to be distinguished
  from one that returned no findings; if a spawned agent produced no report, that
  phase is NOT ASSESSED, not clean — an agent can return a fluent sentence,
  write nothing, and consume a phase.
- **The design pillars are undefined**, so pillar-drift has no reference to drift
  from — the same shape as an accessibility gate with no committed tier.
- **A PRD is present but empty** (headings only, or all placeholders), **or
  could not be read**. Present is not the same as reviewable, and a stub
  contradicts nothing.

Report the covered set explicitly either way: `PRDs reviewed: [N] of [M] present`
(`[M]` counts the system PRDs present — the Phase 1c set, not `product-concept.md`,
`product-pillars.md`, `features-modules-index.md` or an earlier `prd-cross-review-*.md`),
and the `Not read:` line naming every PRD that could not be read or is present but empty, whatever the
verdict — a FAIL found in the PRDs that were read does not make the unread ones
reviewed.
A cross-review that silently skipped half the systems is indistinguishable from
one that found them consistent.

---
