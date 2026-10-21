# /saas-prototype — Phase 2: Load Concept Context

> Part of `/saas-prototype`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 2: Load Concept Context

Read `design/prd/product-concept.md` — or `design/product-brief.md`, the one-page brief
that replaces it at `rigor: minimal` — if either exists. Read it by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the headings you need with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read those ranges with offset and limit. Extract:
- Core fantasy (what the user is supposed to feel)
- Core loop (the moment-to-moment action being tested)

Determine the engine and language in use: read `stack.frontend` and
`engine.language` from `project.yaml`. For each field, if its key is absent or
empty (including when `project.yaml` has no `engine:` block), fall back to
`CLAUDE.md` and `.claude/docs/technical-preferences.md`. Treat a
`[TO BE CONFIGURED]` value as not set.

---
