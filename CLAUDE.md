# Basinfy SaaS Studio -- Autonomous SaaS & Software Studio Agent Architecture

Full-lifecycle SaaS and modern software development managed through 50 coordinated Claude Code subagents across 7 lifecycle phases. Each agent owns a specific technical or strategic domain, enforcing strict separation of concerns, architectural discipline, and enterprise software quality.

## Technology Stack

- **Frontend**: Next.js 14+ (App Router) / React / Tailwind CSS / shadcn/ui
- **Backend / APIs**: Next.js Server Actions & Route Handlers / FastAPI / Go / Node.js
- **Database**: PostgreSQL (Supabase / Neon) with Row Level Security (RLS) & Prisma / Drizzle ORM
- **Authentication**: Supabase Auth / NextAuth (Auth.js) / Clerk with RBAC
- **Billing & Subscriptions**: Stripe / Paddle / LemonSqueezy (Webhooks with raw body signature check)
- **Deployment & Cloud**: Vercel / Cloudflare Workers / AWS / Docker
- **Version Control**: Git with trunk-based development

> **Note**: Stack-specialist agents exist for Next.js, React, Tailwind/shadcn, Supabase, Prisma/Drizzle, FastAPI, Go, Docker/K8s, AWS, Cloudflare, and Stripe Billing. Use the specialists matching your stack.

## Project Structure

@.claude/docs/directory-structure.md

## Technical Preferences

`project.yaml` at the repo root is the primary config store — stack, specialists, naming, platform, performance budgets, and modes. Skills resolve it dynamically via `resolve_config` (see `.claude/docs/config-resolution.md`).

`.claude/docs/technical-preferences.md` is the fallback reference read on demand when a key is absent from `project.yaml`.

## Coordination Rules

@.claude/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
  (exempt: `active.md` appends, agent memory, a subagent's new file at the path its orchestrating skill named; see `.claude/rules/agent-memory.md`).
- Agents MUST show drafts or summaries before requesting approval.
- Multi-file changes require explicit approval for the full changeset.
- No commits without explicit user instruction.
- A skipped or dismissed question is not an answer: act on nothing, re-ask in plain text and wait.
- Started outside this file's folder? Warn first: hooks, deny rules and the ask-first mode load only when Claude Code starts here.
- **Dynamic Human Interface (Portuguese & English) / English Engine**:
  - **Dynamic Language Detection & Translation**: The human-facing interface (`AskUserQuestion`, `ask_question`, options, dialogs) adapts dynamically to the developer:
    - If the user interacts in **Portuguese** (or `project.yaml` defines `locale: pt-BR`): All questions, selectable options, modal dialogs, and confirmations MUST be presented in **Brazilian Portuguese (PT-BR)**.
    - **CRITICAL OVERRIDE**: This rule strictly OVERRIDES any English question strings or templates found in skills or documentation. Any quoted question or option template in a skill (e.g. `Ask: "Does this rule summary look complete?"`, `Options: Yes...`) is an example and MUST be translated into natural Brazilian Portuguese before asking the user. NEVER display English questions or options to a Portuguese-speaking developer.
    - If the user interacts in **English** (or `locale: en`): All questions, selectable options, and confirmations appear in **English**.
  - **Agent Engine in English**: In both cases, internal code synthesis, architecture reasoning, tests, commits, and subagent coordination execute in **English** to guarantee maximum LLM intelligence, benchmark precision, and universal code standards.

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no stack configured and no product concept,
> run `/saas-start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Smart Code Discovery & Dynamic Basinfy Protocol

Whenever agents, specialists, or workflows explore the codebase, discover endpoints, or locate symbols:
- **Environment Detection**: Check if .basinfy/ exists in the workspace (or if Basinfy MCP tools / basinfy CLI are active).
- **If Basinfy is Present (.basinfy/ detected)**: Route code discovery through the **Basinfy Smart Indexing Protocol** first. Standard IDE Grep/Read/rg are strictly the last resort fallback:
  - Symbols / Functions / Components: basinfy_prepare_edit or basinfy_locate (delivers definition, gate checks, and impact graph in one call)
  - Configs / Routes / YAML / Text: basinfy_search then basinfy_read
  - Document Headings: basinfy_search to find headings instead of regex grepping ^#
  - New Files: basinfy_prepare_create before generating new components or modules
  - Impact Analysis: basinfy_impact or basinfy_orbit for cross-file blast radius checks
  - Fallback Ladder: Brute-force grep / ripgrep / IDE Read are strictly last-resort fallbacks (e.g., for binary assets or files outside the index root).
- **Fallback (No .basinfy/ directory)**: When .basinfy/ is not present, gracefully use standard IDE tools (Grep, ripgrep, Glob, Read).

## Context Management

Read `.claude/docs/context-management.md` on demand — it is a reference, not session context. Two of its conventions are load-bearing and cited by name elsewhere in the repo:

- **`production/session-state/active.md` is the session checkpoint.** The file is the memory, not the conversation. Read it first after any compaction, crash, or `/clear`.
- **Helpers in `.claude/scripts/` emit observations, never verdicts.** A script that scores or judges will eventually contradict a mode or override it cannot see. (Cited by `artifact-check.sh` and `adr-dep-graph.sh`.)

## Studio Workflows & Slash Commands (/saas-*)

Basinfy SaaS Studio provides 95 specialized workflows covering the full lifecycle of software development:
- **First-time Onboarding & Diagnosis**: /saas-start, /saas-help, /saas-setup-stack, /saas-project-stage-detect
- **Product & Specifications**: /saas-brainstorm, /saas-map-features, /saas-design-system, /saas-create-architecture, /saas-architecture-decision
- **Sprints & Implementation**: /saas-sprint-plan, /saas-create-epics, /saas-create-stories, /saas-dev-story, /saas-story-done
- **Privacy & Security**: /saas-lgpd, /saas-team-lgpd, /saas-security-audit
- **Quality & Launch**: /saas-code-review, /saas-perf-profile, /saas-gate-check, /saas-release-checklist, /saas-launch-checklist

Run /saas-help at any time to inspect the full workflow catalog and receive recommendations based on the active stage.
