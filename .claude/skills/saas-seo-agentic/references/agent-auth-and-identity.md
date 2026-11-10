# Agent Auth, Identity & Registration Discovery

Standards enabling AI agents to verify identity, discover OAuth servers, register autonomously, and bind user sessions safely.

---

## 1. Web Bot Auth (`/.well-known/http-message-signatures-directory`)

Per the IETF WebBotAuth Working Group (`draft-ietf-webbotauth-httpsig-protocol`):
- **Public Key Directory**: Serve a valid **JWKS** (`{"keys": [...]}`) at `/.well-known/http-message-signatures-directory` containing at least one public key (typically Ed25519).
- **Signed Requests**: Outgoing SaaS agent/crawler HTTP requests sign payloads with HTTP Message Signatures (RFC 9421) and include `Signature-Agent` (dictionary form `sig1="https://..."`) and `Signature-Input` headers.
- **Verification**: Receiving edge WAFs (Cloudflare, AWS WAF, Vercel) verify `Signature-Agent` against the published JWKS directory.

---

## 2. OAuth / OIDC Discovery (RFC 8414 & OIDC 1.0)

Publish JSON at `/.well-known/openid-configuration` and/or `/.well-known/oauth-authorization-server`:
- Required keys: `issuer`, `authorization_endpoint`, `token_endpoint`, `jwks_uri`.
- Recommended arrays: `grant_types_supported`, `response_types_supported`.
- For Auth.md integration, optionally include an `agent_auth` block with `skill`, `register_uri`, and registration methods.

---

## 3. OAuth Protected Resource Metadata (RFC 9728)

Publish JSON at `/.well-known/oauth-protected-resource` for APIs and MCP servers accepting OAuth Bearer tokens:
- Required keys: `resource` (canonical URL of the protected resource), `authorization_servers` (array of issuer URLs matching AS metadata).
- Recommended: `scopes_supported`, `bearer_methods_supported` (e.g., `["header"]`).
- Return `WWW-Authenticate: Bearer resource_metadata="https://example.com/.well-known/oauth-protected-resource"` on HTTP `401` responses.

---

## 4. `/auth.md` Agent Registration Discovery

Serve `/auth.md` at the origin root as `text/markdown; charset=utf-8`:
- **H1 Rule**: First heading must contain `auth.md` (e.g., `# Example auth.md`).
- **OAuth Pairing**: Prefer pairing `/auth.md` with RFC 9728 PRM and RFC 8414 AS metadata, ensuring `issuer` strings match exactly.
- **Flow Metadata**:
  - **ID-JAG**: `identity_types_supported: ["identity_assertion"]`, `identity_assertion.assertion_types_supported: ["urn:ietf:params:oauth:token-type:id-jag"]`, credential types, optional `revocation_uri` + `events_supported`.
  - **Verified Email**: `identity_assertion.assertion_types_supported` containing `"verified_email"`, credential types, and `claim_uri`.
  - **Anonymous**: `identity_types_supported: ["anonymous"]`, `anonymous.credential_types_supported`, and `claim_uri`.
- **Passive Scan Security Rule**: Scanners must NEVER probe `POST /agent/auth` during passive audits (it may create accounts, emit emails, or provision credentials). Read public discovery docs only.

---

## 5. Personal Agent Protocol — Poppy (`/.well-known/poppy.json`)

Draft 0.1 informational discovery (`personalagentprotocol.org/docs/spec#3-discovery`):
- **Website-only discovery**:
  ```json
  {
    "protocol_version": "0.1",
    "organization": { "name": "Example Company", "domain": "example.com" },
    "web": {}
  }
  ```
- `organization.domain` must match the requested hostname (ignoring leading `www.`).
- **Session-enabled interfaces**: If `agent.protocols`, `apis`, or `web.browser_session_endpoint` are declared, `auth.issuer` is required and must resolve to RFC 8414 metadata declaring `issuer` (exact match), `poppy_domains` containing `organization.domain`, HTTPS `token_endpoint`, and `revocation_endpoint`. Never place real credentials or secrets in discovery metadata.
