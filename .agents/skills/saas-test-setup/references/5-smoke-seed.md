# /saas-test-setup — Phase 5: Create Smoke Test Seed

> Part of `/saas-test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Create Smoke Test Seed

Create `tests/smoke/critical-paths.md`:

```markdown
# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/saas-smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Application boots and serves landing/dashboard route without error (200 OK)
2. New product / session can be started from the landing / dashboard
3. Main navigation responds to all inputs without freezing

## Core Workflow (update per sprint)

<!-- Add the primary feature workflow for each sprint here as it is implemented -->
<!-- Example: "User can sign up, create an organization, and invite a team member" -->
4. [Primary feature workflow — update when first core module is implemented]

## Data Integrity & Persistence

5. Database mutations persist across page reloads and tenant switches
6. Row-Level Security (RLS) prevents unauthorized cross-tenant data access

## Performance & Web Vitals

7. Initial page load completes with LCP < 2.5s and zero layout shift
8. No memory leaks or zombie event listeners over 5 minutes of active usage
```

---
