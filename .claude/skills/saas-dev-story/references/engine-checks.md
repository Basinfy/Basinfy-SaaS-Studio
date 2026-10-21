# Phase 6: Syntax, Typecheck and Autonomous Self-Correction

Read when verifying implementation code across Next.js, FastAPI, Cloudflare Workers, or Go.

## Stack-Specific Build & Syntax Checks

### Next.js & TypeScript
Run typechecking and build validation:
```bash
npx tsc --noEmit
# Or build check:
npm run build
```
- **Exit 0**: Typecheck passed: VERIFIED.
- **Exit 1**: TypeScript errors: extract error lines (`TS2322`, `TS2339`, etc.) and invoke the Autonomous Reflection Loop.

### FastAPI & Python
Run syntax compilation and static type checks:
```bash
python -m py_compile <changed_files.py>
mypy <changed_files.py> --ignore-missing-imports
```
- **Exit 0**: Syntax and types valid: VERIFIED.
- **Exit 1**: SyntaxError or TypeError: extract traceback and invoke the Autonomous Reflection Loop.

### Cloudflare Workers
Run worker type generation and TypeScript verification:
```bash
npx wrangler types
npx tsc --noEmit
```
- **Exit 0**: Worker syntax verified: VERIFIED.
- **Exit 1**: Type errors: invoke the Autonomous Reflection Loop.

### Go Microservices
```bash
go vet ./...
go build ./...
```
- **Exit 0**: Go compilation clean: VERIFIED.
- **Exit 1**: Compilation error: invoke Autonomous Reflection Loop.

---

## Autonomous Reflection & Self-Correction Protocol (Standard Engineering SOP)

When a syntax check, typecheck, or unit test exits with a non-zero code:

1. **Step 1: Failure Capture**:
   - Capture stderr and stdout.
   - Extract the failing file path, line number, error code, and stack trace.

2. **Step 2: Diagnosis & Reflection**:
   - Analyze the root cause:
     - Missing import or exported symbol?
     - Type mismatch (e.g. `string | undefined` passed to non-nullable param)?
     - Incorrect mock or broken assertion in test?
     - Schema drift between database model and API contract?

3. **Step 3: Surgical Patch Application**:
   - Formulate a targeted patch that fixes the error without breaking existing tests or violating the Acceptance Criteria.
   - Apply the patch to the failing file.

4. **Step 4: Retest & Iteration**:
   - Re-run the verification command.
   - If it passes (exit 0): Log `Self-Correction Succeeded on attempt [N]` and proceed.
   - If it fails: Repeat reflection and patch (maximum 3 attempts).

5. **Step 5: Fallback & Escalation**:
   - If after 3 attempts the issue persists, halt further changes.
   - Mark the story checkpoint as `BLOCKED: Automated check failed after 3 self-correction attempts`.
   - Provide the exact reproduction steps and error log in the summary.
