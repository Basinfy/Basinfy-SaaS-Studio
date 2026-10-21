# SaaS Studio Agent Architecture -- Quick Start Guide

## What Is This?

This is a complete Claude Code agent architecture for SaaS and modern web application development. It
organizes 49 specialized AI agents into a studio hierarchy that mirrors
real software product engineering teams, with defined responsibilities, delegation
rules, and coordination protocols. It includes stack-specialist agents
for Next.js, FastAPI, and Cloudflare — each with dedicated sub-specialists for
major stack subsystems (React, Supabase, Tailwind, Prisma/Drizzle, Docker/K8s, etc.).
All design agents and templates are grounded in
established product design and SaaS growth methodologies (Jobs To Be Done, Product-Led Growth,
Customer Journey Mapping, Unit Economics). Use whichever stack set matches your project.

## The Default Path: Rigor Minimal

`modes.rigor` defaults to `minimal` (`/saas-start` infers it from what you describe and shows it
before saving; `/saas-settings` changes it any time). At `minimal` the path to code is four steps:

1. `/saas-setup-stack` -- configure the stack
2. `/saas-brainstorm` -- writes the one-page `design/product-brief.md`, in place of the
   concept doc, systems decomposition and per-system PRDs
3. `/saas-create-stories` -- turns the brief's MVP list into stories under
   `production/epics/<slug>/`; the brief's build order is the plan, so there is
   no `/saas-create-epics` or `/saas-sprint-plan`
4. `/saas-dev-story` then `/saas-story-done`, story by story -- `/saas-story-done` names the
   next story, and `/saas-help` knows this route

