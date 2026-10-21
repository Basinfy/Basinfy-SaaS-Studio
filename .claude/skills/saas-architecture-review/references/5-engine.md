# /saas-architecture-review — Phases 5 and 5b: Engine Cross-Check and Design Revision Flags

> Part of `/saas-architecture-review`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Engine Compatibility Cross-Check

**In this file:**

- Version Consistency
- Post-Cutoff API Consistency
- Deprecated API Check
- Missing Engine Compatibility Sections
- Engine Specialist Consultation

Across all ADRs, check for engine consistency:

### Version Consistency
- Do all ADRs that mention an engine version agree on the same version?
- If any ADR was written for an older engine version, flag it as potentially stale

### Post-Cutoff API Consistency
- Collect all "Post-Cutoff APIs Used" fields from all ADRs
- For each, verify against the relevant module reference doc
- Check that no two ADRs make contradictory assumptions about the same post-cutoff API

### Deprecated API Check
- Grep all ADRs for API names listed in `deprecated-apis.md`
- Flag any ADR referencing a deprecated API

### Missing Engine Compatibility Sections
- List all ADRs that are missing the Engine Compatibility section entirely
- These are blind spots — their engine assumptions are unknown

Output format:
```
### Engine Audit Results
Engine: [name + version]
ADRs with Engine Compatibility section: X / Y total

Deprecated API References:
  - ADR-0002: uses [deprecated API] — deprecated since [version]

Stale Version References:
  - ADR-0001: written for [older version] — current project version is [version]

Post-Cutoff API Conflicts:
  - ADR-0004 and ADR-0007 both use [API] with incompatible assumptions
```

---

### Engine Specialist Consultation

After completing the stack audit above, spawn the **primary stack specialist** via `Agent` for a domain-expert second opinion:
- Resolve the primary specialist: `<engine>-specialist` derived from `stack.frontend` in `project.yaml` (Next.js→`nextjs-specialist`, FastAPI→`fastapi-specialist`, Cloudflare→`cloudflare-specialist`); if `stack.frontend` is absent or empty, read the Primary line of the `## Engine Specialists` section in `.claude/docs/technical-preferences.md`
- If no engine is configured (neither source yields an engine), skip this consultation **Record ``Engine validation: NOT ASSESSED — no engine configured (`stack.frontend` unset in `project.yaml`)`` in this run's output.** A skipped check that says nothing is indistinguishable from a check that passed; the reader cannot tell engine guidance was never sought.
- Spawn `subagent_type: [primary specialist]` with: all ADRs that contain stack-specific decisions or `Post-Cutoff APIs Used` fields, the stack reference docs, and the Phase 5 audit findings. Ask them to:
  1. Confirm or challenge each audit finding — specialists may know of framework nuances not captured in the reference docs
  2. Identify stack-specific anti-patterns in the ADRs that the audit may have missed (e.g., using the wrong Next.js node type, FastAPI component coupling, Cloudflare subsystem misuse)
  3. Flag ADRs that make assumptions about framework behavior that differ from the actual pinned version

Incorporate additional findings under `### Engine Specialist Findings` in the Phase 5 output. These feed into the final verdict — specialist-identified issues carry the same weight as audit-identified issues.

---

## Phase 5b: Design Revision Flags (Architecture → PRD Feedback)

For each **HIGH RISK stack finding** from Phase 5, check whether any PRD makes an
assumption that the verified stack reality contradicts.

Specific cases to check:

1. **Post-cutoff API behaviour differs from training-data assumptions**: If an ADR
   records a verified API behaviour that differs from the default LLM assumption,
   check all PRDs that reference the related system. Look for design rules written
   around the old (assumed) behaviour.

2. **Known framework/stack limitations in ADRs**: If an ADR records a known framework limitation
   (e.g. "Server Actions timeout after 15s on Vercel Hobby", "Prisma accelerates queries but adds cold start overhead"), check
   PRDs that design workflows around the affected feature.

3. **Deprecated API conflicts**: If Phase 5 flagged a deprecated API used in an ADR,
   check whether any PRD contains business logic that assumes the deprecated API's behaviour.

For each conflict found, record it in the PRD Revision Flags table:

```
### PRD Revision Flags (Architecture → Design Feedback)
These PRD assumptions conflict with verified framework behavior or accepted ADRs.
The PRD should be revised before its system enters implementation.

| PRD | Assumption | Reality (from ADR/engine-reference) | Action |
|-----|-----------|--------------------------------------|--------|
| billing.md | "Use parsed JSON body for Stripe webhook" | Stripe constructEvent requires raw body buffer — ADR-0003 | Revise PRD |
```

If no revision flags are found, write: "No PRD revision flags — all PRD assumptions
are consistent with verified framework behavior."

Before asking, display the proposed change inline — show the current systems-index row for each flagged PRD and the proposed updated row side by side so the user can see exactly what will change.

Then use `AskUserQuestion`:
- "I found [N] PRD revision flag(s). May I update the systems index?"
  - [A] Yes — apply all [N] updates to the systems index now
  - [B] Show me the full diff first, then ask again
  - [C] No — leave the systems index unchanged for now

If [A]: apply the updates. Status field must be exactly `Needs Revision` — no parentheticals
(other skills match that exact string and parentheticals break the match).
If [B]: display the complete proposed systems-index section, then re-ask with `AskUserQuestion`.

---
