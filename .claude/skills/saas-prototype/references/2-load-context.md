# /saas-prototype — Phase 2: Load Concept Context

> Part of `/saas-prototype`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 2: Load Concept Context

Read `design/prd/product-concept.md` — or `design/product-brief.md`, the one-page brief
that replaces it at `rigor: minimal` — if either exists. Read it by section: Use the project discovery protocol to find the relevant headings and read those sections. When the index cannot provide them, find the headings with a local text search and read the matching ranges. Extract:
- Core fantasy (what the user is supposed to feel)
- Core loop (the moment-to-moment action being tested)

Determine the engine and language in use: read `stack.frontend` and
`engine.language` from `project.yaml`. For each field, if its key is absent or
empty (including when `project.yaml` has no `engine:` block), fall back to
`CLAUDE.md` and `.claude/docs/technical-preferences.md`. Treat a
`[TO BE CONFIGURED]` value as not set.

---
