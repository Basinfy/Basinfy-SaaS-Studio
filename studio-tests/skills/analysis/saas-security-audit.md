# Skill Test Spec: /saas-security-audit

## Skill Summary

`/saas-security-audit` audits the codebase for common SaaS security failures across
six categories: multi-tenancy & tenant isolation (RLS/IDOR), authentication & sessions,
authorization & webhook integrity (Stripe signatures), input validation (OWASP Top 10),
rate limiting & secret exposure, and dependencies. It takes a scope
(`full`, `tenant`, `auth`, `api`, `quick`; no argument runs `full`), reads
`stack.frontend`, `stack.backend`, and `modes.workflow` from `project.yaml`, and spawns the `appsec-engineer` agent
with a structured brief — providing scope, framework stack, database schema path,
and report path. Findings are classified CRITICAL / HIGH /
MEDIUM / LOW, each with file, line, attack scenario, and remediation. The
report's release recommendation, first match wins, is DO NOT SHIP, FIX BEFORE
SHIPPING, NOT ASSESSED (e.g. INSUFFICIENT IMPLEMENTATION) or CLEAR TO SHIP.
The skill presents the executive summary and CRITICAL/HIGH
findings in conversation, then asks "May I write the full security audit report
to `production/security/saas-security-audit-[date]-[scope].md`?" At
`workflow: minimal` the Phase 7 message notes that the minimal release gate does not block
on this report. No director gates are invoked.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: CLEAR TO SHIP, FIX BEFORE SHIPPING, DO NOT SHIP, NOT ASSESSED, and the severities CRITICAL / HIGH / MEDIUM / LOW
- [ ] Contains "May I write" language naming `production/security/saas-security-audit-[date]-[scope].md`
- [ ] Has a next-step handoff (Phase 7: `/saas-security-audit quick`, `/saas-gate-check release`, `/saas-launch-checklist`)

---

## Director Gate Checks

None. The skill spawns the `appsec-engineer` specialist to run the audit;
that is its core mechanism, not a director gate. No director gate is invoked in
any review mode.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Standard Next.js SaaS project, no findings

**Fixture:**
- `project.yaml`: `stack.frontend: nextjs`, `stack.backend: nextjs-server-actions`, `stack.database: supabase-postgres`, `modes.rigor: standard`
- `src/` holds the implemented product: 42 `.ts` files across auth, billing, dashboard, and settings
- `supabase/migrations/` has RLS enabled on all tenant tables with `auth.uid()` checks
- No API keys, secrets, passwords or tokens hardcoded anywhere in `src/` or client bundles
- Dependencies in `package.json` are up-to-date with no high/critical CVEs

**Input:** `/saas-security-audit`

**Expected behavior:**
1. No argument → `full` scope
2. Skill reads stack configuration from `project.yaml`
3. Skill spawns `appsec-engineer` with the brief: scope `full`, Next.js/Supabase stack, code root `src/`, schema in `supabase/migrations/`
4. All 6 categories are audited against the Next.js and Supabase AppSec rules
5. Executive Summary shows zero findings over 42 source files; Release recommendation: **CLEAR TO SHIP**
6. Skill presents the summary, then asks "May I write the full security audit report to `production/security/saas-security-audit-[date]-full.md`?"
7. After writing: "✅ No blocking security findings. Report written to `production/security/`. Include this path when running `/saas-gate-check release`."

**Assertions:**
- [ ] `appsec-engineer` is spawned with the structured brief template — scope, stack, code root, and output path
- [ ] Multi-tenant isolation (RLS policies) is verified across database migrations
- [ ] Hardcoded-credential patterns (`api_key`, `secret`, `password`, `token`, `private_key`) are scanned
- [ ] Release recommendation is CLEAR TO SHIP
- [ ] "May I write" precedes the report write

---

### Case 1b: Single-tenant or Intranet App, One HIGH Finding — FIX BEFORE SHIPPING

**Fixture:**
- Same as Case 1, except `src/app/api/documents/[id]/route.ts` fetches a document by ID without verifying `tenant_id` ownership (IDOR/BOLA vulnerability)
- No other findings

**Input:** `/saas-security-audit`

**Expected behavior:**
1. The IDOR finding is classified **HIGH** (broken object-level authorization that exposes tenant data)
2. Release recommendation: **FIX BEFORE SHIPPING** — an open HIGH, no CRITICAL
3. After the write: "⚠️ 1 HIGH finding(s) are open. The Polish → Release gate's security audit item requires none — fix them and re-run `/saas-security-audit quick` before `/saas-gate-check release`."

