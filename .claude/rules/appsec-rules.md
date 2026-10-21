---
paths:
  - "src/**"
---

# Application Security (AppSec) Rules

1. **Zero Secret Leakage**: Never expose private API keys (`STRIPE_SECRET_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, DB passwords) in code or client bundles (`NEXT_PUBLIC_`).
2. **Sanitization**: Protect against XSS by sanitizing rich text or user-generated HTML.
3. **Least Privilege**: API clients and database roles must operate with the lowest privilege needed for their function.
