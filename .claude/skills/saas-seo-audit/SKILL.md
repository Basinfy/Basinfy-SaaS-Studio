---
name: saas-seo-audit
description: "Run a full SaaS platform SEO audit — technical crawlability, Next.js SPA rendering, Core Web Vitals, Schema.org rich results, AI search readiness (GEO), Agentic Browsing, and SXO conversion alignment."
argument-hint: "[url]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-audit/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS Platform Full SEO Audit

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Conducts an end-to-end, multi-vector SEO audit of a SaaS web application or staging server (`http://localhost:3000`).

---

## 1. Audit Pipeline

1. **URL Validation & Security Pre-Flight**:
   - Check target URL with `python scripts/seo/url_safety.py`. Ensure SSRF protection and DNS pinning are engaged.
   - If auditing local development environments, set `CLAUDE_SEO_LOCAL_TARGETS=localhost:3000`.

2. **Technical & Crawlability Evaluation**:
   - Fetch and parse target URL using `python scripts/seo/parse_html.py <url> --json`.
   - Verify robots.txt and XML sitemaps using `python scripts/seo/sitemap_discovery.py <url> --json`.
   - Check for Googlebot 2MB fetch cap violations (oversized inline CSS/JS or base64 images).

3. **Schema.org Structured Data Audit**:
   - Check JSON-LD blocks for SaaS entities: `SoftwareApplication`, `Organization`, `WebSite`, `Product`, `Offer`.
   - Enforce 2026 schema deprecation rules (flag retired `FAQPage` or `HowTo` rich results).

4. **AI Search (GEO) & Citability**:
   - Check for citable self-contained answer blocks (130-170 words answering query in first 40-60 words).
   - Evaluate front-loaded content density (44% of citations emerge from the top 30% of page).

5. **Agentic Browsing Readiness**:
   - Run `python scripts/seo/agentic_check.py <url> --json`.
   - Audit `llms.txt`, Markdown endpoints (`Accept: text/markdown`), `ai-catalog.json`, and WebMCP markup.
   - Run `python scripts/seo/lighthouse_agentic.py <url> --json` to compute the Lighthouse Agentic Browsing fraction (X/N).

6. **Search Experience (SXO) & Conversion Alignment**:
   - Detect page-type mismatches (e.g. informational blog posts ranking for transactional tool queries).
   - Audit time-to-value (TTV) and signup friction.

---

## 2. Output Format: Prioritized SaaS Action Plan

Structure the audit findings report into clear severity tiers:

```markdown
# SaaS SEO Health Report: [Target URL]

| Metric | Score / Status | Benchmark |
|---|---|---|
| Technical Crawlability | PASS / WARN | Clean robots.txt, 2MB cap respected |
| Schema.org JSON-LD | PASS / FAIL | Valid SoftwareApplication + Organization |
| Core Web Vitals (Lab) | Score (0-100) | LCP < 2.5s, CLS < 0.1, INP < 200ms |
| AI Search Citability (GEO) | High / Moderate | Self-contained 130-170w answer blocks |
| Lighthouse Agentic Browsing | X / N passed | Axe accessibility + llms.txt + WebMCP |

## P0 — Critical (Immediate Traffic / Crawl Loss Risk)
- [Issue description, evidence, exact Next.js code fix, verification step]

## P1 — High Impact (Search Visibility & GEO Citability)
- [Issue description, evidence, exact Next.js code fix, verification step]

## P2 — Medium Impact (Agent Readiness & SXO)
- [Issue description, evidence, recommendation]
```
