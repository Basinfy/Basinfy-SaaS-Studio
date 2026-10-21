> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-FEATURE-COHERENCE — Cross-Module Feature Coherence Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: System-wide feature interactions, permission rules, billing tiers, workflow integrity

**Trigger**: When multiple feature modules interact or before major release milestone

**Context to pass**:
- Feature modules index (`docs/specs/features-modules-index.md`)
- Multi-tenancy spec (`docs/specs/multi-tenancy-spec.md`)
- Pricing and quota model (`docs/specs/saas-pricing-model.md`, `usage-limits-quota-model.md`)

**Prompt**:
> "Review feature module interactions across the SaaS platform for business logic coherence. Do permission tiers (RBAC) apply consistently across all modules without privilege escalation gaps? Are billing quotas and usage limits enforced predictably across features without dead ends? Are there conflicting assumptions between modules (e.g., auth session lifetime vs background export jobs)? Return COHERENT (features interact logically and consistently) or CONFLICTS [contradictory business logic or permission gaps]."

**Verdicts**: COHERENT / CONFLICTS
