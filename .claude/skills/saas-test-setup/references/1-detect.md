# /saas-test-setup — Phase 1: Detect Engine and Existing State

> Part of `/saas-test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 1: Detect Engine and Existing State

1. **Read engine config**:
   - Read `stack.frontend` from `project.yaml`; if that key is absent or empty
     (including when `project.yaml` has no `engine:` block), fall back to the
     `Engine:` value in `.claude/docs/technical-preferences.md`.
   - If neither source yields a configured engine (project.yaml `stack.frontend`
     absent/empty and technical-preferences.md shows `[TO BE CONFIGURED]` or is
     missing), stop:
     "Engine not configured. Run `/saas-setup-stack` first, then re-run `/saas-test-setup`."

2. **Check for existing test infrastructure**:
   - Glob `tests/` — does the directory exist?
   - Glob `tests/unit/` and `tests/integration/` — do subdirectories exist?
   - Glob `.github/workflows/` — does a CI workflow file exist?
   - Glob `node_modules/vitest/` (Next.js / Vitest),
     `tests/` or `pytest.ini` (FastAPI / Pytest), or
     `node_modules/wrangler/` (Cloudflare) for stack-specific artifacts.

3. **Report findings**:
   - "Engine: [engine]. Test directory: [found / not found]. CI workflow: [found / not found]."
   - If everything already exists AND `force` argument was not passed:
     "Test infrastructure appears to be in place. Re-run with `/saas-test-setup force`
     to regenerate. Proceeding will not overwrite existing test files."

If the `force` argument is passed, skip the "already exists" early-exit and
proceed — but still do not overwrite files that already exist at a given path.
Only create files that are missing.

---
