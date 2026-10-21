# Skill Test Spec: /saas-smoke-check

## Skill Summary

`/saas-smoke-check` is the gate between implementation and QA hand-off. Phase 1 runs
`project-coherence.sh`, verifies that **product test files** exist under the
stack's test root or `tests/smoke/` (not merely that `tests/` exists), and
reads the stack from `project.yaml` (falling back to `technical-preferences.md`),
then resolves the editor executable — the one `commands.test` names, else
`stack.path`, else the name on `PATH` — before it calls the runner unavailable.
Phase 2 runs `commands.test` (or the per-stack default) under a timeout and
reads the result by stack — test runner exit codes (Vitest, Jest, Pytest, Playwright);
E2E integration suites get their own results
file. At `qa.level: minimal` with no automated tests, the automated row is WAIVED
and Phase 2 runs a build check instead — `commands.smoke`, else
`commands.build`, when set. Phase 3 scans test coverage against the QA plan or
sprint stories; Phase 4 batch-verifies manual smoke checks with
`AskUserQuestion`, and Batch 1 first asks whether the build was launched this
session — "not launched" makes the manual checks NOT ASSESSED. The report is written
to `production/qa/smoke-[date].md` after explicit approval.

Verdicts, first matching rule wins: FAIL (a test failure, a suite that did not
complete — timeout, compile/parse/build error, no results file — or a Batch
1/Batch 2 check FAILED, or a failed build check), NOT ASSESSED (suite unconfirmed NOT RUN, a runner that
could not run or executed zero tests, a check
that could not execute — including a build not launched this session — an
`UNKNOWN` coverage row, Batch 3 skipped — or no automated tests at `qa.level`
`standard`/`full`; at `minimal` the automated row is WAIVED and the batches carry
the verdict), PASS WITH WARNINGS (MISSING test evidence, a runner warning such
as unhandled promise rejections / open handles, or a NOT RUN suite the developer confirmed),
PASS. NOT ASSESSED ranks above both pass values and below FAIL.
Whether a FAIL blocks hand-off depends on `qa.level` (advisory at `minimal`)
and `testing.strict.config` (unset → blocking).

No director gates apply. The skill does NOT invoke any director agents.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: PASS, PASS WITH WARNINGS, NOT ASSESSED, FAIL
- [ ] Contains "May I write" collaborative protocol language before writing the report
- [ ] Has a next-step handoff (re-run `/saas-smoke-check` after a FAIL; QA hand-off to qa-manual-tester on PASS)

---

## Director Gate Checks

None. `/saas-smoke-check` is a pre-QA utility skill. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Automated tests pass, manual items confirmed, PASS

**Fixture:**
- `project.yaml` has `stack.name: Next.js` and `commands.test` set to the test runner command (`npm test -- --run`)
- `package.json` test scripts exist; product tests exist under
  `tests/unit/` and `tests/integration/`
- `production/qa/saas-qa-plan-sprint-005.md` exists
- The runner exits 0 with 12 tests, 12 passing
- The developer says the build was launched this session and selects no FAILED item in Batch 1, Batch 2 or Batch 3
- Every sprint story is COVERED or EXPECTED (no MISSING, no UNKNOWN)

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Phase 1 reports environment: Next.js, tests found, QA plan path
2. Runs `nextjs --headless --path . --import`, then `commands.test`
   (`npm test -- --run`)
   under `timeout 900`; the report says `commands.test` was the command run
