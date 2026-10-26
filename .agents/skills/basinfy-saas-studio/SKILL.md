---
name: basinfy-saas-studio
description: "Turn your AI session into an autonomous SaaS and software engineering studio with 49 specialized agents, 74 workflow skills (/saas-*), 28 director gates, and complete architecture across Next.js, FastAPI, Supabase, Tailwind, and Stripe."
user-invocable: true
argument-hint: "[command or topic]"
---

# Basinfy SaaS Studio

Turn a single AI session into a complete, structured software engineering studio for SaaS platforms, cloud applications, and modern web services.
Organized into 3 tiers of 49 specialized agents, 74 workflow skills (`/saas-*`), 28 formal Director Gates, automated validation hooks, and enterprise coding standards.

## Quick Start Workflows

1. **New SaaS / First Session**:
   - `/saas-start` — Guided first-time onboarding wizard. Analyzes current state and guides stack selection.
   - `/saas-help` — Diagnostic workflow catalog navigator reporting active stage and recommended next actions.
   - `/saas-brainstorm` — Explore SaaS product ideas, ICP (Ideal Customer Profile), UVP, and competitor matrices.
   - `/saas-setup-stack` — Configure frontend, backend, database, auth, and billing in `project.yaml`.
   - `/saas-project-stage-detect` — Analyze an existing repository to determine current SaaS development stage.

2. **Architecture & Product Specifications**:
   - `/saas-design-tokens` — Define Tailwind semantic design tokens, color palette, typography, and spacing.
   - `/saas-map-features` — Decompose product into functional modules and feature dependency graphs.
   - `/saas-design-system` — Author comprehensive PRDs with schemas, metrics, and user stories.
   - `/saas-create-architecture` — Generate master architecture blueprints (C4 diagrams, API boundaries, DB schemas).
   - `/saas-architecture-decision` — Create formal Architecture Decision Records (ADRs) with trade-offs.
   - `/saas-gate-check` — Phase transition engine evaluating criteria against 28 formal Director Gates.

3. **Sprint Planning & Development**:
   - `/saas-create-epics` & `/saas-create-stories` — Break down specifications into trackable epics and user stories.
   - `/saas-sprint-plan` — Plan sprint backlog based on developer capacity and velocity.
   - `/saas-dev-story [story-id]` — Implement a user story with test-driven verification.
   - `/saas-story-done [story-id]` — Validate acceptance criteria, verify automated tests, and log evidence.
   - `/saas-code-review` — Architectural code review verifying SOLID principles, security, and performance.

4. **Security, Hardening & Launch**:
   - `/saas-security-audit` — OWASP Top 10 security audit, PostgreSQL RLS verification, and dependency CVE scans.
   - `/saas-perf-profile` — Profile Core Web Vitals (LCP, FID, CLS) and API p95 latencies.
   - `/saas-load-test` — Stress test endpoints, worker queues, and database connection pools.
   - `/saas-release-checklist` — Pre-deployment checklist (DNS, SSL, production secrets, rollback plan).
   - `/saas-launch-checklist` — Go-To-Market launch checklist (Product Hunt, docs, customer support).

## Studio Hierarchy (49 Agents)

- **Tier 1 — Strategic Directors (Claude Opus / MaxTurns: 30)**:
  - `product-director`: Guards the product vision, ICP, UVP, positioning, pricing, and strategic scope.
  - `technical-director`: Enforces software architecture, foundation ADRs, scalability, and security posture.
  - `delivery-producer`: Manages milestones (MVP, Beta, GA), sprint velocity, capacity, and scope governance.

- **Tier 2 — Department Leads (Claude Sonnet / MaxTurns: 20-25)**:
  - `lead-product-manager`: Owns PRDs, feature specs, business rules, and acceptance criteria.
  - `lead-engineer`: Reviews code, oversees engineering patterns, and audits technical debt.
  - `design-system-director`: Owns design tokens, Tailwind semantics, component libraries, and brand.
  - `growth-director`: Owns acquisition, technical SEO, activation funnels, and viral loops.
  - `ux-content-strategist`: Owns microcopy, transactional emails, error messages, and product voice.
  - `qa-lead`: Oversees test pyramids (Unit, Integration, E2E), CI automation, and quality gates.
  - `release-manager`: Manages semantic versioning (SemVer), feature flags, and deployments.
  - `localization-lead`: Manages internationalization (i18n), translation tables, and RTL layouts.

- **Tier 3 — Specialists (Claude Sonnet / Inherit)**:
  - *Core Engineering & Cloud*: `backend-engineer`, `cloud-infra-engineer`, `frontend-engineer`, `api-integrations-specialist`, `dev-tools-engineer`, `ai-engineer`, `web-perf-analyst`, `appsec-engineer`, `devops-engineer`, `billing-engineer` (Stripe/Paddle), `database-architect`, `data-telemetry-engineer`.
  - *SaaS Stack Specialists*: `nextjs-specialist`, `react-specialist`, `tailwind-shadcn-specialist`, `supabase-specialist`, `prisma-drizzle-specialist`, `fastapi-specialist`, `python-backend-specialist`, `go-specialist`, `queue-worker-specialist`, `auth-security-specialist`, `cloudflare-specialist`, `aws-specialist`, `docker-k8s-specialist`, `realtime-websockets-specialist`, `email-messaging-specialist`.
  - *Product, UX, QA & Ops*: `user-flow-architect`, `ux-designer`, `ui-motion-designer`, `pricing-economist`, `technical-writer`, `onboarding-specialist`, `rapid-prototyper`, `qa-manual-tester`, `accessibility-auditor` (WCAG 2.2 AA), `sre-observability-engineer`, `customer-success-ops`.

## Starting a New SaaS Project

To configure and run the studio in your workspace:
```bash
# In your workspace directory
/saas-start
```
Use `/saas-help` at any time to inspect your project's current lifecycle stage and next recommended action.

## Smart Code Discovery & Basinfy Protocol (Free vs Pro Code Mode)
- **Auto-detection**: Checks whether `.basinfy/` exists in the workspace (or if Basinfy MCP / CLI are active).
- **Basinfy Pro / Trial (Code Mode Active)**:
  - Multi-file feature & architecture discovery: `basinfy_discover` (with `digest: true`) or `basinfy_query_script` (`basinfy.discover(query, { digest: true })`). Delivers AST locate, barrel resolution, and 12-line previews in 1 turn (90%+ token reduction). NEVER loop `search` + `read`.
  - Compound programmatic queries & graph traversals: `basinfy_query_script` (CLI `basinfy script <code>`) executing in-memory `basinfy.*` API logic in a single turn. Inspect types via `basinfy_sdk_inspect`.
- **Basinfy Free (Core Smart Indexing)**:
  - Symbols & Code: `basinfy_prepare_edit` or `basinfy_locate`.
  - Configs & YAML: `basinfy_search` then targeted `basinfy_read`.
  - New Files: `basinfy_prepare_create`.
  - Impact & Architecture: `basinfy_impact` or `basinfy_orbit`.
- **Fallback**: Gracefully uses standard IDE/LLM tools (Grep, ripgrep, Glob, Read) when `.basinfy/` is not present.
