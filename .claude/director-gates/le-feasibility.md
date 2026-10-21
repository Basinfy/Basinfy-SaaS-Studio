> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# LE-FEASIBILITY — Engineering Technical Feasibility Sign-Off

Agent: `lead-engineer` | Model tier: session (inherit) | Domain: Implementation complexity, library maturity, third-party API limits, tech debt risk

**Trigger**: During story breakdown, epic planning, or architecture technical spikes

**Context to pass**:
- Proposed feature specification or story description
- Tech stack and versions from `project.yaml`
- Third-party API documentation and rate limits (Stripe, Supabase, OAuth providers)

**Prompt**:
> "Assess the technical feasibility, engineering complexity, and delivery risk of the proposed implementation. Can this feature be implemented reliably within the pinned tech stack without esoteric hacks? Do third-party APIs support required throughput, webhooks, and failure modes? What technical risks or maintenance burdens does this approach introduce? Return FEASIBLE (ready for implementation), RISKY [viable but carries specific technical debt or complexity], or BLOCKED [infeasible without upstream architectural changes]."

**Verdicts**: FEASIBLE / RISKY / BLOCKED
