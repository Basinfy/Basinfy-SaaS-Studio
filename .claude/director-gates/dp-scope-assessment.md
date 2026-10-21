> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DP-SCOPE-ASSESSMENT — Delivery Producer Scope & Creep Audit

Agent: `delivery-producer` | Model tier: session (inherit) | Domain: Scope baseline tracking, backlog growth, gold-plating detection, timeline impact

**Trigger**: Mid-sprint review, backlog audit (`/saas-scope-check`), or when scope increases

**Context to pass**:
- Baseline PRD requirements pool (`docs/specs/*.md`)
- Current story backlog and implementation progress (`production/epics/`)
- Sprint capacity and burnup rate

**Prompt**:
> "Compare current implementation scope against the baseline PRD requirements pool. Have unauthorized features, non-essential settings, or over-engineered abstractions crept into the sprint? Does the current trajectory threaten the release schedule or sprint delivery commitment? Return ON TRACK (scope remains disciplined and aligned with PRD) or CREEP DETECTED [unapproved additions identified for deferral]."

**Verdicts**: ON TRACK / CREEP DETECTED
