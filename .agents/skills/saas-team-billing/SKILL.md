---
name: saas-team-billing
description: "Orchestrate the billing team — pricing-economist, backend-engineer, frontend-engineer, qa-manual-tester — plans, Stripe Checkout, webhooks, and customer portal."
argument-hint: "[billing feature description] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Billing & Subscriptions

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the billing engineering team to implement pricing tiers, Stripe Checkout,
webhook listeners, usage-based metering, and self-serve customer billing portals.

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-billing [billing feature description] [--review full|lean|solo]` — Describe the billing feature to build (e.g. Monthly/Annual subscription toggle, Stripe Checkout integration, Webhook synchronization, Customer Portal redirect, Usage limit gates)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **Pricing Model & Tier Spec**:
   - `pricing-economist`: Define plan tiers (Starter, Pro, Enterprise), feature entitlement gates, and seat/usage thresholds
   - `backend-engineer`: Database migration for `Subscription`, `Plan`, `Customer`, and `Invoice` records

2. **Stripe Integration & Webhooks**:
   - `backend-engineer`:
     - Create Stripe Checkout sessions (`/api/billing/checkout`)
     - Implement Customer Portal session creation (`/api/billing/portal`)
     - Build idempotent webhook handler with raw signature verification (`customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_succeeded`, `invoice.payment_failed`)

3. **Frontend Billing UI**:
   - `frontend-engineer`:
     - Responsive pricing table with Monthly / Annual toggle and savings badge
     - Current plan status badge in settings, payment method display, invoice history table
     - Upgrade prompt modals when users hit plan limits

4. **Testing with Stripe Mock Webhooks**:
   - `qa-manual-tester`: Verify successful checkout redirects, subscription state updates via Stripe CLI (`stripe trigger invoice.payment_succeeded`), expired card handling, and downgrade access revocation.

5. **Verdict**:
   - Output: **COMPLETE** — billing pipeline designed, implemented, and verified with Stripe tests.
