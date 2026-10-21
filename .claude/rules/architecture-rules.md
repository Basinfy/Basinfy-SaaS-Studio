---
paths:
  - "docs/architecture/**"
---

# Architecture & ADR Rules

1. **Architecture Decision Records (ADRs)** are immutable once Accepted. Any change requires a new ADR superseding the previous one.
2. System architecture must define C4 context and container diagrams, explicit layer boundaries, and API contracts.
3. Every requirement from PRDs must trace to an ADR or architecture component.
4. System design blueprints must include explicit OpenAPI / REST endpoint tables, TypeScript data structures, and Mermaid Sequence Diagrams tracing primary user workflows and billing webhook reconciliation.
