# /saas-adopt — Phase 5: Present Summary and Ask to Write

> Part of `/saas-adopt`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Present Summary and Ask to Write

Present a compact summary before writing:

```
## Adoption Audit Summary
Phase detected: [phase]
Engine: [configured / NOT CONFIGURED]
PRDs audited: [N] ([X] fully compliant, [Y] with gaps)
ADRs audited: [N] ([X] fully compliant, [Y] with gaps)
Stories audited: [N]

Gap counts:
  BLOCKING: [N] — template skills will malfunction without these fixes
  HIGH:     [N] — unsafe to run /saas-create-stories or /saas-story-readiness
  MEDIUM:   [N] — quality degradation
  LOW:      [N] — optional improvements

Estimated remediation: [X blocking items × ~Y min each = roughly Z hours]
```

Before asking to write, show a **Gap Preview**:
- List every BLOCKING gap as a one-line bullet describing the actual problem
  (e.g. `features-modules-index.md: 3 rows have parenthetical status values`,
  `adr-0002.md: missing ## Status section`). No counts — show the actual items.
- Show HIGH / MEDIUM / LOW as counts only (e.g. `HIGH: 4, MEDIUM: 2, LOW: 1`).

This gives the user enough context to judge scope before committing to writing the file.

If a prior adoption plan was detected in Phase 1, add a note:
> "A previous plan exists at `docs/adoption-plan-[prior-date].md`. The new plan will
> reflect current project state — it does not diff against the prior run."

Use `AskUserQuestion` (Render in Portuguese for PT-BR sessions, while processing internally in English):
- PT-BR (preferred when user interacts in Portuguese or locale is pt-BR):
  - Question: "Pronto para gravar o plano de adoção / migração?"
  - "(Recomendado) Sim — gravar `docs/adoption-plan-[date].md`"
  - "Ver a prévia completa do plano primeiro (não gravar ainda)"
  - "Cancelar — farei a migração manualmente"
- EN (fallback for English sessions):
  - Question: "Ready to write the migration plan?"
  - "(Recommended) Yes — write `docs/adoption-plan-[date].md`"
  - "Show me the full plan preview first (don't write yet)"
  - "Cancel — I'll handle migration manually"

*(Note: The agent processes the selected choice and produces all internal plan artifacts and code in English for maximum LLM performance).*

If the user picks "Show me the full plan preview", output the complete plan as a
fenced markdown block. Then ask again with the same three options.

---
