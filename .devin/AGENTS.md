# Autonomous SaaS Studio — Devin Autonomous Rules

This workspace operates under the **Basinfy SaaS Studio** autonomous engineering platform: **50 specialized agents**, **108 `/saas-*` workflows & subcommands**, and **28 formal Director Gates** across **7 lifecycle phases**.

## 1. Founder & Layperson Autopilot (`user_profile: founder | developer`)
Check `project.user_profile` in `project.yaml` (defaults to `"founder"` when unset or when the user is non-technical):
- **Natural-Language Continuous Maestro (Zero Command Memorization Required)**:
  - Users NEVER need to memorize `/saas-*` slash commands. When a user describes an idea, problem, or next goal in plain language (e.g., *"Quero criar um SaaS para clínicas"* or *"Create a subscription CRM"*), automatically route through the lifecycle (`/saas-start` → `/saas-brainstorm` → `/saas-setup-stack` → `/saas-design-tokens` → `/saas-create-stories` → `/saas-dev-story`).
  - At the end of every step, display a clear human progress indicator (`[Passo X de 7 concluído ✅]`) and ask directly if you should execute the next step immediately — never leave a non-technical user stranded at a blank prompt.
- **When `user_profile: "founder"` (Layperson / Non-Technical Creator Mode)**:
  - **100% Business Language — Zero Tech Jargon in Questions**: NEVER ask a layperson to choose between *"Prisma vs. Drizzle"*, *"Server Actions vs. FastAPI"*, *"RLS policies"*, or *"ADRs"*. Ask purely about their **customers, pricing, team access, and business rules**, always placing the safest option first prefixed with **`(Recomendado)`**.
  - **Opinionated Golden Stack Default**: Unless the user explicitly requests another stack, recommend and configure the battle-tested SaaS Golden Stack (**Next.js App Router + Tailwind CSS / shadcn/ui + Supabase PostgreSQL & Auth + Prisma + Stripe + Vercel**), explaining each piece in 1 plain-language line (screen, secure customer vault, automatic billing, cloud hosting).
- **When `user_profile: "developer"` (Technical Mode)**: Expose full architectural trade-offs across Next.js, FastAPI, Go, Drizzle, Cloudflare Workers, AWS, Docker, and granular ADR controls.
- **Invisible Senior Guardrails (Always Enforced Automatically)**:
  - Multi-tenant PostgreSQL Row-Level Security (RLS) on every tenant/user table (`(select auth.uid())` / `tenant_id`).
  - Server-side schema validation (Zod / Pydantic) on every route and Server Action; zero exposed secrets.
  - Stripe webhook HMAC verification against raw request body (`await req.text()`) + idempotent event ledger.
  - Built-in LGPD privacy-by-design (`.lgpd/`) and Agentic SEO (`llms.txt`, JSON-LD, RFC 9727) defaults.

## 2. Studio Hierarchy — 50 Specialized Agents (3 Tiers)
Role definitions live in `.claude/agents/`:
- **Tier 1 — Strategic Directors (3)**: `product-director` (ICP, UVP, MVP scope, unit economics), `technical-director` (C4 architecture, ADRs, security boundaries), `delivery-producer` (milestones, sprints, scope governance).
- **Tier 2 — Department Leads (8)**: `lead-product-manager`, `lead-engineer`, `design-system-director`, `growth-director`, `ux-content-strategist`, `qa-lead`, `release-manager`, `localization-lead`.
- **Tier 3 — Execution Specialists (39)**: Dedicated specialists across Next.js, React, Tailwind/shadcn, Supabase, Prisma/Drizzle, FastAPI, Python, Go, Stripe Billing, Queue Workers, Auth/RBAC, AppSec, DPO/LGPD (`dpo-privacy-specialist`), Cloudflare, AWS, Docker/K8s, WebSockets, Email, UX/Motion, Accessibility, Perf, SRE, Onboarding, Pricing, and QA.

