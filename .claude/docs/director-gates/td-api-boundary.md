> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-API-BOUNDARY — Technical Director API Boundary & Multi-Tenant Isolation Sign-Off

Agent: `technical-director` | Model tier: session (inherit) | Domain: API contracts, tRPC/REST schemas, multi-tenant isolation, authorization barriers

**Trigger**: When API routes or multi-tenant database access layer is designed or modified

**Context to pass**:
- API route definitions (`src/app/api/`, `src/server/`)
- Multi-tenancy spec (`docs/specs/multi-tenancy-spec.md`)
- Database RLS policies or tenant isolation middleware

**Prompt**:
> "Verify that API boundaries and tenant data isolation mechanisms are mathematically leak-proof. Does every API handler authenticate the user and authorize access strictly within the tenant context? Is tenant ID enforced server-side rather than accepted trustingly from client input? Are API payloads strictly validated with schemas preventing mass-assignment vulnerabilities? Return SOUND (boundaries are secure, isolated, and strictly enforced) or LEAKY BOUNDARIES [potential data leakage across tenants or missing authorization checks]."

**Verdicts**: SOUND / LEAKY BOUNDARIES
