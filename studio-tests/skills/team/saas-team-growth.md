# Skill Test Spec: /saas-team-growth

## Skill Summary

Orchestrates the growth & acquisition team through a structured pipeline: growth strategy
(growth-director) → copywriting and SEO metadata in parallel (ux-content-strategist
+ growth-director) → frontend landing page / demo implementation (frontend-engineer)
→ analytics instrumentation (data-telemetry-engineer). Reads relevant PRDs, product concept,
and tracking requirements before spawning agents. Sub-agents write working artifacts to paths
the orchestrator names; the orchestrator compiles the growth deliverable and writes it
only after asking via `AskUserQuestion`. Uses `AskUserQuestion` at each step transition.
Verdict is COMPLETE when the growth feature is produced, BLOCKED when an unresolved dependency
stops the pipeline.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE, BLOCKED
- [ ] Spawns growth-director, ux-content-strategist, growth-director, frontend-engineer, or data-telemetry-engineer

---

## Scenarios

### Scenario 1: Valid Growth Initiative
- Input: `/saas-team-growth Landing page redesign with interactive product demo`
- Expected: Orchestrates strategy, copy, SEO metadata, frontend implementation, and analytics instrumentation. Verdict COMPLETE.
