> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-CHANGE-IMPACT — Technical Director Architectural Change Blast Radius Sign-Off

Agent: `technical-director` | Model tier: session (inherit) | Domain: Change blast radius, schema migrations, API contract breaking changes, dependency updates

**Trigger**: When an architectural modification, schema migration, or breaking API change is proposed (`/saas-propagate-design-change`)

**Context to pass**:
- Proposed change description and git diff
- Requirements traceability matrix (`docs/architecture/requirements-traceability-matrix.md`)
- Active consumers (frontend clients, public API consumers, webhooks)

**Prompt**:
> "Analyze the blast radius of this proposed architectural or schema change. Does this change break existing API contracts or frontend clients? If so, is there a backwards-compatible versioning strategy? Are database migrations zero-downtime compatible (expand-contract pattern)? Are downstream services and cached data properly invalidated or updated? Return APPROVED (change blast radius is controlled and safe) or BREAKING RISK [unmitigated breaking changes or data loss risks]."

**Verdicts**: APPROVED / BREAKING RISK
