# Launch Checklist: [SaaS Product Name]
Target Launch: [Date or DRY RUN]
Generated: [Date]
Version: [Version, e.g. v1.0.0]
Domain: [https://app.yourdomain.com]

---

## 1. Code & Build Readiness

### Build Health
- [ ] Production build succeeds cleanly (`npm run build` or framework equivalent)
- [ ] Zero TypeScript / typecheck errors (`npx tsc --noEmit` exits 0)
- [ ] Linter passes with zero errors (`npm run lint` exits 0)
- [ ] All automated unit tests pass (`npm test` / `pytest`)
- [ ] All integration & API route tests pass
- [ ] Initial JavaScript bundle size within budget (< 200KB gzip per route)
- [ ] Git working tree clean; release tag created in version control

### Code Quality & Hygiene
- [ ] TODO count: [N] (zero blocker TODOs in production paths)
- [ ] FIXME count: [N] (zero unresolved FIXMEs)
- [ ] Zero console.log or raw debug prints in server or client code
- [ ] Zero hardcoded localhost URLs, test credentials, or mock flags
- [ ] All feature flags set to production launch values
- [ ] Structured error boundaries implemented for all client views

### Application Security (AppSec)
- [ ] Zero exposed API keys, secret tokens, or private keys in repository or client bundles
- [ ] Database connection credentials passed exclusively via server environment variables
- [ ] Multi-tenant isolation verified: Row-Level Security (RLS) active on all PostgreSQL tables
- [ ] JWT / session tokens signed with strong random secret and transmitted via HTTP-only Secure SameSite cookies
- [ ] Rate limiting active on sensitive endpoints (auth, password reset, checkout, API keys)
- [ ] Dependency CVE scan clean (`npm audit` / `pip-audit` zero CRITICAL or HIGH vulnerabilities)

---

## 2. Product & UX Readiness

### Design Tokens & Brand Assets
- [ ] Favicon package deployed (favicon.ico, 16x16, 32x32, 192x192, apple-touch-icon, manifest.json)
- [ ] OpenGraph image (`og:image` 1200x630px) and Twitter card preview tested
- [ ] Dark / Light theme tokens consistent with contrast ratios (WCAG 2.1 AA)
- [ ] Empty states, loading skeletons, and error toasts designed and implemented for all views

### User Experience & Core Journeys
- [ ] Sign-up / Login / OAuth authentication loop verified end-to-end
- [ ] Onboarding wizard / setup checklist guides new user to first moment of value
- [ ] Core business workflow functions without friction or dead ends
- [ ] Team collaboration (invitations, RBAC roles: Owner, Admin, Member) verified
- [ ] Account settings: profile edit, password change, session logout, account deletion functional

### Accessibility & Responsiveness
- [ ] WCAG 2.1 AA color contrast compliance verified across all text and buttons
- [ ] Full keyboard navigation operational (Tab, Shift+Tab, Enter, Space, Escape, Cmd+K palette)
- [ ] Mobile responsive layout verified across phone (<640px), tablet (768-1024px), and desktop viewports
- [ ] Screen reader aria-labels and roles present on all interactive and modal elements

---

## 3. Infrastructure & Cloud Deployment

### Hosting & Deployment Provider
- [ ] Production hosting provisioned (Vercel, Cloudflare, AWS, Fly.io, or Docker K8s)
- [ ] Production branch auto-deployment / CI/CD pipeline verified
- [ ] Preview / Staging environment active for pre-release validation
- [ ] Deployment rollback strategy documented and tested

### Custom Domain, DNS & SSL
- [ ] Apex domain (A records) and www/app subdomains (CNAME) configured
- [ ] SSL/TLS certificate issued, active, and auto-renewing (Let's Encrypt / Cloudflare)
- [ ] HTTP-to-HTTPS redirect enforced globally with HSTS header enabled

### Production Database
- [ ] Production database provisioned (Supabase PostgreSQL, Neon, AWS RDS, PlanetScale)
- [ ] All database migrations applied successfully (`prisma migrate deploy` / `drizzle-kit migrate`)
- [ ] Connection pooling configured (PgBouncer, Supabase pooler, Prisma Accelerate)
- [ ] Automated daily database backups enabled with point-in-time recovery (PITR)
- [ ] Database failover and disaster recovery plan documented

### Transactional Email (Resend / SendGrid / Postmark)
- [ ] Custom sending domain verified with DNS records:
  - [ ] SPF record (`v=spf1 ...`) verified
  - [ ] DKIM public keys verified
  - [ ] DMARC policy (`v=DMARC1; p=reject; ...`) verified
- [ ] Transactional email delivery verified:
  - [ ] Welcome / confirmation email
  - [ ] Magic link / password reset
  - [ ] Team member invitation
  - [ ] Invoice / payment receipt

---

## 4. Billing & Monetization (Stripe Live Activation)

### Stripe Go-Live Checklist
- [ ] Stripe account verified and live mode activated
- [ ] Production API keys (`pk_live_...`, `sk_live_...`) configured in production environment
- [ ] Production webhook endpoint registered (`https://app.yourdomain.com/api/webhooks/stripe`)
- [ ] Live webhook signing secret (`whsec_...`) configured and verified
- [ ] Webhook cryptographic signature verification enforced on all webhook events
- [ ] Webhook replay attack tolerance configured (5-minute window)
- [ ] Test purchase completed in Stripe live mode with real card (and refunded)
- [ ] Stripe Customer Portal configured: allows cancel, upgrade, and card updates
- [ ] Stripe Tax / automated sales tax collection configured (if applicable)

---

## 5. Observability, Telemetry & Operations

### Error Tracking & Logs
- [ ] Sentry / exception tracker active in production with source maps uploaded
- [ ] Unhandled client exceptions and server crashes generate real-time alerts
- [ ] Structured logging configured without passwords, tokens, or customer PII

### Analytics & Product Telemetry
- [ ] Analytics provider (PostHog, Plausible, Mixpanel) initialized with cookie consent
- [ ] Core SaaS conversion funnel tracked:
  - [ ] Landing page view
  - [ ] Sign-up started and completed
  - [ ] Onboarding step completed (Activation)
  - [ ] Core value action executed
  - [ ] Upgrade / Checkout started and completed

### Health Check & Uptime Monitoring
- [ ] `/api/health` heartbeat route deployed and reporting database/cache latency
- [ ] External uptime monitoring active (BetterUptime, Pingdom, Checkly) with SMS/Slack alerts
- [ ] Public Status Page configured (e.g. `status.yourdomain.com`)

---

## 6. Compliance, Legal & Storefront

### Compliance Certifications
[Compliance Certification: the one block for this project's `compliance.cert_tier`, copied from `certification-none.md`, `certification-gdpr-lgpd.md`, `certification-pci-dss.md` or `certification-soc2.md`; `certification-unknown.md` when the tier cannot be determined]

### Legal Documents
- [ ] Terms of Service published, dated, and linked in footer and signup form
- [ ] Privacy Policy published with data retention and subprocessor disclosures
- [ ] Cookie consent banner active for visitors from EU / UK / California / Brazil
- [ ] Data Processing Agreement (DPA) available for B2B enterprise customers

---

## 7. Go-To-Market (GTM) & Distribution Pack

### Product Hunt Launch Kit
- [ ] Product Hunt name, tagline (under 60 chars), and primary category
- [ ] Thumbnail / animated GIF logo (240x240px)
- [ ] Gallery screenshots / product preview slides (1270x760px)
- [ ] Maker's first comment drafted (story, problem solved, exclusive launch offer)
- [ ] Hunter outreach / scheduling confirmed

### Social & Community Distribution
- [ ] Launch thread written for Twitter/X with product demo video/GIF
- [ ] LinkedIn company and founder launch announcement scheduled
- [ ] Reddit community post drafted (r/SaaS, r/SideProject) following self-promo rules
- [ ] Show HN (Hacker News) submission prepared with clean title and technical details
- [ ] Customer release notes published (`docs/saas-patch-notes/v1.0.0.md`)

### Support & Operations
- [ ] Support inbox active (`support@yourdomain.com`) or chat widget connected
- [ ] FAQ and documentation / knowledge base published
- [ ] On-call engineer schedule confirmed for the first 72 hours post-launch
- [ ] Rollback and emergency hotfix procedure verified

---

## Go / No-Go Decision

**Overall Status**: [READY / CONDITIONAL / NOT ASSESSED / NOT READY]

### Blocking Items (Must be resolved before launch)
- [List any FAIL or unresolved blocker]

### Conditional Items (Approved with documented mitigation)
- [List items accepted by technical or product leads]

### Sign-Offs Required
- [ ] Product Director — User experience, positioning & feature completeness
- [ ] Technical Director — Architecture, security & infrastructure stability
- [ ] Lead Engineer — Code quality, test pass rate & performance budgets
- [ ] QA Lead — Regression test evidence & critical path validation
- [ ] Release Manager — Production deployment, DNS, Stripe & release cut
