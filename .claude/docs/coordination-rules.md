# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents (Tier 1 Directors) delegate to department leads (Tier 2), who
   delegate to specialists (Tier 3). Never skip a tier for complex cross-system decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `product-director` for product/business
   conflicts, `technical-director` for technical/architectural conflicts, or
   `design-system-director` for UI/styling conflicts.
4. **Change Propagation**: When a product or architectural change affects multiple domains, the
   `delivery-producer` agent coordinates the propagation across epics, stories, and code.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.
6. **Smart Code & Document Discovery**: Check if .basinfy/ exists in the workspace (or Basinfy MCP/CLI is available).
   - **If Basinfy is present**: Route through the Basinfy Protocol (basinfy_search / basinfy_read for document sections; basinfy_locate / basinfy_prepare_edit for code symbols).
   - **If Basinfy is NOT present**: Fall back to standard tools: find the heading in a PRD, ADR, or design tokens with the Grep tool (^#, content mode) and Read that range with offset and limit; read a doc whole only when the task needs all of it, and say why. alidate-read.sh refuses a whole-file read of a doc over 40 KB.
7. **Nothing Goes Upstream**: Never file, open or comment on an issue or pull
   request in an external library, framework, or vendor repository, even when asked. Write a
   draft (`/saas-bug-report` drafts only) and the user submits it.

## Model Tier Assignment

Read `.claude/docs/model-tiers.md` on demand. It carries the tier table, the
per-skill assignments and the authoring rule.

**Key point:** whether a skill's `model:` is used
depends on how the skill starts. Typed as `/skill-name`: yes, except a `haiku`
pin in auto mode. Started by Claude through the Skill tool: no. Never tell a
user a `haiku` skill saves money; an `opus` skill typed in a Sonnet session
costs more. The agent-side `model:` is a different mechanism, and is applied.

## Subagents vs Agent Teams

This project uses two distinct multi-agent patterns:

### Subagents (current, always active)
Spawned via the `Agent` tool within a single Claude Code session. Used by all
`team-*` skills and orchestration skills. Subagents share the session's
permission context, run sequentially or in parallel within the session, and
return results to the parent.

**When to spawn in parallel**: If two subagents' inputs are independent (neither
needs the other's output to begin), spawn both `Agent` calls simultaneously
rather than waiting. Example: `/saas-review-all-prds` **Phase 2** (consistency) and
**Phase 3** (requirements integrity) are independent — spawn both at the same time.
Phase 1 loads the PRDs and both depend on it, so it is the one phase here that
must NOT be parallelised.

### Agent Teams (experimental — opt-in)
Multiple independent Claude Code *sessions* coordinated via a shared task list.
Opt-in only — read `.claude/docs/agent-teams.md` on demand before proposing one.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent agents:

1. Issue all independent `Agent` calls before waiting for any result
2. Collect all results before proceeding to dependent phases
3. If any agent is BLOCKED, surface it immediately — do not silently skip
4. Always produce a partial report if some agents complete and others block