3. Exit 0 with tests found → automated tests PASS (12/12)
4. Coverage scan: all stories COVERED or EXPECTED
5. `AskUserQuestion` for Batch 1, Batch 2 and Batch 3 — nothing selected
6. Report names its checklist source (the QA plan's Smoke Test Scope)
7. Asks "May I write this smoke check report to `production/qa/smoke-[date].md`?"
8. Writes after approval; delivers "Smoke check passed cleanly. The build is ready for manual QA."

**Assertions:**
- [ ] Automated test runner is invoked via Bash, after the Next.js import
- [ ] `AskUserQuestion` is used for manual smoke check batches
- [ ] "May I write" is asked before writing the report file
- [ ] Report is written to `production/qa/smoke-[date].md`
- [ ] Verdict is PASS

---

### Case 2: Failure Path — Automated test fails, blocking FAIL

**Fixture:**
- As Case 1, but `project.yaml` sets `modes.rigor: standard` (so `qa.level`
  resolves to `standard`) and leaves `testing.strict` unset
- The runner exits 100: 10 tests run, 8 passing, 2 failing —
  `test_quota_clamp_at_zero`, `test_tax_calculation_negative`

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Skill runs automated tests via Bash; exit 100 → FAIL
2. Records both failing test names
3. Proceeds through the manual smoke check batches
4. Report shows automated tests as FAIL with the failing test names listed
5. Asks to write the report; writes after approval
6. Gate is blocking (`qa.level: standard`, `testing.strict.config` unset → blocking)
7. Delivers: "The smoke check failed. Do not hand off to QA until these failures
   are resolved: …" listing each failure, then "Fix the failures and run
   `/saas-smoke-check` again to re-gate before QA hand-off."

**Assertions:**
- [ ] Failing test names are listed in the report
- [ ] Verdict is FAIL
- [ ] The blocking message directs the developer to fix failures before QA hand-off
- [ ] `/saas-smoke-check` re-run is suggested after fixing

---

### Case 3: Manual Confirmation — MISSING coverage, PASS WITH WARNINGS

**Fixture:**
- As Case 1: runner exits 0 with 8/8 passing
- One Logic story has no matching test file (MISSING coverage); no UNKNOWN rows
- The developer selects no FAILED item in Batch 1, Batch 2 or Batch 3

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Automated tests PASS
2. Coverage scan finds 1 MISSING entry for a Logic story
3. `AskUserQuestion` is used for Batches 1–3 — nothing selected
4. Report shows automated tests PASS, manual checks PASS, and the MISSING entry
   under "Missing Test Evidence" with its expected test path
5. Verdict is PASS WITH WARNINGS; the message says the build is ready for manual
   QA and lists the MISSING entry as an advisory item to resolve before
   `/saas-story-done` on the affected story
6. Asks to write the report; writes after approval

**Assertions:**
- [ ] `AskUserQuestion` is used for manual smoke check batches (not inline text prompts)
- [ ] MISSING test coverage entry appears in the report
- [ ] Verdict is PASS WITH WARNINGS (not PASS, not FAIL)
- [ ] Advisory note says the MISSING entry must be resolved before `/saas-story-done`
- [ ] Report file is written to `production/qa/smoke-[date].md`

---

### Case 4: Scaffold Without Product Tests — NOT ASSESSED, then stop

**Fixture:**
- `project.yaml` sets `modes.rigor: standard` (so `qa.level` resolves to `standard`)
- Engine is Next.js; `tests/unit/` and `tests/integration/` exist but hold only
  the `.tsignore_placeholder` files `/saas-test-setup` creates
- No `tests/smoke/` directory

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Phase 1 counts product test files, not directories — none are found
2. Skill delivers: "Smoke check: **NOT ASSESSED — no automated tests found** under
   [the test root] or `tests/smoke/`. Run `/saas-test-setup` to scaffold the testing
   infrastructure, or point me at where tests live."
3. Skill stops — no automated run, no manual batches, no report written

**Assertions:**
- [ ] The presence of `tests/` and its subdirectories is not treated as tests existing
- [ ] Verdict is NOT ASSESSED — the skill does not stop without a verdict
- [ ] `/saas-test-setup` is suggested as the remediation step
- [ ] No further phases run and no report file is written

---

### Case 4b: No Product Tests at `qa.level: minimal` — WAIVED, the build carries the verdict

**Fixture:**
- No `modes.rigor` set (the default, `minimal`, so `qa.level` resolves to `minimal`)
- Engine is Next.js; no automated test files under `tests/unit/`, `tests/integration/` or `tests/smoke/`
- `commands.smoke` is `nextjs --headless --quit-after 5`; it exits 0 with no `SCRIPT ERROR` line
- The user says the build was launched this session and confirms every Batch 1, Batch 2 and Batch 3 check

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Phase 1 finds no automated test files and, at `qa.level: minimal`, records the automated row as `WAIVED — qa.level: minimal, no automated tests`
2. Phase 2's test run and Phase 3 are skipped, each with a one-line note saying why
3. Phase 2's build check runs `commands.smoke` (after the Next.js import) under a timeout: `Build check: PASS`
4. Phase 4 runs Batches 1–3; every check passes
5. Verdict: PASS — the report's Automated Tests status reads WAIVED

**Assertions:**
- [ ] The missing tests are WAIVED, not NOT ASSESSED, because `qa.level` is `minimal`
- [ ] The skipped test run and Phase 3 are announced, not silent
- [ ] The build check runs `commands.smoke` and its result is in the report
- [ ] Batch 1 and Batch 2 still run — PASS is never given without them
- [ ] Verdict is PASS and the report's Automated Tests row reads WAIVED
- [ ] A Batch 1 or Batch 2 check that could not be executed (no build) makes the verdict NOT ASSESSED, as at any level
- [ ] Variant — the user answers that the build was not launched this session: Batches 2 and 3 are not asked (the skip is said), the Batch 1 checks read `NOT RUN — build not launched this session`, and the verdict is NOT ASSESSED — never PASS from an empty failure list
- [ ] Variant — `commands.smoke` prints `SCRIPT ERROR` (Next.js's boot check exits 0 on it): the build check is FAIL and so is the verdict

---

### Case 5: Director Gate Check — No gate; smoke-check is a QA pre-check utility

**Fixture:**
- Valid test setup, automated tests pass, manual smoke checks confirmed

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Skill runs all phases and produces a verdict
2. No director agents are spawned at any point
3. No gate IDs (CD-*, TD-*, AD-*, PR-*) appear in output
4. No `/saas-gate-check` is invoked

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is PASS, PASS WITH WARNINGS, NOT ASSESSED, or FAIL — no gate verdict involved

---

### Case 6: Test Runner Lookalikes — exit 0 over zero tests, and warnings on exit

**Fixture:**
- As Case 1, with every story COVERED or EXPECTED and nothing selected in
  Batch 1, Batch 2 or Batch 3
- Run A: the suites under `tests/unit/` declare no test functions; the runner
  prints `No test cases found` and exits 0
- Run B: the runner exits with warnings — 12 tests, 12 passing, 2 unhandled promise rejections / open handles

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Run A: exit 0 is not read as a pass — the automated tests are
   `NOT ASSESSED — no tests found`, and the verdict is NOT ASSESSED even though
   every manual check passed
2. Run B: warning output is PASS WITH WARNINGS, naming the warning count; with no MISSING
   entry, the verdict is PASS WITH WARNINGS and the advisory list names the
   warnings

**Assertions:**
- [ ] Run A's verdict is NOT ASSESSED — not PASS
- [ ] Run B's Status line is PASS WITH WARNINGS with the warning count
- [ ] Run B's verdict is PASS WITH WARNINGS — not PASS, and not FAIL

---

### Case 7: Timeout — the suite never completed, FAIL

**Fixture:**
- As Case 2 (`qa.level: standard`, `testing.strict` unset)
- The runner hangs; `timeout 900` ends it with exit 124 and no summary printed

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Exit 124 is a gate FAILURE, never a pass — the run did not complete and
   nothing was verified
2. The Status line reads FAIL, naming the timeout
3. The verdict is FAIL and the gate is blocking

**Assertions:**
- [ ] A timeout is FAIL — not NOT ASSESSED and not NOT RUN
- [ ] The report names the timeout as the reason
- [ ] The blocking message is delivered

---

### Case 8: Batch 3 Skipped — NOT ASSESSED, not PASS

**Fixture:**
- As Case 1: runner exits 0 with 12/12 passing, no MISSING or UNKNOWN rows
- In Batch 3 the developer selects only "Performance not checked this session"

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Batches 1 and 2 pass
2. The skipped Batch 3 item is recorded as not checked — it is not a FAIL
3. The verdict is NOT ASSESSED, and the Phase 6 message names the performance
   check that did not run

**Assertions:**
- [ ] Verdict is NOT ASSESSED — not PASS, not FAIL
- [ ] The unchecked performance item is named in the report

---

### Case 9: FastAPI — Integration suite is evaluated alongside Unit suite

**Fixture:**
- `stack.name: FastAPI`; `pytest` is configured
- `commands.test` is the pytest command `/saas-setup-stack` writes
- `tests/unit/` and `tests/integration/` both hold test files
- Unit tests exit 0 with 8/8 passing; Integration tests fail with 1 of 3 failing

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. Pytest executes the test suites
2. Unit tests pass (8/8) while integration tests report 1 failure
3. The report displays status: `Unit: PASS (8/8)` and `Integration: FAIL (1 failure)`
4. The verdict is FAIL

**Assertions:**
- [ ] Integration tests are evaluated alongside unit tests
- [ ] Each suite is reported on its own line
- [ ] The integration failure makes the verdict FAIL — the unit pass does not cover it

---

### Case 10: `quick` — no coverage scan, no Batch 3

**Fixture:**
- As Case 1: runner exits 0 with 12/12 passing; the developer says the build was
  launched this session and selects no FAILED item in Batch 1 or Batch 2
- One Logic story in the sprint has no matching test file (it would be MISSING
  if scanned)
- The sprint plan and QA plan exist

**Input:** `/saas-smoke-check quick`

**Expected behavior:**
1. Phases 1 and 2 run as normal; the automated tests PASS (12/12)
2. Phase 3 is skipped and says so: "Coverage scan skipped — run
   `/saas-smoke-check sprint` for full coverage analysis."
3. `AskUserQuestion` is used for Batch 1 and Batch 2 only; Batch 3 is not asked
4. The report's Argument line reads `quick`, and its Test Coverage section reads
   "Coverage: not checked (quick run) — run `/saas-smoke-check sprint` before
   hand-off." in place of story rows — the scan was skipped, not passed
5. The unscanned Logic story is not reported as MISSING, no coverage row is
   invented for it, and Missing Test Evidence reads "Not checked (quick run).",
   not "All Logic and Integration stories have test coverage."
6. The verdict is labelled: `PASS (quick — coverage and Batch 3 not checked)`
7. Asks "May I write this smoke check report to `production/qa/smoke-[date].md`?"
   and writes after approval

**Assertions:**
- [ ] The Phase 3 skip is announced with the "Coverage scan skipped" note, not silent
- [ ] Batch 3 is never asked under `quick`; Batches 1 and 2 still are
- [ ] The automated test run still happens: `quick` skips only Phase 3 and Batch 3
- [ ] The report shows `Argument: quick` and carries no COVERED / MISSING / UNKNOWN rows
- [ ] The report says coverage was not checked, in the Test Coverage and Missing Test Evidence sections, and never claims full coverage
- [ ] The verdict line carries the `(quick — coverage and Batch 3 not checked)` label
- [ ] No Batch 3 skip makes the verdict NOT ASSESSED: Batch 3 was not offered, so the "offered and skipped" rule does not fire
- [ ] The report is still written only after "May I write" is approved

---

### Case 11: `--platform` — platform batches and a per-platform verdict table

**Fixture:**
- As Case 1: runner exits 0 with 12/12 passing; the developer says the build was
  launched this session and selects no FAILED item in Batches 1, 2 or 3;
  every story COVERED or EXPECTED
- Tablet batch: the developer selects "Tablet layout / responsive breakpoints (768px-1024px) —
  FAILED" and describes the clipped text on the settings modal
- Desktop and mobile batches (variants below): nothing selected

**Input:** `/saas-smoke-check sprint --platform tablet`

**Expected behavior:**
1. Phases 1–3 run as in Case 1
2. Phase 4 asks Batches 1–3, then the tablet batch (tablet layout, responsive breakpoints,
   touch scrolling, tap gestures); the failure is followed by a request to
   describe what is clipped
3. The report has a Platform-Specific Results table with a Tablet row
   (checks run, passed, failed 1, Platform Verdict FAIL) and no Desktop or Mobile row
4. The overall verdict is FAIL: "Any platform with one or more FAIL checks
   contributes to the overall FAIL verdict" — even though the automated tests
   and Batches 1–3 passed
5. Asks "May I write …"; writes after approval

**Assertions:**
- [ ] The tablet batch is asked in addition to Batches 1–3
- [ ] The report contains the per-platform verdict table, with the Tablet row FAIL
- [ ] The overall verdict is FAIL, driven by the tablet check alone
- [ ] No desktop or mobile batch is asked and no Desktop or Mobile row appears
- [ ] The user's description of the failure is recorded in the report
- [ ] Variant `--platform all`, nothing selected in any platform batch: the desktop, tablet and mobile batches are all asked, the table has three rows each PASS, and the verdict is PASS
- [ ] Variant `quick --platform desktop`: Phase 3 and Batch 3 are skipped as in Case 10, the desktop batch is still asked, and the table has a Desktop row

---

### Case 12: Phase files — each `references/` file is read before its phase, and again after compaction

**Fixture:**
- As Case 1 (valid setup, 12/12 passing, nothing selected in any batch)
- The conversation is compacted during Phase 3, after the test run finished and
  before the coverage scan's results are used

**Input:** `/saas-smoke-check`

**Expected behavior:**
1. `references/1-detect-setup.md` is read before the Phase 1 work, and likewise
   `references/2-run-tests.md` before the test runner is invoked,
   `references/3-coverage.md` before the story list is drawn,
   `references/4-manual-checks.md` before the first `AskUserQuestion`,
   `references/5-report.md` before the report is assembled and
   `references/6-write-gate.md` before "May I write" is asked
2. The reads happen phase by phase, in order — each phase's steps come from its
   file, not from `SKILL.md`, which only names the file
3. After the compaction, `references/3-coverage.md` is read again before the
   scan continues ("Read it again if the conversation was compacted or resumed
   during this phase"); the files of the finished phases are not read again
4. The run ends as in Case 1: Verdict PASS, report written after approval

**Assertions:**
- [ ] Six Read calls on `references/1-…` through `6-…` appear in the transcript, one per phase, in phase order
- [ ] Each file is read before the first action of its own phase (the runner for 2, the story scan for 3, `AskUserQuestion` for 4, the report for 5, the write question for 6)
- [ ] `references/3-coverage.md` is read a second time after the compaction, before the coverage work continues
- [ ] No other phase's file is re-read after the compaction
- [ ] The reads change none of Case 1's results (Verdict PASS)

---

## Protocol Compliance

- [ ] Uses `AskUserQuestion` for all manual smoke check batches (Batch 1, Batch 2, Batch 3), and Batch 1 asks whether the build was launched this session; "not launched" yields NOT ASSESSED
- [ ] Resolves the editor executable from `commands.test`, then `stack.path`, then `PATH` before reporting the runner unavailable; a bare `nextjs` that does not resolve is never read as "no stack installed"
- [ ] Never edits `project.yaml`: a `commands.test` missing flags or using a relative path is adjusted for the run and reported to the user
- [ ] Runs automated tests via Bash before asking any manual questions
- [ ] Asks "May I write" before creating the report file — never writes without approval
- [ ] Verdict vocabulary is PASS / PASS WITH WARNINGS / NOT ASSESSED / FAIL — no other verdicts
- [ ] FAIL is triggered by automated test failures, a suite that did not complete (timeout, compile/parse/build error, no results file), or Batch 1/Batch 2 FAIL responses
- [ ] PASS WITH WARNINGS is triggered by MISSING test coverage, a runner warning on a passing suite (e.g. unhandled promise rejections / open handles), or a confirmed NOT RUN — with no critical failures
- [ ] Unconfirmed NOT RUN (runner not available) yields NOT ASSESSED — never FAIL, never a pass verdict
- [ ] A run over zero tests or a runner that could not run yields NOT ASSESSED
- [ ] Does not invoke director gates at any point

---

## Coverage Notes

- The `quick` argument (skips the Phase 3 coverage scan and Batch 3) is
  Case 10; the `--platform` argument (platform batches and the per-platform
  verdict table) is Case 11; the per-phase `references/` reads and the
  re-read after compaction are Case 12. Each platform batch's individual
  options are not enumerated.
- The runner-not-available path (NOT RUN, then NOT ASSESSED until the developer
  confirms a result from their IDE or CI) is covered by the protocol compliance
  assertions above.
- At `qa.level: minimal` a FAIL is advisory and never blocks hand-off; Case 2
  pins `standard` to test the blocking path. FastAPI's `testcasecount="0"` and
  Cloudflare's `No automation tests matched` (→ NOT ASSESSED) follow Case 6 Run A;
  not separately fixture-tested.
- The Linux and macOS Cloudflare commands (picked by `uname -s`) are not
  fixture-tested. On macOS, Cloudflare tests are NOT ASSESSED until `commands.test`
  is set — asserted in the skill, not given a case here.
- An integration test suite run that cannot be made (`Integration: NOT RUN`, unconfirmed →
  NOT ASSESSED) is covered by protocol compliance, not by its own case.
