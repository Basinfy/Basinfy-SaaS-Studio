#!/usr/bin/env python3
"""Unit tests for IsItAgentReady / Agent-Readiness validators, maturity levels, and drafters."""

import json
import os
import sys
import unittest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEO_SCRIPTS = os.path.join(REPO_ROOT, "scripts", "seo")
if SEO_SCRIPTS not in sys.path:
    sys.path.insert(0, SEO_SCRIPTS)

import agent_standards as std  # noqa: E402
import agentic_check as chk  # noqa: E402
import agentic_fix as fix  # noqa: E402


class TestAgentStandardsValidators(unittest.TestCase):
    def test_api_catalog(self):
        good = json.dumps({
            "linkset": [{"anchor": "https://ex.com/api", "service-desc": [{"href": "/openapi.json"}]}]
        })
        res = std.validate_api_catalog(good)
        self.assertEqual(res["errors"], [])
        self.assertEqual(res["warnings"], [])

        bad = json.dumps({"linkset": []})
        self.assertTrue(std.validate_api_catalog(bad)["errors"])

    def test_oauth_discovery_and_prm(self):
        as_doc = json.dumps({
            "issuer": "https://auth.ex.com",
            "authorization_endpoint": "https://auth.ex.com/auth",
            "token_endpoint": "https://auth.ex.com/token",
            "jwks_uri": "https://auth.ex.com/jwks",
            "grant_types_supported": ["authorization_code"],
            "response_types_supported": ["code"],
        })
        self.assertEqual(std.validate_oauth_discovery(as_doc)["errors"], [])
        self.assertTrue(std.validate_oauth_discovery("{}")["errors"])

        prm_doc = json.dumps({
            "resource": "https://api.ex.com",
            "authorization_servers": ["https://auth.ex.com"],
            "scopes_supported": ["read"],
        })
        self.assertEqual(std.validate_oauth_prm(prm_doc)["errors"], [])
        self.assertTrue(std.validate_oauth_prm(json.dumps({"resource": "x"}))["errors"])

    def test_mcp_server_card_variants(self):
        card_a = json.dumps({
            "serverInfo": {"name": "MCP", "version": "1.0.0"},
            "endpoint": "https://ex.com/mcp",
            "capabilities": {"tools": {}},
        })
        card_b = json.dumps({
            "serverInfo": {"name": "MCP", "version": "1.0.0"},
            "url": "https://ex.com/mcp",
            "transport": {"type": "streamable-http"},
            "capabilities": {"tools": True},
        })
        self.assertEqual(std.validate_mcp_server_card(card_a)["errors"], [])
        self.assertEqual(std.validate_mcp_server_card(card_b)["errors"], [])
        self.assertTrue(std.validate_mcp_server_card("{}")["errors"])

    def test_a2a_card(self):
        card = json.dumps({
            "name": "Agent", "version": "1.0", "description": "Helper",
            "supportedInterfaces": [{"url": "https://ex.com/a2a", "protocol": "jsonrpc"}],
            "capabilities": {"streaming": False},
            "skills": [{"id": "s1", "name": "Search", "description": "Find docs"}],
        })
        res = std.validate_a2a_card(card)
        self.assertEqual(res["errors"], [])
        self.assertEqual(res["warnings"], [])

    def test_agent_skills_index(self):
        idx = json.dumps({
            "$schema": std.AGENT_SKILLS_SCHEMA_V020,
            "skills": [{
                "name": "scan-site",
                "type": "skill-md",
                "description": "Scan site",
                "url": "https://ex.com/.well-known/agent-skills/scan-site/SKILL.md",
                "digest": "sha256:" + ("a" * 64),
            }],
        })
        self.assertEqual(std.validate_agent_skills_index(idx)["errors"], [])

        bad = json.dumps({
            "$schema": std.AGENT_SKILLS_SCHEMA_V020,
            "skills": [{"name": "Bad_Name", "type": "unknown", "digest": "md5:123"}],
        })
        self.assertGreaterEqual(len(std.validate_agent_skills_index(bad)["errors"]), 3)

    def test_web_bot_auth_jwks(self):
        jwks = json.dumps({"keys": [{"kty": "OKP", "crv": "Ed25519", "x": "abc"}]})
        self.assertEqual(std.validate_web_bot_auth_jwks(jwks)["errors"], [])
        self.assertTrue(std.validate_web_bot_auth_jwks(json.dumps({"keys": []}))["errors"])

    def test_auth_md(self):
        self.assertEqual(std.validate_auth_md(200, "text/markdown", "# My auth.md\n\nDocs.")["status"], "pass")
        self.assertEqual(std.validate_auth_md(200, "text/html", "<html></html>")["status"], "warn")
        self.assertEqual(std.validate_auth_md(200, "text/markdown", "# Wrong Heading")["status"], "fail")
        self.assertEqual(std.validate_auth_md(404, "text/plain", "")["status"], "na")

    def test_poppy_manifest(self):
        poppy_ok = json.dumps({
            "protocol_version": "0.1",
            "organization": {"name": "Ex", "domain": "example.com"},
            "web": {},
        })
        self.assertEqual(std.validate_poppy_manifest(poppy_ok, "www.example.com")["errors"], [])

        poppy_session_no_issuer = json.dumps({
            "protocol_version": "0.1",
            "organization": {"name": "Ex", "domain": "example.com"},
            "web": {"browser_session_endpoint": "https://example.com/session"},
        })
        self.assertTrue(std.validate_poppy_manifest(poppy_session_no_issuer, "example.com")["errors"])

    def test_commerce_protocols(self):
        acp = json.dumps({
            "protocol": {"name": "acp", "version": "1.0"},
            "api_base_url": "https://api.example.com/acp",
            "transports": ["rest-json"],
            "capabilities": {"services": ["checkout"]},
        })
        self.assertEqual(std.validate_acp_manifest(acp)["errors"], [])

        ucp = json.dumps({
            "protocol_version": "1.0",
            "services": {"shopping": {"version": "1.0"}},
            "capabilities": [{"name": "checkout"}],
            "endpoints": {"checkout": "https://api.example.com/ucp/checkout"},
        })
        self.assertEqual(std.validate_ucp_manifest(ucp)["errors"], [])
        self.assertTrue(std.validate_ucp_manifest(json.dumps({"protocol_version": "1.0"}))["errors"])

        openapi = json.dumps({
            "openapi": "3.1.0",
            "paths": {
                "/v1/generate": {
                    "post": {
                        "x-payment-info": {"intent": "charge", "method": "stripe", "amount": "0.05"}
                    }
                }
            },
        })
        mpp = std.validate_mpp_openapi(openapi)
        self.assertEqual(mpp["errors"], [])
        self.assertEqual(mpp["payable_ops"], 1)

    def test_ard_host_check(self):
        raw = json.dumps({
            "specVersion": "1.0",
            "host": {"displayName": "Ex", "identifier": "did:web:example.com"},
            "entries": [{
                "identifier": "urn:air:example.com:mcp:docs",
                "displayName": "Docs MCP",
                "type": "application/mcp-server-card+json",
                "url": "https://example.com/.well-known/mcp/server-card.json",
                "representativeQueries": ["query 1", "query 2"],
            }],
        })
        res = chk.validate_ai_catalog(raw)
        self.assertEqual(res["errors"], [])
        self.assertEqual(res["warnings"], [])

    def test_readiness_levels_0_to_5(self):
        p = lambda cid: (cid, {"status": "pass"})

        # Level 0: only robots
        l0 = std.compute_readiness_level(dict([p("robots-reachable")]))
        self.assertEqual(l0["level"], 0)

        # Level 1: robots + sitemap
        l1 = std.compute_readiness_level(dict([p("robots-reachable"), p("sitemap-reachable")]))
        self.assertEqual(l1["level"], 1)

        # Level 2: + ai rules (via star) + content-signal
        base_l2 = dict([
            p("robots-reachable"),
            p("sitemap-reachable"),
            ("robots-ai-groups", {"status": "info", "evidence": {"has_star_rules": True}}),
            p("content-signal"),
        ])
        self.assertEqual(std.compute_readiness_level(base_l2)["level"], 2)

        # Level 3: + markdown
        base_l3 = {**base_l2, **dict([p("markdown-delivery")])}
        self.assertEqual(std.compute_readiness_level(base_l3)["level"], 3)

        # Level 4: + 1 integration
        base_l4 = {**base_l3, **dict([p("well-known:mcp/server-card.json")])}
        self.assertEqual(std.compute_readiness_level(base_l4)["level"], 4)

        # Level 5: + web bot auth + oauth
        base_l5 = {
            **base_l4,
            **dict([p("well-known:http-message-signatures-directory"), p("well-known:oauth-authorization-server")]),
        }
        l5 = std.compute_readiness_level(base_l5)
        self.assertEqual(l5["level"], 5)
        self.assertEqual(l5["level_name"], "Agent-Native")

    def test_drafters_round_trip(self):
        skills_res = fix.draft_agent_skills_index("https://example.com", os.path.join(REPO_ROOT, ".claude", "skills"))
        self.assertEqual(skills_res["validation"]["errors"], [])
        self.assertEqual(skills_res["validation"]["skills_count"], 108)

        self.assertEqual(fix.draft_mcp_card("Test", "https://example.com")["validation"]["errors"], [])
        self.assertEqual(fix.draft_api_catalog("https://example.com")["validation"]["errors"], [])
        self.assertEqual(fix.draft_poppy("Test Co", "example.com")["validation"]["errors"], [])
        self.assertEqual(fix.draft_acp("https://example.com")["validation"]["errors"], [])
        self.assertIn("# Test Co auth.md", fix.draft_auth_md("Test Co", "https://example.com")["auth_md"])


if __name__ == "__main__":
    unittest.main()
