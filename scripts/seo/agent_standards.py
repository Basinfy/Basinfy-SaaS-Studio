#!/usr/bin/env python3
"""
Pure validators and maturity scoring for IsItAgentReady / Agent-Readiness standards.

Covers RFC 9727 (api-catalog), RFC 8414 / OIDC (oauth-discovery), RFC 9728
(oauth-protected-resource), SEP-1649 (mcp-server-card), A2A agent-card,
Agent Skills Discovery RFC v0.2.0, Web Bot Auth JWKS, Auth.md, Personal Agent
Protocol (Poppy), Agentic Commerce (ACP, UCP, MPP OpenAPI), and the
IsItAgentReady Level 0-5 maturity scale.
"""

from __future__ import annotations

import json
import re
from typing import Any, Optional
from urllib.parse import urlparse

from url_safety import MAX_JSON_DEPTH, json_depth_exceeds

SKILL_NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
SHA256_DIGEST_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
AGENT_SKILLS_SCHEMA_V020 = "https://schemas.agentskills.io/discovery/0.2.0/schema.json"

LEVEL_NAMES = {
    0: "Not Ready",
    1: "Basic Web Presence",
    2: "Bot-Aware",
    3: "Agent-Readable",
    4: "Agent-Integrated",
    5: "Agent-Native",
}


def _parse_json_obj(raw: str) -> tuple[Optional[dict], list[str]]:
    """Parse JSON safely with depth guard, expecting a root JSON object."""
    if json_depth_exceeds(raw):
        return None, [f"malformed JSON: nested deeper than {MAX_JSON_DEPTH} levels"]
    try:
        data = json.loads(raw)
    except (ValueError, RecursionError) as exc:
        return None, [f"malformed JSON: {type(exc).__name__}: {str(exc)[:200]}"]
    if not isinstance(data, dict):
        return None, ["root must be a JSON object"]
    return data, []


def _res(errors: list[str], warnings: list[str], **extra: Any) -> dict:
    return {"errors": errors, "warnings": warnings, **extra}


def validate_api_catalog(raw: str) -> dict:
    """Validate RFC 9727 API Catalog (linkset+json)."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    linkset = data.get("linkset")
    if not isinstance(linkset, list) or not linkset:
        errors.append("missing non-empty 'linkset' array (RFC 9727)")
        return _res(errors, warnings)
    for idx, entry in enumerate(linkset):
        if not isinstance(entry, dict):
            errors.append(f"linkset[{idx}] must be an object")
            continue
        if not entry.get("anchor"):
            errors.append(f"linkset[{idx}] missing 'anchor' URL")
        if not any(rel in entry for rel in ("service-desc", "service-doc")):
            warnings.append(f"linkset[{idx}] should declare 'service-desc' or 'service-doc'")
    return _res(errors, warnings, entries=len(linkset))


def validate_oauth_discovery(raw: str) -> dict:
    """Validate OIDC Discovery / RFC 8414 OAuth Authorization Server metadata."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    for key in ("issuer", "authorization_endpoint", "token_endpoint", "jwks_uri"):
        if not data.get(key):
            errors.append(f"missing required '{key}'")
    for key in ("grant_types_supported", "response_types_supported"):
        val = data.get(key)
        if val is None:
            warnings.append(f"missing recommended '{key}'")
        elif not isinstance(val, list) or not val:
            errors.append(f"'{key}' must be a non-empty array")
    return _res(errors, warnings, issuer=data.get("issuer"), has_agent_auth="agent_auth" in data)


