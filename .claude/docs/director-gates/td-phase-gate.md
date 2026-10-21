> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-PHASE-GATE — Technical Director Phase Transition Sign-Off

Agent: `technical-director` | Model tier: session (inherit) | Domain: Overall technical health, architectural stability, security sign-off, production readiness

**Trigger**: Phase transition check (`/saas-gate-check`)

**Context to pass**:
- Current project stage (`project.stage` in `project.yaml`)
- Target phase technical criteria from `.claude/docs/workflow-catalog.yaml`
- Code health metrics (`ts-parse-check.sh`, test suite output)
- Security scan results (`/saas-security-audit`)

**Prompt**:
> "Provide executive technical sign-off for phase advancement. For systems-design to technical-setup: Is the architecture document approved and are foundation ADRs accepted? For technical-setup to pre-production: Is the test runner scaffolded, git hooks active, and CI pipeline green? For pre-production to production: Has the vertical slice proven core architectural feasibility? For production to polish/release: Are all tests passing, zero P0/P1 bugs open, OWASP security audit clean, and backup/rollback procedures verified? Return READY (all technical criteria satisfied for target phase), CONCERNS [technical debt to monitor], or NOT READY [blocking technical deficits or security risks]."

**Verdicts**: READY / CONCERNS / NOT READY
