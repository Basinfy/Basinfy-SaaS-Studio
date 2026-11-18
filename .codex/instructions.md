# Autonomous SaaS Studio — OpenAI Codex Global & Workspace Instructions

1. **Read `CODEX.md` or `AGENTS.md` at session start** and honor `project.yaml` (`locale`, `user_profile`, `modes.rigor`, `modes.automation`).
2. **Founder & Layperson Autopilot (`user_profile: founder`)**:
   - Guide non-technical founders from raw idea to deployed SaaS using plain business questions (with `(Recomendado)` first), the opinionated Golden Stack (Next.js + Tailwind/shadcn + Supabase + Prisma + Stripe + Vercel), and `[Passo X de 7]` continuous progression without requiring slash-command memorization.
3. **Full 50-Agent & 108-Workflow Capability**:
   - Execute `$saas-*` / `/saas-*` workflows from `.agents/skills/` and specialist role briefs from `.claude/agents/`.
4. **Mandatory Invisible Guardrails**:
   - Enforce PostgreSQL RLS on all tenant/user tables, Zod/Pydantic validation on inputs, and raw-body HMAC + idempotency on Stripe webhooks.
5. **Dynamic Bilingual UI / English Engine**:
   - Render all questions and options in **Brazilian Portuguese (PT-BR)** when the user writes in Portuguese or `locale: pt-BR`; write code, schemas, and tests in **English (EN)**.

<!-- BASINFY:START -->
## Basinfy Protocol (Smart Code Indexing)

When this workspace has a `.basinfy/` directory, route code discovery through Basinfy first. IDE Grep/Read/rg are the last resort.

**Default path (MCP live — tools listed and a call succeeds):**
- Start with one bootstrap: `basinfy_session_start` or `basinfy_brief` (not both). Pass `projectRoot` = active workspace path.
- Check `projectRoot` / `rootSource`; on mismatch or `unresolved`, retry with `projectRoot`. Always supply `projectRoot` when working under global MCP daemons.
- **Level 1 — Code Mode First (Default standard):** `basinfy_query_script` (MCP) or CLI `basinfy script <code>` — always execute compound exploration inside the in-memory JS sandbox in 1 turn to achieve maximum token economy (-90%+). NEVER call multiple standalone search/read/orbit/impact tools in separate turns when Code Mode can resolve them in a single batch.
- **Level 2 — Simple Direct Tools:** Use standalone tools (`basinfy_search`, `basinfy_read`, `basinfy_orbit`, `basinfy_impact`, `basinfy_prepare_edit`, `basinfy_locate`) ONLY for simple, 1-step queries (e.g. checking a single configuration line or editing a known symbol).
- **Level 3 — Primary Discovery (when not writing script):** `basinfy_discover` with `digest: true` (candidate files + primary exports + instant 12-line code preview in 1 turn). Use FIRST before search.
- code/symbol edit → `basinfy_prepare_edit` / `basinfy_locate`
- new file → `basinfy_prepare_create`; ADR/lesson → `basinfy_remember`; end → `basinfy_session_end`
- **STRICT ANTI-PATTERNS (PROHIBITED):**
  - ❌ NEVER loop `basinfy_search` + `basinfy_read` across multiple files. Use `basinfy_query_script` or `basinfy_discover({ query, digest: true })`.
  - ❌ NEVER re-read code already delivered in a discover digest or briefing.
- **Fallback (No `.basinfy/` directory):** When `.basinfy/` is absent and Basinfy MCP/CLI is inactive, seamlessly use standard IDE tools (`Glob`, `Grep`, `Read`).

**Code Mode (`basinfy_query_script` / `basinfy script`) Recipes:**
1. Discover & Preview in 1 turn:
   `return await basinfy.discover("query", { digest: true });`
2. Compound Topology, Orbit & Impact (Zero Bloat):
   `const [orbit, impact] = await Promise.all([basinfy.orbit("src/file.ts"), basinfy.impact("src/file.ts")]); return { orbit, impact };`
3. Multi-file search & targeted reading in 1 turn:
   `const hits = await basinfy.search("str"); return await Promise.all(hits.slice(0,3).map(x => basinfy.read({ path: x.file, offset: Math.max(1, x.line - 5), limit: 20 })));`
4. Trace file dependency path:
   `return await basinfy.path("src/a.ts", "src/b.ts");`

Args (aliases accepted): code mode `{ script }`; discover `{ query, digest: true }`; search `{ query }` (alias `pattern`); read `{ path }` (aliases `filePath`, `file`, `paths[0]`); locate/prepare_edit `{ symbol }`; orbit/gate_edit/impact `{ filePath }` (aliases `path`, `file`); create `{ targetPath }`. Optional `projectRoot` on any tool.

**Escape hatches (fallback ladder):**
- Transport/discovery only (`Not connected`, namespace error/loading/needsAuth) → CLI-first for this session (`basinfy script`, `basinfy session-start`, `basinfy discover`, `basinfy search`, `basinfy read`, `basinfy prepare-edit`, `basinfy prepare-create`, `basinfy gate-edit`, `basinfy health`, `basinfy drive`, `basinfy resource`).
- InvalidParams / `-32602` is not MCP-down — retry the same MCP tool once with the schema; then CLI if still failing.
- Empty search / locate `{found:false}` is a normal miss — try the next Basinfy tool; after repeated misses on the same need, CLI then IDE search.
- `allowed:false` from gate/prepare is advisory (writes are not blocked) — pass `force:true` when proceeding.
- IDE Read/Grep/rg while MCP succeeds: only for images, binaries, notebooks, paths outside the index root, or a range beyond a truncated `basinfy_read`.
<!-- BASINFY:END -->
