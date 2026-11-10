#!/usr/bin/env python3
"""
Agent-readiness fix drafter.

Produces reviewable drafts for the fixes ``agentic_check.py`` reports. It never
writes to the site or overwrites a file: every draft goes to stdout (or the
``--output`` path the user names), and each one says what a person must decide
before shipping it.

Subcommands
===========
robots      Add a ``Content-Signal`` line to every user-agent group of an
            existing robots.txt that lacks one. Allow/Disallow rules are never
            changed: access policy is the site owner's decision.
llms        Draft an ``/llms.txt`` from a page's title, meta description and
            same-site navigation links (llmstxt.org structure; passes the
            Lighthouse ``llms-txt`` rules when the page has links).
ai-catalog  Draft an ``ai-catalog.json`` (Agentic Resource Discovery 1.0) from
            ``--entry`` values and validate it with the same rules as
            ``agentic_check.py``.
webmcp      Draft WebMCP scaffolds for each ``<form>`` on a page: declarative
            attributes (Chrome only) and an imperative ``registerTool`` block
            (Chrome origin trial and ChatGPT desktop) that submits through the
            form itself, so the tool runs the same handler as the UI.

CLI
===
    python agentic_fix.py robots https://example.com --signal "search=yes, ai-input=yes, ai-train=no"
    python agentic_fix.py robots --file robots.txt --signal "search=yes, ai-train=no"
    python agentic_fix.py llms https://example.com
    python agentic_fix.py ai-catalog --publisher example.com \\
        --entry "Docs MCP|application/mcp-server-card+json|https://example.com/mcp/server-card"
    python agentic_fix.py webmcp https://example.com/contact --json
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urljoin, urlparse

_SCRIPTS_DIR = os.path.dirname(os.path.abspath(__file__))
if _SCRIPTS_DIR not in sys.path:
    sys.path.insert(0, _SCRIPTS_DIR)
from agent_standards import (  # noqa: E402
    AGENT_SKILLS_SCHEMA_V020,
    validate_acp_manifest,
    validate_agent_skills_index,
    validate_api_catalog,
    validate_mcp_server_card,
    validate_poppy_manifest,
)
from agentic_check import (  # noqa: E402
    fetch,
    parse_content_signal,
    robots_lines,
    validate_ai_catalog,
)

DEFAULT_SIGNAL = "search=yes, ai-input=yes, ai-train=no"
SLUG = re.compile(r"[^a-z0-9]+")


# --------------------------------------------------------------------------- robots


def add_content_signal(robots_text: str, signal: str) -> dict:
    """Insert ``Content-Signal: <signal>`` into each user-agent group that has none.

    Groups follow RFC 9309 as ``agentic_check.parse_robots`` reads them: a group
    is a run of ``user-agent`` lines (blank lines and comments between them do
    not end it) followed by rule lines, until the next ``user-agent`` line after
    a rule. The signal goes directly after the group's last ``user-agent`` line,
    so no group is split and every Allow/Disallow outcome stays identical.
    """
    parsed = parse_content_signal(signal)
    if parsed["issues"]:
        raise ValueError("invalid signal: " + "; ".join(parsed["issues"]))
    robots_text = robots_text.lstrip("\ufeff")
    newline = "\r\n" if "\r\n" in robots_text else "\n"
    lines = robots_lines(robots_text)

    # Pass 1: find groups as (index of last user-agent line, agents, has_signal).
    groups, current, in_ua_block = [], None, False
    for idx, line in enumerate(lines):
        field = _field(line)
        if not field:
            continue  # blank line or comment: neither starts nor ends a block
        if field == "user-agent":
            if current is None or not in_ua_block:
                current = {"last_ua": idx, "agents": [], "has_signal": False}
                groups.append(current)
            current["agents"].append(line.split(":", 1)[1].split("#", 1)[0].strip())
            current["last_ua"] = idx
            in_ua_block = True
            continue
        in_ua_block = False
        if current is not None and field == "content-signal":
            current["has_signal"] = True

    # Pass 2: insert after the last user-agent line of each group lacking a signal.
    insert_after = {g["last_ua"] for g in groups if not g["has_signal"]}
    changed = [g["agents"] for g in groups if not g["has_signal"]]
    out = []
    for idx, line in enumerate(lines):
        out.append(line)
        if idx in insert_after:
            out.append(f"Content-Signal: {signal}")

    if not groups:
        # Append (never prepend): rules outside any group stay inert instead of
        # joining the new group, and no Allow/Disallow line is invented.
        tail = ["User-agent: *", f"Content-Signal: {signal}"]
        out = (out + [""] + tail) if any(ln.strip() for ln in out) else tail
        changed.append(["*"])
    text = newline.join(out)
    if robots_text.endswith(("\n", "\r")) or not robots_text:
        text += newline
    return {"robots_txt": text, "groups_changed": changed}


def _field(line: str) -> str:
    """Lower-cased field name; "" for blank or comment lines.

    A line with a colon but no name (': junk') is a non-user-agent field, as in
    agentic_check.parse_robots, so it ends a user-agent block.
    """
    body = line.lstrip("\ufeff").split("#", 1)[0]
    if ":" not in body:
        return ""
    return body.split(":", 1)[0].strip().lower() or "(unnamed)"


# --------------------------------------------------------------------------- llms.txt


def draft_llms_txt(url: str, html: str, max_links: int = 30) -> str:
    """Build an llms.txt draft; ``url`` should be the final URL after redirects."""
    from bs4 import BeautifulSoup

    soup = BeautifulSoup(html, "lxml")
    title = (soup.title.get_text(strip=True) if soup.title else "") or urlparse(url).netloc
    desc_tag = soup.find("meta", attrs={"name": "description"})
    summary = (desc_tag.get("content") or "").strip() if desc_tag else ""
    host = urlparse(url).netloc
    seen, links = set(), []
    containers = soup.find_all(["nav", "header", "footer"]) or [soup]
    for container in containers:
        for a in container.find_all("a", href=True):
            href = urljoin(url, a["href"]).split("#", 1)[0]
            text = " ".join(a.get_text(" ", strip=True).split())
            if urlparse(href).netloc != host or not text or href in seen:
                continue
            seen.add(href)
            links.append((text, href))
            if len(links) >= max_links:
                break
        if len(links) >= max_links:
            break
    lines = [f"# {title}", ""]
    lines += [f"> {summary}", ""] if summary else ["> TODO: one or two sentences on what this site offers.", ""]
    lines += ["## Pages", ""]
    lines += [f"- [{text}]({href})" for text, href in links] or ["- [Home](" + url + ")"]
    lines += ["", "## Optional", "", "- TODO: secondary links agents may skip", ""]
    return "\n".join(lines)


# --------------------------------------------------------------------------- ai-catalog


def draft_ai_catalog(publisher: str, entries: list) -> dict:
    items = []
    pub = SLUG.sub("-", publisher.lower()).strip("-") or "example"
    for raw in entries:
        parts = [p.strip() for p in raw.split("|")]
        if len(parts) != 3:
            raise ValueError(f"--entry must be 'Display name|media type|url': {raw!r}")
        name, media, url = parts
        items.append({
            "identifier": f"urn:air:{pub}:{SLUG.sub('-', name.lower()).strip('-')}",
            "displayName": name,
            "type": media,
            "url": url,
            "representativeQueries": [f"TODO: a question {name} answers",
                                      f"TODO: a second question {name} answers"],
        })
    catalog = {
        "specVersion": "1.0",
        "host": {
            "displayName": publisher,
            "identifier": f"did:web:{publisher.lower()}",
        },
        "entries": items,
    }
    return {"catalog": catalog, "validation": validate_ai_catalog(json.dumps(catalog))}


# --------------------------------------------------------------------------- agent-skills / discovery / auth / commerce


def draft_agent_skills_index(base_url: str, skills_dir: str | None = None) -> dict:
    """Draft /.well-known/agent-skills/index.json (RFC v0.2.0) with real SHA-256 digests."""
    base = base_url.rstrip("/")
    skills = []
    if skills_dir:
        root = Path(skills_dir)
        for skill_md in sorted(root.glob("*/SKILL.md")):
            raw_bytes = skill_md.read_bytes()
            digest = "sha256:" + hashlib.sha256(raw_bytes).hexdigest()
            text = raw_bytes.decode("utf-8", errors="ignore")
            m_desc = re.search(r'(?m)^description:\s*"?(.+?)"?\s*$', text)
            desc = (m_desc.group(1).strip() if m_desc else f"Skill {skill_md.parent.name}")[:200]
            name = SLUG.sub("-", skill_md.parent.name.lower()).strip("-")
            skills.append({
                "name": name,
                "type": "skill-md",
                "description": desc,
                "url": f"{base}/.well-known/agent-skills/{name}/SKILL.md",
                "digest": digest,
            })
    if not skills:
        sample = b"# Example Skill\n\nDescribe what agents can do with this skill.\n"
        skills.append({
            "name": "example-skill",
            "type": "skill-md",
            "description": "TODO: concise description of what this agent skill performs.",
            "url": f"{base}/.well-known/agent-skills/example-skill/SKILL.md",
            "digest": "sha256:" + hashlib.sha256(sample).hexdigest(),
        })
    doc = {"$schema": AGENT_SKILLS_SCHEMA_V020, "skills": skills}
    return {"index": doc, "validation": validate_agent_skills_index(json.dumps(doc))}


def draft_mcp_card(name: str, base_url: str, version: str = "1.0.0") -> dict:
    """Draft /.well-known/mcp/server-card.json (SEP-1649)."""
    doc = {
        "serverInfo": {"name": name, "version": version},
        "endpoint": f"{base_url.rstrip('/')}/mcp",
        "capabilities": {"tools": {}, "resources": {}, "prompts": {}},
    }
    return {"server_card": doc, "validation": validate_mcp_server_card(json.dumps(doc))}


def draft_api_catalog(base_url: str) -> dict:
    """Draft /.well-known/api-catalog (RFC 9727 linkset+json)."""
    base = base_url.rstrip("/")
    doc = {
        "linkset": [
            {
                "anchor": f"{base}/api",
                "service-desc": [{"href": f"{base}/openapi.json", "type": "application/openapi+json"}],
                "service-doc": [{"href": f"{base}/docs", "type": "text/html"}],
                "status": [{"href": f"{base}/api/health", "type": "application/json"}],
            }
        ]
    }
    return {"api_catalog": doc, "validation": validate_api_catalog(json.dumps(doc))}


def draft_auth_md(name: str, base_url: str) -> dict:
    """Draft /auth.md agent registration discovery Markdown."""
    base = base_url.rstrip("/")
    md = (
        f"# {name} auth.md\n\n"
        f"> Agent registration and OAuth discovery guide for {name}.\n\n"
        "## Audience\n"
        "Autonomous AI agents and MCP/A2A clients authenticating against protected APIs.\n\n"
        "## Discovery Endpoints\n"
        f"- Protected Resource Metadata: `{base}/.well-known/oauth-protected-resource`\n"
        f"- Authorization Server Metadata: `{base}/.well-known/oauth-authorization-server`\n\n"
        "## Supported Flows\n"
        "- OAuth 2.1 Authorization Code + PKCE\n"
        "- Dynamic Client Registration / Verified Agent Identity\n"
    )
    return {"auth_md": md}


def draft_poppy(name: str, domain: str) -> dict:
    """Draft /.well-known/poppy.json (Personal Agent Protocol draft 0.1)."""
    clean_domain = urlparse(domain if "://" in domain else "https://" + domain).netloc or domain
    doc = {
        "protocol_version": "0.1",
        "organization": {"name": name, "domain": clean_domain},
        "web": {},
    }
    return {"poppy": doc, "validation": validate_poppy_manifest(json.dumps(doc), clean_domain)}


def draft_acp(base_url: str) -> dict:
    """Draft /.well-known/acp.json (Agentic Commerce Protocol)."""
    base = base_url.rstrip("/")
    doc = {
        "protocol": {"name": "acp", "version": "1.0"},
        "api_base_url": f"{base}/api/acp",
        "transports": ["rest-json"],
        "capabilities": {"services": ["checkout", "subscriptions"]},
    }
    return {"acp": doc, "validation": validate_acp_manifest(json.dumps(doc))}


# --------------------------------------------------------------------------- WebMCP


def _tool_name(form, index: int) -> str:
    base = form.get("id") or form.get("name") or urlparse(form.get("action") or "").path
    base = SLUG.sub("_", (base or f"form_{index}").lower()).strip("_") or f"form_{index}"
    return base[:48]


def _form_fields(form) -> list:
    fields = []
    for el in form.find_all(["input", "select", "textarea"]):
        name = el.get("name")
        kind = (el.get("type") or el.name).lower()
        if not name or kind in ("hidden", "submit", "button", "reset", "image", "file", "password"):
            continue
        label = ""
        if el.get("id"):
            tag = form.find("label", attrs={"for": el["id"]})
            label = tag.get_text(" ", strip=True) if tag else ""
        label = label or el.get("aria-label") or el.get("placeholder") or name
        schema = {"type": "number" if kind in ("number", "range") else
                  "boolean" if kind == "checkbox" else "string",
                  "description": label}
        if el.name == "select":
            options = [o.get("value", o.get_text(strip=True)) for o in el.find_all("option")]
            schema["enum"] = [o for o in options if o]
        if kind == "email":
            schema["format"] = "email"
        if kind == "radio":
            schema = {"type": "string", "description": name, "enum": []}
        existing = next((f for f in fields if f["name"] == name), None)
        if existing:  # radio and checkbox groups share one name
            if kind == "radio" and el.get("value"):
                existing["schema"].setdefault("enum", []).append(el["value"])
            existing["required"] = existing["required"] or el.has_attr("required")
            continue
        if kind == "radio" and el.get("value"):
            schema["enum"].append(el["value"])
        fields.append({"name": name, "schema": schema, "required": el.has_attr("required")})
    return fields


def draft_webmcp(url: str, html: str) -> list:
    from bs4 import BeautifulSoup

    soup = BeautifulSoup(html, "lxml")
    drafts = []
    for index, form in enumerate(soup.find_all("form")):
        fields = _form_fields(form)
        if not fields:
            continue
        name = _tool_name(form, index)
        method = (form.get("method") or "get").lower()
        consequential = method == "post"
        properties = {f["name"]: f["schema"] for f in fields}
        required = [f["name"] for f in fields if f["required"]]
        # document.forms follows document order; CSS :nth-of-type counts siblings only.
        locator = (f"document.getElementById({json.dumps(form['id'])})" if form.get("id")
                   else f"document.forms[{index}]")
        selector = f"form#{form['id']}" if form.get("id") else f"document.forms[{index}]"
        schema = {"type": "object", "properties": properties}
        if required:
            schema["required"] = required
        annotations = {"readOnlyHint": not consequential}
        if consequential:
            annotations["consequentialHint"] = True
        imperative = IMPERATIVE_TEMPLATE.format(
            name=name, locator=_js_safe(locator),
            schema=_js_safe(json.dumps(schema, indent=2).replace("\n", "\n    ")),
            annotations=json.dumps(annotations))
        drafts.append({
            "form": selector,
            "action": form.get("action"),
            "method": method,
            "tool_name": name,
            "consequential": consequential,
            "declarative_attributes": {
                "form": {"toolname": name, "tooldescription": "TODO: what submitting does"},
                "fields": {f["name"]: {"toolparamdescription": f["schema"]["description"]}
                           for f in fields},
            },
            "imperative_js": imperative,
            "review": [
                "Replace every TODO description with plain language an agent can act on.",
                "Keep the tool bound to the form submit so it runs the UI's own handler.",
                "Consequential tools (purchases, sends, deletes) must keep a human "
                "confirmation step; consequentialHint does not replace it.",
                "Log SubmitEvent.agentInvoked server-side and rate-limit agent submissions.",
            ],
        })
    return drafts


def _js_safe(text: str) -> str:
    """Keep page-derived strings from closing the surrounding <script> element."""
    return text.replace("<", "\\u003c")


IMPERATIVE_TEMPLATE = """<script type="module">
// Draft generated by claude-seo. WebMCP is a W3C Community Group draft.
const mc = document.modelContext ?? navigator.modelContext; // navigator: legacy engines
const form = {locator};
if (mc?.registerTool && form) {{
  mc.registerTool({{
    name: "{name}",
    description: "TODO: one sentence on what this does and what it returns.",
    inputSchema: {schema},
    annotations: {annotations},
    async execute(input) {{
      for (const [key, value] of Object.entries(input)) {{
        const field = form.elements.namedItem(key);
        if (!field) continue;
        if (field.type === "checkbox") field.checked = Boolean(value);
        else if ("value" in field) field.value = String(value);
      }}
      form.requestSubmit(); // same submit handler and validation as the UI
      return {{ content: [{{ type: "text", text: "Submitted. TODO: describe the visible result." }}] }};
    }}
  }});
}}
</script>"""


# --------------------------------------------------------------------------- CLI


def _with_scheme(url: str) -> str:
    return url if "://" in url else "https://" + url


def _page(url: str) -> tuple[str, str]:
    """Return (final_url, html); the final URL keeps same-site checks right after redirects."""
    rec = fetch(url)
    if rec["error"] or not rec["status"] or rec["status"] >= 400:
        raise SystemExit(f"Could not fetch {url}: {rec['error'] or rec['status']}")
    return rec["final_url"] or url, rec["text"]


def main() -> None:
    parser = argparse.ArgumentParser(description="Agent-readiness fix drafter")
    sub = parser.add_subparsers(dest="cmd", required=True)
    p_robots = sub.add_parser("robots", help="Add Content-Signal to each robots.txt group")
    p_robots.add_argument("url", nargs="?", help="Site URL (reads /robots.txt)")
    p_robots.add_argument("--file", help="Local robots.txt instead of a URL")
    p_robots.add_argument("--signal", default=DEFAULT_SIGNAL)
    p_llms = sub.add_parser("llms", help="Draft /llms.txt from a page")
    p_llms.add_argument("url")
    p_cat = sub.add_parser("ai-catalog", help="Draft ai-catalog.json")
    p_cat.add_argument("--publisher", required=True, help="Publisher id, e.g. example.com")
    p_cat.add_argument("--entry", action="append", default=[],
                       help="'Display name|media type|url' (repeatable)")
    p_web = sub.add_parser("webmcp", help="Draft WebMCP scaffolds for a page's forms")
    p_web.add_argument("url")
    p_skills = sub.add_parser("agent-skills", help="Draft /.well-known/agent-skills/index.json")
    p_skills.add_argument("url", help="Site base URL")
    p_skills.add_argument("--skills-dir", help="Local skills directory containing */SKILL.md")
    p_mcp = sub.add_parser("mcp-card", help="Draft /.well-known/mcp/server-card.json")
    p_mcp.add_argument("--name", required=True, help="MCP server display name")
    p_mcp.add_argument("--url", required=True, help="Site base URL")
    p_mcp.add_argument("--version", default="1.0.0")
    p_apic = sub.add_parser("api-catalog", help="Draft /.well-known/api-catalog (RFC 9727)")
    p_apic.add_argument("url", help="Site base URL")
    p_auth = sub.add_parser("auth-md", help="Draft /auth.md agent registration Markdown")
    p_auth.add_argument("--name", required=True, help="Service name")
    p_auth.add_argument("--url", required=True, help="Site base URL")
    p_pop = sub.add_parser("poppy", help="Draft /.well-known/poppy.json (Personal Agent Protocol)")
    p_pop.add_argument("--name", required=True, help="Organization name")
    p_pop.add_argument("--domain", required=True, help="Organization domain")
    p_acp = sub.add_parser("acp", help="Draft /.well-known/acp.json (Agentic Commerce Protocol)")
    p_acp.add_argument("url", help="Site base URL")
    for p in (p_robots, p_llms, p_cat, p_web, p_skills, p_mcp, p_apic, p_auth, p_pop, p_acp):
        p.add_argument("--json", action="store_true", help="JSON output")
        p.add_argument("--output", help="Write the draft to this path instead of stdout")
    args = parser.parse_args()

    if args.cmd == "robots":
        if args.file:
            with open(args.file, encoding="utf-8") as fh:
                text = fh.read()
        elif args.url:
            root = urlparse(_with_scheme(args.url))
            rec = fetch(f"{root.scheme}://{root.netloc}/robots.txt")
            if rec["status"] == 200:
                text = rec["text"]
            elif rec["status"] and 400 <= rec["status"] < 500:
                text = ""  # 4xx: no robots.txt, so start a new one
            else:
                # A 5xx, WAF block or network error is not "no file"; drafting from
                # nothing here would propose replacing the real policy.
                raise SystemExit(f"Could not read robots.txt ({rec['error'] or rec['status']}). "
                                 "Retry, or pass the current file with --file.")
        else:
            parser.error("robots needs a URL or --file")
        result = add_content_signal(text, args.signal)
        draft = result["robots_txt"]
    elif args.cmd == "llms":
        draft = draft_llms_txt(*_page(_with_scheme(args.url)))
        result = {"llms_txt": draft}
    elif args.cmd == "ai-catalog":
        if not args.entry:
            parser.error("ai-catalog needs at least one --entry")
        result = draft_ai_catalog(args.publisher, args.entry)
        draft = json.dumps(result["catalog"], indent=2) + "\n"
    elif args.cmd == "agent-skills":
        result = draft_agent_skills_index(_with_scheme(args.url), args.skills_dir)
        draft = json.dumps(result["index"], indent=2) + "\n"
    elif args.cmd == "mcp-card":
        result = draft_mcp_card(args.name, _with_scheme(args.url), args.version)
        draft = json.dumps(result["server_card"], indent=2) + "\n"
    elif args.cmd == "api-catalog":
        result = draft_api_catalog(_with_scheme(args.url))
        draft = json.dumps(result["api_catalog"], indent=2) + "\n"
    elif args.cmd == "auth-md":
        result = draft_auth_md(args.name, _with_scheme(args.url))
        draft = result["auth_md"]
    elif args.cmd == "poppy":
        result = draft_poppy(args.name, args.domain)
        draft = json.dumps(result["poppy"], indent=2) + "\n"
    elif args.cmd == "acp":
        result = draft_acp(_with_scheme(args.url))
        draft = json.dumps(result["acp"], indent=2) + "\n"
    else:
        final_url, html = _page(_with_scheme(args.url))
        result = {"url": final_url, "tools": draft_webmcp(final_url, html)}
        draft = "\n\n".join(t["imperative_js"] for t in result["tools"]) or "No forms with named fields.\n"

    body = json.dumps(result, indent=2) + "\n" if args.json else draft
    if args.output:
        try:
            with open(args.output, "x", encoding="utf-8") as fh:  # atomic: never overwrites
                fh.write(body)
        except FileExistsError:
            raise SystemExit(f"Refusing to overwrite {args.output}; choose a new path.") from None
        print(f"Draft written to {args.output}")
    else:
        sys.stdout.write(body)


if __name__ == "__main__":
    main()
