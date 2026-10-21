# SaaS Pricing & Unit Economics Model

> **Status**: [Draft | Validated | Live]
> **Owner**: `growth-director` / `product-director`
> **Last Updated**: [YYYY-MM-DD]
> **Billing Engine**: Stripe Billing (Checkout, Customer Portal, Webhooks)

---

## 1. Executive Summary & Monetization Strategy

This model defines the packaging, pricing tiers, feature gates, and unit economics for the SaaS platform.
The monetization strategy aligns pricing directly with customer value metrics (e.g. active users, compute jobs, or saved hours).

---

## 2. Subscription Tiers & Feature Matrix

| Plan Tier | Price (Monthly / Annual) | Target Segment | Seat Limit | Key Feature Entitlements | Support SLA |
|---|---|---|---|---|---|
| **Free / Starter** | $0 | Individuals & Indie Builders | 1 user | Core features, up to 100 resources, community support | Community |
| **Pro / Growth** | $29 / mo ($24/mo billed annually) | Growing Teams & Startups | 5 users included (+$10/extra seat) | Unlimited resources, priority webhooks, custom exports | 24-hour email |
| **Enterprise** | Custom ($499+ / mo) | Scale-ups & Regulated Orgs | Unlimited | SSO (SAML), dedicated database pool, audit logs, custom SLA | 99.9% uptime, Slack channel |

---

## 3. Usage Quotas & Metered Overages

| Quota Metric | Free Tier | Pro Tier | Enterprise | Overage Pricing |
|---|---|---|---|---|
| API Calls / month | 10,000 | 250,000 | Unlimited | $5 per 50,000 requests |
| File Storage | 1 GB | 50 GB | 1 TB+ | $0.15 per additional GB |
| Background Jobs | 50 / day | 2,500 / day | Custom pool | Throttled with 429 backoff |

---

## 4. Unit Economics & Margin Target

| Financial Metric | Free User Target | Pro Customer Target | Target Benchmark |
|---|---|---|---|
| **Average Revenue Per Account (ARPA)** | $0 | $39 / mo (with seats) | Healthy SaaS Baseline |
| **Customer Acquisition Cost (CAC)** | < $15 (organic) | < $180 | Payback < 6 months |
| **Estimated Infrastructure COGS** | < $0.40 / mo | < $3.50 / mo | Serverless + Postgres pool |
| **Gross Margin Target** | — | **> 85%** | Industry standard SaaS margin |
| **Net Revenue Retention (NRR)** | — | > 110% | Growth via seat expansion |

---

## 5. Stripe Billing Integration Architecture

### 5.1 Stripe Primitives
- **Products**: Defined in Stripe Dashboard with mirror records in `project.yaml` or database seed.
- **Price IDs**:
  - `price_pro_monthly`: Recurring $29.00 USD / month
  - `price_pro_annual`: Recurring $288.00 USD / year (Save 17%)
  - `price_seat_addon`: Recurring $10.00 USD / seat / month

### 5.2 Webhook Event Handling
All subscriptions rely on resilient, idempotent Stripe webhook processing (`/api/webhooks/stripe`):
1. `customer.subscription.created` -> Initialize workspace plan and limits.
2. `customer.subscription.updated` -> Update tier, seat count, and billing interval.
3. `customer.subscription.deleted` -> Downgrade workspace to Free tier at period end.
4. `invoice.payment_failed` -> Trigger dunning email and 7-day grace period.

---

## 6. Upgrade, Downgrade & Churn Policy

- **Upgrades**: Prorated immediately; customer gains instant access to higher limits.
- **Downgrades**: Retain paid tier access until the end of the current billing cycle.
- **Data Retention on Downgrade**: If resource count exceeds Free tier limits upon downgrade, resources enter read-only mode for 60 days before archival.
