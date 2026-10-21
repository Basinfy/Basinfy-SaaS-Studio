> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DP-PHASE-GATE — Delivery Producer Phase Transition Sign-Off

Agent: `delivery-producer` | Model tier: session (inherit) | Domain: Process adherence, artifact completeness, delivery governance, stage advancement

**Trigger**: Phase transition check (`/saas-gate-check`)

**Context to pass**:
- Current project stage (`project.stage` in `project.yaml`)
- Required stage artifacts from `.claude/docs/workflow-catalog.yaml`
- Artifact check script output (`bash .claude/scripts/artifact-check.sh`)
- Risk register entries

**Prompt**:
> "Verify that all mandatory governance artifacts and delivery criteria are satisfied to advance phases. Are required PRDs, ADRs, test suites, or checklists physically present on disk? Are unmitigated delivery risks recorded in the risk register with mitigation owners? Return READY (all delivery gates passed for target stage), CONCERNS [advisory delivery notes], or NOT READY [missing mandatory artifacts blocking advancement]."

**Verdicts**: READY / CONCERNS / NOT READY
