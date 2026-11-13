---
name: saas-seo-agentic
description: "Audit and implement AI Agent readiness (IsItAgentReady Level 0-5 + Lighthouse Agentic Browsing X/N) — llms.txt, Markdown negotiation, Link headers, DNS-AID, WebMCP, MCP/A2A/Agent-Skills discovery, Web Bot Auth, OAuth/Auth.md, Poppy, and agentic commerce (x402, MPP, ACP, UCP)."
argument-hint: "[audit|fix|lighthouse] [url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Agentic Browsing & Agent-Native Readiness for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Audits and engineers SaaS platforms across **25 agent-readiness standards** (5 categories + IsItAgentReady Level 0–5 maturity scale) and Google Lighthouse **Agentic Browsing** ($X/N$).

---

## 1. The 5 Agent-Readiness Categories & Maturity Levels

Read `references/isitagentready-levels.md` for the full Level 0–5 calculation rules:

1. **Discoverability** (`references/dns-aid-and-link-headers.md`):
   - `robots.txt` (RFC 9309), `sitemap.xml`, RFC 8288 `Link` headers (`api-catalog`, `service-desc`, `service-doc`, `describedby`), and **DNS-AID** (`SVCB`/`HTTPS`/`TXT` under `_agents.<domain>` with DNSSEC).
2. **Content Accessibility** (`references/discovery-and-markdown.md`):
   - `/llms.txt`, `/llms-full.txt`, and `Accept: text/markdown` content negotiation (`Vary: Accept`, `x-markdown-tokens`).
3. **Bot Access Control** (`references/access-policy.md`):
   - Explicit AI crawler `User-agent` rules (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`, `GPTBot`, `ClaudeBot`, `Google-Extended`, `Applebot-Extended`, `CCBot`, `Bytespider`, `Amazonbot`), `Content-Signal`, and **Web Bot Auth** (`/.well-known/http-message-signatures-directory` JWKS).
4. **API, Auth & Agent Discovery** (`references/agent-auth-and-identity.md`):
   - `/.well-known/api-catalog` (RFC 9727), `/.well-known/oauth-authorization-server` / `openid-configuration` (RFC 8414 / OIDC), `/.well-known/oauth-protected-resource` (RFC 9728), `/auth.md`, `/.well-known/mcp/server-card.json` (SEP-1649), `/.well-known/agent-card.json` (A2A), `/.well-known/agent-skills/index.json` (RFC v0.2.0), `/.well-known/ai-catalog.json` (ARD 1.0 + CORS), **WebMCP** (`document.modelContext.registerTool` + `AbortController` + `toolparamdescription`), and **Personal Agent Protocol** (`/.well-known/poppy.json`, informational).
5. **Agentic Commerce & Machine Payments** (`references/agentic-commerce-protocols.md`):
   - **x402** (`@x402/next` HTTP 402), **MPP** (`/openapi.json` `x-payment-info`), **ACP** (`/.well-known/acp.json`), and **UCP** (`/.well-known/ucp`).

---

## 2. Priority Hierarchy (P0 to P3)

| Priority | Check | Tool Check ID |
|---|---|---|
| **P0** | Accessible names, valid ARIA roles, interactive elements exposed | `agent-accessibility-tree` |
| **P0** | Cumulative Layout Shift (CLS) <= 0.1 | `cumulative-layout-shift` |
| **P0** | Core content present in initial server-rendered HTML | `server-rendered` |
| **P0** | `robots.txt` reachable with explicit AI crawler groups | `robots-ai-groups` |
| **P1** | `llms.txt` present and compliant (`# Title`, link, 50+ chars) | `llms-txt` |
| **P1** | Markdown via `Accept: text/markdown` (`Vary: Accept`) | `markdown-delivery` |
| **P1** | XML Sitemap reachable | `sitemap-reachable` |
| **P1** | Real 404 for unknown routes (catch-all 200 breaks discovery) | `http-404` |
| **P2** | RFC 8288 `Link` discovery response headers | `link-headers` |
| **P2** | MCP Server Card, Agent Skills Index, API Catalog, Web Bot Auth JWKS, OAuth | `well-known:*` |
| **P2** | WebMCP tools registered on `document.modelContext` | `webmcp-entry-point` |
| **P3** | ARD `ai-catalog.json`, A2A Card, Poppy, Auth.md, DNS-AID, ACP, UCP, MPP | `ard-catalog`, `auth-md`, `dns-aid`, `commerce:*` |

---

## 3. Next.js 14+ App Router Scaffolds (`templates/seo/`)

When scaffolding agent-readiness into a Next.js App Router SaaS project, reuse the studio templates under `templates/seo/`:
- `templates/seo/robots-txt-route.ts` -> `app/robots.txt/route.ts` (supports `Content-Signal` and `Amazonbot`)
- `templates/seo/llms-txt-route.ts` -> `app/llms.txt/route.ts`
- `templates/seo/markdown-negotiation-middleware.ts` -> `middleware.ts` (`Accept: text/markdown` + RFC 8288 `Link` headers)
- `templates/seo/agent-skills-index-route.ts` -> `app/.well-known/agent-skills/index.json/route.ts`
- `templates/seo/mcp-server-card-route.ts` -> `app/.well-known/mcp/server-card.json/route.ts`
- `templates/seo/api-catalog-route.ts` -> `app/.well-known/api-catalog/route.ts`
- `templates/seo/ai-catalog-route.ts` -> `app/.well-known/ai-catalog.json/route.ts`
- `templates/seo/auth-md-route.ts` -> `app/auth.md/route.ts`
- `templates/seo/web-bot-auth-jwks-route.ts` -> `app/.well-known/http-message-signatures-directory/route.ts`

---

## 4. Tool Execution & Draft Generation

```bash
# Full audit (25 standards + Level 0-5 maturity score)
python scripts/seo/agentic_check.py <url> --json
python scripts/seo/lighthouse_agentic.py <url> --json

# Generate reviewable drafts for missing files
python scripts/seo/agentic_fix.py agent-skills https://example.com --skills-dir .claude/skills
python scripts/seo/agentic_fix.py mcp-card --name "My SaaS MCP" --url https://example.com
python scripts/seo/agentic_fix.py api-catalog https://example.com
python scripts/seo/agentic_fix.py auth-md --name "My SaaS" --url https://example.com
python scripts/seo/agentic_fix.py poppy --name "My SaaS" --domain example.com
python scripts/seo/agentic_fix.py acp https://example.com
```
