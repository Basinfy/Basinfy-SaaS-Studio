# Basinfy SaaS Studio — OpenAI Codex & ChatGPT Instructions

This workspace operates under the **Basinfy SaaS Studio** autonomous engineering standard for full-lifecycle SaaS platforms, APIs, and modern cloud applications.

## 1. Studio Architecture & 50 Specialized Agents
The studio organizes 50 specialized agents into 3 distinct operational tiers:
- **Tier 1 — Strategic Directors (Opus / GPT-4o / O-series)**:
  - `product-director`: Guards product vision, ICP, UVP, positioning, pricing, and strategic scope.
  - `technical-director`: Enforces master software architecture, ADRs, scalability, and security posture.
  - `delivery-producer`: Manages milestones (MVP, Beta, GA), sprint velocity, capacity, and scope governance.

- **Tier 2 — Department Leads**:
  - `lead-product-manager`: Owns PRDs, functional specifications, business rules, and acceptance criteria.
  - `lead-engineer`: Reviews code, oversees engineering patterns, and audits technical debt.
  - `design-system-director`: Owns design tokens, Tailwind semantics, component libraries, and brand.
  - `growth-director`: Owns acquisition, technical SEO, activation funnels, and viral loops.
  - `ux-content-strategist`: Owns microcopy, transactional emails, error messages, and product voice.
  - `qa-lead`: Oversees test pyramids (Unit, Integration, E2E), CI automation, and quality gates.
  - `release-manager`: Manages semantic versioning (SemVer), feature flags, and deployments.
  - `localization-lead`: Manages internationalization (i18n), translation tables, and RTL layouts.

- **Tier 3 — Execution Specialists**:
  - 39 dedicated engineering specialists across Frontend (Next.js, React, Tailwind, shadcn/ui), Backend (FastAPI, Python, Go, Node), Database (Supabase, PostgreSQL, Prisma, Drizzle), Payments (Stripe), Cloud & Infra (AWS, Cloudflare, Docker, K8s), Security, Privacy & DPO (`dpo-privacy-specialist`), and QA.

## 2. 95 Slash Workflows (/saas-*)
Always interpret and execute commands prefixed with `/saas-*` according to the canonical skills in `.claude/skills/` or `.agents/skills/`:
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

## 6. Smart Code Discovery & Dynamic Basinfy Protocol (Free vs Pro Code Mode)
Always determine the code discovery mechanism before reading, searching, or modifying codebase files:
- **Dynamic Detection**: Check if the workspace contains a .basinfy/ directory OR if Basinfy MCP tools (asinfy_session_start, asinfy_search, asinfy_locate, asinfy_prepare_edit, asinfy_read, asinfy_impact, asinfy_discover, asinfy_query_script, etc.) or the CLI asinfy are available.
- **When Basinfy is Detected (.basinfy/ exists or MCP active)**:
  Route code discovery through the **Basinfy Smart Indexing Protocol** first. Standard IDE Grep/Read/rg are strictly the last resort fallback:
  - **Tier Detection (Pro Code Mode vs. Free Standard)**:
    - **Basinfy Pro / Trial (Code Mode Active)**: Triggered when asinfy_discover or asinfy_query_script are present in MCP tools, or CLI asinfy discover / script are available:
      - **Multi-File Exploration & Feature Discovery**: ALWAYS use asinfy_discover (with digest: true) or asinfy_query_script with asinfy.discover(query, { digest: true }) (CLI asinfy discover <query> --digest). Delivers AST locate, barrel resolution, confidence scores, and targeted 12-line code previews in ONE turn (90%+ token reduction). NEVER loop multiple asinfy_search + asinfy_read calls across files.
      - **Compound / Multi-Module Programmatic Analysis**: Use asinfy_query_script (CLI asinfy script <code>) for in-memory JavaScript/TypeScript execution with direct access to the asinfy.* API object (asinfy.discover, asinfy.search, asinfy.read, asinfy.locate, asinfy.orbit, asinfy.impact, asinfy.gateEdit, asinfy.prepareEdit, asinfy.prepareCreate). Executes compound queries and graph traversals in a single turn with zero intermediate token bloat. Inspect types via asinfy_sdk_inspect.
    - **Basinfy Free (Core Smart Indexing)**:
      - **Symbols & Code**: asinfy_prepare_edit or asinfy_locate
      - **Configs, YAML & Literal Search**: asinfy_search then targeted asinfy_read (never loop search+read indefinitely)
  - **Universal Governance & Lifecycle (Free & Pro)**:
    - **New Files**: asinfy_prepare_create before generating new components or modules
    - **Impact & Architecture**: asinfy_impact or asinfy_orbit before modifying shared interfaces
    - **Session Lifecycle**: One bootstrap at start (asinfy_session_start or asinfy_brief), one update at end (asinfy_session_end or asinfy_update).
    - **Fallback Ladder**: CLI asinfy search / asinfy read / asinfy discover -> IDE Grep/Read only for binaries or paths outside the index.
- **Fallback Mode (No .basinfy/ directory)**: If .basinfy/ is not present, seamlessly use standard IDE tools (Grep, ripgrep, Glob, Read).
## 7. Dynamic Human Interface (Portuguese & English) / English Engine
The studio provides full dynamic bilingual support for the human developer while keeping the technical engine in English:
- **Dynamic Language Matching & Translation for User Prompts**:
  - If the user communicates in **Portuguese** (or `project.yaml` defines `locale: pt-BR`): All interactive questions, option choices, confirmation dialogs, and next-step proposals MUST be translated and rendered in **Brazilian Portuguese (PT-BR)**.
  - **CRITICAL OVERRIDE**: This rule strictly OVERRIDES any English question strings or templates found in skills or documentation. NEVER display English questions or options to a Portuguese developer.
  - If the user communicates in **English** (or `locale: en`): All questions, options, and dialogs are rendered in **English**.
- **English Engineering Engine**: In both cases, the agent's internal reasoning, code generation, unit tests, PRD/ADR authoring, git commits, and subagent delegation execute in **English** (EN) to maximize reasoning depth and benchmark code quality.

## 8. Unskippable Workflow Autotrigger Table
Always-on prose is budget-capped. Prefer loading on-demand skills immediately when initiating any of the following lifecycle actions:
- **Onboarding & Setup**: Read `.claude/skills/saas-start/SKILL.md` or `.agents/skills/saas-start/SKILL.md`
- **Architecture & ADRs**: Read `.claude/skills/saas-create-architecture/SKILL.md` or `.agents/skills/saas-create-architecture/SKILL.md`
- **PRDs & Design System**: Read `.claude/skills/saas-design-system/SKILL.md` or `.agents/skills/saas-design-system/SKILL.md`
- **Auth, RBAC & Multi-Tenancy**: Read `.claude/skills/saas-team-auth-access/SKILL.md`
- **Stripe Billing & Webhooks**: Read `.claude/skills/saas-team-billing/SKILL.md`
- **Sprint & Epics Planning**: Read `.claude/skills/saas-sprint-plan/SKILL.md` or `.agents/skills/saas-create-stories/SKILL.md`
- **Story Implementation**: Read `.claude/skills/saas-dev-story/SKILL.md` or `.agents/skills/saas-dev-story/SKILL.md`
- **Story Sign-off & QA**: Read `.claude/skills/saas-story-done/SKILL.md` or `.agents/skills/saas-qa-plan/SKILL.md`
- **Security Audit & RLS Gate**: Read `.claude/skills/saas-security-audit/SKILL.md`
- **Release & Deployment**: Read `.claude/skills/saas-release-checklist/SKILL.md`
