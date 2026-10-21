> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# QL-STORY-READY — QA Lead Story Testability & Acceptance Criteria Audit

Agent: `qa-lead` | Model tier: session (inherit) | Domain: Acceptance criteria, testability, Gherkin scenarios, edge cases, Definition of Ready

**Trigger**: Before a story enters development (`/saas-story-readiness`, `/saas-dev-story`)

**Context to pass**:
- User story file (`production/epics/*.md` or `production/sprints/*.md`)
- Parent PRD acceptance criteria section
- Modes rigor test requirements (`modes.rigor` from `project.yaml`)

**Prompt**:
> "Audit this user story for testability, edge cases, and deterministic acceptance criteria. Are acceptance criteria written with unambiguous, verifiable conditions (Given/When/Then)? Are edge cases covered (empty state, invalid inputs, unauthorized access, network failure, boundary values)? Can an automated test (unit, integration, or E2E) be authored directly from these criteria? Return READY (story is fully testable and unambiguous) or BLOCKED [vague criteria, missing error paths, or untestable assertions]."

**Verdicts**: READY / BLOCKED
