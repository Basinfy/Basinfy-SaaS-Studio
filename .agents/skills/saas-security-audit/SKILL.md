---
name: saas-security-audit
description: "Application security (AppSec) audit — tenant isolation, auth & RBAC, OWASP Top 10, webhook signatures, rate limiting, dependency CVEs. Before release."
argument-hint: "[full | auth | tenant | api | quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, Bash(bash "*/.claude/skills/saas-security-audit/../../hooks/yaml-helper.sh" resolve_config *)
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

# Application Security (AppSec) Audit

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Security is mandatory for any production SaaS application. Multi-tenant SaaS products
face tenant data cross-contamination risks, broken authorization (BOLA/IDOR), session hijacking,
webhook forging, and denial-of-service vulnerabilities. This skill systematically audits the
codebase for the most critical SaaS security failures and produces an actionable, prioritized
remediation plan.

**Run this skill:**
- Before any public or staging release (required for the Polish → Release gate at `workflow: standard` and `full`)
- Before onboarding external customers or enabling billing/payments
- After implementing multi-tenancy, authentication, billing webhooks, or file uploads
- When a security vulnerability or anomalous behavior is reported

**Output:** `production/security/saas-security-audit-[date]-[scope].md` — the scope
in the name keeps a same-day `quick` or `auth` run from overwriting the `full`
report the release gate reads.

---

## Phase 1: Parse Arguments and Scope

**Modes:**
- `full` — all 6 categories (recommended before release; default if no argument given)
- `tenant` — Category 1 (Multi-tenancy, RLS, cross-tenant isolation, IDOR/BOLA)
- `auth` — Category 2 & 3 (Authentication, sessions, RBAC, API keys, webhook signatures)
- `api` — Category 4 & 5 (Input validation, OWASP Top 10, rate limiting, secret exposure)
- `quick` — CRITICAL checks only across all categories (15-minute smoke scan)

Parse the first argument. If unrecognized, display usage and default to `full`.

---

## Phase 2: Spawn Security Engineer

Spawn a specialized subagent:
```yaml
subagent_type: security-engineer
role: Application Security Specialist
focus: SaaS vulnerability assessment, tenant isolation, and OWASP compliance
```

Provide the subagent:
1. Target scope (`full`, `tenant`, `auth`, `api`, or `quick`)
2. Path to stack configuration (`project.yaml`)
3. Database schema location (e.g. `prisma/schema.prisma` or `src/db/`)
4. Output report path: `production/security/saas-security-audit-[date]-[scope].md`

---

## Phase 3: Audit Categories

### Stack Pattern Sets — Read this before any Category below

Detect the framework from `project.yaml`:
- **Next.js / Node.js**: Look for API routes in `app/api/**/route.ts`, server actions (`"use server"`), middleware in `middleware.ts`.
- **FastAPI / Python**: Look for routers in `api/routes/**`, dependencies `Depends(get_current_user)`, SQLAlchemy/SQLModel models.
- **Supabase / PostgreSQL**: Look for migration files in `supabase/migrations/**`, RLS policies `CREATE POLICY`, schema definitions.

---

### Category 1: Multi-Tenancy & Tenant Isolation (IDOR / BOLA)

*Why it matters*: In a multi-tenant SaaS, tenant A must NEVER access or modify tenant B's data.

**Checks:**
1. **Row-Level Security (RLS)**:
   - Does every database table containing tenant data have RLS enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)?
   - Do RLS policies enforce tenant matching: `tenant_id = auth.tenant_id()` or equivalent?
   - Are service-role keys bypassed or leaked to client components?
2. **Broken Object-Level Authorization (BOLA / IDOR)**:
   - For every API route taking an ID parameter (e.g. `GET /api/documents/:id`, `PATCH /api/projects/:id`):
     - Does the query filter by BOTH the resource ID AND the active user's `tenant_id`?
     - Example violation: `prisma.document.findUnique({ where: { id } })` without checking tenant ownership.
3. **Cache & Queue Isolation**:
   - Are Redis keys scoped with tenant identifiers: `tenant:{tenant_id}:resource:{id}`?
   - Do background jobs carry tenant context and re-verify permissions before execution?

---

### Category 2: Authentication & Session Management

*Why it matters*: Broken authentication allows attackers to impersonate users or bypass login.

**Checks:**
1. **JWT & Session Security**:
   - Are session tokens stored in `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict`) cookies?
   - Are JWT secrets at least 256 bits of entropy and never hardcoded in source?
   - Is token expiration enforced? Are refresh tokens single-use with token rotation?
2. **Session Lifecycle**:
   - Does password reset or email change invalidate all existing active sessions?
   - Does logout invalidate the session token on the server/DB side, not just clear the client cookie?
3. **MFA & Auth Fallback**:
   - Are brute-force protections enabled on login and password reset routes?

---

### Category 3: Authorization, RBAC & Webhook Integrity

*Why it matters*: Privilege escalation gives standard users admin access; forged webhooks grant free subscriptions.

**Checks:**
1. **Role-Based Access Control (RBAC)**:
   - Are sensitive actions (e.g. invite user, change plan, delete workspace) guarded by explicit role checks?
   - Do API endpoints verify permissions server-side rather than trusting client UI role state?
2. **Webhook Signature Verification**:
   - Does the Stripe webhook handler verify signatures with `stripe.webhooks.constructEvent(body, signature, secret)`?
   - Does the webhook route use the raw request body (unparsed buffer) for signature verification?
   - Are other incoming webhooks (GitHub, Supabase, Postmark) signed and verified with HMAC?
