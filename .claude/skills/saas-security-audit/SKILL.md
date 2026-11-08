---
name: saas-security-audit
description: "Application security (AppSec) audit — adversarial vulnerability discovery, tenant isolation, auth & RBAC, AI/LLM boundaries, OWASP Top 10, webhook signatures, rate limiting, and dependency CVEs. Before release."
argument-hint: "[full | auth | tenant | api | quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash(bash "*/.claude/skills/saas-security-audit/../../hooks/yaml-helper.sh" resolve_config *), Bash(node *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation,workflow`

**Automation mode**: Resolve `modes.automation` (`project.local.yaml` →
`project.yaml` → default `collaborative`). Every `AskUserQuestion` call and
every file write follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`workflow`** (resolved above) decides only what Phase 7 tells you about the
release gate: at `standard` and `full` it requires this report; at `minimal` it
does not. The audit itself runs the same at every tier.

# Application Security (AppSec) Audit & Vulnerability Harness

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Security is mandatory for production SaaS platforms. Multi-tenant SaaS architectures face tenant data cross-contamination risks, broken object-level authorization (BOLA/IDOR), session fixation, webhook forgery, AI/LLM context injection, and resource exhaustion.

This skill implements an adversarial, evidence-grounded security audit workflow (derived from the Cloudflare Vulnerability Harness standard). It systematically maps attack surfaces, performs coverage-led hunting, executes independent verification to eliminate false positives, and generates structured, schema-validated remediation reports.

**Core Defensive Principles (Cloudflare Standard):**
1. **Concrete Boundary Violations Only**: A candidate without a concrete affected principal, resource, or security outcome is not a confirmed finding.
2. **Adversarial Validation**: The agent that checks a candidate finding is never the agent that identified it. Verifiers actively seek upstream defenses or framework protections.
3. **Severity Requires Real Impact**: Severity = Likelihood × Impact. Defense-in-depth gaps are hardening notes, not vulnerabilities, when an upstream layer reliably prevents exploitation.
4. **Three Strict Verdicts**:
   - `confirmed`: Complete source-visible lineage and bounded reproducible verification.
   - `needs_validation`: Viable vector where external deployment state, WAF rules, or third-party provider behavior is not observable locally.
   - `rejected`: Hypothesis tested and disproved by existing deterministic safeguards.

---

## Phase 1: Parse Arguments and Scope

**Modes:**
- `full` — All attack domains with adversarial Hunter-Verifier loop (recommended before release; default if no argument given).
- `tenant` — Data isolation, RLS, cross-tenant leakage, and tombstone lifecycle (`references/data-isolation-lifecycle.md`).
- `auth` — Authentication, JWT/OAuth binding, session rotation, and API keys (`references/web-protocol-auth.md`).
- `api` — Input validation, OWASP Top 10, rate limiting, and resource exhaustion (`references/resource-exhaustion.md`).
- `quick` — CRITICAL checks only across all categories (15-minute smoke scan).

---

## Phase 2: Reconnaissance & Surface Mapping

Inspect the stack configuration and codebase entry points:
- **Framework Detection (`project.yaml`)**:
  - *Next.js / Node.js*: API routes (`app/api/**/route.ts`), Server Actions (`"use server"`), middleware (`middleware.ts`).
  - *FastAPI / Python*: Route handlers (`api/routes/**`), dependencies (`Depends(get_current_user)`), SQLAlchemy/SQLModel models.
  - *Database & Storage*: Migration files (`supabase/migrations/**`, `prisma/schema.prisma`), RLS policies (`CREATE POLICY`), Redis key patterns.
- Consult the specialized attack manuals in `references/`:
  - `references/data-isolation-lifecycle.md`: Multi-tenancy, soft-delete bypass, derived copies.
  - `references/web-protocol-auth.md`: JWT/OAuth binding, session fixation, WebAuthn.
  - `references/ai-llm-security.md`: RAG indirect injection, tool dispatch, MCP security.
  - `references/resource-exhaustion.md`: ReDoS, unpaginated queries, worker starvation.
  - `references/attack-classes.md`: Core and wildcard attack vectors.

---

## Phase 3: Coverage-Led Hunting (Hunter Agent)

Spawn the primary auditor subagent:
```yaml
subagent_type: appsec-engineer
role: Adversarial Security Hunter
focus: Source-to-sink vulnerability discovery and tenant boundary verification
```

The Hunter examines the target against the 6 core SaaS attack domains:

### 1. Multi-Tenancy & Tenant Isolation (IDOR / BOLA)
- **Row-Level Security (RLS)**: Is RLS enabled and strictly enforced on all tenant tables (`tenant_id = auth.tenant_id()`)?
- **Query Ownership Scoping**: Does every parameterized query filter by both entity ID AND active tenant ID?
- **Tombstone & Lifecycle Bypass**: Do direct lookups, nested relations, search endpoints, or background workers ever return soft-deleted (`deleted_at`) or consent-revoked records?
- **Derived Copies**: Do Redis caches, search indexes, analytics logs, or export packages leak tenant data across boundaries?

