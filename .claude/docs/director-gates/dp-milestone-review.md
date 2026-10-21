> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DP-MILESTONE-REVIEW — Delivery Producer Milestone Progress Review

Agent: `delivery-producer` | Model tier: session (inherit) | Domain: Milestone commitments, delivery burndown, blocker resolution, Go/No-Go decisions

**Trigger**: Milestone checkpoint (`/saas-milestone-review`), end of release sprint

**Context to pass**:
- Milestone definition and target date (`docs/specs/milestone-definition.md`)
- Sprint burndown and velocity data (`production/sprints/`)
- Bug triage queue and open P0/P1 issues (`production/qa/`)

**Prompt**:
> "Evaluate milestone health, completion percentage, and open blocker issues. Are all committed P0 stories completed and verified with QA evidence? Are there open critical security vulnerabilities or blocking regression bugs? Is the team on track for scheduled release, or is scope adjustment required? Return GO (milestone objectives met, proceed to next stage), NO-GO [unresolved blockers require remediation], or PROCEED WITH RISK [minor non-critical items deferred with explicit sign-off]."

**Verdicts**: GO / NO-GO / PROCEED WITH RISK
