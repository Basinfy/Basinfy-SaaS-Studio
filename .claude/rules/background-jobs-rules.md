---
paths:
  - "src/jobs/**"
  - "src/workers/**"
---

# Background Jobs & Workers Rules

1. **Idempotence**: Jobs must be safely retryable without causing duplicate mutations or notifications.
2. **Backoff & Retries**: Configure exponential backoff with a maximum retry ceiling.
3. **Dead Letter Queue (DLQ)**: Failed jobs after maximum retries must be captured in a DLQ with structured error logs and alert telemetry.
