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

## Smart Code Discovery & Dynamic Basinfy Protocol (Free vs Pro Code Mode)

Whenever agents, specialists, or workflows explore the codebase, discover endpoints, or locate symbols:
- **Environment Detection**: Check if .basinfy/ exists in the workspace (or if Basinfy MCP tools / asinfy CLI are active).
- **If Basinfy is Present (.basinfy/ detected)**: Route code discovery through the **Basinfy Smart Indexing Protocol** first. Standard IDE Grep/Read/rg are strictly the last resort fallback:
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
    - **Document Headings**: asinfy_search to find headings instead of regex grepping ^#
    - **Session Lifecycle**: One bootstrap at start (asinfy_session_start or asinfy_brief), one update at end (asinfy_session_end or asinfy_update).
    - **Fallback Ladder**: CLI asinfy search / asinfy read / asinfy discover -> IDE Grep/Read only for binaries or paths outside the index.
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
