> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-CONTROL-MANIFEST — Technical Director Engineering Control Manifest Audit

Agent: `technical-director` | Model tier: session (inherit) | Domain: Engineering guardrails, Must-Do / Never-Do rules, automated lint enforcement, code boundaries

**Trigger**: After control manifest creation (`/saas-create-control-manifest`), before sprint kickoff

**Context to pass**:
- Control manifest document (`docs/architecture/control-manifest.md`)
- Accepted ADRs in `docs/architecture/`
- Automated linting and validation rules (`.claude/rules/`)

**Prompt**:
> "Verify that the engineering control manifest accurately distills all accepted ADRs into actionable rules. Are all Must-Do and Never-Do constraints unambiguous, non-negotiable, and verifiable by automated checks? Are architectural boundaries (e.g., no database queries from Client Components, no client secrets in bundle) explicitly codified? Return ENFORCED (manifest accurately captures all architectural constraints) or VIOLATIONS [missing rules, contradictions, or unverifiable mandates]."

**Verdicts**: ENFORCED / VIOLATIONS
