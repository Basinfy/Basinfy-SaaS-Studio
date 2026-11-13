# Skill Test Spec: /saas-team-ui

## Skill Summary

Orchestrates the UI pipeline team through the complete frontend workflow:
UX spec authoring (ux-designer) → design token styling (design-system-director)
→ accessible component development (frontend-engineer) → WCAG accessibility validation (qa-manual-tester).
Verdict is COMPLETE when UI feature is designed, styled, implemented, and validated.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE
- [ ] Spawns ux-designer, design-system-director, frontend-engineer, or qa-manual-tester
- [ ] Uses the UX spec path from `/saas-ux-design` and the purpose-based checks from `/saas-frontend-taste`.
- [ ] Reports NEEDS REVISION for blockers and NOT ASSESSED when required verification could not run.
