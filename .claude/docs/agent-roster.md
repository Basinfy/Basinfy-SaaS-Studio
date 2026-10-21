# Agent Roster

The following 49 canonical agents are available in Claude Code SaaS Studio. Each has a dedicated definition file in `.claude/agents/`. Use the agent best suited to the task at hand. When a task spans multiple domains, the coordinating agent (usually `delivery-producer` or the domain lead) delegates to specialists.

Which model an agent runs on is set by the `model:` line in its own file; `model-tiers.md` lists the agents that pin one (`product-director`, `technical-director`, `delivery-producer` on Opus; leads and specialists on Sonnet or session inherit).

## Tier 1 — Leadership Agents (Opus)
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `product-director` | Product Vision & UVP | Major strategic decisions, value proposition conflicts, roadmap, market positioning |
| `technical-director` | Technical Architecture | Foundation ADRs, scalability strategy, tech stack governance, security architecture |
| `delivery-producer` | Delivery Management | Sprint planning, milestone tracking, risk management, scope governance, velocity |

## Tier 2 — Department Lead Agents (Sonnet)
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `lead-product-manager` | Product Specifications | Authoring PRDs, user stories, business rules, acceptance criteria, workflows |
| `lead-engineer` | Code Architecture | System design, code reviews, API contracts, refactoring, technical debt tracking |
| `design-system-director` | Design System & UI | Semantic design tokens (Tailwind), component library (shadcn/ui), brand consistency |
| `growth-director` | Growth & Acquisition | Acquisition strategy, technical SEO, activation funnels, onboarding conversion |
| `ux-content-strategist` | UX Writing & Content | Microcopy, error states, onboarding tours, help center documentation, transactional emails |
| `qa-lead` | Quality Assurance | Test pyramid strategy (unit, integration, e2e), automated quality gates, bug triage |
| `release-manager` | Release Operations | Deployment pipelines, SemVer versioning, feature flags, changelogs, zero-downtime releases |
| `localization-lead` | Internationalization | i18n string externalization, l10n translation tables, regional formatting, RTL support |

## Tier 3 — Specialist Agents (Sonnet / Inherit)

### A. Core Engineering, Cloud & Data
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `backend-engineer` | Backend & APIs | REST/Route Handlers, Server Actions, Zod/Pydantic validation, core business logic |
| `cloud-infra-engineer` | Cloud Infrastructure | Vercel, AWS, Cloudflare, Docker containers, serverless architectures, edge computing |
| `frontend-engineer` | Frontend & React | Next.js/React components, Server vs Client components, state management, hydration |
| `api-integrations-specialist` | Integrations & Webhooks | Third-party API clients, incoming webhook handlers, asynchronous queues, resilience |
| `dev-tools-engineer` | Developer Tooling | Internal admin panels, seed scripts, developer tools, CLI utilities |
| `ai-engineer` | AI & LLM Systems | LLM integrations (Anthropic, OpenAI, Gemini), RAG pipelines, embeddings, vector stores |
| `web-perf-analyst` | Web Performance | Core Web Vitals (LCP, FID/INP, CLS), slow SQL query profiling, bundle optimization |
| `appsec-engineer` | Application Security | OWASP Top 10 compliance, XSS/CSRF/SQLi prevention, secrets audits, vulnerability scanning |
| `devops-engineer` | CI/CD & Deployments | GitHub Actions workflows, preview deployments, containerized builds, automated checks |
| `billing-engineer` | Billing & Subscriptions | Stripe/Paddle integration, subscription lifecycle, checkout webhooks, usage-based metering |
| `database-architect` | Database & PostgreSQL | PostgreSQL schema design, migrations, Row Level Security (RLS) policies, query indexes |
| `data-telemetry-engineer` | Product Telemetry | Telemetry instrumentation (PostHog, Mixpanel), event tracking schemas, analytics funnels |

### B. Tech Stack Specialists
| Agent | Stack / Domain | When to Use |
|-------|----------------|-------------|
| `nextjs-specialist` | Next.js App Router | App Router layouts, Server Components, Route Handlers, Middleware, ISR, Edge Runtime |
| `react-specialist` | React Ecosystem | React hooks, context, state management, render optimization, suspense boundaries |
| `tailwind-shadcn-specialist` | Tailwind & UI Kit | Tailwind CSS utility classes, Radix UI primitives, shadcn/ui components, dark/light themes |
| `supabase-specialist` | Supabase Platform | Supabase Auth, PostgreSQL RLS, Realtime websockets, Edge Functions, Storage buckets |
| `prisma-drizzle-specialist` | Modern ORMs | Prisma & Drizzle schema modeling, type-safe migrations, strict query construction |
| `fastapi-specialist` | Python FastAPI | Asynchronous FastAPI endpoints, Pydantic v2 validation, OpenAPI schema generation |
| `python-backend-specialist` | Python Backend | Django/Flask services, SQLAlchemy ORM, Celery/background tasks, data scripts |
| `go-specialist` | Go Microservices | Go Gin/Fiber services, high-throughput concurrent workers, low-latency microservices |
| `queue-worker-specialist` | Async Queues & Jobs | BullMQ, Redis, Inngest, Temporal, AWS SQS, background job processing and retries |
| `auth-security-specialist` | Auth & Identity | OAuth2, NextAuth/Auth.js, Clerk, WorkOS, RBAC roles, JWT session tokens, MFA |
| `cloudflare-specialist` | Cloudflare Edge | Cloudflare Workers, Pages, D1 SQL, KV store, R2 object storage, Edge Compute |
| `aws-specialist` | AWS Cloud Services | AWS Lambda, ECS/Fargate, S3, RDS PostgreSQL, CloudFront CDN, IAM roles |
| `docker-k8s-specialist` | Containers & K8s | Multi-stage Docker builds, docker-compose setups, Kubernetes manifests, Helm charts |
| `realtime-websockets-specialist` | Realtime Comms | WebSockets, Server-Sent Events (SSE), Socket.io, collaborative real-time sync |
| `email-messaging-specialist` | Email & Messaging | Resend, React Email templates, SendGrid, transactional emails, delivery reputation |

### C. Product, UX, QA & Operations
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `user-flow-architect` | User Experience Flows | Information architecture, conversion funnels, wireflows, cognitive load reduction |
| `ux-designer` | UI/UX Design | Usability testing, interface mockups, empty and error states, complex form patterns |
| `ui-motion-designer` | UI Motion & Animation | Micro-interactions, Framer Motion transitions, CSS keyframe animations, loading states |
| `pricing-economist` | SaaS Economics & Pricing | Pricing tiers (freemium, per-seat, usage-based), gross margin analysis, unit economics |
| `technical-writer` | Documentation | Developer docs, API references, tutorials, integration guides, quickstart docs |
| `onboarding-specialist` | User Onboarding | First-Time User Experience (FTUE), interactive product tours, activation checklists |
| `rapid-rapid-prototyper` | Rapid Prototyping | MVP spikes, interactive proof-of-concept prototypes, technical feasibility validation |
| `qa-manual-tester` | Manual QA Testing | Functional test cases, exploratory manual testing, acceptance criteria validation |
| `accessibility-auditor` | Accessibility (a11y) | WCAG 2.2 AA audits, keyboard navigation, screen reader accessibility, ARIA patterns |
| `sre-observability-engineer` | Observability & SRE | Monitoring (Sentry, Datadog), uptime alerting, health checks, incident response |
| `customer-success-ops` | Customer Operations | Support workflows, knowledge base FAQs, customer feedback loops, churn triage |
