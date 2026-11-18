# /saas-setup-stack — Section 4: Update Stack Configuration & Reference Docs

> Part of `/saas-setup-stack`. Follow `locale` and `user_profile` (`founder` vs `developer`) from `project.yaml`.

## 4.1 Founder / Layperson Golden Stack Shortcut (`user_profile: founder`)

When `project.user_profile` is `founder` (or the user states they are non-technical / unsure which technologies to pick), DO NOT overwhelm them with raw framework or ORM jargon. Present the **1-Click Recommended SaaS Golden Stack** in plain business terms:

- **`(Recommended) Complete SaaS Golden Stack`**:
  - **Screens & App (`Next.js + Tailwind/shadcn`)**: Fast, modern web & mobile-ready interface.
  - **Customer Vault & Login (`Supabase PostgreSQL + Prisma`)**: Secure database with automatic company/customer isolation.
  - **Automatic Billing (`Stripe`)**: Monthly/annual card subscriptions, checkout, and customer cancellation portal.
  - **Cloud Hosting (`Vercel`)**: Instant deployment with generous free tier.
- **`Choose technologies manually (Developer Mode)`**: Full selection across Next.js, FastAPI (Python), Go, Cloudflare Workers, Drizzle, Clerk, and AWS.

## 4.2 Language Selection (Developer Mode — Next.js)

When in `developer` mode with Next.js:
- **A) `(Recommended) TypeScript`** — Static type-safety, autocompletion, and end-to-end schema validation.
- **B) `JavaScript`** — Dynamic scripting for lightweight prototypes.

## 4.3 Record Stack in `CLAUDE.md` (When Applicable) and `docs/engine-reference/`

Show the selected stack summary clearly and ask: `"May I write these stack settings to CLAUDE.md and project.yaml?"` (translated to PT-BR when `locale: pt-BR`).
- If `CLAUDE.md` contains a `## Technology Stack` section or `ENGINE-REFERENCE-IMPORT` marker, update it in place; if `CLAUDE.md` uses the compact Master Constitution (where `project.yaml` is the single source of truth), keep `CLAUDE.md` intact and record the version reference under `docs/engine-reference/<stack>/VERSION.md` (or `docs/stack-reference/<stack>/VERSION.md`).
