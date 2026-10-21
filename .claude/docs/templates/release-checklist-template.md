## Release Checklist: [Version] -- [Environment]
Generated: [Date]

### Codebase & Build Health
- Scanned: [N] source files (or `NOT ASSESSED — [reason]`)
- TODO count: [N] ([list top 5 if many])
- FIXME count: [N] ([list all -- potential blockers])
- HACK count: [N] ([list all -- need review])
- [ ] Clean production build succeeds (`npm run build` / `docker build`)
- [ ] Zero TypeScript / linter errors or compiler warnings
- [ ] Dependency audit clean (`npm audit` / `pip-audit`) with zero critical/high CVEs
- [ ] Frontend bundle size within budget (< 200KB initial JS chunk)
- [ ] Release version and git commit tag correctly set ([version] @ [commit_sha])

### Quality & Performance Gates
- Open bugs (`production/qa/bugs/`): [N] S1, [N] S2, [N] S3 -- or `NOT ASSESSED — no bug records`
- [ ] Zero open S1 (Critical/Blocker) bugs
- [ ] Zero open S2 (High) bugs (`workflow: full` strict requirement)
- [ ] Zero open S3 (Medium) bugs (`workflow: full` strict requirement)
- [ ] Core user journeys tested and signed off by QA:
  - [ ] User signup, login, password reset, and session invalidation
  - [ ] Onboarding wizard and tenant workspace provisioning
  - [ ] Core product workflow end-to-end
  - [ ] Billing checkout, plan upgrade, invoice download, and cancellation
- [ ] Performance benchmarks met:
  - [ ] API latency: p95 < 100ms, p99 < 250ms under peak load
  - [ ] Lighthouse Core Web Vitals: LCP < 2.5s, FID/INP < 100ms, CLS < 0.1
  - [ ] Concurrency load test passed (sustained traffic without memory leaks)
- [ ] Automated test suite 100% passing (Unit, Integration, E2E Playwright)

> The release gate (`/saas-gate-check release`) blocks any open S1–S3 bug at `workflow: full`,
> with no exceptions; at `standard` and `minimal` it blocks open S1 only, and an open
> S2 or S3 is a risk to record in the Rationale.

### Database & Migration Integrity
- [ ] All database migrations applied successfully (`prisma migrate deploy` / `alembic upgrade head`)
- [ ] Multi-tenant Row-Level Security (RLS) policies verified active on all tenant tables
- [ ] Foreign keys, unique constraints, and essential indexes confirmed
- [ ] Database connection pooler (PgBouncer / Supabase pooler) configured with adequate capacity
- [ ] Automated database backup verified with Point-in-Time Recovery (PITR)
- [ ] Downward migration / rollback procedure documented and verified

### Infrastructure, DNS & Security
- [ ] Production custom domain configured with DNS propagation verified
- [ ] SSL/TLS 1.3 certificate active with automatic renewal
- [ ] Cloudflare / WAF active with DDoS mitigation and rate-limiting rules enabled
- [ ] Environment variables and production secrets verified in secure vault
- [ ] Cross-Origin Resource Sharing (CORS) strictly restricted to authorized production domains
- [ ] Security headers active (Strict-Transport-Security, Content-Security-Policy, X-Frame-Options)

### Billing & Integrations Verification
- [ ] Stripe Live Mode API keys active (`pk_live_...`, `sk_live_...`)
- [ ] Stripe Webhook endpoint configured (`https://app.example.com/api/webhooks/stripe`)
- [ ] Stripe Webhook signature verification (`STRIPE_WEBHOOK_SECRET`) tested and passing
- [ ] Customer billing portal enabled and localized
- [ ] Tax collection / Stripe Tax configured if applicable

### Transactional Email & Messaging
- [ ] Domain verification passed in email provider (Resend, Postmark, AWS SES)
- [ ] SPF, DKIM, and DMARC DNS records verified
- [ ] Transactional email deliverability tested (Welcome, Password Reset, Invoice, Team Invite)
- [ ] Unsubscribe links and transactional email headers compliant with CAN-SPAM / GDPR

### Observability & Incident Response
- [ ] Sentry / error tracking initialized with production DSN and release version tagged
- [ ] Product analytics (PostHog, Mixpanel) initialized and receiving events
- [ ] Uptime monitoring pinging `/api/health` with automated incident alert triggers
- [ ] Production logging level set to `INFO` or `WARN` (sensitive PII masked)
- [ ] 72-hour launch on-call engineering roster assigned
- [ ] Rollback runbook documented and accessible to deployment leads

### Go-To-Market & Compliance
- [ ] Terms of Service and Privacy Policy published and accessible from landing and app footer
- [ ] Cookie consent banner active (if analytics/tracking cookies used)
- [ ] Product Hunt launch assets and copy ready (Gallery, Maker comment, Tagline)
- [ ] Social share preview cards (OpenGraph `og:image`, Twitter Cards) verified
- [ ] Support channels active (support email, live chat widget, or Discord community)

### Go / No-Go: [READY / NOT ASSESSED / NOT READY]

First match wins: **NOT READY** if any blocking item fails; else **NOT ASSESSED**
if any section or item came out `NOT ASSESSED` (name each one); else **READY**. NOT
ASSESSED outranks READY — an unassessed section is not a passed one — and ranks
below NOT READY, so a known blocker is never buried behind it.

**Rationale:**
[Summary of readiness assessment. List any blocking items that must be
resolved before launch. If NOT READY, list the specific items that need
resolution and estimated time to address them.]

**Sign-offs Required:**
- [ ] QA Lead
- [ ] Lead Software Engineer
- [ ] Security & DevOps Lead
- [ ] Product Owner
