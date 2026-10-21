> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-ARCHITECTURE-REVIEW — Technical Director System Architecture Blueprint Review

Agent: `technical-director` | Model tier: session (inherit) | Domain: System architecture, C4 modeling, multi-tenancy, data modeling, API boundaries

**Trigger**: After architecture blueprint is drafted (`/saas-create-architecture`, `/saas-architecture-review`)

**Context to pass**:
- System architecture document (`docs/architecture/system-architecture.md`)
- PRD feature index and data modeling requirements
- Security and performance budgets from `project.yaml`

**Prompt**:
> "Evaluate the complete SaaS system architecture for scalability, modularity, security, and operational viability. Are architectural layers (Client, API, Domain Services, Database) cleanly decoupled? Is tenant data strictly isolated at the database level (Postgres Row Level Security or schema-per-tenant)? Are asynchronous background jobs (Stripe webhooks, email queues, report exports) designed with idempotency? Are performance budgets (LCP, API latency p95) achievable with this architecture? Return SOUND (architecture is robust, scalable, and production-ready) or FLAWED [architectural gaps, bottlenecks, or security risks]."

**Verdicts**: SOUND / FLAWED
