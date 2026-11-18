# /saas-setup-stack — Section 8: Verify Stack Coherence

> Part of `/saas-setup-stack`.

## 8. Verify Configuration Coherence

Run the deterministic coherence observer after writing `project.yaml`:

```bash
bash .claude/scripts/project-coherence.sh
```

1. Confirm `project.yaml` declares `stack.frontend`, `stack.backend`, `stack.database`, `stack.orm`, `stack.auth`, and `stack.billing`.
2. If `CLAUDE.md` carries an optional `ENGINE-REFERENCE-IMPORT` marker, verify it matches the selected stack; if `CLAUDE.md` uses the Master Constitution (which delegates stack config to `project.yaml`), no duplicate import line is needed.
3. Report any `[DIFFERS]` row to the user and resolve it before finishing. On a brand-new project before `package.json` or test scaffolding exists, `[NOT CHECKED]` rows for uninitialized packages/tests are expected — note `/saas-test-setup` as the step that initializes the test runner.
