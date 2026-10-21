> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-PRD-ALIGNMENT — Product Requirements Alignment Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: Product strategy, user value, PRD integrity, problem-solution alignment

**Trigger**: After PRD drafting or modification (`/saas-design-system`, `/saas-quick-design`), before architecture review

**Context to pass**:
- PRD file path (`docs/specs/*.md`)
- Product pillars (`docs/specs/product-pillars.md`)
- User persona profiles and problem statements
- Modes rigor setting (`modes.rigor` from `project.yaml`)

**Prompt**:
> "Evaluate this PRD for strategic alignment with product pillars and ICP needs. Does the document clearly articulate the customer problem, target user, success metrics, and acceptance criteria? Are all user stories formatted with clear 'As a / I want / So that' structure and measurable outcomes? Does the PRD maintain consistency with previously approved specifications without contradiction? Return ALIGNED (PRD aligns with strategy and problem statement) or DRIFT DETECTED [areas of divergence or conflicting logic]."

**Verdicts**: ALIGNED / DRIFT DETECTED
