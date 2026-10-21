---
paths:
  - "**/*"
---

# Smart Code Discovery & Basinfy Protocol

Whenever an agent, specialist, or workflow needs to search, locate, inspect, or understand code, schemas, or configurations:

## 1. Dynamic Environment Detection
Always check whether Basinfy is active in the workspace:
- **Check Criteria**: Does a `.basinfy/` folder exist in the project root, OR are Basinfy MCP tools (`basinfy_session_start`, `basinfy_search`, `basinfy_locate`, `basinfy_prepare_edit`, `basinfy_read`, `basinfy_impact`, etc.) or the `basinfy` CLI available?

## 2. When Basinfy is Detected (`.basinfy/` exists or MCP active)
Route all code discovery and editing preparation through the **Basinfy Smart Indexing Protocol** first. Standard IDE Grep/Read/rg are strictly the last resort fallback:
- **Session Bootstrap**: Run `basinfy_session_start` or `basinfy_brief` once at start of session.
- **Code & Symbols**: Use `basinfy_prepare_edit` (or `basinfy_locate`) for locating functions, classes, components, routes, and type definitions (delivers definition, gate checks, and impact graph in one call).
- **Configs, YAML, Routes & Text**: Use `basinfy_search { query }` then `basinfy_read { path }`.
- **Document Sections**: Use `basinfy_search` to find headings and `basinfy_read` to read relevant blocks without manual line-offset paging.
- **New Files**: Use `basinfy_prepare_create { targetPath }` before generating new components or modules to verify architectural placement.
- **Impact & Architecture**: Use `basinfy_impact` or `basinfy_orbit` before executing large refactors or modifying shared interfaces.
- **Fallback Ladder**: If a query returns empty or MCP reports connection errors, retry via CLI `basinfy search` / `basinfy read`. Use standard IDE Grep/Read only for binary assets, images, or files outside the index root.

## 3. Fallback Mode (No `.basinfy/` directory & No Basinfy tools)
If the project does NOT have a `.basinfy/` directory and Basinfy is not configured:
- Gracefully and seamlessly fall back to standard IDE/LLM discovery tools:
  - `Grep` / `ripgrep` (`rg`) for text and pattern matching (e.g. `^#` for markdown headings).
  - `Read` with offset and limit for large documents.
  - `Glob` for file scanning.
  - Standard Read / Edit / Write tools for inspection and modification.
