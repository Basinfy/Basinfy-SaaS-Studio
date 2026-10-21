# SaaS Stack Configuration — setup-stack reference

Lookup tables for `/saas-setup-stack` defining stack options, templates, naming conventions, and specialist routing for web and SaaS applications.

---

### A1. CLAUDE.md Technology Stack Templates

**Next.js 14+ Fullstack (Standard):**
```markdown
- **Frontend**: Next.js 14+ (App Router), React, TypeScript
- **Styling**: Tailwind CSS + shadcn/ui (Radix UI)
- **Backend**: Next.js Server Actions & Route Handlers
- **Database & ORM**: PostgreSQL (Supabase / Neon) + Prisma / Drizzle ORM
- **Authentication**: Supabase Auth / Clerk / NextAuth (Auth.js)
- **Payments & Billing**: Stripe Checkout, Customer Portal & Webhooks
- **Testing**: Vitest (Unit/Integration) + Playwright (E2E)
- **Deployment**: Vercel / Cloudflare Pages
```

**FastAPI + React / Next.js (Python Backend):**
```markdown
- **Frontend**: Next.js / React (Vite), TypeScript, Tailwind CSS
- **Backend**: FastAPI (Python 3.11+), Pydantic v2, Uvicorn
- **Database & ORM**: PostgreSQL + SQLAlchemy 2.0 / Alembic migrations
- **Authentication**: OAuth2 JWT Bearer tokens / Supabase Auth
- **Payments & Billing**: Stripe Webhooks & Subscription billing
- **Testing**: Pytest (Backend) + Vitest / Playwright (Frontend)
- **Deployment**: Docker container on AWS ECS / Fly.io / GCP Cloud Run
```

**Go + Next.js (High Performance Microservices):**
```markdown
- **Frontend**: Next.js, React, TypeScript, Tailwind CSS
- **Backend**: Go (1.22+), Gin / Fiber, net/http
- **Database & ORM**: PostgreSQL + GORM / pgx / sqlc
- **Authentication**: JWT session tokens / WorkOS / Clerk
- **Payments & Billing**: Stripe API SDK (Go)
- **Testing**: Go `testing` package + Vitest
- **Deployment**: Multi-stage Docker container on AWS / GCP / Fly.io
```

---

### A2. Naming Conventions

**TypeScript / React / Next.js:**
- Components: PascalCase (e.g., `UserAvatar.tsx`, `BillingTable.tsx`)
- Hooks: camelCase with `use` prefix (e.g., `useSubscription.ts`, `useUserSession.ts`)
- Utilities / Libs: camelCase (e.g., `formatCurrency.ts`, `stripeClient.ts`)
- API Route Handlers: `route.ts` inside feature folders (e.g., `app/api/webhooks/stripe/route.ts`)
- Database Tables: snake_case plural (e.g., `users`, `subscriptions`, `workspaces`, `invoices`)
- Database Columns: snake_case (e.g., `created_at`, `stripe_customer_id`, `plan_tier`)
- Types / Interfaces: PascalCase (e.g., `UserProfile`, `SubscriptionTier`, `WorkspaceRole`)
- Environment Variables: UPPER_SNAKE_CASE (e.g., `DATABASE_URL`, `STRIPE_SECRET_KEY`)

**Python / FastAPI:**
- Modules & Files: snake_case (e.g., `user_service.py`, `stripe_router.py`)
- Classes & Pydantic Models: PascalCase (e.g., `UserCreateRequest`, `SubscriptionResponse`)
- Functions & Variables: snake_case (e.g., `calculate_usage()`, `active_subscriptions`)
- Routes: kebab-case paths (e.g., `/api/v1/user-profiles`, `/api/v1/billing-portal`)

---

### A3. Stack Specialists Routing

When an agent needs to be spawned for a task or file type, route using this table:

| Technology / Layer | Primary Specialist | Secondary Specialist |
|---|---|---|
| Next.js App Router, Server Components, Route Handlers | `nextjs-specialist` | `frontend-engineer` |
| React UI components, custom hooks, state | `react-specialist` | `frontend-engineer` |
| Tailwind CSS, Radix UI, shadcn/ui components | `tailwind-shadcn-specialist` | `ui-motion-designer` |
| Supabase Auth, PostgreSQL RLS, Storage | `supabase-specialist` | `database-architect` |
| Prisma / Drizzle ORMs, schemas, migrations | `prisma-drizzle-specialist` | `database-architect` |
| FastAPI, Pydantic, Python asynchronous services | `fastapi-specialist` | `backend-engineer` |
| Django/Flask, SQLAlchemy, Python background tasks | `python-backend-specialist` | `backend-engineer` |
| Go microservices, Gin/Fiber, high throughput | `go-specialist` | `backend-engineer` |
| BullMQ, Redis, Celery, Temporal async queues | `queue-worker-specialist` | `backend-engineer` |
| NextAuth, Clerk, OAuth2, RBAC, JWT security | `auth-security-specialist` | `appsec-engineer` |
| Stripe Checkout, subscriptions, customer portal | `billing-engineer` | `pricing-economist` |
| Cloudflare Workers, Pages, D1, KV, R2 | `cloudflare-specialist` | `cloud-infra-engineer` |
| AWS Lambda, ECS, S3, RDS, CloudFront | `aws-specialist` | `cloud-infra-engineer` |
| Docker containers, docker-compose, CI/CD | `docker-k8s-specialist` | `devops-engineer` |
| WebSockets, Server-Sent Events, realtime sync | `realtime-websockets-specialist` | `backend-engineer` |
| Resend, React Email, transactional notifications | `email-messaging-specialist` | `ux-content-strategist` |
