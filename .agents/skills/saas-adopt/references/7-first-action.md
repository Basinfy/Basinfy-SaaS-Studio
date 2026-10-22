# /saas-adopt — Phase 7: Offer First Action

> Part of `/saas-adopt`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 7: Offer First Action

After writing the plan, don't stop there. Pick the single highest-priority gap
and offer to handle it immediately using `AskUserQuestion`. Choose the first
branch that applies:

**If Phase 2g found a v1.0 project needing migration:** offer the converter run
described there — report what the dry run listed and ask "May I run the
converter? It writes `project.yaml` and `production/migration-report.md`."
Every other fix reads config through it, so it comes first.

**If there are parenthetical status values in features-modules-index.md:**
Use `AskUserQuestion`:
- "The most urgent fix is `features-modules-index.md` — [N] rows have parenthetical status
  values (e.g. `Needs Revision (see notes)`) that break /saas-gate-check,
  /saas-create-stories, and /saas-architecture-review right now. I can fix these in-place."
  - "Fix it now — edit features-modules-index.md"
  - "I'll fix it myself"
  - "Done — leave me with the plan"

**If ADRs are missing `## Status` (and no parenthetical issue):**
Use `AskUserQuestion`:
- "The most urgent fix is adding `## Status` to [N] ADR(s): [list filenames].
  Without it, /saas-story-readiness silently passes all ADR checks. Start with
  [first affected filename]?"
  - "Yes — retrofit [first affected filename] now"
  - "Retrofit all [N] ADRs one by one"
  - "I'll handle ADRs myself"

**If PRDs are missing Acceptance Criteria (and no blocking issues above):**
Use `AskUserQuestion`:
- "The most urgent gap is missing Acceptance Criteria in [N] PRD(s):
  [list filenames]. Without them, /saas-create-stories can't generate stories.
  Start with [highest-priority PRD filename]?"
  - "Yes — add Acceptance Criteria to [PRD filename] now"
  - "Do all [N] PRDs one by one"
  - "I'll handle PRDs myself"

**Otherwise, if any BLOCKING or HIGH gap remains** (one no branch above names —
e.g. a missing TR registry):
Use `AskUserQuestion` (Render in Portuguese for PT-BR sessions, while processing internally in English):
- PT-BR (preferred when user interacts in Portuguese or locale is pt-BR):
  - Question: "A lacuna mais urgente restante é [item] — [o que ela impede]. Deseja iniciar agora?"
  - "(Recomendado) Sim — iniciar [item]"
  - "Ver detalhes deste item primeiro"
  - "Concluído — manter apenas o plano"
- EN (fallback for English sessions):
  - Question: "The most urgent remaining gap is [first BLOCKING or HIGH item in the plan] — [one line on what it breaks]. Start on it now?"
  - "(Recommended) Yes — start on [item]"
  - "Show me that plan item first"
  - "Done — leave me with the plan"

*(Note: The agent executes the underlying action in English for maximum engineering precision).*

**If no BLOCKING or HIGH gaps exist:**
Use `AskUserQuestion`:
- "No blocking gaps — this project is template-compatible. What next?"
  - "Walk me through the medium-priority improvements"
  - "Run /saas-project-stage-detect for a broader health check"
  - "Done — I'll work through the plan at my own pace"

> **Adoption plan saved to `docs/adoption-plan-[date].md`.** Re-run `/saas-adopt` at any time to re-check remaining gaps as you complete them.

---