**Assertions:**
- [ ] The IDOR finding is classified as HIGH
- [ ] Release recommendation is FIX BEFORE SHIPPING — never CLEAR TO SHIP with a HIGH open, and not DO NOT SHIP without a CRITICAL
- [ ] The ⚠️ HIGH message names the release gate's security audit item as the requirement, and names `/saas-security-audit quick` and `/saas-gate-check release`

---

### Case 2: Critical Finding — Forged Webhook / Exposed Stripe Secret Key

**Fixture:**
- `project.yaml`: `stack.frontend: nextjs`, `stack.billing: stripe`
- `src/app/api/webhooks/stripe/route.ts` line 24: processes `checkout.session.completed` events without verifying `stripe-signature` via `stripe.webhooks.constructEvent()`
- `src/app/client-portal/page.tsx` line 8: `const STRIPE_SECRET = "sk_live_1234567890abcdef"` (leaked in client-facing component)

**Input:** `/saas-security-audit full`

**Expected behavior:**
1. Category 3 runs and flags the unsigned Stripe webhook as **CRITICAL** (attackers can forge payment confirmations to grant free access)
2. Category 5 flags the raw `sk_live_` secret key in client code as **CRITICAL** (complete payment account compromise)
3. Each finding is written as `SEC-NNN` with Category, File and line, Description, Attack scenario, Remediation and Effort
4. Release recommendation is **DO NOT SHIP** — open CRITICAL findings decide it
5. Skill presents the executive summary and CRITICAL findings, then asks "May I write"
6. Phase 7: "⛔ CRITICAL security findings must be resolved before any public release. Do not proceed to `/saas-launch-checklist` until these are addressed."

**Assertions:**
- [ ] The unverified webhook finding cites `src/app/api/webhooks/stripe/route.ts` with line number and attack scenario
- [ ] The hardcoded secret key is raised to CRITICAL
- [ ] Every finding carries a specific remediation
- [ ] Release recommendation is DO NOT SHIP (open CRITICAL findings)
- [ ] The ⛔ message is shown and `/saas-launch-checklist` is held back

---

### Case 3: Empty Codebase — NOT ASSESSED — INSUFFICIENT IMPLEMENTATION

**Fixture:**
- `project.yaml`: `stack.frontend: nextjs`, `stack.backend: nextjs-server-actions`
- `src/` exists but contains no source files

**Input:** `/saas-security-audit`

**Expected behavior:**
1. The code root resolves to `src/`, but there is nothing in it to audit
2. Every code-scanning category has zero files to scan, so each is NOT ASSESSED rather than clean
3. Release recommendation: **NOT ASSESSED — INSUFFICIENT IMPLEMENTATION**
4. The report names what was missing (no source under `src/`) and which skill produces it
5. CLEAR TO SHIP is not reported

**Assertions:**
- [ ] The empty code root leaves every code-scanning category NOT ASSESSED; none is reported clean or as zero findings
- [ ] Release recommendation is NOT ASSESSED — INSUFFICIENT IMPLEMENTATION
- [ ] Output names what was missing and which skill produces it
- [ ] CLEAR TO SHIP is not reachable from a scan with nothing to look at

---

### Case 4: FastAPI Project — Python / Pydantic / SQLAlchemy Security Scanning

**Fixture:**
- `project.yaml`: `stack.frontend: react-vite`, `stack.backend: fastapi`, `stack.orm: sqlalchemy`
- `api/routes/users.py` uses Pydantic schema validation on all inputs
- `api/routes/auth.py` enforces password hashing via bcrypt and validates JWT expiry
- No raw string SQL interpolation detected

**Input:** `/saas-security-audit`

**Expected behavior:**
1. The stack resolves to FastAPI / Python; patterns scan `api/` and `app/` routes
2. Category 4 validates Pydantic model usage for input schema validation
3. Release recommendation is **CLEAR TO SHIP** when all checks pass

**Assertions:**
- [ ] The audit uses the FastAPI / Python pattern set
- [ ] Input validation checks examine Pydantic request models
- [ ] CLEAR TO SHIP is reported on clean analysis

---

## Protocol Compliance

- [ ] Reads stack configuration from `project.yaml` before auditing
- [ ] Spawns `appsec-engineer` via `Agent` with the structured brief template (scope, stack, schema, report path)
- [ ] Each finding carries severity, category, file and line, attack scenario and remediation
- [ ] Release recommendation, first match: DO NOT SHIP, FIX BEFORE SHIPPING, NOT ASSESSED, CLEAR TO SHIP
- [ ] Presents the executive summary and CRITICAL/HIGH findings before asking "May I write" for `production/security/saas-security-audit-[date]-[scope].md`; writes only after approval
- [ ] No director gates are invoked
- [ ] Ends with the Phase 7 gate-integration guidance