### 2. Authentication & Session Integrity
- **JWT Binding**: Are signature algorithms strictly pinned? Are `kid`, `jku`, and `alg: "none"` bypass vectors prevented? Are `iss`, `aud`, and `exp` validated?
- **Session Lifecycle**: Are session IDs rotated upon login, MFA step-up, organization switch, or impersonation? Does logout cascade across active tokens and WebSocket sessions?
- **Cookie Transport**: Are `HttpOnly`, `Secure`, and `SameSite=Lax/Strict` attributes enforced?

### 3. Authorization, RBAC & Webhooks
- **Server-Side RBAC**: Are sensitive mutations guarded by explicit role checks on the server rather than trusting client-supplied claims?
- **Webhook Signature Verification**: Are Stripe and third-party webhooks verified using raw request bodies against signature secrets?
- **API Key Scoping**: Are API keys stored as constant-time hashes and bound to specific tenant scopes?

### 4. Input Validation & Injection Sinks
- **Strict Schema Parsing**: Does every public endpoint validate payloads with Zod / Pydantic and strip unknown keys?
- **SQL / Command Injection**: Are all database queries parameterized? Are command execution sinks absent or strictly validated?
- **SSRF Prevention**: Are user-supplied URLs validated against private RFC 1918 ranges and cloud metadata IPs (`169.254.169.254`)?

### 5. AI, LLM & Agent Delegation (When Applicable)
- **Indirect Prompt Injection**: Can untrusted user content in RAG documents or issue bodies reach other users' model contexts?
- **Tool-Argument Authorization**: Do model-dispatched tools re-verify user authorization before executing side-effects?
- **MCP Trust Boundaries**: Are MCP tool schemas, descriptions, and servers treated as untrusted input?

### 6. Resource Exhaustion & Availability
- **Pagination Bounds**: Are all listing endpoints strictly capped (e.g. `limit` <= 100)?
- **Rate Limiting**: Are public authentication, password reset, and expensive AI endpoints throttled per IP/tenant?
- **ReDoS**: Are regular expressions on user input free of polynomial/exponential backtracking?

---

## Phase 4: Adversarial Candidate Validation (Verifier Agent)

In `full` audit mode, every candidate vulnerability identified by the Hunter is assigned to an independent Verifier:
```yaml
subagent_type: auth-security-specialist
role: Independent Security Verifier
focus: Adversarial disproval and verification of candidate vulnerabilities
```

The Verifier actively seeks:
1. Upstream sanitization or framework middleware that neutralizes the vector.
2. Type constraints or ORM guarantees that prevent the invalid state.
3. Defense-in-depth layers that prevent real-world exploitation.

Each candidate is resolved into:
- **`confirmed`**: The exploit trace is complete and unobstructed from source to sink.
- **`needs_validation`**: The code path appears vulnerable, but runtime verification depends on external infrastructure (e.g. WAF rules, Cloudflare edge config).
- **`rejected`**: Disproved by existing defenses (recorded to avoid re-hunting).

---

## Phase 5: Structured Output & Schema Validation

Validate the structured findings using the zero-dependency validator:
```bash
node .claude/skills/saas-security-audit/scripts/validate-findings.cjs <findings-file.json>
```

Ensure all records adhere to `scripts/report-schema.json`.

---

## Phase 6: Author Audit Report

Save the report to `production/security/saas-security-audit-[date]-[scope].md`:

```markdown
# Application Security Audit Report

> **Target**: [Project Name]
> **Date**: [YYYY-MM-DD]
> **Scope**: [full | tenant | auth | api | quick]
> **Auditors**: appsec-engineer (Hunter) / auth-security-specialist (Verifier)
> **Standard**: Cloudflare Vulnerability Harness Defensive Standard
> **Status**: [PASSED | REMEDIATION REQUIRED]

## Executive Summary
[High-level overview of security posture, verified findings count, and release recommendation]

| Verdict | Count | Blockers for Release |
|---|---|---|
| Confirmed (Critical / High) | [N] | Yes |
| Confirmed (Medium / Low) | [N] | No |
| Needs Validation | [N] | Manual review |
| Rejected (Disproved) | [N] | None (Hardened) |

## Confirmed Vulnerabilities

### SEC-001: [Title]
- **Severity**: CRITICAL | HIGH | MEDIUM | LOW
- **Domain**: [Data Isolation | Web Protocol & Auth | AI/LLM | Resource Exhaustion | Injection]
- **Affected Principal & Resource**: [Attacker role, Victim role, Affected entity]
- **Source Trace**: `src/path/to/file.ts:L45` -> `src/path/to/sink.ts:L112`
- **Observed Result**: [Concrete security failure]
- **Smallest Effective Fix**: [Code diff or targeted remediation]

## Items Needing External Validation
[List of leads requiring staging environment, WAF, or IdP configuration verification]

## Hardening Notes & Disproved Candidates
[Defense-in-depth observations that are not exploitable vulnerabilities]

## Remediation Priority Order
1. SEC-001: [Immediate fix]
```

---

## Phase 7: Gate Integration

- **CRITICAL / HIGH Confirmed Finding**:
  - Verdict: **REMEDIATION REQUIRED** (Hard block for Polish → Release gate).
- **MEDIUM / LOW Confirmed Only**:
  - Verdict: **CONCERNS** (Review with user; fix in current or next sprint).
- **Zero Confirmed Findings**:
  - Verdict: **PASSED** (Ready for deployment).
