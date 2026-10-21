# /saas-test-setup — Phase 4: Create CI/CD Workflow

> Part of `/saas-test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 4: Create CI/CD Workflow

**In this file:**

- Next.js (TypeScript / Vitest / Playwright)
- FastAPI (Python / Pytest)
- Cloudflare Workers (TypeScript / Wrangler)
- Dockerized Full-Stack CI

### Next.js & TypeScript CI

Create `.github/workflows/ci.yml`:

```yaml
name: Continuous Integration

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Lint, Test & Build
    runs-on: ubuntu-latest

    permissions:
      contents: read
      checks: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run Linter
        run: npm run lint

      - name: Run Unit & Integration Tests
        run: npm run test:ci || npm test

      - name: Build Application
        run: npm run build
        env:
          NEXT_PUBLIC_APP_URL: "http://localhost:3000"

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: coverage/
```

### FastAPI & Python Backend CI

Create `.github/workflows/backend-ci.yml`:

```yaml
name: Backend CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Pytest & Linting
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: password
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-asyncio pytest-cov httpx

      - name: Run Pytest Suite
        run: |
          pytest --cov=app --cov-report=xml tests/
        env:
          DATABASE_URL: postgresql://postgres:password@localhost:5432/test_db
          ENVIRONMENT: test

      - name: Upload Coverage
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: python-coverage
          path: coverage.xml
```

### Cloudflare Workers CI

Create `.github/workflows/cloudflare-ci.yml`:

```yaml
name: Cloudflare Workers CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test & Typecheck
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Typecheck
        run: npx tsc --noEmit

      - name: Run Tests (Vitest / Miniflare)
        run: npm test

      - name: Dry-run Deploy
        run: npx wrangler deploy --dry-run
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

---
