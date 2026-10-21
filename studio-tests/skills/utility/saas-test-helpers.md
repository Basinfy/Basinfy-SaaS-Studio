# Skill Test Spec: /saas-test-helpers

## Skill Summary

`/saas-test-helpers [module-slug | base | all]` generates test helper files in
the project's helper root (`tests/helpers/` for TypeScript/Next.js or Python/FastAPI).
It writes base assertion and factory helpers (`scaffold` or `base`), and a
`tests/helpers/[module]_factory.[ext]` per module built from that module's PRD
(`[module-slug]` or `all`). No argument runs `scaffold` when no helpers exist,
else `all`. It reads `stack.name`, `stack.language` and `testing.framework`
from `project.yaml` (falling back to `technical-preferences.md`), samples up to
5 existing test files for house style, and section-greps the PRD (Formulas,
Edge Cases, Detailed Rules/Design) rather than reading it whole.

Helpers must assert through the configured framework's API — never bare
`assert()` — and must not extend the framework's test-suite base class. If the
framework's assertion API cannot be confirmed, the skill says so and generates
no helper. It never overwrites an existing helper: it skips it with a message.
After presenting the file list it asks "May I write these helper files to
`[helper root]`?". No director gates apply. Verdict: COMPLETE when helper files
are created.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains "May I write" collaborative protocol language before writing helpers
- [ ] Has a next-step handoff (Next Steps: `/saas-test-setup`, `/saas-dev-story`, `/saas-skill-test`)

---

## Director Gate Checks

None. `/saas-test-helpers` is a scaffolding utility. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — User helper generated for Next.js/TypeScript

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `stack.language: TypeScript`,
  `testing.framework: vitest`; `vitest` is installed, so its
  assertion API can be confirmed from the project
- `tests/unit/user/user_authentication.test.ts` exists
- `design/prd/user.md` has a Formulas section bounding seat quotas to 1–100
- No existing files in `tests/helpers/`; the user approves the write

**Input:** `/saas-test-helpers user`

**Expected behavior:**
1. Skill reads stack, language and framework; samples the existing test file
2. Skill greps `design/prd/user.md` for the Formulas / Edge Cases / Detailed
   Rules headings instead of reading it whole
3. Skill drafts `tests/helpers/user_factory.ts`: a modular TypeScript helper with
   static `make_*` factories with default parameters,
   bound constants commented as coming from the PRD, and a header line
   "Based on: design/prd/user.md"
4. Every assertion goes through Vitest's confirmed API (`expect().toBe()`) — no bare `assert()`,
   no `FAIL_IF` placeholder
5. Skill presents the file list and asks "May I write these helper files to `tests/helpers/`?"
6. Files written on approval; verdict COMPLETE, followed by the per-stack usage note

**Assertions:**
- [ ] Generated helper is TypeScript at `tests/helpers/user_factory.ts`
- [ ] Bound constants trace to the PRD's Formulas section (not invented values)
- [ ] Helper uses modular exports, not global singletons
- [ ] No bare `assert()` and no unresolved `FAIL_IF` reaches the file
- [ ] Verdict is COMPLETE

---

### Case 2: Engine Not Configured — Stops with /saas-setup-stack

**Fixture:**
- `project.yaml` has no `stack` block; `technical-preferences.md` shows
  `[TO BE CONFIGURED]` for Engine

**Input:** `/saas-test-helpers user`

**Expected behavior:**
1. Skill checks `project.yaml`, then `technical-preferences.md` — no stack in either
2. Skill outputs: "Engine not configured. Run `/saas-setup-stack` first."
3. Skill stops — no test scan, no draft, no write

**Assertions:**
- [ ] The message states the stack is not configured
- [ ] `/saas-setup-stack` is named as the prerequisite
- [ ] No write tool is called
- [ ] Verdict is not COMPLETE (nothing was created)

---

### Case 3: Helper Already Exists — Skipped, never overwritten

**Fixture:**
- Next.js/TypeScript/vitest configured as in Case 1
- `tests/helpers/test_assertions.ts` already exists with hand-written additions
- `tests/helpers/workspace_factory.ts` and `tests/helpers/api_test_client.ts` do
  not exist; the user approves the write

