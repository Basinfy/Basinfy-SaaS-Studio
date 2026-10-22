# /saas-create-architecture — Phase 5: ADR Audit and Traceability Check

> Part of `/saas-create-architecture`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: ADR Audit + Traceability Check

Review all existing ADRs from Phase 0c against both the architecture built in
Phases 1-4 AND the Technical Requirements Baseline from Phase 0b.

### ADR Quality Check

For each ADR:
- [ ] Does it have an Engine Compatibility section?
- [ ] Is the engine version recorded?
- [ ] Are post-cutoff APIs flagged?
- [ ] Does it have a "PRD Requirements Addressed" section?
- [ ] Does it conflict with the layer/ownership decisions made in this session?
- [ ] Is it still valid for the pinned engine version?

| ADR | Engine Compat | Version | PRD Linkage | Conflicts | Valid |
|-----|--------------|---------|-------------|-----------|-------|
| ADR-0001: [title] | ✅/❌ | ✅/❌ | ✅/❌ | None/[conflict] | ✅/⚠️ |

### Traceability Coverage Check

Map every requirement from the Technical Requirements Baseline to existing ADRs.
For each requirement, check if any ADR's "PRD Requirements Addressed" section
or decision text covers it:

| Req ID | Requirement | ADR Coverage | Status |
|--------|-------------|--------------|--------|
| TR-auth-001 | Session token verification | ADR-0003 | ✅ |
| TR-billing-001 | Stripe webhook handler | — | ❌ GAP |

Count: X covered, Y gaps. For each gap, it becomes a **Required New ADR**.

### Required New ADRs

List all decisions made during this architecture session (Phases 1-4) that do
not yet have a corresponding ADR, PLUS all uncovered Technical Requirements.
Group by layer — Foundation first:

**Foundation Layer (must create before any coding):**
- `/saas-architecture-decision [title]` → covers: TR-[id], TR-[id]

**Core Layer:**
- `/saas-architecture-decision [title]` → covers: TR-[id]

---