def validate_oauth_prm(raw: str) -> dict:
    """Validate RFC 9728 OAuth Protected Resource Metadata."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    if not data.get("resource"):
        errors.append("missing required 'resource' URL")
    servers = data.get("authorization_servers")
    if not isinstance(servers, list) or not servers:
        errors.append("missing non-empty 'authorization_servers' array")
    if not data.get("scopes_supported"):
        warnings.append("consider declaring 'scopes_supported'")
    return _res(errors, warnings, resource=data.get("resource"), authorization_servers=servers or [])


def validate_mcp_server_card(raw: str) -> dict:
    """Validate MCP Server Card (/.well-known/mcp/server-card.json)."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    info = data.get("serverInfo")
    if not isinstance(info, dict) or not info.get("name") or not info.get("version"):
        errors.append("missing 'serverInfo' with 'name' and 'version'")
    if not (data.get("endpoint") or data.get("transport") or data.get("transports") or data.get("url")):
        errors.append("missing transport 'endpoint' (or transport definition)")
    caps = data.get("capabilities")
    if not isinstance(caps, dict):
        errors.append("missing 'capabilities' object")
    elif not any(k in caps for k in ("tools", "resources", "prompts")):
        warnings.append("'capabilities' lists none of tools, resources, prompts")
    return _res(errors, warnings, server_name=(info or {}).get("name") if isinstance(info, dict) else None)


def validate_a2a_card(raw: str) -> dict:
    """Validate A2A Agent Card (/.well-known/agent-card.json)."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    for key in ("name", "version", "description"):
        if not data.get(key):
            errors.append(f"missing required '{key}'")
    if not data.get("supportedInterfaces"):
        if data.get("url"):
            warnings.append("uses legacy 'url' instead of 'supportedInterfaces'")
        else:
            errors.append("missing 'supportedInterfaces' array")
    if not isinstance(data.get("capabilities"), dict):
        errors.append("missing 'capabilities' object")
    skills = data.get("skills")
    if not isinstance(skills, list) or not skills:
        warnings.append("missing or empty 'skills' array")
    else:
        for idx, sk in enumerate(skills):
            if not isinstance(sk, dict) or not all(sk.get(f) for f in ("id", "name", "description")):
                errors.append(f"skills[{idx}] must include 'id', 'name', and 'description'")
    return _res(errors, warnings, skills_count=len(skills) if isinstance(skills, list) else 0)


def validate_agent_skills_index(raw: str) -> dict:
    """Validate /.well-known/agent-skills/index.json per Agent Skills Discovery RFC v0.2.0."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    schema = data.get("$schema")
    if not schema:
        errors.append("missing required '$schema'")
    elif schema != AGENT_SKILLS_SCHEMA_V020:
        warnings.append(f"unrecognised '$schema' {schema!r}, expected {AGENT_SKILLS_SCHEMA_V020!r}")
    skills = data.get("skills")
    if not isinstance(skills, list) or not skills:
        errors.append("missing non-empty 'skills' array")
        return _res(errors, warnings, skills_count=0)
    for idx, item in enumerate(skills):
        if not isinstance(item, dict):
            errors.append(f"skills[{idx}] must be an object")
            continue
        name = item.get("name", "")
        if not isinstance(name, str) or not SKILL_NAME_RE.match(name):
            errors.append(f"skills[{idx}]: invalid lowercase hyphenated 'name' ({name!r})")
        if item.get("type") not in ("skill-md", "archive"):
            errors.append(f"skills[{idx}]: 'type' must be 'skill-md' or 'archive'")
        for req in ("description", "url"):
            if not item.get(req):
                errors.append(f"skills[{idx}]: missing '{req}'")
        digest = item.get("digest", "")
        if not isinstance(digest, str) or not SHA256_DIGEST_RE.match(digest):
            errors.append(f"skills[{idx}]: 'digest' must match 'sha256:{{64-hex}}'")
    return _res(errors, warnings, skills_count=len(skills))