3. **API Key Security**:
   - Are user-generated API keys hashed (SHA-256 / bcrypt) before storage in the database?
   - Are API keys prefix-identified (e.g. `sk_live_...`) and scannable for leaks?

---

### Category 4: Injection & Input Validation (OWASP Top 10)

*Why it matters*: Unvalidated input leads to remote code execution, database compromise, or XSS.

**Checks:**
1. **Schema Validation**:
   - Does every API endpoint validate request bodies, query params, and headers with a schema validator (Zod, Pydantic, Yup)?
   - Are unknown fields stripped (`.strip()` / strict schemas) to prevent mass-assignment vulnerabilities?
2. **SQL & Command Injection**:
   - Are raw SQL queries parameterized? (Flag any string interpolation: `SELECT * FROM users WHERE id = '${id}'`).
   - Are system command executions (`child_process.exec`, `os.system`) absent or strictly parameterized?
3. **XSS & Content Security**:
   - Is user-supplied content sanitized before HTML rendering (e.g. DOMPurify for rich text)?
   - Are `dangerouslySetInnerHTML` or `v-html` avoided or guarded?
   - Are Content Security Policy (CSP) headers configured in middleware?
4. **SSRF (Server-Side Request Forgery)**:
   - Does any feature fetch URLs supplied by users (e.g. webhook URLs, avatar URL import)?
   - Are internal private IP ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.1`, metadata `169.254.169.254`) blocked?

---

### Category 5: Rate Limiting & Sensitive Data Exposure

*Why it matters*: Uncapped endpoints allow brute-forcing, scraping, bill denial-of-service, or data leakage.

**Checks:**
1. **API Rate Limiting**:
   - Are authentication routes (`/api/auth/login`, `/api/auth/register`, `/api/auth/forgot-password`) rate-limited per IP?
   - Are AI generation / expensive endpoints rate-limited per tenant?
2. **Secret Exposure in Client Bundles**:
   - Scan client code (`src/app/**`, `src/components/**`) for leaked private keys (`DATABASE_URL`, `STRIPE_SECRET_KEY`, `SUPABASE_SERVICE_ROLE_KEY`).
   - Confirm only `NEXT_PUBLIC_*` or explicitly public environment variables are accessed in client components.
3. **Sensitive Data in Responses & Logs**:
   - Do API user responses omit password hashes, salts, and internal auth tokens?
   - Are passwords, authorization headers, and payment credentials stripped from structured logger outputs?

---

### Category 6: Dependency & Supply Chain Security

*Why it matters*: Known vulnerabilities in packages give attackers trivial exploits.

**Checks:**
1. **Vulnerability Audit**:
   - Run package auditor (`npm audit --json` or `pip audit`).
   - Flag any dependencies with published CRITICAL or HIGH CVEs.
2. **Lockfile Integrity**:
   - Verify `package-lock.json`, `pnpm-lock.yaml`, or `poetry.lock` is committed to git and in sync.

---

## Phase 4: Classify Findings

Assign severity to each discovered issue:

| Severity | Definition | Examples | SLA |
|---|---|---|---|
| **CRITICAL** | Directly exploitable tenant data leak, remote execution, auth bypass, forged payment | BOLA on sensitive tenant record, Stripe webhook without signature check, leaked service-role key | Must fix immediately before release |
| **HIGH** | Significant risk requiring specific conditions to exploit | Missing rate limit on login, CSRF on mutating API, missing RLS policy on secondary table | Fix in current sprint |
| **MEDIUM** | Security weakness or defense-in-depth failure | Verbose error stack trace in production response, missing CSP header, weak password policy | Fix in next sprint |
| **LOW** | Hardening opportunity or minor informational issue | Missing security headers (`X-Frame-Options`), outdated non-critical package | Backlog |

---

## Phase 5: Generate Report

Write the report following this exact structure:

```markdown
# Application Security Audit Report

> **Target**: [Project Name]
> **Date**: [YYYY-MM-DD]
> **Scope**: [full | tenant | auth | api | quick]
> **Auditor**: security-engineer
> **Status**: [PASSED | REMEDIATION REQUIRED]

## Executive Summary
[Brief high-level summary of security posture, total findings count, and release recommendation]

| Severity | Count | Blockers for Release |
|---|---|---|
| CRITICAL | [N] | Yes |
| HIGH | [N] | Review required |
| MEDIUM | [N] | No |
| LOW | [N] | No |

## Findings

### SEC-001: [Title]
- **Severity**: CRITICAL | HIGH | MEDIUM | LOW
- **Category**: [Tenant Isolation | Auth | RBAC | Injection | Rate Limiting | Dependencies]
- **File(s)**: `src/path/to/file.ts:L45`
- **Description**: [Exact description of vulnerability and impact]
- **Proof of Concept / Trace**: [How it could be triggered]
- **Remediation**: [Code diff or clear instructions to fix]

## Dependency Inventory
[Audit summary of external packages and CVE status]

## Remediation Priority Order
1. SEC-001: [Immediate fix]
2. SEC-002: [...]

## Re-Audit Trigger
[What changes require running /saas-security-audit again]
```

---

## Phase 6: Write Report

Save the report to `production/security/saas-security-audit-[date]-[scope].md`.
Ensure the `production/security/` directory exists.

---

## Phase 7: Gate Integration

- If any **CRITICAL** finding exists:
  - Verdict: **REMEDIATION REQUIRED** (Blocks Polish → Release gate).
  - Output summary of blockers with clear remediation steps.
- If only **HIGH/MEDIUM/LOW** findings exist:
  - Check with user: Approve with documented risk or address before release.
- If zero findings:
  - Verdict: **PASSED** (Security audit requirements satisfied for release).
