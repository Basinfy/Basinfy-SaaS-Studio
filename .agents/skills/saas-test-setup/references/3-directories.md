# Test Directory Layout & CI Configuration

This reference documents the canonical test directory layout and CI automation structure
for SaaS applications.

---

## 1. Directory Structure

```
tests/
├── unit/               # Fast, isolated unit tests (pure functions, utilities, schema parsing)
│   ├── auth/           # Tests for token generation, password validation
│   └── billing/        # Tests for invoice calculations, plan quota checks
├── integration/        # Route handler and database query tests (mock DB or test database)
│   ├── api/            # API endpoints (GET /api/documents, POST /api/checkout)
│   └── db/             # Prisma/Postgres queries, RLS policy tests
├── e2e/                # Playwright end-to-end browser tests
│   ├── auth.spec.ts    # Login, signup, password reset browser flow
│   └── billing.spec.ts # Stripe checkout redirect and customer portal
└── helpers/            # Shared test fixtures, mock sessions, factories
    ├── auth.ts
    └── factories.ts
```

---

## 2. Configuration Files

### Vitest (`vitest.config.ts`)
```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'node',
    globals: true,
    setupFiles: ['./tests/helpers/setup.ts'],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

### Playwright (`playwright.config.ts`)
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 14'] } },
  ],
});
```

---

## 3. GitHub Actions CI (`.github/workflows/test.yml`)

```yaml
name: Test Suite

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npx playwright install --with-deps
      - run: npx playwright test
```
