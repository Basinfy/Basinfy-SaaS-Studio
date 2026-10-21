> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-PHASE-GATE — Product Direction Phase Transition Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: Product strategy, feature readiness, market alignment, customer journey completion

**Trigger**: Phase transition check (`/saas-gate-check`)

**Context to pass**:
- Current project stage (`project.stage` in `project.yaml`)
- Target phase requirements from `.claude/docs/workflow-catalog.yaml`
- PRD index and feature completion status (`docs/specs/features-modules-index.md`)
- Customer journey map and usability evidence

**Prompt**:
> "Evaluate whether the product meets strategic and functional criteria to advance to the target phase. For concept to systems-design: Are core problem, pillars, and brief validated? For systems-design to technical-setup: Are PRDs complete with acceptance criteria per modes.rigor? For pre-production to production: Is the core workflow (vertical slice) validated? For production to release: Are all planned P0 features implemented and verified? Return READY (product definition complete for target phase), CONCERNS [strategic risks to track], or NOT READY [critical product gaps blocking advance]."

**Verdicts**: READY / CONCERNS / NOT READY
