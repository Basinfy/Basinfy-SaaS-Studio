# DNS-AID & RFC 8288 Link Headers

Network-layer and HTTP-header discovery mechanisms that allow agents to locate APIs, catalogs, and endpoints before crawling HTML.

---

## 1. DNS for AI Discovery (DNS-AID)

Publish discovery records under your domain's `_agents` DNS namespace using `SVCB` or `HTTPS` records with `alpn` and `port` connection parameters:

```dns
_a2a._agents.example.com.    3600 IN SVCB  1 agent.example.com. alpn="a2a" port=443 mandatory=alpn,port
_index._agents.example.com.  3600 IN HTTPS 1 . alpn="h2,h3"
_catalog._agents.example.com. 3600 IN TXT  "url=https://example.com/.well-known/ai-catalog.json"
_search._agents.example.com.  3600 IN SRV  10 1 443 search.example.com.
```

### Requirements
- Use numeric `keyNNNNN` SvcParamKey names for experimental custom DNS-AID parameters until IANA registration.
- Enable **DNSSEC** on the zone so validating DNS-over-HTTPS resolvers (`cloudflare-dns.com/dns-query`, `dns.google/resolve`) return `AD: true` (Authenticated Data).

---

## 2. RFC 8288 / RFC 9727 §3 `Link` Response Headers

Return `Link` headers on the homepage HTTP response pointing to machine-readable resources (multiple `Link` headers or comma-separated values are both valid):

```http
Link: </.well-known/api-catalog>; rel="api-catalog"
Link: </openapi.json>; rel="service-desc"; type="application/openapi+json"
Link: </docs>; rel="service-doc"; type="text/html"
Link: </llms.txt>; rel="describedby"; type="text/plain"
Link: </.well-known/ai-catalog.json>; rel="ai-catalog"; type="application/ai-catalog+json"
```

### Registered Relation Types Checked by Agent Scanners
- `api-catalog` -> RFC 9727 linkset catalog
- `service-desc` -> OpenAPI / machine service description
- `service-doc` -> Human/developer documentation
- `describedby` -> Machine-readable site description (e.g., `/llms.txt` or schema)
- `ai-catalog` -> ARD capability manifest
- `alternate` (`type="text/markdown"`) -> Markdown representation of the page