def validate_web_bot_auth_jwks(raw: str) -> dict:
    """Validate Web Bot Auth JWKS at /.well-known/http-message-signatures-directory."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors = []
    keys = data.get("keys")
    if not isinstance(keys, list) or not keys:
        errors.append("JWKS must contain a non-empty 'keys' array")
    elif not all(isinstance(k, dict) and k.get("kty") for k in keys):
        errors.append("every JWK entry must be an object with 'kty'")
    return _res(errors, [], key_count=len(keys) if isinstance(keys, list) else 0)


def validate_auth_md(status: Optional[int], content_type: str, text: str) -> dict:
    """Validate /auth.md agent registration discovery document."""
    if status is None:
        return _res(["fetch failed"], [], status="na")
    if status >= 400:
        return _res([], [], status="na")
    ctype = (content_type or "").lower()
    if ctype.startswith("text/html") or re.match(r"^\s*<(!doctype|html)", text or "", re.I):
        return _res([], ["/auth.md returned HTML (soft 404); serve real 404 or Markdown"], status="warn", soft_404=True)
    errors, warnings = [], []
    h1_match = re.search(r"^\s*#\s+(.+)", text or "", re.M)
    if not h1_match:
        errors.append("missing H1 heading")
    elif "auth.md" not in h1_match.group(1).lower():
        errors.append("H1 heading must contain 'auth.md'")
    if "markdown" not in ctype and "text/plain" not in ctype:
        warnings.append(f"unexpected Content-Type '{ctype}' (prefer text/markdown or text/plain)")
    return _res(errors, warnings, status="fail" if errors else ("warn" if warnings else "pass"))


def _strip_www(host: str) -> str:
    host = (host or "").split(":", 1)[0].lower().rstrip(".")
    return host[4:] if host.startswith("www.") else host


def validate_poppy_manifest(raw: str, request_host: str) -> dict:
    """Validate Personal Agent Protocol (Poppy) discovery at /.well-known/poppy.json."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors, warnings = [], []
    if not data.get("protocol_version"):
        errors.append("missing required 'protocol_version'")
    org = data.get("organization")
    if not isinstance(org, dict) or not org.get("name") or not org.get("domain"):
        errors.append("missing 'organization' with 'name' and 'domain'")
    elif _strip_www(str(org["domain"])) != _strip_www(request_host):
        errors.append(f"organization.domain '{org['domain']}' does not match host '{request_host}'")
    if "web" not in data or not isinstance(data.get("web"), dict):
        warnings.append("missing 'web' object")
    session_declared = bool(
        (isinstance(data.get("agent"), dict) and data["agent"].get("protocols"))
        or data.get("apis")
        or (isinstance(data.get("web"), dict) and data["web"].get("browser_session_endpoint"))
    )
    auth_issuer = (data.get("auth") or {}).get("issuer") if isinstance(data.get("auth"), dict) else None
    if session_declared and not auth_issuer:
        errors.append("session/agent/API declarations require 'auth.issuer'")
    return _res(errors, warnings, session_declared=session_declared, auth_issuer=auth_issuer)


def validate_acp_manifest(raw: str) -> dict:
    """Validate Agentic Commerce Protocol (/.well-known/acp.json)."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors = []
    proto = data.get("protocol")
    if not isinstance(proto, dict) or proto.get("name") != "acp" or not proto.get("version"):
        errors.append("missing 'protocol' with name='acp' and 'version'")
    base_url = str(data.get("api_base_url") or "")
    parsed = urlparse(base_url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        errors.append("'api_base_url' must be an absolute HTTP(S) URL")
    if not isinstance(data.get("transports"), list) or not data["transports"]:
        errors.append("missing non-empty 'transports' array")
    caps = data.get("capabilities")
    if not isinstance(caps, dict) or not isinstance(caps.get("services"), list) or not caps["services"]:
        errors.append("missing non-empty 'capabilities.services' array")
    return _res(errors, [])


def validate_ucp_manifest(raw: str) -> dict:
    """Validate Universal Commerce Protocol (/.well-known/ucp)."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [])
    errors = [f"missing required '{k}'" for k in ("protocol_version", "services", "capabilities", "endpoints") if not data.get(k)]
    return _res(errors, [])