## 3. Complete Catalog — 108 Slash Workflows & Subcommands (`/saas-*`)
Canonical skills live in `.claude/skills/` (mirrored portably in `.agents/skills/`):
- **Onboarding & Navigation**: `/saas-start`, `/saas-help`, `/saas-setup-stack`, `/saas-project-stage-detect`, `/saas-adopt`, `/saas-settings`, `/saas-onboard`
- **Product, UX & Frontend Taste**: `/saas-brainstorm`, `/saas-prototype`, `/saas-design-tokens`, `/saas-frontend-taste`, `/saas-map-features`, `/saas-design-system`, `/saas-quick-design`, `/saas-ux-design`, `/saas-ux-review`, `/saas-design-review`, `/saas-review-all-prds`, `/saas-consistency-check`
- **Architecture & Delivery**: `/saas-create-architecture`, `/saas-architecture-decision`, `/saas-architecture-review`, `/saas-create-control-manifest`, `/saas-gate-check`, `/saas-create-epics`, `/saas-create-stories`, `/saas-story-readiness`, `/saas-sprint-plan`, `/saas-sprint-status`, `/saas-dev-story`, `/saas-story-done`, `/saas-code-review`, `/saas-hotfix`
- **Multidisciplinary Teams**: `/saas-team-core-feature`, `/saas-team-auth-access`, `/saas-team-billing`, `/saas-team-ui`, `/saas-team-content`, `/saas-team-growth`, `/saas-team-seo`, `/saas-team-lgpd`, `/saas-team-polish`, `/saas-team-qa`, `/saas-team-release`
- **LGPD, ANPD & ECA Digital (21 Skills)**: `/saas-lgpd` + 19 specialized compliance subcommands (`audit`, `consent-schema`, `data-mapping`, `legal-basis`, `privacy-policy`, `dsar`, `ropa`, `ripd`, `incident-response`, `eca-digital-minors`, `dpo-encarregado`, `dpa`, `vendor-audit`, `international-transfer`, `retention-erasure`, `anonymization`, `encryption-keys`, `audit-logging`, `legacy-retrofit`)
- **SEO, GEO & Agent Readiness (12 Skills)**: `/saas-seo` + `audit`, `technical`, `schema`, `geo`, `agentic`, `drift`, `programmatic`, `competitor-pages`, `sxo`, `content`
- **Quality, AppSec & Launch**: `/saas-test-setup`, `/saas-smoke-check`, `/saas-qa-plan`, `/saas-security-audit`, `/saas-perf-profile`, `/saas-load-test`, `/saas-pricing-audit`, `/saas-release-checklist`, `/saas-launch-checklist`, `/saas-post-launch-monitor`

## 4. Collaboration Modes & Durable State
Respect `modes.automation` from `project.yaml`:
- `collaborative` (default): Present concise options with `(Recomendado)` first, show a clear summary, and request **one consolidated approval per stage/changeset** before writing project files (exempt: `production/session-state/active.md`, `.claude/agent-memory/`, and designated subagent output files). Subagents execute their assigned brief directly without pausing mid-flight for human prompts.
- `guided`: Prompt only on architectural choices and `automation_always_ask` categories (`schema_changes`, `billing_changes`, `auth_policies`, `file_deletions`).
- `autonomous` (or `/goal`): Execute end-to-end, log decisions in `production/session-logs/decision-log.md`, and verify with automated checks.
- **Canonical Paths**: Config in `project.yaml`; PRDs in `docs/specs/` (fallback `design/prd/`); Architecture/ADRs in `docs/architecture/`; Tokens in `design/tokens/`; Stories in `production/epics/`; Session checkpoint in `production/session-state/active.md`; Domain lessons in `.basinfy/experience/`.

## 5. Dynamic Bilingual Interface (PT-BR & EN) / English Engine
- **Portuguese (`locale: pt-BR` or user writes in Portuguese)**: ALL human-facing questions (`AskUserQuestion` / `ask_question`), options, confirmations, and explanations MUST be rendered in **natural Brazilian Portuguese (PT-BR)**. This strictly OVERRIDES any English prompt examples inside skills. NEVER show English questions/options to a Portuguese-speaking user.
- **English (`locale: en` or user writes in English)**: Render all questions and options in **English**.
- **English Technical Engine**: Internal reasoning, source code, database identifiers, unit tests, and git commits always execute in **English (EN)** (except Brazilian legal compliance documents under `.lgpd/`).

<!-- BASINFY:START -->
## Basinfy Protocol (Smart Code Indexing)

