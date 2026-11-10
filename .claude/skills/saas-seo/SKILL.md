---
name: saas-seo
description: "Master SaaS SEO command center — audits, technical crawlability, Next.js App Router metadata, Schema.org JSON-LD, GEO (AI Overviews, ChatGPT, Perplexity), Agentic Browsing (llms.txt, WebMCP), and SQLite drift monitoring."
argument-hint: "[command] [url|args]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS SEO Command Center

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Master command hub for SaaS search optimization, generative AI search visibility (GEO), autonomous agent readiness, and on-page technical integrity.

---

## 1. Quick Command Dispatch

| Command | Skill Routed | Primary Objective |
|---|---|---|
| `/saas-seo audit <url>` | `saas-seo-audit` | Full multi-agent SaaS website audit & prioritized fix plan |
| `/saas-seo technical <url>` | `saas-seo-technical` | 9-category technical crawlability, SSR/SSG rendering, robots.txt |
| `/saas-seo schema <url>` | `saas-seo-schema` | Schema.org JSON-LD generation (SoftwareApplication, Organization) |
| `/saas-seo geo <url>` | `saas-seo-geo` | Generative Engine Optimization (AI Overviews, Perplexity, ChatGPT) |
| `/saas-seo agentic <url>` | `saas-seo-agentic` | Lighthouse Agentic Browsing (X/N), llms.txt, WebMCP, discovery |
| `/saas-seo content <url>` | `saas-seo-content` | SaaS value messaging, E-E-A-T, AI text humanization & watermarks |
| `/saas-seo competitor-pages [url]`| `saas-seo-competitor-pages` | High-converting 'X vs Y' and 'Alternatives to X' pages |
| `/saas-seo programmatic [plan]` | `saas-seo-programmatic` | Scaled template pages (tools, directories) with <40% thin-content gate |
| `/saas-seo sxo <url> [keyword]` | `saas-seo-sxo` | Search Experience Optimization & SERP intent mismatch detection |
| `/saas-seo drift <cmd> <url>` | `saas-seo-drift` | Git-like SQLite baseline snapshotting and CI/CD regression diffs |
| `/saas-seo scaffold [component]` | internal | Scaffold Next.js 14+ SEO files (robots.ts, sitemap.ts, llms.txt) |
| `/saas-seo doctor` | internal | Check Python runtime readiness and dependencies without modifying system |

---

## 2. Bundled Python Execution Engine

All bundled CLI tools live in `scripts/seo/` and execute with zero external network bloat and built-in SSRF protection:

```bash
python scripts/seo/parse_html.py <url> --json
python scripts/seo/agentic_check.py <url> --json
python scripts/seo/drift_baseline.py <url>
python scripts/seo/drift_compare.py <url>
python scripts/seo/schema_generate.py profile --script-tag
```

For local development servers (`http://localhost:3000`), the engine safely allows loopback inspection when `CLAUDE_SEO_LOCAL_TARGETS=localhost:3000` is present.

---

## 3. Next.js 14+ App Router Code Generation Standards

Whenever implementing SEO features directly into a SaaS codebase, strictly generate code conforming to Next.js App Router conventions:

1. **Static & Dynamic Metadata**: Use `export const metadata: Metadata` or `export async function generateMetadata(): Promise<Metadata>`.
2. **Granular AI Crawler Management**: Generate `app/robots.ts` explicitly distinguishing AI training bots (`GPTBot`, `ClaudeBot`, `Google-Extended`) from AI search citability bots (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`).
3. **Dynamic Sitemaps**: Generate `app/sitemap.ts` implementing `MetadataRoute.Sitemap`.
4. **Agentic Discovery**: Implement `app/llms.txt/route.ts` delivering concise Markdown documentation to AI agents.
5. **JSON-LD Structured Data**: Deliver server-rendered `<script type="application/ld+json">` components to ensure instant indexing by crawlers without client-side hydration delays.

---

## 4. Execution Workflow

1. **Identify Request Intent**: Route single-domain requests to the respective specialized `/saas-seo-*` skill.
2. **Execute Diagnostic Check**: If URL is provided, run `scripts/seo/parse_html.py` or `scripts/seo/agentic_check.py`.
3. **Formulate Findings**: Structure findings into **Critical (P0)**, **High (P1)**, **Medium (P2)**, and **Low (P3)**.
4. **Draft Code or Recommendations**: Provide copy-pasteable Next.js 14+ components or configuration files.
5. **Ask for Approval**: Follow the studio 5-step collaborative loop before writing to disk: `"May I write this to [filepath]?"`
