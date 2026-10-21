> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DP-EPIC-READINESS — Delivery Producer Epic Readiness Sign-Off

Agent: `delivery-producer` | Model tier: session (inherit) | Domain: Epic scoping, story decomposition, traceability, acceptance criteria completeness

**Trigger**: After epic drafting (`/saas-create-epics`), before sprint breakdown

**Context to pass**:
- Epic document path (`production/epics/*.md`)
- PRD source document (`docs/specs/*.md`)
- Architecture blueprint and module boundaries

**Prompt**:
> "Evaluate whether this epic is sufficiently structured and ready for story decomposition. Are business goals and user outcomes clearly defined? Is the scope bounded with an explicit 'Out of Scope' section to prevent creep? Are architectural dependencies and prerequisites identified? Return READY (epic is actionable and properly scoped) or NEEDS WORK [sections requiring definition before breakdown]."

**Verdicts**: READY / NEEDS WORK
