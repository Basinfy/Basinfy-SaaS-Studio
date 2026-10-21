# Directory Structure

```text
/
├── CLAUDE.md                    # Master collaboration protocol and durable checkpointer
├── project.yaml                 # Machine-readable project config — stack, modes, stage (source of truth)
├── project.local.yaml.example   # Developer local overrides template (gitignored)
├── .claude/                     # Multi-tier agents, skills, hooks, rules, director gates, docs
│   ├── agents/                  # 49 specialized agents across 3 tiers
│   ├── director-gates/          # 28 formal phase gate acceptance criteria
│   ├── docs/                    # Workflow catalog, effect maps, config resolution, templates
│   ├── hooks/                   # Lifecycle, pre-commit validation, and deep-merge scripts
│   ├── rules/                   # Path-scoped code and architecture rules
│   └── scripts/                 # Deterministic inspection and governance utilities
├── src/                         # SaaS application source code (see stack root below)
│   ├── app/                     # Next.js App Router (pages, layouts, routes, server actions)
│   ├── components/              # UI components (ui/, forms/, layouts/, providers/)
│   ├── lib/                     # Shared utilities, database client, API clients, helpers
│   ├── server/                  # Server actions, tRPC routers, business domain services
│   └── styles/                  # Tailwind CSS, globals, typography
├── public/                      # Static assets (favicons, SVG icons, brand assets)
├── prisma/ or supabase/         # Database schemas, migrations, seed scripts, RLS policies
├── docs/                        # Technical documentation and specs
│   ├── architecture/            # Architecture api handlers, ADRs, control manifest, C4 diagrams
│   └── specs/                   # PRDs, user flows, personas, multi-tenancy, pricing models
├── design/                      # Design system tokens, styling guides, UI mockups
│   └── tokens/                  # tokens.json, typography, color palettes, brand guidelines
├── tests/                       # Comprehensive test suites
│   ├── unit/                    # Fast isolated unit tests (Vitest / Jest / Pytest)
│   ├── integration/             # Database and API route integration tests
│   ├── e2e/                     # End-to-end browser tests (Playwright)
│   └── smoke/                   # Critical-path smoke tests
├── prototypes/                  # Throwaway spikes and exploratory prototypes
├── production/                  # Production management
│   ├── epics/                   # Epics and user stories
│   ├── sprints/                 # Sprint plans, burndown metrics, status snapshots
│   ├── qa/                      # Test evidence logs and regression reports
│   ├── session-state/           # active.md (durable session checkpoint — gitignored)
│   └── session-logs/            # Subagent execution audit logs (gitignored)
└── studio-tests/                # Quality framework for testing and improving the studio itself
```

## The code root is stack-specific

SaaS applications adapt their code and route structure according to the configured stack in `project.yaml`:

| `stack.frontend` / `stack.backend` | Code Root | Routing & API Root | Test Location |
|---|---|---|---|
| **Next.js (App Router)** | `src/` (or root `app/`) | `src/app/api/` or `app/api/` | `tests/unit/`, `tests/e2e/` |
| **React + Vite / Node** | `src/` | `src/routes/` or `server/api/` | `src/**/*.test.ts`, `tests/` |
| **Python / FastAPI** | `src/` or `app/` | `src/routers/` or `app/api/` | `tests/`, `pytest` |
| **Go (Gin / Chi)** | `cmd/`, `internal/`, `pkg/` | `internal/api/` or `internal/handler/` | `internal/**/*_test.go` |

**Always resolve the code root from `project.yaml` (`stack.*`) before writing source files.**
The default SaaS code root is `src/`, with schemas located in `prisma/` or `supabase/migrations/` and end-to-end tests in `tests/e2e/`.
