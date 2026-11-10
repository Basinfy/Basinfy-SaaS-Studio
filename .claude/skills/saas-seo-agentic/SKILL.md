---
name: saas-seo-agentic
description: "Audit and implement AI Agent readiness — Lighthouse Agentic Browsing fraction (X/N), accessibility tree for agents, llms.txt, Markdown content negotiation, WebMCP tools, and /.well-known discovery files."
argument-hint: "[audit|fix|lighthouse] [url]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-agentic/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Agentic Browsing Readiness for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Audits and engineers SaaS platforms for autonomous AI agents that browse, interact with forms, invoke APIs, and retrieve product data on behalf of human users.

---

## 1. The Core Agent-Readiness Architecture

Agent readiness consists of:
1. **Accessibility Tree (Axe Rules)**: AI agents consume the DOM via the accessibility tree. Interactive controls must have accessible names, valid ARIA roles, and keyboard focusability without trap loops.
2. **Lighthouse Agentic Browsing Fraction (X/N)**: Computed via PageSpeed Insights v5 / Lighthouse `category=AGENTIC_BROWSING`.
3. **Machine-Readable Markdown Delivery**: Serving clean, token-efficient Markdown to bots requesting `Accept: text/markdown` or querying `app/llms.txt/route.ts`.
4. **WebMCP Protocol**: Exposing client-side tools to browsing agents via `document.modelContext.registerTool`.
5. **Discovery Endpoints**: `/.well-known/ai-catalog.json`, `/.well-known/agent-card.json`, and API catalogs.

---

## 2. Priority Hierarchy (P0 to P3)

| Priority | Check | Tool Check ID |
|---|---|---|
| **P0** | Accessible names, valid roles, interactive elements exposed | `agent-accessibility-tree` |
| **P0** | Cumulative Layout Shift (CLS) <= 0.1 | `cumulative-layout-shift` |
| **P0** | Core content present in initial server-rendered HTML | `server-rendered` |
| **P0** | robots.txt reachable with explicit AI crawler policies | `robots-ai-groups` |
| **P1** | `llms.txt` present and compliant with standards (H1 + links) | `llms-txt` |
| **P1** | Markdown endpoints via `Accept: text/markdown` (Vary: Accept) | `markdown-delivery` |
| **P1** | Real 404 for unknown routes (catch-all 200 breaks agent discovery) | `http-404` |
| **P2** | WebMCP tools registered on `document.modelContext` | `webmcp-entry-point` |
| **P3** | `ai-catalog.json` and agent cards | `ard-catalog` |

---

## 3. Next.js 14+ Implementation Code

### Route Handler: `app/llms.txt/route.ts`
```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  const content = `# Basinfy SaaS

> Production Multi-Agent Cloud Platform.

## Overview
- Architecture: Next.js 14+ App Router, Supabase RLS, Stripe
- Docs: https://example.com/docs.md
- Pricing: https://example.com/pricing.md
`;

  return new NextResponse(content, {
    status: 200,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'public, max-age=86400',
    },
  });
}
```

---

## 4. Tool Execution

```bash
python scripts/seo/agentic_check.py <url> --json
python scripts/seo/lighthouse_agentic.py <url> --json
```
