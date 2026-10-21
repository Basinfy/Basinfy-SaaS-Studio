> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-FEASIBILITY — Technical Director Architectural Feasibility Sign-Off

Agent: `technical-director` | Model tier: session (inherit) | Domain: End-to-end technical viability, performance limits, security constraints, infrastructure cost

**Trigger**: During concept, architecture design, or before major capital/engineering commitments

**Context to pass**:
- High-level product concept and feature requirements
- Performance targets (`target_lcp_ms`, `api_p95_latency_ms` from `project.yaml`)
- Hosting infrastructure constraints (Vercel serverless execution limits, Postgres connection limits)

**Prompt**:
> "Evaluate the end-to-end architectural feasibility of the proposed system under real-world constraints. Can the required throughput and latency SLAs be achieved within serverless execution timeouts (e.g. Vercel 15s/60s)? Is the connection pooling strategy (Prisma Accelerate, Supabase PgBouncer) adequate for expected concurrency? Are unit economics of cloud infrastructure viable given the target pricing model? Return FEASIBLE (architecturally sound and achievable within budgets) or INFEASIBLE [insurmountable architectural bottlenecks or cost explosion]."

**Verdicts**: FEASIBLE / INFEASIBLE
