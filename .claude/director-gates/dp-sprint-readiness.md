> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DP-SPRINT-READINESS — Delivery Producer Sprint Planning Readiness

Agent: `delivery-producer` | Model tier: session (inherit) | Domain: Sprint backlog readiness, capacity allocation, dependency sequencing, Definition of Ready

**Trigger**: Sprint planning session (`/saas-sprint-plan`), before starting development

**Context to pass**:
- Sprint backlog candidate stories (`production/sprints/saas-sprint-plan.md`)
- Story readiness check results (`/saas-story-readiness`)
- Team capacity and velocity metrics from `project.yaml` (`cadence.*`)

**Prompt**:
> "Validate that the proposed sprint backlog is balanced, sequenced, and implementation-ready. Does every committed story satisfy the Definition of Ready (PRD link, clear acceptance criteria, test plan)? Is total story complexity aligned with historical team velocity without overloading capacity? Are external dependencies (e.g., Stripe keys, OAuth client credentials) resolved? Return READY (sprint plan is solid and executable) or BLOCKED [stories missing criteria or unresolved dependencies]."

**Verdicts**: READY / BLOCKED