**Input:** `/saas-test-helpers scaffold`

**Expected behavior:**
1. Skill drafts the Next.js base helpers only — `test_assertions.ts`,
   `workspace_factory.ts` and `api_test_client.ts`; no system-specific helpers in
   `scaffold` mode
2. Skill asks "May I write these helper files to `tests/helpers/`?"
3. The two missing files, `tests/helpers/workspace_factory.ts` and
   `tests/helpers/api_test_client.ts`, are created
4. For the existing file, skill reports: "Skipping `tests/helpers/test_assertions.ts`
   — already exists. Remove the file manually if you want it regenerated."
5. Verdict COMPLETE

**Assertions:**
- [ ] `scaffold` mode generates no `[system]_factory` helper
- [ ] The existing `test_assertions.ts` is left byte-for-byte unchanged
- [ ] The skip message names the existing file and how to regenerate it
- [ ] Only the two missing files are written; Verdict is COMPLETE

---

### Case 4: Framework Assertion API Unconfirmed — No helper generated

**Fixture:**
- `project.yaml` has `stack.name: Next.js`, `stack.language: TypeScript`;
  `testing.framework` is absent and `technical-preferences.md` shows no Framework
- No `vitest` installed and no existing test files to learn the API from

**Input:** `/saas-test-helpers scaffold`

**Expected behavior:**
1. Skill cannot confirm which assertion call registers a failure with the runner
2. Skill says so, and generates no helper rather than guessing a form such as
   `assert_that`, `assert_eq`, `assert_true` or a bare `assert()`
3. No "May I write" is asked and nothing is written

**Assertions:**
- [ ] The skill states it cannot confirm the framework's assertion API
- [ ] No helper file is written
- [ ] No guessed assertion form (and no `FAIL_IF` placeholder) is presented as ready to write
- [ ] Verdict is not COMPLETE

---

### Case 5: Director Gate Check — No gate; test-helpers is a scaffolding utility

**Fixture:**
- Engine and framework configured as in Case 1, no existing helpers

**Input:** `/saas-test-helpers user`

**Expected behavior:**
1. Skill generates and writes the helper file
2. No director agents are spawned
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is COMPLETE without any gate check

---

### Case 6: FastAPI / Python — Pytest fixtures and helpers under tests/helpers/

**Fixture:**
- `project.yaml` has `stack.name: FastAPI`, `stack.language: Python`,
  `testing.framework: pytest`; `pytest` assertion conventions can be confirmed
- `tests/` exists
- No helpers exist yet; the user approves the write

**Input:** `/saas-test-helpers scaffold`

**Expected behavior:**
1. The helper root is `tests/helpers/`
2. Skill drafts `tests/helpers/auth.py` and `tests/helpers/factories.py` for that folder,
   providing reusable pytest fixtures and factory helpers
3. Skill asks "May I write these helper files to `tests/helpers/`?"
4. Files written on approval; the usage note explains importing fixtures in `tests/conftest.py`;
   verdict COMPLETE

**Assertions:**
- [ ] Helpers are written under `tests/helpers/`
- [ ] Pytest helper functions and fixtures are generated cleanly
- [ ] The "May I write" ask names `tests/helpers/`
- [ ] Verdict is COMPLETE

---

## Protocol Compliance

- [ ] Reads stack, language and test framework before generating any helper
- [ ] Writes helpers to the stack's helper root (`tests/helpers/`)
- [ ] Section-greps the PRD for system helpers (numbered headings such as `## 4. Formulas` included); constants trace to its Formulas section
- [ ] Async event assertions correctly resolve promises / async fixtures without unhandled rejections
- [ ] Asserts only through the configured framework — never bare `assert()` — and generates nothing when that API cannot be confirmed
- [ ] Helpers never extend the framework's test-suite base class
- [ ] Never overwrites an existing helper; reports the skip instead
- [ ] Asks "May I write" before any file is created
- [ ] Verdict is COMPLETE when helper files are written

---

## Coverage Notes

- `all` mode (one factory per module with test files) follows Case 1 per module;
  not separately tested.
- Cloudflare Workers helper generation follows Case 1's pattern for TypeScript helpers;
  not separately tested.
- A requested module with no PRD is not tested; the skill does not define that path.
