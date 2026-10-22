# /saas-setup-stack — Section 4: Update CLAUDE.md Technology Stack

> Part of `/saas-setup-stack`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 4. Update CLAUDE.md Technology Stack

### Language Selection (Next.js only)

If Next.js was chosen, ask the user which language configuration to use **before** showing the proposed Technology Stack:

> "Next.js supports two primary options:
>
>   **A) TypeScript (Recommended)** — Full static type-safety, autocompletion, best integration with App Router and server components.
>   **B) JavaScript** — Dynamic, zero build-step typing. Best for rapid scripts and prototypes.
>
> Which will this project primarily use?"

Record the choice (default: TypeScript). It determines the CLAUDE.md template, naming conventions, specialist routing, and which agent is spawned for code files throughout the project.

### Backend Language (FastAPI & Cloudflare)

- **FastAPI**: Python 3.11+ (async, Pydantic v2).
- **Cloudflare Workers**: TypeScript (Wrangler + Hono) or Go. Default to TypeScript.

---

Read `CLAUDE.md` and show the user the proposed Technology Stack changes.
Ask: "May I write these stack settings to `CLAUDE.md`?"

Wait for confirmation before making any edits.

Update the Technology Stack section, replacing the `[CHOOSE]` placeholders with the actual values:

**For Next.js** — use the template matching the language chosen above. See `references/saas-stack-config.md` (**A1**):
```markdown
- **Frontend**: Next.js 15+ (App Router), React 19, TypeScript
- **Styling**: Tailwind CSS + shadcn/ui (Radix UI)
- **Backend**: Next.js Server Actions & Route Handlers
- **Database & ORM**: PostgreSQL (Supabase / Neon) + Prisma / Drizzle ORM
- **Authentication**: Supabase Auth / Clerk / NextAuth (Auth.js)
- **Payments & Billing**: Stripe Checkout, Customer Portal & Webhooks
- **Testing**: Vitest (Unit/Integration) + Playwright (E2E)
- **Deployment**: Vercel / Cloudflare Pages
```

**For FastAPI:**
```markdown
- **Frontend**: Next.js / React (Vite), TypeScript, Tailwind CSS
- **Backend**: FastAPI (Python 3.11+), Pydantic v2, Uvicorn
- **Database & ORM**: PostgreSQL + SQLAlchemy 2.0 / Alembic migrations
- **Authentication**: OAuth2 JWT Bearer tokens / Supabase Auth
- **Payments & Billing**: Stripe Webhooks & Subscription billing
- **Testing**: Pytest (Backend) + Vitest / Playwright (Frontend)
- **Deployment**: Docker container on AWS ECS / Fly.io / GCP Cloud Run
```

**For Cloudflare Workers:**
```markdown
- **Frontend**: Next.js / React / Cloudflare Pages, TypeScript, Tailwind CSS
- **Backend**: Cloudflare Workers (TypeScript / Hono)
- **Database & Storage**: Cloudflare D1 (SQL) / KV / R2
- **Authentication**: JWT session tokens / Clerk / WorkOS
- **Payments & Billing**: Stripe API SDK & Webhook handlers
- **Testing**: Vitest + Miniflare
- **Deployment**: Cloudflare Workers via Wrangler CLI
```

### Stack reference import

In the same CLAUDE.md write, set the **Engine Version Reference** import to the
chosen engine. Find the line marked `ENGINE-REFERENCE-IMPORT` (an
`@docs/engine-reference/<engine>/VERSION.md` line under its comment) and Edit it
to point at the configured engine:
- Next.js → `@docs/engine-reference/nextjs/VERSION.md`
- FastAPI → `@docs/engine-reference/fastapi/VERSION.md`
- Cloudflare → `@docs/engine-reference/cloudflare/VERSION.md`

This keeps a FastAPI or Cloudflare project from loading the Next.js reference in every
session. It is idempotent — re-running `/saas-setup-stack` for a different
engine rewrites the same line. (The target `docs/engine-reference/<engine>/`
directory is created in Section 7, Populate Engine Reference Docs, if it does not yet exist.)

---
