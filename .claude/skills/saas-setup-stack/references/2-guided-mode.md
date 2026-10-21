# Guided Stack Setup Mode

This guide walks through configuring the SaaS architecture stack in `project.yaml`.

---

### Step 1: Check for Existing Product Concept

Check if `design/product-concept.md` or `design/product-brief.md` exists:
- If neither exists:
  > "No product concept found. Consider running `/saas-brainstorm` first to discover what you want to build, or describe your SaaS product and target customers here."

---

### Step 2: Target Audience & Deployment Model

Prompt the user:
- What deployment model are you targeting?
  1. *Serverless / Edge (Next.js + Vercel / Cloudflare)*: Instant deployment, zero devops, edge caching.
  2. *API + Single Page App (FastAPI / Go + React/Vite)*: Heavy computational logic, high-throughput microservices.
  3. *Full-stack Monolith (Next.js + Node / Supabase)*: Fast iteration, unified TypeScript types across frontend and backend.
  4. *Containerized Cloud (Docker + AWS / Fly.io)*: Complete environment control, custom background workers.

---

### Step 3: Architecture Stack Selection

1. **Frontend**:
   - `Next.js` (React 19, App Router, TypeScript, Tailwind CSS) — Recommended default.
   - `React / Vite` (SPA with client-side routing).
   - `Vue / Nuxt` or `SvelteKit`.

2. **Backend**:
   - `Node.js` (Next.js Server Actions / Route Handlers).
   - `FastAPI` (Python async endpoints, ideal for AI/ML pipelines).
   - `Go` (High performance, low memory microservices).

3. **Database & ORM**:
   - `PostgreSQL` via `Supabase` or `Neon`.
   - ORM: `Prisma` or `Drizzle`.

4. **Auth & Payments**:
   - Auth: `Supabase Auth` / `Auth.js` / `Clerk`.
   - Payments: `Stripe` (Subscriptions, Checkout, Customer Portal).

---

### Step 4: Write Configuration

Generate `project.yaml` and local environment files (`.env.example`).
