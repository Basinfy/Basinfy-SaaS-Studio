# /saas-test-setup — Phase 6: Post-Setup Summary

> Part of `/saas-test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 6: Post-Setup Summary

After writing all files, report:

```
Test infrastructure created for [engine].

Files created:
- tests/README.md
- tests/unit/ and tests/integration/ (Next.js / Vitest / Jest)
- tests/e2e/ (Playwright) or tests/unit/ (FastAPI / pytest)
- tests/smoke/critical-paths.md
- production/qa/evidence/.gitkeep
[stack-specific files]
- .github/workflows/tests.yml

Next steps:
1. Install test dependencies if not already present (`npm install -D vitest` or `poetry add --group dev pytest`)
2. Write your first test in the project's test root:
   `tests/unit/[module]/[module]_[feature].test.ts` (Next.js), or
   `tests/unit/test_[module].py` (FastAPI)
3. Run `/saas-qa-plan sprint` before your first sprint to classify stories and set
   test evidence requirements. At `workflow: minimal` — the default — skip
   this: there are no sprints. At `qa.level: minimal`, also the default, tests
   are waived, so `/saas-dev-story` writes none. Raise `qa.level` with `/saas-settings`
   to have it write them
4. `/saas-smoke-check` before every QA hand-off

Gate note: /saas-gate-check Technical Setup → Pre-Production now requires:
- the test root: tests/unit/ and tests/integration/ (Next.js / TypeScript), or
  tests/unit/ (FastAPI / Python)
- .github/workflows/tests.yml
- At least one example test file
Run /saas-test-setup and write one example test before advancing.
(At `workflow: minimal` that gate requires only the engine.)

Verdict: **COMPLETE** — test framework scaffolded and CI/CD wired up.
```

---