def validate_mpp_openapi(raw: str) -> dict:
    """Inspect /openapi.json for MPP (Machine Payment Protocol) x-payment-info extensions."""
    data, errs = _parse_json_obj(raw)
    if data is None:
        return _res(errs, [], payable_ops=0)
    errors, warnings, payable_ops = [], [], 0
    paths = data.get("paths") or {}
    if not isinstance(paths, dict):
        return _res([], [], payable_ops=0)
    for path_key, path_item in paths.items():
        if not isinstance(path_item, dict):
            continue
        for method, op in path_item.items():
            if not isinstance(op, dict) or "x-payment-info" not in op:
                continue
            payable_ops += 1
            info = op["x-payment-info"]
            if not isinstance(info, dict):
                errors.append(f"{method.upper()} {path_key}: 'x-payment-info' must be an object")
                continue
            if info.get("intent") not in ("charge", "session"):
                errors.append(f"{method.upper()} {path_key}: x-payment-info.intent must be 'charge' or 'session'")
            if not info.get("method") or info.get("amount") is None:
                errors.append(f"{method.upper()} {path_key}: x-payment-info requires 'method' and 'amount'")
    return _res(errors, warnings, payable_ops=payable_ops)


def compute_readiness_level(checks_by_id: dict[str, dict]) -> dict:
    """Compute IsItAgentReady Level 0-5 maturity score from check results."""
    def passed(cid: str) -> bool:
        return (checks_by_id.get(cid) or {}).get("status") == "pass"

    has_robots = passed("robots-reachable")
    has_sitemap = passed("sitemap-reachable")
    has_links = passed("link-headers")
    l1_hits = sum((has_robots, has_sitemap, has_links))

    ai_grp = checks_by_id.get("robots-ai-groups") or {}
    has_ai_rules = passed("robots-ai-groups") or bool((ai_grp.get("evidence") or {}).get("has_star_rules"))
    has_signals = passed("content-signal")
    has_md = passed("markdown-delivery")

    integrations = {
        "mcp_server_card": passed("well-known:mcp/server-card.json") or passed("mcp-server-card"),
        "a2a_agent_card": passed("well-known:agent-card.json"),
        "agent_skills": passed("well-known:agent-skills/index.json"),
        "api_catalog": passed("well-known:api-catalog"),
    }
    int_count = sum(integrations.values())

    has_wba = passed("well-known:http-message-signatures-directory")
    has_auth = (
        passed("well-known:oauth-authorization-server")
        or passed("well-known:openid-configuration")
        or passed("well-known:oauth-protected-resource")
        or passed("auth-md")
    )
    l5_hits = sum((has_wba, int_count == 4, has_auth))

    level = 0
    if l1_hits >= 2:
        level = 1
        if has_ai_rules and has_signals:
            level = 2
            if has_md:
                level = 3
                if int_count >= 1:
                    level = 4
                    if l5_hits >= 2:
                        level = 5

    next_req: list[str] = []
    if level == 0:
        missing = [n for n, ok in (("robots.txt", has_robots), ("sitemap.xml", has_sitemap), ("Link headers", has_links)) if not ok]
        next_req = [f"Satisfy at least 2 of 3 basics (missing: {', '.join(missing)})"]
    elif level == 1:
        if not has_ai_rules:
            next_req.append("Add named AI bot rules in robots.txt")
        if not has_signals:
            next_req.append("Add Content-Signal directive in robots.txt")
    elif level == 2:
        next_req.append("Enable Accept: text/markdown content negotiation with Vary: Accept")
    elif level == 3:
        next_req.append("Publish at least 1 integration: MCP Server Card, A2A Agent Card, Agent Skills index, or API Catalog")
    elif level == 4:
        if not has_wba:
            next_req.append("Publish Web Bot Auth JWKS at /.well-known/http-message-signatures-directory")
        if int_count < 4:
            next_req.append("Publish all 4 discovery integrations (MCP, A2A, Agent Skills, API Catalog)")
        if not has_auth:
            next_req.append("Publish OAuth discovery/PRM or /auth.md")

    return {
        "level": level,
        "level_name": LEVEL_NAMES[level],
        "integrations_count": int_count,
        "integrations": integrations,
        "next_level": level + 1 if level < 5 else None,
        "next_level_requirements": next_req,
    }
