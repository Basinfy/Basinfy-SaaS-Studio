# Code Root Resolution

Shared procedure for any skill that reads, scans, counts, or writes application source files. **An unresolved code root means the check did not run.**

`.claude/docs/directory-structure.md` is the authority for directory layout; this file defines the deterministic resolution order.

## Stack Code Roots

| `stack.frontend` / `stack.backend` | Primary Code Root | Fallbacks Checked | Rationale |
|---|---|---|---|
| **Next.js** (`nextjs`) | `src/` | `app/` | Standard Next.js App Router layout, Server Actions, and UI components |
| **React / Vue / Svelte** | `src/` | `app/` | Standard SPA / fullstack frontend source directory |
| **FastAPI / Python** (`fastapi`) | `app/` | `backend/app/`, `src/` | Idiomatic FastAPI package housing routers, schemas, and domain services |
| **Cloudflare Workers** (`cloudflare`) | `src/` | `workers/` | Standard Wrangler / Hono TypeScript worker entrypoint |
| **Go (Gin / Chi)** (`go-gin`) | `cmd/` | `internal/`, `src/` | Idiomatic Go service layout (`cmd/` entrypoints + `internal/` packages) |
| **Node / Fastify** (`node-fastify`) | `src/` | `server/`, `api/` | Standard Node.js service source tree |

## Resolution Order

1. `stack.frontend` (then `stack.backend`) from `project.local.yaml`, falling back to `project.yaml`.
2. Legacy fallback: a `Stack:` line in `.claude/docs/technical-preferences.md` (values containing `[TO BE CONFIGURED]` are ignored).
3. Unambiguous directory detection when stack is unset: check `src`, `app`, `backend`, `server`, `cmd`. If **exactly one** exists, use it; if two or more exist without config, return **unresolved** rather than guessing.
4. Otherwise: **unresolved.**

Hooks and helpers implement this exact contract via `resolve_code_root()` in `.claude/hooks/yaml-helper.sh` (and `.claude/runtime/studio-core.cjs`).

## Unresolved Never Defaults to `src/`

- **For a read or scan:** report `NOT ASSESSED — code root unresolved` and name which check did not run. Never report zero hits (an empty scan is indistinguishable from a clean scan).
- **For a write:** stop and ask to configure `project.yaml` via `/saas-setup-stack` before writing application source files.
