---
paths:
  - "src/billing/**"
  - "src/app/api/webhooks/stripe/**"
---

# Billing & Stripe Webhook Rules

1. **Raw Body Verification**: Stripe webhooks must verify the cryptographic signature (`stripe-signature`) using the raw unparsed request body.
2. **Event Idempotency**: Record processed `event.id` in a database table (`stripe_events`) before applying changes to prevent double-charging or duplicate provisioning.
3. **Never Trust Client Prices**: Plan prices, credits, and subscription tiers must be resolved strictly from server-side configuration or Stripe product IDs.
