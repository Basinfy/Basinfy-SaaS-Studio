> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# QL-TEST-COVERAGE — QA Lead Test Suite Coverage & Integrity Sign-Off

Agent: `qa-lead` | Model tier: session (inherit) | Domain: Test execution results, code coverage, regression suites, assertion depth, Playwright evidence

**Trigger**: Post-sprint review, story completion (`/saas-story-done`), or pre-release gate

**Context to pass**:
- Test execution output (`bash .claude/scripts/test-run.sh saas`)
- Test evidence directory (`production/qa/evidence/`)
- Critical-path smoke test results (`tests/smoke/critical-paths.md`)

**Prompt**:
> "Evaluate automated test execution results and coverage quality across critical paths. Do all unit, integration, and critical-path E2E tests pass with exit code 0? Are assertions meaningful and strict (no empty expect statements or tautologies)? Are critical SaaS paths (auth, payment webhook, tenant data isolation) covered by automated tests? Return ADEQUATE (tests pass with robust assertions and sufficient coverage) or INSUFFICIENT [failing tests, missing critical paths, or hollow assertions]."

**Verdicts**: ADEQUATE / INSUFFICIENT
