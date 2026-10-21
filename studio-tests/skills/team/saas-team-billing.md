# Skill Test Spec: /saas-team-billing

## Skill Summary

Orchestrates the billing & subscriptions team:
pricing tier modeling (pricing-economist) → Stripe Checkout & webhook handlers (backend-engineer)
→ pricing tables and billing portal UI (frontend-engineer) → Stripe CLI webhook tests and downgrade verification (qa-tester).
Verdict is COMPLETE when billing pipeline is implemented and verified.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE
- [ ] Spawns pricing-economist, backend-engineer, frontend-engineer, or qa-tester
