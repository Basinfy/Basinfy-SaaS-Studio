---
paths:
  - "src/auth/**"
  - "src/middleware/**"
---

# Authentication & Access Control Rules

1. **Server-Side Verification**: Never trust client-side claims or tokens without cryptographic server validation.
2. **RBAC & Multi-Tenancy**: Check organization/workspace membership on every protected database query and mutation.
3. **Secure Cookies**: Session tokens must be stored in `HttpOnly`, `Secure`, `SameSite=Lax` cookies.
4. **CSRF & Origin Checking**: Enforce Origin / Referer validation on mutating endpoints.
