# /saas-test-setup — Phase 2: Present Plan

> Part of `/saas-test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 2: Present Plan

Based on the engine detected and the existing state, present a plan:

```
## Test Setup Plan — [Engine]

I will create the following (skipping any that already exist):

tests/
  unit/           — Isolated unit tests for utilities, schemas, and business logic
  integration/    — Cross-service tests, API route tests, and database queries
  smoke/          — Critical path test list (15-minute manual gate)
  README.md       — Test framework documentation

production/qa/
  evidence/       — Screenshot and manual test sign-off records

[Engine-specific files — see per-engine details below]

.github/workflows/tests.yml  — CI: run tests on every push to main

Estimated time: ~5 minutes to create all files.
```

Ask: "May I create these files? I will not overwrite any test files that
already exist at these paths."

**At `collaborative` and `guided`** — do not proceed without approval. These are
**new** files, and `automation-modes.md:81` gates new-file writes in `guided` too,
so the answer is the same in both modes. **At `autonomous`** — create them and log
the decision; do not block.

---
