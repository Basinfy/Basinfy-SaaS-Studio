---
paths:
  - ".claude/agent-memory/**"
---

# Agent Memory Rules

**Agent memory is exempt from 'May I write?'**
- Appends to `production/session-state/active.md`
- Working memory in `.claude/agent-memory/` (gitignored, per-agent)
- Subagent output written to designated artifact path.

All other writes to `src/`, `docs/`, `design/`, `production/` require explicit user approval.
