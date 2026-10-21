# SaaS Usage Limits, Rate Limiting & Quota Architecture

> **Status**: [Draft | In Review | Approved]
> **Owner**: `lead-engineer` / `growth-director`
> **Last Updated**: [YYYY-MM-DD]
> **Links To**: `docs/specs/saas-pricing-model.md`, `docs/architecture/system-architecture.md`

---

## 1. Executive Summary & Quota Philosophy

The Quota and Rate Limiting Architecture guarantees service stability, prevents noisy-neighbor degradation across tenants, bounds cloud infrastructure costs, and naturally drives upgrade conversion when customers scale.

### Core Principles
- **Predictable & Transparent**: Users receive advance warnings before hitting hard limits, never sudden unexpected lockouts.
- **Graceful Degradation**: Rate-limited requests return structured HTTP 429 headers (`Retry-After`, `X-RateLimit-Reset`) enabling automated client backoff.
- **Fail-Safe Cost Bounding**: Expensive compute operations (e.g. AI processing, background PDF exports) have hard workspace quotas to prevent accidental cost spikes.

---

## 2. Quota Allocation by Subscription Tier

| Quota Metric | Free / Starter | Pro / Growth | Enterprise | Enforcement Mode |
|---|---|---|---|---|
| **API Requests / min** | 60 req/min | 600 req/min | 5,000 req/min | Hard (HTTP 429) |
| **Monthly Active Records** | 500 items | 50,000 items | Custom / Unlimited | Soft warning -> Read-only |
| **Concurrent Jobs** | 1 | 5 | 25 | Queue backpressure |
| **File Storage** | 1 GB | 50 GB | 1 TB+ | Upload rejected (413) |
| **Team Member Seats** | 1 | 5 included | Unlimited | Invitation blocked |

---

## 3. Rate Limiting Architecture & Algorithms

### 3.1 Rate Limiting Algorithm
- **Sliding Window Counter** implemented via Redis (`Upstash Redis` / in-memory cache).
- Key Format: `ratelimit:{tenant_id}:{route_category}:{window_timestamp}`.

### 3.2 Standard HTTP Rate-Limit Headers
```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
Retry-After: 30
X-RateLimit-Limit: 600
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1718900000

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please wait 30 seconds before retrying.",
    "tier": "pro",
    "upgrade_url": "https://app.saas.com/settings/billing"
  }
}
```

---

## 4. Quota Monitoring & Lifecycle Warnings

```text
[Usage < 80%]  ──> Normal operation; invisible to user
       │
[Usage = 80%]  ──> Non-intrusive warning badge in Settings > Usage
       │
[Usage = 90%]  ──> Automated email to Workspace Owner: "Approaching plan limit"
       │
[Usage = 100%] ──> In-app banner: "Limit reached. Upgrade to Pro to continue writing."
                   Existing data remains 100% accessible in read-only mode.
```

---

## 5. Security & DoS Mitigation

1. **Unauthenticated Endpoints**: Rate-limited per IP address (e.g. 10 login attempts per 15 minutes to prevent brute-force attacks).
2. **Authenticated Endpoints**: Rate-limited primarily per `workspace_id` to prevent single bad-actor API keys from overwhelming shared tenant capacity.
3. **Webhook Ingestion**: Dedicated queue worker with throttling to absorb third-party webhook storms.
