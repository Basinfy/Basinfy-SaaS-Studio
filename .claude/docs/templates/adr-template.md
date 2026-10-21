# ADR-[NNNN]: [Title]

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

> **Who may move this to `Accepted`: the user, or `technical-director` on the
> user's explicit confirmation. No other agent, and no skill on its own.**
> Why this is stated here: stories referencing a `Proposed` ADR are set `Blocked`,
> and epics require `Accepted`, so the field needs a named owner.
> `technical-director` is the role `coordination-rules.md` already escalates
> technical conflicts to, and an ADR is that decision made durable.
>
> This does **not** relax the existing rule that `Status: Accepted` is never set
> without explicit user confirmation — it narrows *which agent* may set it once
> that confirmation exists. An agent that believes an ADR is ready says so and
> escalates; it does not edit this field.

## Date

[Date of decision]

## Last Verified

[YYYY-MM-DD — when this ADR was last confirmed accurate against the current
stack version and design. Update this date when you re-read and confirm it is
still correct, even if nothing changed.]

## Decision Makers

[Who was involved in this decision]

## Summary

[2 sentences: what problem this ADR solves, and what was decided. Written for
tiered context loading — a skill scanning 20 ADRs uses this to decide whether to
read the full decision. Be specific: name the system, the problem, and the
chosen approach.]

## Stack & Technology Compatibility

| Field | Value |
|-------|-------|
| **Stack / Framework** | [e.g. Next.js 15 / FastAPI / Supabase Postgres] |
| **Domain** | [Auth / Database / API / UI / Billing / Real-time / Background Jobs / Core] |
| **Layer** | [Foundation / Core / Feature / Presentation] |
| **Knowledge Risk** | [LOW / MEDIUM / HIGH] |
| **References Consulted** | [List stack-reference docs read, e.g. `docs/stack-reference/nextjs/server-actions.md`] |
| **Post-Cutoff APIs Used** | [Any APIs from post-LLM-cutoff versions this decision depends on, or "None"] |
| **Verification Required** | [Specific behaviours to test before shipping, or "None"] |

> **Note**: If Knowledge Risk is MEDIUM or HIGH, this ADR must be re-validated if the
> project upgrades stack versions. Flag it as "Superseded" and write a new ADR.

> **`Layer` is the ADR's own layer, not the referencing epic's — and it is a
> different taxonomy from `Domain`.** Several sites branch on whether an ADR is
> *critical (Foundation-layer)*: `/saas-create-stories`, `/saas-create-epics`,
> `/saas-architecture-decision`, `/saas-story-readiness`, `/saas-propagate-design-change` and
> `gate-pre-production.md`; a missing row counts as critical. At `standard`,
> `/saas-create-stories` **stops** for a missing critical ADR and only **warns** for a
> non-critical one, so this row decides whether a run halts. Do not infer the
> layer from the referencing epic: a Foundation-layer ADR is commonly referenced
> by a Core-layer epic, which would give the wrong answer.
>
> The vocabulary is the same `Foundation / Core / Feature / Presentation` that
> epics and stories already carry — do not invent a fifth value, and do not
> reuse a `Domain` value here. `Domain` says *what part of the stack this
> touches*; `Layer` says *how early in the build it must exist*.

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN (must be Accepted before this can be implemented), or "None"] |
| **Enables** | [ADR-NNNN (this ADR unlocks that decision), or "None"] |
| **Blocks** | [Epic/Story name — cannot start until this ADR is Accepted, or "None"] |
| **Ordering Note** | [Any sequencing constraint that isn't captured above] |

## Context

### Problem Statement
[What problem are we solving? Why does this decision need to be made now?]

### Current State
[How does the system work today? What is wrong with the current approach?]

### Constraints
- [Technical constraints]
- [Timeline constraints]
- [Resource constraints]
- [Compatibility requirements]

### Requirements
- [Must support X]
- [Must perform within Y budget]
- [Must integrate with Z]

## Decision

[The specific technical decision made, described in enough detail for someone
to implement it.]

### Architecture Diagram
[ASCII diagram or description of the system architecture this creates]

### Key Interfaces
[API contracts or interface definitions this decision creates]

### Implementation Guidelines
[Specific guidance for the programmer implementing this decision — the rules a
`/saas-create-control-manifest` or `/saas-dev-story` run should follow. State mandates as
"must / must never" so they extract cleanly.]

## Alternatives Considered

### Alternative 1: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Estimated Effort**: [Relative effort compared to the chosen approach]
- **Rejection Reason**: [Why this was not chosen]

### Alternative 2: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Estimated Effort**: [Relative effort compared to the chosen approach]
- **Rejection Reason**: [Why this was not chosen]

## Consequences

### Positive
- [Good outcomes of this decision]

### Negative
- [Trade-offs and costs accepted]

### Neutral
- [Changes that are neither good nor bad, just different]

## Risks
- [Things that could go wrong]
- [Mitigation for each risk]

## PRD Requirements Addressed

<!-- This section is MANDATORY. Every ADR must trace back to at least one PRD
     requirement, or explicitly state it is a foundational decision with no PRD
     dependency. Traceability is audited by /saas-architecture-review. -->

| PRD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| [system-name].md | [specific rule, formula, or performance constraint from that PRD] | [how this decision satisfies it] |

> If this is a foundational decision with no direct PRD dependency, write:
> "Foundational — no PRD requirement. Enables: [list what PRD systems this
> decision unlocks or constrains]"

## Performance Implications
- **CPU**: [Expected impact]
- **Memory**: [Expected impact]
- **Load Time**: [Expected impact]
- **Network**: [Expected impact, if applicable]

## Migration Plan
[If this changes existing code, how do we get from here to there?]

**Rollback plan**: [How to revert if this decision proves wrong]

## Validation Criteria
[How will we know this decision was correct? What metrics or tests?]

## Related
- [Links to related ADRs — note if supersedes, contradicts, or depends on]
- [Links to related design documents]
- [Links to relevant code files once implemented]