When this workspace has a `.basinfy/` directory, route code discovery through Basinfy first. IDE Grep/Read/rg are the last resort.

**Default path (MCP live — tools listed and a call succeeds):**
- Start with one bootstrap: `basinfy_session_start` or `basinfy_brief` (not both). Pass `projectRoot` = active workspace path.
- Check `projectRoot` / `rootSource`; on mismatch or `unresolved`, retry with `projectRoot`. Always supply `projectRoot` when working under global MCP daemons.
- **Level 1 — Code Mode First (Default standard):** `basinfy_query_script` (MCP) or CLI `basinfy script <code>` — always execute compound exploration inside the in-memory JS sandbox in 1 turn to achieve maximum token economy (-90%+). NEVER call multiple standalone search/read/orbit/impact tools in separate turns when Code Mode can resolve them in a single batch.
- **Level 2 — Simple Direct Tools:** Use standalone tools (`basinfy_search`, `basinfy_read`, `basinfy_orbit`, `basinfy_impact`, `basinfy_prepare_edit`, `basinfy_locate`) ONLY for simple, 1-step queries (e.g. checking a single configuration line or editing a known symbol).
- **Level 3 — Primary Discovery (when not writing script):** `basinfy_discover` with `digest: true` (candidate files + primary exports + instant 12-line code preview in 1 turn). Use FIRST before search.
- code/symbol edit → `basinfy_prepare_edit` / `basinfy_locate`
- new file → `basinfy_prepare_create`; ADR/lesson → `basinfy_remember`; end → `basinfy_session_end`
- **STRICT ANTI-PATTERNS (PROHIBITED):**
  - ❌ NEVER loop `basinfy_search` + `basinfy_read` across multiple files. Use `basinfy_query_script` or `basinfy_discover({ query, digest: true })`.
  - ❌ NEVER re-read code already delivered in a discover digest or briefing.
- **Fallback (No `.basinfy/` directory):** When `.basinfy/` is absent and Basinfy MCP/CLI is inactive, seamlessly use standard IDE tools (`Glob`, `Grep`, `Read`).

**Code Mode (`basinfy_query_script` / `basinfy script`) Recipes:**
1. Discover & Preview in 1 turn:
   `return await basinfy.discover("query", { digest: true });`
2. Compound Topology, Orbit & Impact (Zero Bloat):
   `const [orbit, impact] = await Promise.all([basinfy.orbit("src/file.ts"), basinfy.impact("src/file.ts")]); return { orbit, impact };`
3. Multi-file search & targeted reading in 1 turn:
   `const hits = await basinfy.search("str"); return await Promise.all(hits.slice(0,3).map(x => basinfy.read({ path: x.file, offset: Math.max(1, x.line - 5), limit: 20 })));`
4. Trace file dependency path:
   `return await basinfy.path("src/a.ts", "src/b.ts");`

Args (aliases accepted): code mode `{ script }`; discover `{ query, digest: true }`; search `{ query }` (alias `pattern`); read `{ path }` (aliases `filePath`, `file`, `paths[0]`); locate/prepare_edit `{ symbol }`; orbit/gate_edit/impact `{ filePath }` (aliases `path`, `file`); create `{ targetPath }`. Optional `projectRoot` on any tool.

**Escape hatches (fallback ladder):**
- Transport/discovery only (`Not connected`, namespace error/loading/needsAuth) → CLI-first for this session (`basinfy script`, `basinfy session-start`, `basinfy discover`, `basinfy search`, `basinfy read`, `basinfy prepare-edit`, `basinfy prepare-create`, `basinfy gate-edit`, `basinfy health`, `basinfy drive`, `basinfy resource`).
- InvalidParams / `-32602` is not MCP-down — retry the same MCP tool once with the schema; then CLI if still failing.
- Empty search / locate `{found:false}` is a normal miss — try the next Basinfy tool; after repeated misses on the same need, CLI then IDE search.
- `allowed:false` from gate/prepare is advisory (writes are not blocked) — pass `force:true` when proceeding.
- IDE Read/Grep/rg while MCP succeeds: only for images, binaries, notebooks, paths outside the index root, or a range beyond a truncated `basinfy_read`.
<!-- BASINFY:END -->
