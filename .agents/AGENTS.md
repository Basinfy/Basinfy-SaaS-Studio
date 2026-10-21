# Basinfy SaaS Studio — Agent Architecture & Engineering Rules

This workspace operates under the **Basinfy SaaS Studio** autonomous engineering standard for full-lifecycle SaaS platforms, APIs, and modern cloud applications.

## 1. Studio Architecture & 49 Specialized Agents
The studio organizes 49 specialized agents into 3 distinct operational tiers:
- **Tier 1 — Strategic Directors (Claude Opus / MaxTurns: 30)**:
  - `product-director`: Guards product vision, ICP, UVP, positioning, pricing, and strategic scope.
  - `technical-director`: Enforces master software architecture, ADRs, scalability, and security posture.
  - `delivery-producer`: Manages milestones (MVP, Beta, GA), sprint velocity, capacity, and scope governance.

- **Tier 2 — Department Leads (Claude Sonnet / MaxTurns: 20-25)**:
  - `lead-product-manager`: Owns PRDs, functional specifications, business rules, and acceptance criteria.
  - `lead-engineer`: Reviews code, oversees engineering patterns, and audits technical debt.
  - `design-system-director`: Owns design tokens, Tailwind semantics, component libraries, and brand.
  - `growth-director`: Owns acquisition, technical SEO, activation funnels, and viral loops.
  - `ux-content-strategist`: Owns microcopy, transactional emails, error messages, and product voice.
  - `qa-lead`: Oversees test pyramids (Unit, Integration, E2E), CI automation, and quality gates.
  - `release-manager`: Manages semantic versioning (SemVer), feature flags, and deployments.
  - `localization-lead`: Manages internationalization (i18n), translation tables, and RTL layouts.

- **Tier 3 — Execution Specialists (Claude Sonnet / MaxTurns: 20)**:
  - 38 dedicated engineering specialists across Frontend (Next.js, React, Tailwind, shadcn/ui), Backend (FastAPI, Python, Go, Node), Database (Supabase, PostgreSQL, Prisma, Drizzle), Payments (Stripe), Cloud & Infra (AWS, Cloudflare, Docker, K8s), Security, and QA.

## 2. 74 Slash Workflows (/saas-*)
Always interpret and execute commands prefixed with `/saas-*` according to the canonical skills in `.claude/skills/`:
- **Onboarding & Discovery**: `/saas-start`, `/saas-help`, `/saas-setup-stack`, `/saas-project-stage-detect`, `/saas-brainstorm`
- **Specifications & Architecture**: `/saas-design-system`, `/saas-create-architecture`, `/saas-architecture-decision`, `/saas-map-features`, `/saas-gate-check`
- **Sprints & Implementation**: `/saas-sprint-plan`, `/saas-create-epics`, `/saas-create-stories`, `/saas-dev-story`, `/saas-story-done`, `/saas-code-review`
- **Quality, Security & Launch**: `/saas-qa-plan`, `/saas-security-audit`, `/saas-perf-profile`, `/saas-load-test`, `/saas-release-checklist`, `/saas-launch-checklist`

## 3. The 5-Step Collaborative Loop
Never perform silent, unconfirmed, or destructive file modifications. Follow:
`Question -> Options -> Decision -> Draft -> Approval`
Before writing or editing code, always ask: `"May I write this to [filepath]?"`

## 4. Durable Session State
- Session checkpointing is maintained at `production/session-state/active.md`.
- Read `active.md` first upon session start or context restoration.

## 5. Security & Engineering Standards
- Zero secrets committed to git.
- Mandatory PostgreSQL Row Level Security (RLS) on all user data tables.
- Stripe webhooks must verify signatures against raw request bodies (`rawBody`).
- Strictly follow technology stack standards defined in `project.yaml`.
