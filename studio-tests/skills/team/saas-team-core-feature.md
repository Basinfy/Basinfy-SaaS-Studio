# Skill Test Spec: /saas-team-core-feature

## Skill Summary

Orchestrates the core feature engineering team through a multi-step delivery pipeline:
feature specification (lead-product-manager) → architecture & schema notes (backend-engineer)
→ UI state & component hierarchy (frontend-engineer) → optional AI pipeline integration (ai-engineer)
→ integration & E2E validation (qa-tester). Reads relevant PRDs and database schemas before spawning agents.
Verdict is COMPLETE when the core feature is designed, implemented, and validated.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE
- [ ] Spawns lead-product-manager, backend-engineer, frontend-engineer, or qa-tester

---

## Scenarios

### Scenario 1: Valid Core Feature Build
- Input: `/saas-team-core-feature Automated document extraction and AI summarization pipeline`
- Expected: Orchestrates PRD spec, database schema migration, backend API route, frontend UI view, and test validation. Verdict COMPLETE.
