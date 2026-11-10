# IsItAgentReady Maturity Scale (Level 0–5) & 25 Standards Matrix

Maps the Cloudflare / IsItAgentReady scanner taxonomy (`scan-site`) onto `Basinfy SaaS Studio` audits (`scripts/seo/agentic_check.py`) and Next.js 14+ App Router deliverables.

---

## Readiness Level Scale

| Level | Name | Requirements |
|---|---|---|
| **0** | Not Ready | Fewer than 2 of: `robots.txt`, `sitemap.xml`, `Link` response headers |
| **1** | Basic Web Presence | At least 2 of 3: `robots.txt`, `sitemap.xml`, `Link` response headers |
| **2** | Bot-Aware | Level 1 + both: AI bot rules in `robots.txt` + `Content-Signal` directives |
| **3** | Agent-Readable | Level 2 + `Accept: text/markdown` content negotiation (`Vary: Accept`) |
| **4** | Agent-Integrated | Level 3 + at least 1 of 4: MCP Server Card, A2A Agent Card, Agent Skills Index, API Catalog |
| **5** | Agent-Native | Level 4 + at least 2 of 3: Web Bot Auth JWKS, all 4 discovery integrations, Auth metadata (OAuth or `/auth.md`) |

> **Informational Check:** Personal Agent Protocol (`/.well-known/poppy.json`) validates public discovery and OAuth issuer binding, but does not affect Level 0–5 scoring.

---

## The 25 Standards Across 5 Categories

### 1. Discoverability (`discoverability`)
1. `robots-txt`: Valid `/robots.txt` per RFC 9309 (`text/plain`, HTTP 200, Sitemap ref).
2. `sitemap`: Valid XML `/sitemap.xml` per Sitemaps protocol.
3. `link-headers`: RFC 8288 / RFC 9727 §3 `Link` headers on homepage (`api-catalog`, `service-desc`, `service-doc`, `describedby`).
4. `dns-aid`: DNS-over-HTTPS `SVCB` / `HTTPS` / `TXT` records under `_agents.<domain>` with DNSSEC.

### 2. Content Accessibility (`contentAccessibility`)
5. `llms-txt`: `/llms.txt` (`# Title`, summary blockquote, Markdown links, 50+ chars).
6. `llms-full-txt`: `/llms-full.txt` detailed plain-text/Markdown overview linked from `/llms.txt`.
7. `markdown-negotiation`: `Accept: text/markdown` returning `Content-Type: text/markdown`, `Vary: Accept`, and `x-markdown-tokens`.

### 3. Bot Access Control (`botAccessControl`)
8. `ai-rules`: Explicit `User-agent` rules for search (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`) and training (`GPTBot`, `ClaudeBot`, `Google-Extended`, `Applebot-Extended`, `CCBot`, `Bytespider`, `Amazonbot`).
9. `content-signals`: `Content-Signal: ai-train=..., search=..., ai-input=...` in `robots.txt`.
10. `web-bot-auth`: `/.well-known/http-message-signatures-directory` JWKS + `Signature-Agent` / `Signature-Input` headers.

### 4. API, Auth & Agent Discovery (`discovery`)
11. `api-catalog`: `/.well-known/api-catalog` (`application/linkset+json`, RFC 9727 `linkset`).
12. `oauth-discovery`: `/.well-known/openid-configuration` and/or `/.well-known/oauth-authorization-server` (RFC 8414).
13. `oauth-protected-resource`: `/.well-known/oauth-protected-resource` (RFC 9728) + `WWW-Authenticate` on 401.
14. `auth-md`: `/auth.md` agent registration discovery Markdown.
15. `mcp-server-card`: `/.well-known/mcp/server-card.json` (SEP-1649 `serverInfo`, `endpoint`/`transport`, `capabilities`).
16. `a2a-agent-card`: `/.well-known/agent-card.json` (A2A `supportedInterfaces`, `capabilities`, `skills`).
17. `agent-skills`: `/.well-known/agent-skills/index.json` (Agent Skills Discovery RFC v0.2.0 with `sha256:` digests).
18. `ard`: `/.well-known/ai-catalog.json` (ARD 1.0 `host`, `entries`, `Access-Control-Allow-Origin: *`).
19. `webmcp`: `document.modelContext.registerTool()` + `AbortController` + declarative form attributes (`toolname`, `tooldescription`, `toolparamdescription`).
20. `personal-agent-protocol`: `/.well-known/poppy.json` + OAuth issuer `poppy_domains` binding (informational).

### 5. Agentic Commerce & Machine Payments (`commerce`)
21. `x402`: HTTP 402 Payment Required middleware (`@x402/next`, `@x402/hono`, `@x402/express`).
22. `mpp`: Machine Payment Protocol `/openapi.json` with `x-payment-info` (`intent`, `method`, `amount`).
23. `acp`: Agentic Commerce Protocol `/.well-known/acp.json` (`protocol`, `api_base_url`, `transports`, `capabilities.services`).
24. `ucp`: Universal Commerce Protocol `/.well-known/ucp` (`protocol_version`, `services`, `capabilities`, `endpoints`).
25. `scan-site`: Unified Level 0–5 readiness check computed by `scripts/seo/agentic_check.py`.
