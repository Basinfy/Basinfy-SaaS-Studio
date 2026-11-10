# Discovery files and Markdown delivery

What agents and agent registries can fetch without rendering the page. Facts
checked 2026-09-23. None of these files affects Google Search ranking.

## llms.txt

Community spec (llmstxt.org). Lighthouse counts it in the Agentic Browsing
fraction; Google Search ignores it (see `seo-geo`,
`references/llmstxt-evidence.md`, for the citation evidence).

Structure, in order: optional BOM; an **H1 with the site or project name**
(the only required part); an optional `>` blockquote summary; optional prose;
H2 sections that each hold a list of `[name](url)` links with optional
`: notes`. An `## Optional` section marks links an agent may skip. The file
may live at `/llms.txt` or on a subpath.

Lighthouse `llms-txt` rules: 4xx is N/A; 5xx or fetch error fails; otherwise
an H1, one Markdown link, and 50+ characters. A soft 404 (HTML with 200)
is not a Lighthouse rule, but it almost never has a `# ` line, so it fails in
practice; `agentic_check.py` also notes it separately. Draft one with
`agentic_fix.py llms <url>`, then edit the TODOs.

## Markdown versions of pages

Two patterns, both plain HTTP. No consumer agent is publicly confirmed to
send `Accept: text/markdown`, so present this as optional.

1. **Alternate URL**: `/pricing.md` next to `/pricing`, advertised with
   `<link rel="alternate" type="text/markdown" href="/pricing.md">` or the
   header `Link: </pricing.md>; rel="alternate"; type="text/markdown"`.
   OpenAI's developer docs use the `.md` suffix pattern.
2. **Content negotiation**: the same URL returns Markdown when the request
   carries `Accept: text/markdown`, always with `Vary: Accept` so caches keep
   the two apart. Cloudflare's Markdown for Agents does this at the edge
   (`content-type: text/markdown; charset=utf-8`, `vary: accept`,
   `x-markdown-tokens`, `x-original-tokens`, and a `content-signal` header).

Keep Markdown content-equivalent to the HTML. Google's John Mueller has
questioned serving pages "that no user sees", and Bing warned that separate
Markdown URLs add crawl load. Negotiation keyed on `Accept` (not user agent)
avoids cloaking concerns and extra URLs.

### nginx: negotiation with HTML fallback (tested 2026-09-23, nginx:alpine)

```nginx
# http {} context
map $uri $md_path {
    ~^(?<base>.*[^/])/?$  $base.md;   # /pricing and /pricing/ -> /pricing.md
    default               /index.md;  # /                     -> /index.md
}
map $http_accept $md_try {
    default               $uri;
    ~*text/markdown       $md_path;
}

# server {} context
types { text/html html; text/markdown md; }
charset utf-8;
charset_types text/markdown;
location / {
    add_header Vary Accept always;
    try_files $md_try $uri $uri.html $uri/ =404;
}
```

Behaviour: Markdown when requested and the `.md` file exists, HTML otherwise,
`Vary: Accept` on every response. Advertise alternates from the page template
(`<link rel="alternate" ...>`) only on pages that really have a `.md` file;
a `Link` header built from `$uri` in nginx points at the wrong file after an
internal rewrite. Verify with:

```bash
curl -sI -H "Accept: text/markdown" https://example.com/pricing | grep -iE "content-type|vary"
curl -sI https://example.com/pricing | grep -i vary
```

## Agentic Resource Discovery: ai-catalog.json

ARD 1.0 (agenticresourcediscovery.org/spec; ards-project/ard-spec) lists a
site's agent-facing resources: MCP server cards, A2A agent cards, agent skills,
nested catalogs. Lighthouse 13.5 validates it (`ard-schema`). Discovery order:
robots.txt `Agentmap: <url>`, `<link rel="ai-catalog">`, HTTP
`Link ...; rel="ai-catalog"`, DNS `_catalog._agents` TXT (`url=...`), then `/.well-known/ai-catalog.json`.

```json
{
  "specVersion": "1.0",
  "host": {
    "displayName": "Example Systems",
    "identifier": "did:web:example.com"
  },
  "entries": [
    {
      "identifier": "urn:air:example.com:docs-mcp",
      "displayName": "Example Docs MCP server",
      "type": "application/mcp-server-card+json",
      "url": "https://example.com/.well-known/mcp/server-card.json",
      "representativeQueries": ["How do I rotate an API key?", "What are the rate limits?"]
    }
  ]
}
```

Rules: `host` object (`displayName`, `identifier`); `identifier` matches `urn:air:<publisher>[:<namespace>]:<name>`;
exactly one of `url` or `data`; 2 to 5 `representativeQueries`; no top-level
`collections`; serve with `Access-Control-Allow-Origin: *`. Publish only when there is a real resource to list. An
invalid or unreachable signalled catalog adds a **counted failure** to the
Lighthouse fraction. Draft with `agentic_fix.py ai-catalog`.

## /.well-known documents (only if you run the service)

| Path | Standard | Content type | When |
|---|---|---|---|
| `/.well-known/api-catalog` | RFC 9727 (published) | `application/linkset+json; profile="https://www.rfc-editor.org/info/rfc9727"` | You publish APIs |
| `/.well-known/oauth-protected-resource` | RFC 9728 (published) | JSON | Your API or MCP server takes OAuth tokens; pair with `WWW-Authenticate: Bearer resource_metadata=...` |
| `/.well-known/oauth-authorization-server` / `openid-configuration` | RFC 8414 / OIDC 1.0 | JSON | You run the authorization server |
| `/.well-known/http-message-signatures-directory` | IETF WebBotAuth | JSON (JWKS) | Your agents sign outgoing requests |
| `/.well-known/mcp/server-card.json` | MCP SEP-1649 (IsItAgentReady) | JSON | You host an MCP server (`serverInfo`, `endpoint`, `capabilities`) |
| `/.well-known/agent-card.json` | A2A protocol | JSON | You run an A2A agent (`supportedInterfaces`, `capabilities`, `skills`) |
| `/.well-known/agent-skills/index.json` | Agent Skills Discovery RFC v0.2.0 | JSON | You publish agent skills (`$schema`, `skills[]` with `sha256:` digests) |
| `/.well-known/poppy.json` | Personal Agent Protocol draft 0.1 | JSON | Informational organization & OAuth issuer binding |
| `/.well-known/acp.json` | ACP (OpenAI + Stripe) | JSON | Agentic commerce checkout API |
| `/.well-known/ucp` | UCP (Google + Shopify) | JSON | Universal commerce checkout |
| `/auth.md` | Auth.md spec | Markdown | Agent registration & credential provisioning guide |

A `/.well-known` URL or `/auth.md` that returns HTML with 200 is a soft 404. It misleads
discovery clients; return a real 404.

## Agentic commerce (pointer)

See `agentic-commerce-protocols.md` for full schemas and validation rules:

| Protocol | Discovery / Middleware | Site-owner action |
|---|---|---|
| UCP | `/.well-known/ucp` | `protocol_version`, `services`, `capabilities`, `endpoints` |
| ACP | `/.well-known/acp.json` | `protocol`, `api_base_url`, `transports`, `capabilities.services` |
| MPP | `/openapi.json` (`x-payment-info`) | Declare `intent`, `method`, `amount` on payable operations |
| x402 | HTTP 402 (`@x402/next`) | Facilitator URL + wallet address for pay-per-request APIs |
