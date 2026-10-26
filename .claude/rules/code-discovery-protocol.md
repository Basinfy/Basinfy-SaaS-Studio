---
paths:
  - "**/*"
---

# Smart Code Discovery & Basinfy Protocol (Free vs Pro Code Mode)

Whenever an agent, specialist, or workflow needs to search, locate, inspect, or understand code, schemas, or configurations:

## 1. Dynamic Environment Detection
Always check whether Basinfy is active in the workspace:
- **Check Criteria**: Does a `.basinfy/` folder exist in the project root, OR are Basinfy MCP tools (`basinfy_session_start`, `basinfy_search`, `basinfy_locate`, `basinfy_prepare_edit`, `basinfy_read`, `basinfy_impact`, `basinfy_discover`, `basinfy_query_script`, etc.) or the `basinfy` CLI available?

## 2. When Basinfy is Detected (`.basinfy/` exists or MCP active)
Route all code discovery and editing preparation through the **Basinfy Smart Indexing Protocol** first. Standard IDE Grep/Read/rg are strictly the last resort fallback:
- **Session Bootstrap**: Run `basinfy_session_start` or `basinfy_brief` once at start of session.
- **Tier Detection (Pro Code Mode vs. Free Standard)**:
  - **Basinfy Pro / Trial (Code Mode Active)**: Triggered when `basinfy_discover` or `basinfy_query_script` are present in MCP tools, or `basinfy discover` / `script` in CLI (status via `basinfy info`):
    - **Multi-File Exploration & Feature Discovery**: ALWAYS use `basinfy_discover` (with `digest: true`) or `basinfy_query_script` with `basinfy.discover(query, { digest: true })` (CLI `basinfy discover <query> --digest`). Delivers AST locate, barrel resolution, confidence scores, and targeted 12-line code previews in ONE turn (90%+ token reduction). NEVER loop multiple `basinfy_search` + `basinfy_read` calls across files.
    - **Compound / Multi-Module Programmatic Analysis**: Use `basinfy_query_script` (CLI `basinfy script <code>`) for in-memory JavaScript/TypeScript execution with direct access to the `basinfy.*` API object (`basinfy.discover`, `basinfy.search`, `basinfy.read`, `basinfy.locate`, `basinfy.orbit`, `basinfy.impact`, `basinfy.gateEdit`, `basinfy.prepareEdit`, `basinfy.prepareCreate`). Executes compound queries and graph traversals in a single turn with zero intermediate token bloat. Inspect types via `basinfy_sdk_inspect`.
  - **Basinfy Free (Core Smart Indexing)**:
    - **Symbols & Code**: Use `basinfy_prepare_edit` (or `basinfy_locate`) for locating functions, classes, components, routes, and type definitions (delivers definition, gate checks, and impact graph in one call).
    - **Configs, YAML, Routes & Literal Search**: Use `basinfy_search { query }` then `basinfy_read { path }`.
- **Universal Governance & Lifecycle (Free & Pro)**:
  - **Document Sections**: Use `basinfy_search` to find headings and `basinfy_read` to read relevant blocks without manual line-offset paging.
  - **New Files**: Use `basinfy_prepare_create { targetPath }` before generating new components or modules to verify architectural placement.
  - **Impact & Architecture**: Use `basinfy_impact` or `basinfy_orbit` before executing large refactors or modifying shared interfaces.
  - **Session Lifecycle**: One bootstrap at start (`basinfy_session_start` or `basinfy_brief`), one update at end (`basinfy_session_end` or `basinfy_update`).
  - **Fallback Ladder**: If a query returns empty or MCP reports connection errors, retry via CLI `basinfy search` / `basinfy read` / `basinfy discover`. Use standard IDE Grep/Read only for binary assets, images, or files outside the index root.

## 3. Fallback Mode (No `.basinfy/` directory & No Basinfy tools)
If the project does NOT have a `.basinfy/` directory and Basinfy is not configured:
- Gracefully and seamlessly fall back to standard IDE/LLM discovery tools:
  - `Grep` / `ripgrep` (`rg`) for text and pattern matching (e.g. `^#` for markdown headings).
  - `Read` with offset and limit for large documents.
  - `Glob` for file scanning.
  - Standard Read / Edit / Write tools for inspection and modification.
