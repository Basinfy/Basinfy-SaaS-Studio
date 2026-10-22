# Basinfy Domain Experience Library

This directory persists verified domain engineering experiences, operational rules, and debugging resolutions across sessions.

## The Experience Triad Schema
Each entry documents a concrete resolution distilled upon `/saas-story-done`:
- **`cue`**: The exact error signature, framework quirk, or architectural friction encountered.
- **`lesson`**: The concise, operational general rule or procedure that resolved it.
- **`evidence`**: The diff snippet, test receipt, or command output proving the resolution.

## Distinction: Workspace Facts vs. General Procedures
- **Workspace Facts** (anchored to current project): e.g., *"In this workspace, the Stripe webhook secret is stored in STRIPE_WEBHOOK_SECRET_LIVE"*.
- **General Procedures** (reusable across domain): e.g., *"Verify Stripe webhook signatures against raw request body (req.text()) before JSON parsing"*.

## Indexed Domains
- `auth`: Authentication, sessions, RBAC, tenant isolation, Supabase Auth, Clerk.
- `billing`: Stripe Checkout, Webhooks, Customer Portal, subscription lifecycle.
- `database`: PostgreSQL Row Level Security (RLS), Prisma / Drizzle ORM, migrations.
- `api`: Next.js Server Actions, Route Handlers, FastAPI endpoints, rate limiting.
