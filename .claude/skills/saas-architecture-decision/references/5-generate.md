# /saas-architecture-decision — Step 5: Generate the ADR

> Part of `/saas-architecture-decision`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 5. Generate the ADR

**In this file:**

- The ADR template
- 5.5 Engine Specialist Validation
- 5.6 Technical Director Strategic Review, with the review mode check
- 5.7 PRD Sync Check: found, none found, could not check
- Write approval
- Update Architecture Registry, and the registry append logic

Following this format:

```markdown
# ADR-[NNNN]: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date
[Date of decision]

## Last Verified
[YYYY-MM-DD — when this ADR was last confirmed accurate against the current
engine version and design. Update this date when you re-read and confirm it is
still correct, even if nothing changed.]

## Decision Makers
[Who was involved in this decision]

## Summary
[2 sentences: what problem this ADR solves, and what was decided. Written for
tiered context loading — a skill scanning 20 ADRs uses this to decide whether to
read the full decision. Be specific: name the system, the problem, and the
chosen approach.]

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | [e.g. Next.js 4.7] |
| **Domain** | [Auth / Database / API / Routing / UI / Billing / State / Background Jobs / Core] |
| **Layer** | [Foundation / Core / Feature / Presentation] |
| **Knowledge Risk** | [LOW / MEDIUM / HIGH — from VERSION.md] |
| **References Consulted** | [List engine-reference docs read, e.g. `docs/engine-reference/nextjs/modules/database.md`] |
| **Post-Cutoff APIs Used** | [Any APIs from post-LLM-cutoff versions this decision depends on, or "None"] |
| **Verification Required** | [Specific behaviours to test before shipping, or "None"] |

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
- **Rejection Reason**: [Why this was not chosen]

### Alternative 2: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Rejection Reason**: [Why this was not chosen]

## Consequences

### Positive
- [Good outcomes of this decision]

### Negative
- [Trade-offs and costs accepted]

## Risks
- [Things that could go wrong]
- [Mitigation for each risk]

## PRD Requirements Addressed

| PRD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| [system-name].md | [specific rule, formula, or performance constraint from that PRD] | [how this decision satisfies it] |

## Performance Implications
- **CPU**: [Expected impact]
- **Memory**: [Expected impact]
- **Load Time**: [Expected impact]
- **Network**: [Expected impact, if applicable]

## Migration Plan
[If this changes existing code, how do we get from here to there?]

## Validation Criteria
[How will we know this decision was correct? What metrics or tests?]

## Related
- [Links to related ADRs — note if supersedes, contradicts, or depends on]
- [Links to related design documents]
```

**Always write the Layer row.** An ADR with no Layer row counts as critical
(Foundation) wherever it is read, so at `standard` its advisory items become
blockers. The value is the ADR's own layer, how early in the build it must
exist: the layer `docs/architecture/architecture.md`'s layer map gives the
system this decision governs. With no layer map, or no system in it, ask the
user, with the four values as options. Never take it from an epic that
references the ADR, and never reuse a `Domain` value (the template's note under
Engine Compatibility says why).

5.5. **Engine Specialist Validation** — Before saving, spawn the **primary stack specialist** via `Agent` to validate the drafted ADR:
   - Resolve the primary specialist: `<engine>-specialist` derived from `stack.frontend` in `project.yaml` (Next.js→`nextjs-specialist`, FastAPI→`fastapi-specialist`, Cloudflare→`cloudflare-specialist`); if `stack.frontend` is absent or empty, read the Primary line of the `## Engine Specialists` section in `.claude/docs/technical-preferences.md`
   - If no engine is configured (neither source yields an engine), skip this step **Record ``Engine validation: NOT ASSESSED — no engine configured (`stack.frontend` unset in `project.yaml`)`` in this run's output.** A skipped check that says nothing is indistinguishable from a check that passed; the reader cannot tell engine guidance was never sought.
   - Spawn `subagent_type: [primary specialist]` with: the ADR's Engine Compatibility section, Decision section, Key Interfaces, and the stack reference docs path. Ask them to:
     1. Confirm the proposed approach is idiomatic for the pinned engine version
     2. Flag any APIs or patterns that are deprecated or changed post-training-cutoff
     3. Identify stack-specific risks or gotchas not captured in the current ADR draft
   - If the specialist identifies a **blocking issue** (wrong API, deprecated approach, engine version incompatibility): revise the Decision and Engine Compatibility sections accordingly, then confirm the changes with the user before proceeding
   - If the specialist finds **minor notes** only: incorporate them into the ADR's Risks subsection

**Review mode check** — apply before spawning TD-ADR:
- `solo` → skip. Note: "TD-ADR skipped — Solo mode." Proceed to Step 5.7 (PRD sync check).
- `lean` → skip (not a PHASE-GATE). Note: "TD-ADR skipped — Lean mode." Proceed to Step 5.7 (PRD sync check).
- `full` → spawn as normal.

