# Domain Experience: Billing & Subscriptions

## Experience: Stripe Webhook Raw Body Signature Verification
- **cue**: `StripeSignatureVerificationError: No signatures found matching the expected signature for payload` occurring in Next.js Route Handlers when `req.json()` was called before signature verification.
- **lesson**: Stripe's SDK requires the verbatim raw binary/text buffer to compute the cryptographic HMAC signature. In Next.js App Router, call `await req.text()` directly, pass it to `stripe.webhooks.constructEvent(rawBody, signature, secret)`, and ONLY parse JSON from the resulting validated event.
- **evidence**: `tests/integration/billing/webhook.test.ts` passes with valid HMAC signature simulation.

## Experience: Idempotent Webhook Event Processing
- **cue**: Duplicate database updates or duplicate transactional emails when Stripe retries delivering webhook events.
- **lesson**: Record every processed `event.id` in a `processed_webhook_events` table within a serializable transaction. If `event.id` already exists, immediately return HTTP 200 without reprocessing.
- **evidence**: Automated test sends duplicate event payload twice; database state reflects exactly one processed transaction.
