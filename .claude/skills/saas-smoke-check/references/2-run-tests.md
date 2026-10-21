# Automated Test Execution & Smoke Gate

Run the automated test suite configured in `commands.test` or the default test command for the stack.

Wrap execution in a timeout (`timeout 900 ...`): **a timeout (exit 124) is a gate FAILURE, never a pass**.

## Stack-Specific Test Runners

### Next.js (TypeScript / React)
Check `package.json` for test scripts.
```bash
# Unit & Integration test suite
npm test -- --run --passWithNoTests 2>&1
# TypeScript compilation check
npm run build 2>&1
```
- **Exit 0**: All tests passed: PASS. (If output indicates `0 tests`, verdict is `NOT ASSESSED — no tests found`).
- **Non-zero exit**: Test failure or build compile error: FAIL.

### FastAPI (Python)
Check for `pytest` or `tests/` directory:
```bash
# Run pytest with concise traceback
pytest tests/ -v --maxfail=5 2>&1
```
- **Exit 0**: All tests passed: PASS.
- **Exit 1**: Tests failed: FAIL.
- **Exit 2**: Interrupted or command error: FAIL.
- **Exit 5**: No tests collected: `NOT ASSESSED — no tests found`.

### Cloudflare Workers & Serverless
```bash
# Vitest / Miniflare runner
npm test -- --run 2>&1
```
- **Exit 0**: All worker unit tests passed: PASS.
- **Non-zero exit**: FAIL.

### Go Microservices
```bash
go test -v ./... 2>&1
```
- **Exit 0**: All unit tests passed: PASS.
- **Non-zero exit**: FAIL.

## Unknown or Unconfigured Stack
If stack is not configured in `project.yaml`:
"Stack not configured in `project.yaml`. Run `/saas-setup-stack` to specify stack, then re-run `/saas-smoke-check`."

## Test Results Extraction
Parse runner output and extract:
- Total tests run
- Passing count
- Failing count
- Names of failing tests (up to 10)
- Any uncaught exception or fatal error
