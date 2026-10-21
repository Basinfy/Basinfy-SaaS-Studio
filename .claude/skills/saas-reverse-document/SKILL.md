---
name: saas-reverse-document
description: "Generate missing design or architecture docs from existing implementation — works backwards from code and prototypes."
argument-hint: "<type> <path> (e.g., 'design src/modules/billing' or 'architecture src/services/auth')"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(bash "*/.claude/skills/saas-reverse-document/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
# Read-only diagnostic skill — no specialist agent delegation needed
---
# Reverse Documentation

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

This skill analyzes existing implementation (code, prototypes, systems) and generates
appropriate design or architecture documentation. Use this when:
- You built a feature without writing a design doc first
- You inherited a codebase without documentation
- You prototyped a workflow and need to formalize it
- You need to document "why" behind existing code

---

## Workflow

## Phase 1: Parse Arguments

**Format**: `/saas-reverse-document <type> <path>`

**Type options**:
- `design` → Generate a product requirement document (PRD section)
- `architecture` → Generate an Architecture Decision Record (ADR)
- `concept` → Generate a concept document from prototype

**Path**: Directory or file to analyze, under the code root — `src/` Next.js,
`app/` FastAPI, `workers/` Cloudflare (`.claude/docs/code-root-resolution.md`)
- `src/modules/billing/` → All billing-related code (Next.js)
- `app/services/auth.py` → Specific service file (FastAPI)
- `workers/telemetry/index.ts` → A worker module (Cloudflare)
- `prototypes/billing-checkout/` → Prototype directory

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,workflow,system_overrides,automation`

**Automation mode**: Resolve `modes.automation` (`project.local.yaml` →
`project.yaml` → default `collaborative`). Every `AskUserQuestion` call and
every file write follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

Resolved above — use as-is. No block → defaults in
`.claude/docs/config-resolution.md`.

**Resolve the workflow tier** for the target system: map `<path>` to a system
name, then use the `system_overrides` row for that system if the block above
lists one, else the project `workflow` value. It sets how much document is
generated — see Phase 5. Semantics of each tier are in
`.claude/docs/workflow-modes.md`.

> **Resolve the tier — do not assume it.** `workflow-modes.md` defines what each
> tier *means*, but it cannot say what *this project* is set to; take that from
> the block above. The consequence is large here — at `full` this skill
> writes an 8-section PRD and at `minimal` a one-page brief, so a wrong tier
> produces the wrong artifact entirely.

**Examples**:
```bash
/saas-reverse-document design src/modules/subscription-billing
/saas-reverse-document architecture src/services/tenant-isolation
/saas-reverse-document concept prototypes/billing-checkout
```

## Phase 2: Analyze Implementation

**Read and understand the code/saas-prototype**:

**For design docs (PRD):**
- Identify core workflows, rules, data contracts
- Extract business configuration values (quotas, rate limits, tier thresholds)
- Find state machines, lifecycle hooks, subscription tiers
- Detect edge cases handled in code
- Map dependencies (what services/modules interact?)

**For architecture docs (ADR):**
- Identify patterns (layered, microservices, repository, event-driven, etc.)
- Understand technical decisions (middleware, ORM, caching, serialization)
- Map dependencies and coupling
- Assess performance characteristics (latency, throughput, DB queries)
- Find constraints and trade-offs

**For concept docs (prototype analysis):**
- Identify core business workflow
- Extract user interaction patterns
- Note what worked vs what didn't
- Find technical feasibility insights
- Document core user experience and value proposition

## Phase 3: Ask Clarifying Questions

**DO NOT** just describe the code. **ASK** about intent:

**Design questions**:
- "I see a [resource] system that depletes during [activity]. Was this for:
  - Pacing (prevent spam)?
  - Resource management (strategic depth)?
  - Or something else?"
- "The [workflow/feature] seems central. Is this a core pillar, or supporting feature?"
- "[Value] scales exponentially with [factor]. Intentional design, or needs rebalancing?"

**Architecture questions**:
- "You're using a service locator pattern. Was this chosen for:
  - Testability (mock dependencies)?
  - Decoupling (reduce hard references)?
  - Or inherited from existing code?"
- "I see manual memory management instead of smart pointers. Performance requirement, or legacy?"

**Concept questions**:
- "The prototype emphasizes self-serve over sales-assist. Is that the intended pillar?"
- "Users seem to exploit the grappling hook for speed. Feature or bug?"

## Phase 3b: Sufficiency Check — is there enough here to document?

**Run this before Phase 4, and stop here if it fails.** This skill infers a
design from an implementation, so when the implementation is thin there is
nothing to infer *from* — and the template below will happily accept invented
content, because every section of it is mandatory.

Count what Phase 2 actually found:

| Signal | What counts |
|---|---|
| Workflows | A named behaviour with observable rules — not a stub, not an empty class |
| Formulas | An expression computing a core business workflow value from inputs |
| Values | A tuning constant with a use site |

**If all three counts are zero, or the target path holds fewer than ~20 lines of
non-boilerplate code, stop and say so:**

> "`[path]` does not contain enough implementation to reverse-document.
> Found: [N] workflows, [N] business formulas, [N] configuration/tuning values.
> Reverse-documentation infers design from behaviour; with no behaviour to read,
> anything I produce would be invention wearing the format of a design document.
> If the design exists only in your head, `/saas-design-system [name]` is the skill
> that captures it — it asks rather than infers."

**Do not proceed on a partial count by filling the rest.** A path with two
workflows and no formulas gets a document with two workflows and an explicit
`FORMULAS DISCOVERED: none found in the source` — see Phase 4.

## Phase 4: Present Findings

Before drafting, show what you discovered:

```
I've analyzed [path]/. Here's what I found:

WORKFLOWS IMPLEMENTED:
- [workflow-a] with [property] (e.g. rate limits, cache TTLs)
- [workflow-b] (e.g. interaction between two states or services)
- [resource] system (depletes on [action], regens on [condition])
- [state] system (builds up, triggers [effect])

FORMULAS DISCOVERED:
- [Output] = [formula using discovered variables]
- [Secondary output] = [formula]

UNCLEAR INTENT AREAS:
1. [Resource] system — pacing or resource management?
2. [Workflow] — core pillar or supporting feature?
3. [Value] scaling — intentional design or needs tuning?

Before I draft the design doc, could you clarify these points?
```

> **Every section above may be empty, and an empty one must say so.** Write
> `none found in the source` under the heading — never omit the heading (which
> reads as "not looked for") and never populate it from what a system like this
> usually has. The bracketed rows are *shapes*, not quotas: a source with one
> workflow yields one row, not four.
>
> This matters more here than in a report, because the output of this skill is not
> a report — it is a **design document**, and `/saas-design-review`, `/saas-create-epics` and
> `/saas-create-stories` will read it as a statement of authored intent. A fabricated
> formula in a PRD does not stay a documentation error; it becomes a requirement,
> and then a story, and then code written to satisfy it.

Wait for user to clarify intent before drafting.

**If the user does not answer the `UNCLEAR INTENT AREAS` questions, do not draft
the resolved version anyway.** Those questions exist because **code cannot tell
you why** — it records what was built, never what was intended, and the gap
between them is the entire content of a design document. Unanswered items are
carried into the draft verbatim as open questions, in the document, marked
`INTENT UNKNOWN — inferred from implementation, not confirmed`. An inferred
intent presented as a settled one is the failure mode of this whole skill.

## Phase 5: Draft Document Using Template

Based on type, use appropriate template:

| Type | Template | Output Path |
|------|----------|-------------|
| `design` | `templates/design-doc-from-implementation.md` | `design/prd/[system-name].md` |
| `architecture` | `templates/architecture-doc-from-code.md` | `docs/architecture/[decision-name].md` |
| `concept` | `templates/concept-doc-from-prototype.md` | `prototypes/[name]/CONCEPT.md` or `design/concepts/[name].md` |

**The `design` output scales with the workflow tier** (resolved in Phase 1):
- **`full`** — generate a full 8-section PRD.
- **`standard`** — generate a 5-section PRD (Overview, Detailed Design, Edge Cases,
  Dependencies, Acceptance Criteria; + Formulas when the recovered system defines
  numeric rules). Skip User Stories & Personas and Configuration Parameters.
- **`minimal`** — generate a **product brief** in the one-page format
  (`.claude/docs/templates/product-brief.md`), not a PRD. For the whole product
  (the path is the code root itself) write `design/product-brief.md`; for a single
  reverse-engineered system write
  `design/[system-name]-brief.md`.

(`architecture` and `concept` outputs are tier-independent.)

**Draft structure**:
- Capture **what exists** (workflows, patterns, implementation)
- Document **why it exists** (intent clarified with user)
- Identify **what's missing** (edge cases not handled, gaps in design)
- Flag **follow-up work** (balance tuning, missing features)

### Stamp the provenance — required, at the top of every document this skill writes

A document produced here lands at the same path, in the same format, as one a
designer wrote by hand, and **every downstream consumer treats the two
identically**. `/saas-design-review` checks it for completeness, `/saas-create-epics`
derives epics from it, `/saas-create-stories` turns its lines into acceptance
criteria. Nothing anywhere asks where it came from.

The difference is not cosmetic: an authored PRD states **intent**, and this one
states **observed behaviour plus inference**. When they disagree, the code is
what needs changing in the first case and the document in the second — and a
reader cannot tell which they are holding unless the document says.

Emit this immediately under the title:

```markdown
> **Reverse-documented from implementation** — generated by `/saas-reverse-document`
> from `[path]` on `[date]`, at commit `[short-sha]`.
> This records what the code **does**; intent marked `INTENT UNKNOWN` below was
> inferred, not confirmed by the author. Where this document and the code
> disagree, do not assume the document is the requirement.
```

Keep the banner on revision. If a human later confirms the intent and adopts the
document as authored design, removing it is their explicit act — not a
side effect of the next edit.

## Phase 6: Show Draft and Request Approval

**Collaborative protocol**:
```
I've drafted the [system-name] design doc based on your code and clarifications.

[Show key sections: Overview, Workflows, Formulas & Business Rules, Design Intent]

ADDITIONS I MADE:
- Documented [workflow] as "[intent]" per your clarification
- Added edge cases not in code (e.g., what if [resource] hits 0 mid-[action]?)
- Flagged balance concern: [scaling type] scaling at [boundary condition]

SECTIONS MARKED AS INCOMPLETE:
- "[System] interaction with [other-system]" (not fully implemented yet)
- "[Variant or feature]" (only [subset] implemented so far)

May I write this to [output path]?
```

Use the tier-correct output path in the prompt: `design/prd/[system-name].md` for
a `full`/`standard` PRD, or `design/[system-name]-brief.md` for a `minimal` brief.

**At `collaborative`** — wait for approval; the user may request changes before
writing. **At `guided`** — this is a *new* file, so `automation-modes.md:81`
still has it asked ("May I write?" is asked for new files only); if the target
already exists, present the diff and proceed without waiting for an explicit
"yes". **At `autonomous`** — write and log the decision.

## Phase 7: Write Document with Metadata

When approved, write the file with special markers:

```markdown
---
status: reverse-documented
source: [path/]
date: [today]
verified-by: [User name]
---

# [System Name] Design

> **Note**: This document was reverse-engineered from the existing implementation.
> It captures current behavior and clarified design intent. Some sections may be
> incomplete where implementation is partial or intent was unclear.

[Rest of document...]
```

## Phase 8: Flag Follow-Up Work

After writing, suggest next steps:

```
✅ Written to design/prd/billing-system.md

FOLLOW-UP RECOMMENDED:
1. Run /saas-pricing-audit on pricing formulas (exponential scaling concern)
2. Create ADR for quota management architecture decision
3. Implement missing edge cases:
   - Quota depletion mid-transaction behavior
   - Retrying state during backoff
4. Extend design doc when tier addons are implemented

Would you like me to tackle any of these now?
```

---

## Template Selection Logic

| If analyzing... | Use template... | Because... |
|----------------|-----------------|------------|
| `<code root>/core business workflow/*` | design-doc-from-implementation.md | Core Business Workflows → PRD |
| `<code root>/core/*`, `<code root>/ai/*` | architecture-doc-from-code.md | Core systems → ADR |
| `prototypes/*` | concept-doc-from-prototype.md | Experiments → concept doc |
| `<code root>/networking/*` | architecture-doc-from-code.md | Technical systems → ADR |
| `<code root>/ui/*` | design-doc-from-implementation.md | UI/UX → design spec |

---

## Example Session: Reverse-Document a System

```
User: /saas-reverse-document design <code root>/core business workflow/[system]

Agent: I'll analyze your [system] implementation to create a design doc.
       [Reads code, discovers workflows, formulas]

Agent: I've analyzed <code root>/core business workflow/[system]/. Here's what I found:
       [Shows workflows, formulas, unclear areas]

       Before drafting, could you clarify:
       1. [Resource] system intent?
       2. Is [workflow] a core pillar?
       3. [Value] scaling — intentional or needs tuning?

User: 1. [Resource] is for pacing, prevent [unwanted behavior]
      2. [Workflow] is core — I want [design intent]
      3. Yeah, exponential is too much, should be linear

Agent: Perfect, that clarifies the vision. Let me draft the design doc.
       [Shows draft with clarified intent]

       May I write this to design/prd/[system-name].md?

User: Yes, write it.

Agent: ✅ Written to design/prd/[system-name].md
       ✅ Marked as [REVERSE-DOCUMENTED]
       ✅ Flagged [value] scaling for rebalancing

       Next steps:
       - Update [formula] to [corrected scaling]
       - Run /saas-pricing-audit to validate [curve]
       - Document [workflow] as core pillar in product-pillars.md
```

---

## Collaborative Protocol

This skill follows the collaborative design principle:

1. **Analyze First**: Read code, understand implementation
2. **Question Intent**: Ask about "why", not just "what"
3. **Present Findings**: Show discoveries, highlight unclear areas
4. **User Clarifies**: Separate intent from accidents
5. **Draft Document**: Create doc based on reality + intent
6. **Show Draft**: Display key sections, explain additions
7. **Get Approval**: "May I write to [filepath]?" On approval: Verdict: **COMPLETE** — document generated. On decline: Verdict: **BLOCKED** — user declined write.
8. **Flag Follow-Up**: Suggest related work, don't auto-execute

**Never assume intent. Always ask before documenting "why".**
