---
paths:
  - "src/app/api/**"
  - "src/server/**"
  - "src/routes/**"
---

# Backend API & Server Actions Rules

1. **Strict Input Validation**: Every request payload, query param, and path variable must be validated with Zod or Pydantic.
2. **Structured Error Responses**: Return standard `{ success: false, error: { code, message, details } }` format with appropriate HTTP status codes.
3. **Rate Limiting & Authentication**: Protect all public endpoints with rate limiting and secure session authentication.
