> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-USABILITY-REVIEW — UX Flow & Usability Evaluation Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: User testing feedback, onboarding friction, task completion rates, usability bugs

**Trigger**: After usability testing sessions, interactive prototype evaluation, or beta feedback

**Context to pass**:
- Usability test reports (`docs/specs/usability-report.md`)
- Task completion metrics, user friction logs, and drop-off points
- Screen flows and onboarding experience (`docs/specs/customer-journey-map.md`)

**Prompt**:
> "Evaluate usability feedback and telemetry from prototype or user testing sessions. Can a new user reach the core value proposition (activation) without external assistance? Are there confusing navigation steps, unexpected error triggers, or excessive form inputs? Are key customer workflows frictionless and intuitive? Return READY (usability is validated for target phase), CONCERNS [minor UX friction to streamline], or NOT READY [severe usability blockers preventing task completion]."

**Verdicts**: READY / CONCERNS / NOT READY
