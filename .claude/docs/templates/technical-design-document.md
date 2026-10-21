# System Architecture Blueprint: [Product Name]

## Document Status
- **Version**: 1.0
- **Last Updated**: [YYYY-MM-DD]
- **Author**: `lead-engineer` / `cloud-architect`
- **Reviewer**: `technical-director`
- **Related ADRs**: [ADR-001, ADR-002, ADR-003]
- **Related PRDs**: [`docs/specs/features-modules-index.md`]

---

## 1. Technology Stack & Framework Inventory

| Architectural Tier | Selected Technology | Version Pinned | Rationale / ADR Link |
|---|---|---|---|
| **Frontend Framework** | [e.g., Next.js 15 (App Router)] | [^15.0.0] | Server Components, SEO, fast SSR |
| **Backend & API Layer** | [e.g., Next.js Server Actions & Route Handlers] | [Node 24 / React 19] | Type-safe RPC, minimal boilerplate |
| **Database & Pooling** | [e.g., Supabase Postgres with PgBouncer] | [Postgres 16] | Row Level Security, relational integrity |
| **ORM / Query Builder** | [e.g., Prisma ORM / Drizzle] | [^6.0.0] | Type-safe migrations & models |
| **Authentication** | [e.g., Supabase Auth / Clerk / WorkOS] | [v2] | JWT sessions, multi-tenant RBAC, OAuth |
| **Billing & Payments** | [e.g., Stripe Checkout & Webhooks] | [2024-11-20] | Industry standard merchant infrastructure |
| **Styling & Design System** | [e.g., Tailwind CSS + shadcn/ui] | [Tailwind v4 / v3.4] | Zero-runtime CSS, accessible Radix primitives |
| **Hosting & CI/CD** | [e.g., Vercel + GitHub Actions] | [Edge / Serverless] | Global CDN, instant preview deployments |

---

## 2. High-Level C4 Architecture

### 2.1 C4 Container Diagram
```text
[Customer Browser / Mobile Client]
               │  (HTTPS / TLS 1.3)
               ▼
[Global Edge CDN (Vercel / Cloudflare)]
               │
       ┌───────┴───────────────────────┐
       ▼                               ▼
[Static UI / SSR Pages]       [API Route Handlers & Server Actions]
                                       │
                      ┌────────────────┼────────────────┐
                      ▼                ▼                ▼
            [Auth Provider]    [Postgres (RLS)]   [Stripe Webhooks]
              (Clerk/Supabase)   (Multi-Tenant)      (Idempotent)
```

---

## 3. Data Flow & Boundary Security

### 3.1 Authentication & Request Lifecycle
1. Client issues request with secure HTTP-Only session cookie.
2. Edge middleware validates session signature and extracts `userId`.
3. Server Action / API Handler loads user's `workspace_id` from database context.
4. Database queries execute with Postgres RLS enforcing `workspace_id = auth.workspace_id()`.
5. Sensitive credentials or DB connections never leak to client bundle.

### 3.2 Asynchronous Event Ingestion & Webhooks
- Webhook payloads (e.g. Stripe, external SaaS integrations) verify cryptographic signature against raw body bytes.
- Incoming event IDs are deduplicated against an `idempotent_events` table before executing side-effects.

---

## 4. Non-Functional Performance & Reliability Budgets

| Performance Dimension | SLA / Budget Target | Monitoring / Verification |
|---|---|---|
| **API Response Latency (p95)** | < 250 ms | Server APM (CloudWatch / Datadog) |
| **Core Web Vitals (LCP)** | < 2.0 s on 4G mobile | Lighthouse / PageSpeed Insights in CI |
| **Initial JS Bundle Size** | < 200 KB gzipped | `@next/bundle-analyzer` |
| **Database Query Budget** | < 25 ms (all queries indexed) | Postgres `pg_stat_statements` |
| **Uptime Commitment** | 99.9% availability | BetterStack / Pingdom health check |

---

## 5. Deployment, Health Checks & Disaster Recovery

- **Health Endpoint**: `GET /api/health` returns HTTP 200 with DB ping status.
- **Database Migrations**: Applied during build step via `prisma migrate deploy` (zero-downtime expand-contract migrations).
- **Backups & RPO/RTO**: Automated daily PITR (Point-In-Time Recovery) backups on Postgres (RPO: 1 hour, RTO: 30 minutes).
