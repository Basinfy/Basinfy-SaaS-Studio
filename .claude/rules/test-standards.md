---
paths:
  - "tests/**"
  - "**/*.test.*"
  - "**/*.spec.*"
---

# Testing Standards & Quality Rules

1. **Arrange-Act-Assert (AAA)**: Every test must have clear setup, execution, and verification steps.
2. **Meaningful Assertions**: Empty assertions or tests without `expect(...)` are strictly prohibited.
3. **Mocking Boundaries**: Mock external HTTP services and third-party APIs (Stripe, Resend, S3); do not mock internal core business logic.
4. **Fail-First Validation**: Ensure test fails when the assertion condition is broken before trusting it.
5. **Autonomous Reflection Loop**: When automated checks fail during development, parse traceback, diagnose root cause, apply surgical patch, and re-test (up to 3 retries). Never disable a valid assertion to force a test pass.
