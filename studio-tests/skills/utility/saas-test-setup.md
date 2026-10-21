# Skill Test Spec: /saas-test-setup

## Skill Summary

`/saas-test-setup [force]` scaffolds the test framework for the configured stack.
It reads `stack.name` from `project.yaml` (falling back to
`technical-preferences.md`) and stops with a `/saas-setup-stack` redirect when
neither names an stack. It checks for existing infrastructure, presents a plan,
and asks "May I create these files? I will not overwrite any test files that
already exist at these paths." before writing.

It creates `tests/README.md`, `tests/smoke/critical-paths.md`,
`production/qa/evidence/`, `.github/workflows/tests.yml`, and the stack's test
root: for Next.js `tests/unit/` and `tests/integration/` (Vitest / Jest);
for FastAPI `tests/unit/` and `tests/integration/` (pytest with `conftest.py`);
for Cloudflare `tests/` (Vitest / Miniflare). When the
infrastructure already exists it exits early unless `force` is passed, and
`force` only creates missing files — it never overwrites. No director gates
apply. The verdict is COMPLETE when the scaffold is in place.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains ask-before-write language before creating files ("May I create these files?")
- [ ] Has a next-step handoff (Phase 6 Next steps: `/saas-qa-plan sprint`, `/saas-smoke-check`)

---

## Director Gate Checks

None. `/saas-test-setup` is a scaffolding utility. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Next.js project, scaffolds Vitest / Jest test structure

**Fixture:**
- `project.yaml` has `stack.name: Next.js`
- `tests/` does not exist; no CI workflow
- The user approves the plan

**Input:** `/saas-test-setup`

**Expected behavior:**
1. Phase 1 reports "Engine: Next.js. Test directory: not found. CI workflow: not found."
2. Phase 2 presents the plan: `tests/unit/`, `tests/integration/`, `tests/smoke/`,
   `tests/README.md`, `production/qa/evidence/`, `.github/workflows/tests.yml` —
   and no runner script
3. Skill asks "May I create these files? I will not overwrite any test files that
   already exist at these paths."
4. On approval: `tests/unit/.tsignore_placeholder`,
   `tests/integration/.tsignore_placeholder`, `tests/README.md` (with the
   standard Vitest/Jest configuration steps),
   `tests/smoke/critical-paths.md`, and a file under `production/qa/evidence/`
5. `.github/workflows/tests.yml` uses `actions/setup-node@v4`
   with `version: 'installed'` and `checks: write`
6. The documented test command matches `coding-standards.md`'s CI command:
   `npm test -- --run`
7. Phase 6 summary; verdict COMPLETE

**Assertions:**
- [ ] `tests/unit/`, `tests/integration/`, `tests/smoke/` and `production/qa/evidence/` all exist afterwards (each holds a written file)
- [ ] No custom runner script is written (the old hand-written runner loaded a file the framework never shipped and failed every run)
- [ ] The test command matches the coding-standards.md CI command
- [ ] Approval is asked before any file is created
- [ ] Verdict is COMPLETE

---

### Case 2: FastAPI Project — Scaffolds Pytest Test Runner & Conftest

**Fixture:**
- `project.yaml` has `stack.name: FastAPI`, `stack.backend: FastAPI`
- No `tests/`; the user approves the plan

**Input:** `/saas-test-setup`

**Expected behavior:**
1. Skill reads stack → FastAPI; detects Python backend
2. The plan places unit and integration tests under `tests/unit/` and `tests/integration/`
3. Skill generates `tests/conftest.py`, `pytest.ini`, and `tests/smoke/critical-paths.md`
4. `.github/workflows/backend-ci.yml` runs `actions/setup-python@v5`, installs dependencies,
   and runs `pytest --cov=app tests/`
5. The README documents running pytest (`pytest -v` and `pytest --cov=app`)
6. The Phase 6 gate note names FastAPI's test root (`tests/unit/` and `tests/integration/`)
7. Approval is asked before writing; verdict COMPLETE

**Assertions:**
- [ ] Tests are under `tests/unit/` and `tests/integration/`
- [ ] `conftest.py` and `pytest.ini` scaffolding are configured
- [ ] Pytest runner config is present, in CI and locally
- [ ] The gate note names the FastAPI test root
- [ ] Verdict is COMPLETE

---

### Case 3: Infrastructure Already Exists — Early exit, nothing re-initialized

**Fixture:**
- Next.js project; `tests/unit/`, `tests/integration/`, `.github/workflows/tests.yml`
  and test scripts all exist
- No `force` argument

**Input:** `/saas-test-setup`

**Expected behavior:**
1. Phase 1 reports "Engine: Next.js. Test directory: found. CI workflow: found."
2. Skill says: "Test infrastructure appears to be in place. Re-run with
   `/saas-test-setup force` to regenerate. Proceeding will not overwrite existing test files."
3. No plan approval is requested and no file is written

**Assertions:**
- [ ] Skill does NOT re-initialize when the infrastructure exists
- [ ] The message points to `/saas-test-setup force`
- [ ] No existing file is modified and no new file is written

---

### Case 4: No Engine Configured — Redirects to /saas-setup-stack

**Fixture:**
- `project.yaml` has no `stack.name`; `technical-preferences.md` shows
  `[TO BE CONFIGURED]` for Engine

**Input:** `/saas-test-setup`

**Expected behavior:**
1. Skill checks `project.yaml`, then `technical-preferences.md` — no stack
2. Skill stops: "Engine not configured. Run `/saas-setup-stack` first, then re-run `/saas-test-setup`."
3. No directories or files are created

**Assertions:**
- [ ] Error message explicitly states stack is not configured
- [ ] `/saas-setup-stack` is suggested as the next step
- [ ] No write tool is called
- [ ] Verdict is not COMPLETE (blocked state)

---

### Case 5: Director Gate Check — No gate; test-setup is a scaffolding utility

**Fixture:**
- Engine configured, tests/ does not exist

**Input:** `/saas-test-setup`

**Expected behavior:**
1. Skill scaffolds and writes all test framework files
2. No director agents are spawned
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is COMPLETE without any gate check

---

## Protocol Compliance

- [ ] Reads the stack (`project.yaml`, then `technical-preferences.md`) before generating any scaffold
- [ ] Generates stack-appropriate test runner config and CI workflow (not generic)
- [ ] Puts unit and integration tests in the stack's test root (`tests/` for Next.js, FastAPI, and Cloudflare)
- [ ] Creates `production/qa/evidence/` — the path the Phase 6 summary reports
- [ ] Asks approval before creating files
- [ ] Exits early when infrastructure exists; `force` creates only missing files and never overwrites
- [ ] Verdict is COMPLETE when scaffold is in place

---

## Coverage Notes

- Cloudflare Workers test scaffolding (Vitest with Miniflare / Wrangler) is not separately fixture-tested.
- The `force` path on a partial scaffold (create only the missing files) is
  covered by protocol compliance, not by its own case.
- The case where tests/ exists but is from a different stack (e.g., FastAPI tests
  in a now-Next.js project) is not tested.