5.6. **Technical Director Strategic Review** — After the stack specialist validation, spawn `technical-director` via `Agent` using gate **TD-ADR** (`.claude/docs/director-gates/td-adr.md`):
   - Pass: the ADR file path (or draft content), engine version, domain, any existing ADRs in the same domain
   - The TD validates architectural coherence (is this decision consistent with the whole system?) — distinct from the stack specialist's API-level check
   - On CONCERNS: show them to the user verbatim and ask with the standard options from `director-gates.md` — `Revise flagged items` / `Accept and proceed` / `Discuss further`. Revise the flagged Decision or Alternatives sections only on `Revise flagged items`.
   - On REJECT: show the blockers verbatim and revise the Decision or Alternatives sections before proceeding.
   - A revised draft still reaches the user through the write approval below; nothing is written before it. A `NOT ASSESSED` answer is not an approval — name the missing input (`director-gates.md`).

5.7. **PRD Sync Check** — Before presenting the write approval, scan all PRDs
referenced in the "PRD Requirements Addressed" section for naming inconsistencies
with the ADR's Key Interfaces and Decision sections (renamed signals, API methods,
or data types). If any are found, surface them as a **prominent warning block**
immediately before the write approval — not as a footnote:

```
⚠️ PRD SYNC REQUIRED
[prd-filename].md uses names this ADR has renamed:
  [old_name] → [new_name_from_adr]
  [old_name_2] → [new_name_2_from_adr]
The PRD must be updated before or alongside writing this ADR to prevent
developers reading the PRD from implementing the wrong interface.
```

**This check has three outcomes, not two.** The two above are "found" and "none
found"; the third is **could not check**, which must never take the silent
branch and render like a clean result.

- **None found** — print one line, do not stay silent:
  `PRD sync: checked [N] referenced PRD(s), no naming inconsistencies.`
  A silent pass is indistinguishable from a check that never ran, and this one
  guards against developers implementing the wrong interface from a stale PRD.
- **Could not check** — the ADR has no `PRD Requirements Addressed` section, it
  names no PRDs, or a named PRD does not exist on disk. Print:
  `PRD sync: NOT ASSESSED — [which reason, and which files]`
  Do **not** treat an ADR that references no PRDs as one whose PRDs are
  consistent. Nothing was compared.

Only the warning block itself is conditional; the check always reports.

5. **Write approval** — Use `AskUserQuestion`:

If PRD sync issues were found:
- "ADR draft is complete. How would you like to proceed?"
  - [A] Write ADR + update PRD in the same pass
  - [B] Write ADR only — I'll update the PRD manually
  - [C] Not yet — I need to review further

If no PRD sync issues:
- "ADR draft is complete. May I write it?"
  - [A] Write ADR to `docs/architecture/adr-[NNNN]-[slug].md`
  - [B] Not yet — I need to review further

If yes to any write option, write the file, creating the directory if needed.
For option [A] with PRD update: also update the PRD file(s) to use the new names.

6. **Update Architecture Registry**

Scan the written ADR for new architectural stances that should be registered:
- State it claims ownership of
- Interface contracts it defines (signal signatures, method APIs)
- Performance budget it claims
- API choices it makes explicitly
- Patterns it bans (Consequences → Negative or explicit "do not use X")

Present candidates:
```
Registry candidates from this ADR:
  NEW state ownership:      usage_quota → billing-system
  NEW interface contract:   quota_exceeded webhook event
  NEW performance budget:   billing-system: p95 < 100ms API latency
  NEW forbidden pattern:    synchronous external billing calls on request path
  EXISTING (referenced_by update only): user_session → already registered ✅
```

**Registry append logic**: When writing to `docs/registry/architecture.yaml`, do NOT assume sections are empty. The file may already have entries from previous ADRs written in this session. Before each Edit call:
1. Read the current state of `docs/registry/architecture.yaml`
2. Find the correct section (state_ownership, interfaces, forbidden_patterns, api_decisions)
3. If the section is still the empty list (`state_ownership: []`), replace `[]` with the first entry: the key alone on its line, the entry below it indented two spaces as in the file's commented example. An entry appended after `[]` makes the file invalid YAML. Otherwise append the new entry AFTER the last existing entry in that section
4. If the section has entries already, use the closing content of the last entry as the `old_string` anchor, and append the new entry after it

**BLOCKING — do not write to `docs/registry/architecture.yaml` without explicit user approval.**

Ask using `AskUserQuestion`:
- "May I update `docs/registry/architecture.yaml` with these [N] new stances?"
  - Options: "Yes — update the registry", "Not yet — I want to review the candidates", "Skip registry update"

Only proceed if the user selects yes. If yes: append new entries. Never modify existing entries — if a stance is
changing, set the old entry to `status: "superseded_by: ADR-[NNNN]"` and add the new entry. Keep the quotes:
unquoted, the second colon makes the file invalid YAML.

After writing, run `bash .claude/scripts/registry.sh validate` and fix every row about an entry this write added
or changed (a DUPLICATE, STATUS or LAYOUT row, an UNQUOTED row (quote the value it names), or a PATH_MISSING row for a path it named) before you go on; name
rows about other entries to the user rather than fixing them unasked. If the script is missing or prints nothing,
say the registry check did not run, then re-read the entries you wrote against the rules in the file's header.

---
