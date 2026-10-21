# Coding Standards

- **TypeScript / Modern Language Strictness**: Strict type checking enabled (`strict: true`, no implicit `any`).
- **Input Validation**: All public APIs, route handlers, server actions, and webhook endpoints must validate incoming payloads using strict runtime schemas (Zod, Pydantic, or equivalent).
- **Architecture Decisions**: Architectural choices are recorded as ADRs in `docs/architecture/`. Number and rigor required is set by `modes.rigor`: all ADRs at `full`, critical foundation ADRs at `standard`, and lightweight decision logs at `minimal`.
- **Configuration & Secrets**: Application configuration, tuning limits, and secrets must be externalized in environment variables or configuration files (`project.yaml`), never hardcoded in source.
- **Server vs. Client Separation**: In React/Next.js applications, server components and client components must be cleanly separated (`use client` only when interactivity or browser APIs are required). Database and secret operations must never execute in client-bundled code.
- **Data Access & Multi-Tenancy**: All database queries must enforce tenant isolation (via Postgres Row Level Security or explicit tenant filtering). Raw SQL string concatenation is strictly forbidden.
- **Webhook Idempotency**: Payment and external event webhooks (e.g. Stripe, Clerk) must verify cryptographic signatures on raw request bodies and maintain an idempotent events table to prevent duplicate processing.
- **Conventional Commits**: Commits follow `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`. Reference the story ID in the message body (e.g., `Story: EPIC-001-S02`).
- **Verification-Driven Development**: Write tests alongside feature logic. Verify UI changes with Playwright / component screenshot evidence saved in `production/qa/evidence/`.

# Product Requirement Document (PRD) Standards

- All product requirement documents use Markdown and reside in `docs/specs/` (or `docs/prd/`).
- The 8 canonical SaaS PRD sections (required in `full` mode; 5 core sections in `standard`; `docs/specs/product-brief.md` in `minimal`):
  1. **Problem Statement**: Target customer pain, context, and expected impact.
  2. **Success Metrics**: Quantifiable business/product KPIs (e.g., activation rate, latency, conversion).
  3. **User Stories**: Persona-driven user stories in "As a [persona], I want [action], So that [value]" format.
  4. **Requirements Pool**: Prioritized functional & non-functional requirements (P0 must-have, P1 should-have, P2 nice-to-have).
  5. **Data Models / Schema**: Entities, relationships, Postgres/Prisma schemas, and migrations.
  6. **Security & Permissions**: RBAC roles, tenant isolation policies, and authentication checks.
  7. **Edge Cases**: Network timeouts, duplicate submissions, rate limits, and partial failures.
  8. **Acceptance Criteria**: Testable Given-When-Then criteria and definition of done.

# Testing & Evidence Standards

## Test Evidence by Story Type

All stories must produce verified test evidence before they can be marked Done (`/saas-story-done`):

| Story Type | Required Evidence | Location | Default Gate Level |
|---|---|---|---|
| **Logic & Domain Services** (pricing, calculations, workflows) | Automated unit tests (Vitest / Pytest) — 100% pass | `tests/unit/` | BLOCKING |
| **API & Integration** (multi-tier, routes, database) | Integration tests with test database or mock server | `tests/integration/` | BLOCKING |
| **UI & Component** (screens, forms, dashboards) | Playwright E2E test or retained screenshot evidence | `production/qa/evidence/` | BLOCKING |
| **Security & Permissions** (auth, RLS, tenant boundaries) | Tenant isolation & permission bypass test suite | `tests/integration/` | BLOCKING |
| **Config & Migrations** (schema changes, env updates) | Smoke check execution record | `production/qa/smoke-[date].md` | ADVISORY |

## Automated Test Rules

- **Determinism**: Tests must be 100% deterministic — no random seeds, timing races, or uncontrolled external network calls.
- **Isolation**: Each test sets up and tears down its own state; tests must run independently regardless of execution order.
- **No Hardcoded Magic Values**: Test fixtures should use factory functions or standardized fixtures.
- **Unit Independence**: Unit tests must not connect to live production databases or third-party APIs; use dependency injection or test containers.

## CI/CD Rules

- The automated test suite executes on every PR and commit to `main`.
- Failing tests block CI/CD pipeline deployments.
- Never disable or skip failing tests to bypass CI.
- Stack CI test commands:
  - **Next.js / TypeScript**: `npm test` or `npx vitest run` and `npx playwright test`
  - **FastAPI / Python**: `pytest --cov=src`
  - **Go**: `go test -v ./...`
