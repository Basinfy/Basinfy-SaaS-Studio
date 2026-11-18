---
name: saas-test-helpers
description: "Scaffold stack-specific test helpers, auth mocks, and tenant-isolated DB fixtures."
argument-hint: "[module-slug or 'base' or 'all']"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,automation` and use its output below.

# SaaS Test Helpers

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


Generates reusable test utilities, mock tenant factories, authenticated request clients,
and custom test assertions in `tests/helpers/` to reduce boilerplate across unit,
integration, and E2E test suites.

---

## Phase 1: Detect Stack & Test Runner

Read `project.yaml`:
- **TypeScript / Next.js**: Vitest or Jest. Helpers written in TypeScript (`tests/helpers/*.ts`).
- **Python / FastAPI**: Pytest. Helpers written in Python (`tests/conftest.py`, `tests/helpers/*.py`).

---

## Phase 2: Core Helper Library (`base`)

Generate standard test utilities:

### 1. `tests/helpers/auth.ts` (Mock Authentication & Sessions)
```typescript
import { vi } from 'vitest';

export interface MockUser {
  id: string;
  email: string;
  tenantId: string;
  role: 'owner' | 'admin' | 'member';
}

export function createMockSession(overrides?: Partial<MockUser>): MockUser {
  return {
    id: overrides?.id || 'usr_' + Math.random().toString(36).substring(7),
    email: overrides?.email || 'test@example.com',
    tenantId: overrides?.tenantId || 'org_test123',
    role: overrides?.role || 'member',
  };
}

export function mockAuthHeaders(user: MockUser) {
  return {
    'x-user-id': user.id,
    'x-tenant-id': user.tenantId,
    'x-user-role': user.role,
  };
}
```

### 2. `tests/helpers/factories.ts` (Entity Model Factories)
```typescript
export function makeTenant(name = 'Acme Corp') {
  return {
    id: 'org_' + Math.random().toString(36).substring(7),
    name,
    slug: name.toLowerCase().replace(/\s+/g, '-'),
    plan: 'pro',
    createdAt: new Date(),
  };
}

export function makeSubscription(tenantId: string, status = 'active') {
  return {
    id: 'sub_' + Math.random().toString(36).substring(7),
    tenantId,
    status,
    priceId: 'price_pro_monthly',
    currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  };
}
```

### 3. `tests/helpers/assertions.ts` (Custom Assertions)
```typescript
import { expect } from 'vitest';

export function assertTenantIsolation(data: { tenantId?: string }, expectedTenantId: string) {
  expect(data.tenantId).toBe(expectedTenantId);
}

export function assertApiResponse(res: Response, status: number) {
  expect(res.status).toBe(status);
}
```

---

## Phase 3: Module-Specific Factories

When invoked with a specific module argument (e.g. `/saas-test-helpers billing` or `/saas-test-helpers teams`):
1. Read the corresponding PRD in `design/prd/[module].md`.
2. Extract required entities, database models, and API payload schemas.
3. Generate typed factory functions in `tests/helpers/[module]-factories.ts`.

---

## Phase 4: Verification

Run `npm test` or `pytest` to verify the generated helper functions compile and execute cleanly.
