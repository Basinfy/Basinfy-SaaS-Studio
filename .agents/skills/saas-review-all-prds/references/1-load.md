# Phase 1: Load and Index PRDs

Gather and index all product requirement documents (`design/prd/*.md`).

### Required Context
1. `design/product-concept.md` (or `design/product-brief.md`) — product vision, core value proposition, ICP, and MVP scope.
2. All feature PRDs in `design/prd/`:
   - e.g. `auth.md`, `billing.md`, `teams-rbac.md`, `dashboard.md`, `integrations.md`, `notifications.md`.

### Indexing Steps
- Extract all requirements with traceability tags (`TR-[system]-[number]`).
- Map cross-module dependencies declared in each PRD.
- Flag any PRD missing an explicit owner, status, or acceptance criteria.