Nothing at `minimal` runs `/saas-gate-check`, so `project.stage` stays at Concept.
Every skill still runs at any tier. The trade: no PRDs catch design problems
before code. Raise rigor with `/saas-settings` when the product outgrows the brief;
`standard` and `full` are the longer pipelines under
[First Steps for a New Project](#first-steps-for-a-new-project).

## How to Use

### 1. Understand the Hierarchy

There are three tiers of agents:

- **Tier 1 — Directors** who make high-level decisions (they run on Opus)
  - `product-director` -- product vision, market fit, and strategic alignment
  - `technical-director` -- architecture, security, and technology decisions
  - `delivery-producer` -- sprint scheduling, coordination, and delivery tracking

- **Tier 2 — Department leads** who own their domain
  - `lead-product-manager`, `lead-engineer`, `design-system-director`, `growth-director`,
    `ux-content-strategist`, `qa-lead`, `release-manager`, `localization-lead`

- **Tier 3 — Specialists** who execute within their domain
  - Product managers, backend/frontend engineers, designers, technical writers, testers, stack specialists

The tiers are seniority of role. Most agents run on your session's model; the
agent file's own `model:` line says which do not
(`.claude/docs/model-tiers.md`).

### 2. Pick the Right Agent for the Job

Ask yourself: "What department would handle this in a real studio?"

| I need to... | Use this agent |
|-------------|---------------|
| Design a new feature or workflow | `lead-product-manager` |
| Write backend APIs & business logic | `backend-engineer` |
| Create animations & micro-interactions | `ui-motion-designer` |
| Write technical documentation & microcopy | `technical-writer` |
| Plan the next sprint | `delivery-producer` |
| Review code quality | `lead-engineer` |
| Write test cases | `qa-manual-tester` |
| Design user navigation & page flows | `user-flow-architect` |
| Fix a performance or bundle problem | `web-perf-analyst` |
| Set up CI/CD & deployment | `devops-engineer` |
| Design pricing tiers & billing models | `billing-engineer` |
| Resolve a product vision conflict | `product-director` |
| Make an architecture decision | `technical-director` |
| Manage a release | `release-manager` |
| Prepare strings for translation | `localization-lead` |
| Prototype a new interaction or UI flow | `rapid-prototyper` |
| Review code for security issues | `appsec-engineer` |
| Check accessibility compliance | `accessibility-auditor` |
| Get Cloudflare Workers advice | `cloudflare-specialist` |
| Get FastAPI advice | `fastapi-specialist` |
| Get Next.js advice | `nextjs-specialist` |
| Design cloud infrastructure & AWS services | `aws-specialist` |
| Configure containers & Kubernetes deployment | `docker-k8s-specialist` |
| Implement realtime communication & WebSockets | `realtime-websockets-specialist` |
| Build transactional emails & notifications | `email-messaging-specialist` |
| Design Python backend architecture & services | `python-backend-specialist` |
| Build high-performance Go services | `go-specialist` |
| Manage asynchronous queues & background jobs | `queue-worker-specialist` |
| Audit authentication & OAuth/SSO security | `auth-security-specialist` |
| Write idiomatic React & state management | `react-specialist` |
| Design Tailwind CSS styling & shadcn/ui components | `tailwind-shadcn-specialist` |
| Configure Supabase database, RLS & auth | `supabase-specialist` |
| Design Prisma / Drizzle ORM schemas & migrations | `prisma-drizzle-specialist` |
| Monitor system reliability, metrics & observability | `sre-observability-engineer` |
| Manage customer support, feedback & onboarding | `customer-success-ops` |
| Brainstorm a new product idea | Use `/saas-brainstorm` skill |

### 3. Use Slash Commands for Common Tasks

| Command | What it does |
|---------|-------------|
| `/saas-start` | First-time onboarding — asks where you are, guides you to the right workflow |
| `/saas-help` | Context-aware "what do I do next?" — reads your current phase and artifacts |
| `/saas-project-stage-detect` | Analyze project state, detect stage, identify gaps |
| `/saas-setup-stack` | Configure stack + version, populate reference docs |
| `/saas-adopt` | Brownfield audit and migration plan for existing projects |
| `/saas-brainstorm` | Guided product concept ideation from scratch |
| `/saas-map-features` | Decompose concept into modules, map dependencies, guide per-feature PRDs |
| `/saas-design-system` | Guided, section-by-section PRD authoring for a single feature or module |
| `/saas-quick-design` | Lightweight spec for small changes — tuning, tweaks, minor additions |
| `/saas-review-all-prds` | Cross-PRD consistency and product design review |
| `/saas-propagate-design-change` | Find ADRs and stories affected by a PRD change |
| `/saas-design-tokens` | Guided, section-by-section Design Tokens authoring — colors, typography, spacing |
| `/saas-asset-spec` | Generate per-asset specifications and AI generation prompts from PRDs or user profiles |
| `/saas-ux-design` | Author UX specs (screen/flow, app shell, interaction patterns) |
| `/saas-ux-review` | Validate UX specs for accessibility and PRD alignment |
| `/saas-create-architecture` | Master architecture document for the application |
| `/saas-architecture-decision` | Creates an ADR |
| `/saas-architecture-review` | Validate all ADRs, dependency ordering, PRD traceability — writes the index to `docs/architecture/requirements-traceability.md` |
| `/saas-create-control-manifest` | Flat engineering rules sheet from Accepted ADRs |
| `/saas-create-epics` | Translate PRDs + ADRs into epics (one per architectural module) |
| `/saas-create-stories` | Break a single epic into implementable story files |
| `/saas-dev-story` | Read a story and implement it — routes to the correct engineer agent |
| `/saas-sprint-plan` | Creates or updates sprint plans |
| `/saas-sprint-status` | Quick 30-line sprint snapshot |
| `/saas-story-readiness` | Validate a story is implementation-ready before pickup |
| `/saas-story-done` | End-of-story completion review — verifies acceptance criteria |
| `/saas-estimate` | Produces structured effort estimates |
| `/saas-design-review` | Reviews a design document |
| `/saas-code-review` | Reviews code for quality and architecture |
| `/saas-pricing-audit` | Analyzes SaaS pricing models, unit economics, and margins |
| `/saas-asset-audit` | Audits assets for compliance |
| `/saas-content-audit` | PRD-specified requirements vs. implemented — find gaps |
| `/saas-scope-check` | Detect scope creep against plan |
| `/saas-perf-profile` | Performance profiling and bottleneck ID |
| `/saas-tech-debt` | Scan, track, and prioritize tech debt |
| `/saas-gate-check` | Validate phase readiness (PASS/CONCERNS/NOT ASSESSED/FAIL) |
| `/saas-consistency-check` | Scan all PRDs for cross-document inconsistencies (conflicting schemas, names, rules) |
| `/saas-security-audit` | Audit for security vulnerabilities: auth bypass, RLS leaks, secret exposure, rate limits |
| `/saas-reverse-document` | Generate design/architecture docs from existing code |
| `/saas-milestone-review` | Reviews milestone progress |
| `/saas-retrospective` | Runs sprint/milestone retrospective |
| `/saas-bug-report` | Structured bug report creation |
| `/saas-usability-test` | Creates or analyzes usability test feedback |
| `/saas-onboard` | Generates onboarding docs for a role |
| `/saas-release-checklist` | Validates pre-release checklist |
| `/saas-launch-checklist` | Complete launch readiness validation |
| `/saas-changelog` | Generates changelog from git history |
| `/saas-patch-notes` | Generate user-facing patch notes |
| `/saas-hotfix` | Emergency fix with audit trail |
| `/saas-post-launch-monitor` | Prepare a focused post-launch monitoring for known issues discovered after release |
| `/saas-prototype` | Concept prototype — validate core idea before writing PRDs (Phase 1) |
| `/saas-vertical-slice` | Production-quality end-to-end build — validate full user workflow (Phase 4) |
| `/saas-localize` | Localization scan, extract, validate |
| `/saas-team-core-feature` | Orchestrate full core feature team pipeline |
| `/saas-team-content` | Orchestrate full content strategy & docs team pipeline |
| `/saas-team-ui` | Orchestrate full UI team pipeline |
| `/saas-team-release` | Orchestrate full release team pipeline |
| `/saas-team-polish` | Orchestrate full polish team pipeline |
| `/saas-team-growth` | Orchestrate full growth & monetization pipeline |
| `/saas-team-auth-access` | Orchestrate full auth & access control pipeline |
| `/saas-team-billing` | Orchestrate billing team for subscription lifecycles, plans, and quotas |
| `/saas-team-qa` | Orchestrate full QA team cycle — test plan, test cases, smoke check, sign-off |
| `/saas-qa-plan` | Generate a QA test plan for a sprint or feature |
| `/saas-bug-triage` | Re-prioritize open bugs, assign to sprints, surface systemic trends |
| `/saas-smoke-check` | Run critical path smoke test gate before QA hand-off (PASS/FAIL) |
| `/saas-load-test` | Generate a load test protocol for extended sessions |
| `/saas-regression-suite` | Map coverage to PRD critical paths, flag gaps, maintain regression suite |
| `/saas-test-setup` | Scaffold test framework + CI pipeline for the project's stack (run once) |
| `/saas-test-helpers` | Generate stack-specific test helper libraries and factory functions |
| `/saas-test-flakiness` | Detect flaky tests from CI history, flag for quarantine or fix |
| `/saas-test-evidence-review` | Quality review of test files and manual evidence — ADEQUATE/INCOMPLETE/MISSING |
| `/saas-skill-test` | Validate skill files for compliance and correctness (static / spec / audit) |
| `/saas-skill-improve` | Improve a skill using a test-fix-retest loop — diagnose, propose fix, rewrite, verify |

### 4. Use Templates for New Documents

Templates are in `.claude/docs/templates/`:

- `prd-template.md` -- for new features and modules
- `architecture-decision-record.md` -- for technical decisions
- `architecture-traceability.md` -- sample layout for a PRD requirement to ADR to
  story index (`/saas-architecture-review` writes its own index to
  `docs/architecture/requirements-traceability.md`)
- `risk-register-entry.md` -- for new risks
- `user-persona-profile.md` -- for user personas
- `test-plan.md` -- for feature test plans
- `sprint-plan.md` -- for sprint planning
- `milestone-definition.md` -- for new milestones
- `user-flow-document.md` -- for user navigation flows
- `product-pillars.md` -- for core product pillars
- `design-system-tokens.md` -- for visual style reference
- `system-architecture-document.md` -- for per-module technical designs
- `post-mortem.md` -- for project/milestone retrospectives
- `brand-voice-tone-guide.md` -- for brand copy and tone style reference
- `release-checklist-template.md` -- for platform release checklists
- `changelog-template.md` -- for user-facing patch notes
- `release-notes.md` -- for user-facing release notes
- `incident-response.md` -- for live incident response playbooks
- `product-concept.md` -- for initial product concepts (JTBD, Personas, Value Prop)
- `product-brief.md` -- for the one-page brief that replaces the concept doc at `rigor: minimal`
- `pitch-document.md` -- for pitching the product to stakeholders
- `saas-pricing-model.md` -- for pricing tiers and unit economics
- `multi-tenancy-spec.md` -- for organization isolation and multi-tenancy
- `features-modules-index.md` -- for feature decomposition and dependency mapping
- `project-stage-report.md` -- for project stage detection output
- `design-doc-from-implementation.md` -- for reverse-documenting existing code into PRDs
- `architecture-doc-from-code.md` -- for reverse-documenting code into architecture docs
- `concept-doc-from-prototype.md` -- for reverse-documenting prototypes into concept docs
- `ux-spec.md` -- for per-screen UX specifications (layout zones, states, events)
- `app-shell-navigation-spec.md` -- for whole-product navigation shell and layout specs
- `accessibility-requirements.md` -- for project-wide accessibility tier and feature matrix
- `ui-component-patterns.md` -- for standard UI controls and SaaS component patterns
- `customer-journey-map.md` -- for user journey stages and retention hooks
- `usage-limits-quota-model.md` -- for plan tiers, rate limits, and quota enforcement
- `test-evidence.md` -- template for recording manual test evidence (screenshots, walkthrough notes)

### 5. Follow the Coordination Rules

1. Work flows down the hierarchy: Directors -> Leads -> Specialists
2. Conflicts escalate up the hierarchy
3. Cross-department work is coordinated by the `delivery-producer`
4. Agents do not modify files outside their domain without delegation
5. All decisions are documented

## First Steps for a New Project

**Don't know where to begin?** Run `/saas-start`. It asks where you are and routes
you to the right workflow. No assumptions about your application, stack, or experience level.

The paths below walk the `standard`/`full` pipeline. At `rigor: minimal` (the
default), follow [The Default Path](#the-default-path-rigor-minimal) instead.

If you already know what you need, jump directly to the relevant path:

### Path A: "I have no idea what to build"

1. **Run `/saas-start`** (or `/saas-brainstorm open`) — guided creative exploration:
   what excites you, market opportunities, target personas, constraints
   - Generates 3 concepts, helps you pick one, defines core user flow and pillars
   - Produces a product concept document and recommends a modern stack
2. **Set up the stack** — Run `/saas-setup-stack` (uses the brainstorm recommendation)
   - Configures CLAUDE.md, detects knowledge gaps, populates reference docs
   - Writes stack, naming conventions, and performance budgets to `project.yaml`
     (the source of truth), mirrored to `.claude/docs/technical-preferences.md`
   - If the stack version is newer than the LLM's training data, it fetches
     current docs from the web so agents suggest correct APIs
3. **Validate the concept** — Run `/saas-design-review design/prd/product-concept.md`
   (or `design/product-brief.md`, if `/saas-brainstorm` wrote the one-page brief)
4. **Prototype the feature** — Run `/saas-prototype [core-feature]` (1 day at most) to
   validate the core user interaction before writing PRDs
5. **Decompose into modules** — Run `/saas-map-features` to map all modules and dependencies
6. **Design each module** — Run `/saas-design-system [module-name]` (or `/saas-map-features next`)
   to write PRDs in dependency order, informed by the prototype findings
7. **Plan the first sprint** — After architecture and `/saas-vertical-slice`, run `/saas-sprint-plan new`
8. Start building

### Path B: "I know what I want to build"

If you already have a product concept and stack choice:

1. **Set up the stack** — Run `/saas-setup-stack [stack] [version]`
   (e.g., `/saas-setup-stack nextjs 14.2`) — also creates technical preferences
2. **Write the Product Pillars** — delegate to `product-director`
3. **Decompose into modules** — Run `/saas-map-features` to enumerate modules and dependencies
4. **Design each module** — Run `/saas-design-system [module-name]` for PRDs in dependency order
5. **Create the initial ADR** — Run `/saas-architecture-decision`
6. **Create the first milestone** in `production/milestones/`
7. **Plan the first sprint** — Run `/saas-sprint-plan new`
8. Start building

### Path C: "I know the product but not the stack"

If you have a concept but don't know which stack fits:

1. **Run `/saas-setup-stack`** with no arguments — it will ask about your product's
   needs (web/mobile, realtime, auth, database, scaling, language preferences) and recommend
   a stack based on your answers
2. Follow Path B from step 2 onward

### Path D: "I have an existing project"

If you have design docs, prototypes, or code already:

1. **Run `/saas-start`** (or `/saas-project-stage-detect`) — analyzes what exists,
   identifies gaps, and recommends next steps
2. **Run `/saas-adopt`** if you have existing PRDs, ADRs, or stories — audits
   internal format compliance and builds a numbered migration plan to fill gaps
   without overwriting your existing work
3. **Configure stack if needed** — Run `/saas-setup-stack` if not yet configured
4. **Validate phase readiness** — Run `/saas-gate-check` to see where you stand
5. **Plan the next sprint** — Run `/saas-sprint-plan new`

## File Structure Reference

```
CLAUDE.md                          -- Master config (read this first, ~80 lines)
project.yaml                       -- Machine-readable project config (stack, modes, stage) — source of truth
.claude/
  settings.json                    -- Claude Code hooks and project settings
  agents/                          -- 49 agent definitions (YAML frontmatter)
  skills/                          -- 74 slash command definitions (YAML frontmatter)
  hooks/                           -- 15 event hooks (.sh, wired by settings.json) + yaml-helper.sh, update-check.sh
  rules/                           -- 14 path-specific rule files
  docs/
    quick-start.md                 -- This file
    technical-preferences.md       -- Legacy fallback for project.yaml config (mirror; see project.yaml at repo root)
    coding-standards.md            -- Coding and design doc standards
    coordination-rules.md          -- Agent coordination rules
    context-management.md          -- Context budgets and compaction instructions
    directory-structure.md         -- Project directory layout
    workflow-catalog.yaml          -- 7-phase pipeline definition (read by /saas-help)
    setup-requirements.md          -- System prerequisites (Git Bash, jq, Python)
    settings-local-template.md     -- Personal settings.local.json guide
    CLAUDE-local-template.md       -- Personal CLAUDE.local.md guide (gitignored overrides)
    templates/                     -- 62 document templates (+ per-section guidance)
```
