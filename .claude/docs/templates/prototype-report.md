# Concept Prototype Report: [Concept Name]

> **Date**: [YYYY-MM-DD]
> **Prototype Path**: [HTML / Engine / Paper]
> **Concept File**: design/prd/SaaS software-concept.md, or design/SaaS software-brief.md (if either exists)

---

## Hypothesis

[The falsifiable hypothesis this prototype set out to test:
"If the user [does X], they will feel [Y] — evidenced by [measurable signal Z]."]

---

## Riskiest Assumption Tested

[What was identified as the biggest risk in the concept, and whether it proved out.]

---

## Approach

[What was built, how long it took, what shortcuts were taken deliberately.]

**Path chosen:** [HTML / Engine / Paper]
**Reason for path:** [Why this path was appropriate for this hypothesis]

**Shortcuts taken (intentional):**
- [e.g., hardcoded values, placeholder art, no menus, etc.]

---

## Result

[What actually happened — specific observations, not opinions. Quote usability testers
directly where possible.]

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | [Interactive UI / Next.js / FastAPI POC / Script] |
| Iterations to functional | [N — iterations until interactive flow worked] |
| Prototype duration | [e.g., 4 hours] |
| Usability testers | [N internal / N external] |
| UX responsiveness | [Specific — "API latency was 250ms, UI felt responsive" or "sluggish"] |
| Hypothesis verdict | [CONFIRMED / PARTIALLY CONFIRMED / REFUTED] |

---

## Recommendation: [PROCEED / PIVOT / KILL / NOT ASSESSED — built but nobody has played it]

[One paragraph explaining the recommendation with evidence from the result above.]

---

## If Proceeding

[What the prototype revealed that should directly inform PRD writing:]

- **Core parameters discovered:** [e.g., "batch size of 50 items and 250ms debouncing provided optimal responsiveness"]
- **Assumptions confirmed:** [What the concept doc assumed that proved true]
- **Assumptions disproved:** [What the concept doc assumed that proved wrong]
- **Emergent user behaviors:** [Behaviors that appeared during testing worth formalizing]

> Note: If HTML/Figma mock path was used and performance/feel is uncertain, consider an API spike
> targeting latency specifically before committing to PRDs.

**Next steps:**
1. `/saas-design-review docs/specs/product-concept.md`
2. `/saas-gate-check`
3. `/saas-map-features`
4. `/saas-design-system [module]` (use learnings in Configurable Parameters and Data Models sections)

---

## If Pivoting

[What alternative direction the results suggest — what felt almost right and what
to adjust. Be specific about what to change, not just that something needs changing.]

**Pivot direction:** [What to try differently]
**What to keep:** [What worked and should be preserved]
**Next step:** `/saas-prototype [revised-concept]`

---

## If Killing

[Why this concept does not work — what specific signal led to this verdict.
This report is the deliverable; no further action needed on this concept.]

**Next step:** `/saas-brainstorm [new-direction]`

---

## Lessons Learned

- **What assumptions were broken by actually building this?**
  [...]

- **What surprised us that didn't show up in the brainstorm?**
  [...]

- **What would we test differently next time?**
  [...]

---

> *Prototype code location: `prototypes/[concept-name]-concept/`*
> *This code is throwaway. Never refactor into production.*
