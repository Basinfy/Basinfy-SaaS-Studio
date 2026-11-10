# Agentic Commerce & Machine Payment Protocols

Protocols allowing AI agents to discover pricing, fulfill HTTP micro-payments, and complete programmatic checkout flows on SaaS APIs and web platforms.

---

## 1. x402 Protocol (`HTTP 402 Payment Required`)

Coinbase-originated open HTTP payment standard (`x402.org`, `@x402/next`, `@x402/hono`, `@x402/express`):
- **Use case**: Pay-per-request SaaS APIs, metered inference endpoints, or premium Markdown content without API keys or monthly subscriptions.
- **Next.js Integration**: Attach `@x402/next` middleware specifying a facilitator URL, wallet address, and route pricing rules.
- **Behaviour**: Unpaid requests receive `HTTP 402 Payment Required` with machine-readable payment instructions; agents sign and resubmit automatically.

---

## 2. MPP — Machine Payment Protocol (`/openapi.json`)

OpenAPI payment discovery (`mpp.dev`, `draft-payment-discovery-00`):
- **Discovery Path**: `/openapi.json` served at site root with HTTP 200.
- **Operation Extensions**: Add `x-payment-info` on payable OpenAPI operations:
  - `intent`: `"charge"` or `"session"`
  - `method`: `"tempo"`, `"stripe"`, `"lightning"`, or `"card"`
  - `amount`: numeric or string payment amount
  - Optional: `currency`, `description`, and top-level `x-service-info` categories.

---

## 3. ACP — Agentic Commerce Protocol (`/.well-known/acp.json`)

OpenAI + Stripe agentic checkout protocol (`agenticcommerce.dev`):
- **Discovery Path**: `/.well-known/acp.json` returning HTTP 200 JSON.
- **Required Fields**:
  - `protocol`: `{ "name": "acp", "version": "1.0" }`
  - `api_base_url`: Absolute `http(s)://` URL
  - `transports`: Non-empty array (e.g., `["rest-json"]`)
  - `capabilities.services`: Non-empty array of offered commerce services (e.g., `["checkout", "subscriptions"]`).

---

## 4. UCP — Universal Commerce Protocol (`/.well-known/ucp`)

Google + Shopify open commerce specification (`ucp.dev/specification/overview/`):
- **Discovery Path**: `/.well-known/ucp` returning HTTP 200 JSON.
- **Required Fields**: `protocol_version`, `services`, `capabilities`, `endpoints`.
- All referenced spec URLs and schemas must be publicly reachable without soft-404 redirects.
