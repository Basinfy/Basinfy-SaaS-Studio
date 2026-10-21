# Vertical Slice Report: [Product Name]

> **Date**: [YYYY-MM-DD]
> **Slice Duration**: [N days]
> **Target Scope**: End-to-end user journey (Signup → Onboarding → Core Value Action → Dashboard Output)
> **Source PRD**: `design/prd/product-concept.md` (or `design/product-brief.md`)

---

## Validation Question

[The end-to-end SaaS validation question this build was proving — both user experience AND technical feasibility:
"Does a user, starting from signup, experience [core value proposition] within [N] minutes,
without operator guidance — and can we build this full-stack vertical slice in [X] days at production-grade quality?"]

---

## Scope Built

[Modules implemented, UI polish level, what was intentionally stubbed or mocked.]

**Modules included:**
- Authentication & tenant workspace creation
- Core value workflow (primary input to processed output)
- Database persistence and API integration
- Dashboard view and export trigger

**UI & Code Quality Level:** [Functional prototype / Representative / Near-production]
**Deliberate shortcuts taken:** [e.g. Mock billing checkout instead of live Stripe API, in-memory cache instead of Redis cluster]
**What was omitted from this slice:** [List]

---

## Build Velocity Log

| Day | Completed Deliverable |
|---|---|
| Day 1 | Database schema migration, auth routes, and session context |
| Day 2 | Core business logic service and API endpoints |
| Day 3 | UI views, forms, and client-side validation |
| Day 4 | Integration testing and end-to-end verification |

**Total elapsed:** [N days]
**Velocity estimate:** [e.g. "1.5 days per API resource, 1 day per major UI view"]

---

## Usability & Validation Results

| Attribute | Value |
|---|---|
| Total test sessions | [N] |
| Internal testers | [N] |
| External users (target ICP) | [N — target customer profile] |
| Avg session length | [N minutes] |
| Time to first "aha moment" / value realization | [N seconds / minutes (target: < 2 min)] |
| Task completion rate | [%] |

---

## Observations & Friction Points

**Where users succeeded without guidance:**
- [...]

**Where users were confused or stuck:**
- [...]

**User feedback quotes:**
- [...]

---

## Metrics

| Metric | Target | Actual |
|---|---|---|
| Time to core value | < 2 min | [N min] |
| Critical usability blockers | 0 | [N] |
| API latency (p95) | < 300ms | [N ms] |
| Architecture / stack surprises | 0 | [N] |

---

## Recommendation: [PROCEED / PIVOT / KILL / NOT ASSESSED]

[One paragraph with empirical evidence: Did the user realize core value within target time?
Can the engineering team build this architecture on the projected schedule?]

**Product Director review (PD-USABILITY-REVIEW):** [APPROVE / CONCERNS / REJECT / NOT ASSESSED]

---

## If Proceeding

**Production requirements** (what must change from slice to production):
- Replace mock integrations with live production services (e.g. real Stripe webhook handler)
- Add complete error boundary handlers, toast notifications, and retry queues
- Enforce strict Row-Level Security (RLS) on all tenant tables

**Next steps:**
1. `/saas-create-epics layer:foundation` — plan Foundation layer epics
2. `/saas-create-epics layer:core` — plan Core workflow epics
3. `/saas-create-stories [epic-slug]` — break epics into implementable stories
4. `/saas-sprint-plan` — schedule Sprint 1 with real velocity data
5. `/saas-gate-check production` — formally advance to Production
