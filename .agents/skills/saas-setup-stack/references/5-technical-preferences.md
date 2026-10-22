# /saas-setup-stack — Section 5: Populate Technical Preferences

> Part of `/saas-setup-stack`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 5. Populate Technical Preferences

**In this file:**

- Stack & Language Selection
- Naming Conventions (web/SaaS standards)
- Platform & Client Support Section
- Performance Budgets & Testing Standards
- SaaS Specialists Routing
- Collaborative Step

After updating CLAUDE.md, create or update `.claude/docs/technical-preferences.md` with
SaaS-appropriate defaults. Read the existing template first, then fill in:

### Stack & Language Section
- Fill from the stack choices made in step 4 (`stack.frontend`, `stack.backend`, `stack.database`, `stack.orm`)

### Naming Conventions (SaaS defaults)

**For TypeScript / Next.js / React:**
- Components: PascalCase matching file (e.g., `UserAvatar.tsx`, `BillingCheckoutModal.tsx`)
- Hooks: camelCase with `use` prefix (e.g., `useWorkspaceMembers.ts`)
- Utilities / Libs: kebab-case or camelCase (e.g., `stripe-client.ts`, `format-currency.ts`)
- Types / Interfaces: PascalCase (e.g., `WorkspaceRole`, `OrganizationSubscription`)
- API Route Handlers: `route.ts` inside App Router folders (e.g., `app/api/webhooks/stripe/route.ts`)
- Server Actions: camelCase exported from `actions.ts` (e.g., `updateUserProfile`)

**For Python / FastAPI:**
- Modules / Files: snake_case (e.g., `billing_router.py`, `database_pool.py`)
- Classes / Models: PascalCase (e.g., `TenantWorkspace`, `UserSession`)
- Functions / Methods: snake_case (e.g., `get_organization_subscription()`)
- Pydantic Schemas: PascalCase with `Schema` or `Response`/`Request` suffix (e.g., `InvoiceResponse`)
- Constants: UPPER_SNAKE_CASE (e.g., `DEFAULT_PAGE_SIZE`, `MAX_INVITE_TOKEN_AGE`)

**For Go / Gin / Fiber:**
- Packages: lowercase single-word (e.g., `billing`, `identity`)
- Exported Types/Functions: PascalCase (e.g., `ProcessPayment`, `TenantContext`)
- Internal Types/Functions: camelCase (e.g., `validateCardToken`)

### Platform & Client Support Section

Populate `## Platform & Client Support` using the target audience and deployment tiers:

| Client Target | Desktop Web | Mobile Responsive | Touch Optimised |
|---|---|---|---|
| B2B SaaS (Desktop primary) | Full (1280px+) | Responsive (768px+) | Standard |
| B2C Web App (Mobile first) | Full | First-class (<640px) | Full gesture support |
| Internal Admin / Portal | Full (1440px+) | Basic viewport | Minimal |
| Cross-device Portal | Full | Full | Full |

Example filled section:
```markdown
## Platform & Client Support
- **Target Devices**: Modern Desktop Browsers (Chrome, Safari, Firefox, Edge), Mobile Web (iOS Safari, Android Chrome)
- **Viewport Breakpoints**: Mobile (320px-640px), Tablet (641px-1024px), Desktop (1025px+)
- **Primary Interaction**: Pointer / Touch responsive with full keyboard accessibility (WCAG 2.1 AA)
- **Keyboard Shortcuts**: Global command palette (Cmd+K / Ctrl+K), modal esc-close, form tab order
- **Theme Support**: System preference default with user toggle (Dark / Light)
```

### Performance Budgets & Testing Standards

- **Core Web Vitals Budgets**:
  - Largest Contentful Paint (LCP): < 2.0s
  - Interaction to Next Paint (INP): < 200ms
  - Cumulative Layout Shift (CLS): < 0.1
  - Initial JS Bundle: < 200KB gzip
  - API p95 Latency: < 250ms
- **Testing Frameworks**:
  - Frontend: Vitest + React Testing Library (unit/component), Playwright (E2E)
  - Backend: Pytest with async fixtures (FastAPI/Python) or Node Test Runner / Jest
  - Security: OWASP ZAP smoke checks, Postgres RLS policy assertions
- **Forbidden Patterns**:
  - No client-side database secrets or raw service keys (`SUPABASE_SERVICE_ROLE_KEY` on client)
  - No unguarded raw database queries without tenant ID scoping
  - No unbounded queries without pagination limits
- **Allowed Libraries**:
  - Explicitly document approved packages in `project.yaml` and lockfiles.

### SaaS Specialists Routing

Populate `## SaaS Specialists Routing` in `technical-preferences.md`:

```markdown
## SaaS Specialists Routing
- **Lead Architecture**: lead-engineer, technical-director
- **Frontend / Next.js / React**: nextjs-specialist, react-specialist, tailwind-shadcn-specialist
- **Backend / API**: fastapi-specialist, python-backend-specialist, go-specialist
- **Database / Schema / ORM**: database-architect, prisma-drizzle-specialist, supabase-specialist
- **Auth & Access Control**: auth-security-specialist, appsec-engineer
- **Billing & Subscriptions**: billing-engineer, pricing-economist
- **Cloud & Deployment**: cloud-infra-engineer, devops-engineer, cloudflare-specialist, docker-k8s-specialist
- **Realtime & Messaging**: realtime-websockets-specialist, email-messaging-specialist

### File Extension / Path Routing

| Path / File Pattern | Specialist to Spawn |
|---|---|
| `app/`, `pages/`, `components/` (React/Next.js) | nextjs-specialist, react-specialist |
| `styles/`, Tailwind, Shadcn UI components | tailwind-shadcn-specialist |
| `api/`, `routers/`, `services/` (Python/FastAPI) | fastapi-specialist, python-backend-specialist |
| `prisma/`, `drizzle/`, `migrations/`, SQL schemas | database-architect, prisma-drizzle-specialist |
| `supabase/` (RLS policies, edge functions) | supabase-specialist |
| `lib/stripe.ts`, billing endpoints, webhooks | billing-engineer |
| `auth/`, middleware JWT verification, RBAC rules | auth-security-specialist |
| `Dockerfile`, `docker-compose.yml`, K8s manifests | docker-k8s-specialist |
| `wrangler.toml`, Cloudflare Workers / Pages | cloudflare-specialist |
| `tests/` (unit, integration, e2e) | qa-lead, dev-tools-engineer |
```

### Collaborative Step
Present the filled-in preferences to the user:
> "Here are the default technical preferences for [frontend] + [backend] ([database] + [orm]). The naming conventions, performance budgets, and specialist routing are ready. Want to customize any of these, or may I save them to `.claude/docs/technical-preferences.md`?"

Wait for approval before writing the file.

---
