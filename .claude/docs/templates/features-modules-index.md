# Features & Modules Index: [Product Name]

> **Status**: [Draft | Under Review | Approved]
> **Created**: [YYYY-MM-DD]
> **Last Updated**: [YYYY-MM-DD]
> **Source Concept**: `docs/specs/product-concept.md` (or `docs/specs/product-brief.md`)

---

## 1. Overview

This catalog enumerates all functional modules and feature subsystems comprising the SaaS platform.
It establishes dependency hierarchies, development sequencing, and ownership for PRD authoring and epic breakdown.

---

## 2. Features & Modules Catalog

| # | Module / Feature Name | Category | Priority | Status | PRD Specification | Dependencies |
|---|---|---|---|---|---|---|
| 1 | Auth & Session Management | Foundation | MVP | Approved | `docs/specs/auth-session.md` | None |
| 2 | Multi-Tenancy & Workspaces | Foundation | MVP | Approved | `docs/specs/multi-tenancy-spec.md` | Auth |
| 3 | Core Business Engine | Core | MVP | In Design | `docs/specs/core-engine.md` | Workspaces |
| 4 | Stripe Billing & Plans | Billing | MVP | In Design | `docs/specs/saas-pricing-model.md` | Workspaces |
| 5 | App Shell & Dashboard UI | Presentation | MVP | In Design | `docs/specs/app-shell-navigation-spec.md` | Workspaces, Design System |
| 6 | Team Invites & Member RBAC | Foundation | Post-MVP | Not Started | `docs/specs/team-rbac.md` | Workspaces |
| 7 | Webhooks & Public API | Integration | Post-MVP | Not Started | `docs/specs/webhooks-api.md` | Core Business Engine |
| 8 | Usage Metering & Quotas | Billing | Post-MVP | Not Started | `docs/specs/usage-limits-quota-model.md` | Stripe Billing |
| 9 | Audit Logging & Activity Trail | Compliance | Enterprise | Not Started | `docs/specs/audit-logging.md` | Workspaces, RBAC |
| 10 | SSO (SAML / Okta) | Compliance | Enterprise | Not Started | `docs/specs/enterprise-sso.md` | Auth, Workspaces |

---

## 3. SaaS Architectural Categories

| Category | Architectural Scope | Typical Modules |
|---|---|---|
| **Foundation** | Identity, multi-tenancy, and data layer | Auth, Session Cookies, Workspace Isolation, Database Migrations, RLS |
| **Core** | Primary value-delivery engine | Business Domain Models, Data Pipelines, Algorithmic Services, CRUD Handlers |
| **Presentation** | Frontend user interface and workflows | Responsive App Shell, Command Menu (`Cmd+K`), Forms, Modals, Empty States |
| **Billing & Quotas** | Monetization and subscription management | Stripe Checkout, Customer Portal, Webhook Handlers, Tier Limits, Invoices |
| **Integration** | External APIs and notification systems | REST/tRPC Endpoints, Inbound/Outbound Webhooks, Slack Alerts, Resend Emails |
| **Compliance & Sec** | Security, privacy, and governance | RBAC Policies, Audit Logs, GDPR Data Deletion, Rate Limiting, Threat Mitigation |

---

## 4. Priority Tiers & Sequencing

| Tier | Definition | Target Milestone | Engineering Urgency |
|---|---|---|---|
| **P0 - MVP** | Essential for end-to-end workflow (Signup -> Action -> Billing) | Beta Launch | Author & Build FIRST |
| **P1 - Post-MVP** | Retention, team collaboration, and automated notification loops | General Availability (GA) | Build SECOND |
| **P2 - Scale** | Advanced analytics, public developer API, and usage optimizations | Growth Phase | Build THIRD |
| **P3 - Enterprise** | Single Sign-On, dedicated audit logs, custom SLA and compliance | Enterprise Release | Build as needed |
