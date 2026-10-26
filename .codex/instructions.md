# OpenAI Codex Workspace Instructions — Basinfy SaaS Studio

This file provides workspace instructions for OpenAI Codex, OpenAI ChatGPT developer integrations, and Codex-compatible CLI harnesses.

## Execution Rules
1. **Always read `CODEX.md` or `AGENTS.md` at session start.**
2. **Follow the 5-Step Collaborative Loop**:
   - `Question -> Options -> Decision -> Draft -> Approval`
   - Ask confirmation before modifying non-temporary files.
3. **Respect PostgreSQL RLS & AppSec Rules**:
   - Every user-facing table must have Row Level Security enabled.
   - All Stripe webhook endpoints must verify `rawBody` signatures.
4. **Use Basinfy Code Discovery Protocol (Free vs Pro Code Mode)**:
   - When `.basinfy/` exists, use Basinfy indexing tools before IDE text search:
     - **Free**: `prepare_edit` / `locate` for symbols, `search` then targeted `read` for configs.
     - **Pro (Code Mode)**: ALWAYS use `discover` (multi-file AST + digest preview) and `query_script` (sandboxed in-memory `basinfy.*` API) for multi-file exploration instead of manual search+read loops.
5. **Dynamic UI Language**:
   - If user asks in Portuguese, present questions and options in Brazilian Portuguese (PT-BR).
   - Code, tests, and documentation are written strictly in English (EN).
