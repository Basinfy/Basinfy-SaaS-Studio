---
name: saas-seo-technical
description: "Audit technical SEO for SaaS across 9 categories — crawlability, indexability, Next.js SSR/SSG rendering, robots.txt AI bot policies, 2MB Googlebot cap, Core Web Vitals, security headers, and IndexNow."
argument-hint: "[url]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-technical/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Technical SEO Audit for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Audits technical SEO fundamentals for modern cloud applications, single-page apps (SPAs), and Next.js 14+ App Router architectures.

---

## The 9 Technical Categories

1. **Crawlability & Bot Governance**:
   - `robots.txt`: Exists, valid syntax, reachable at root.
   - Distinct AI crawler rules: Distinguish training crawlers (`GPTBot`, `ClaudeBot`, `Bytespider`, `Google-Extended`) from search citability crawlers (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`).
   - 2MB HTML Cap: Ensure initial uncompressed HTML is strictly < 2MB (Googlebot limit; avoid bloated inline base64 or CSS).

2. **Indexability & Meta Directives**:
   - Canonical tags: Self-referential, absolute URLs, no contradictory `noindex` directives.
   - Meta robots: Enforce `index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1`.

3. **Rendering & JavaScript Architecture**:
   - Verify critical content and JSON-LD are delivered in initial server-rendered HTML (Next.js SSR/SSG).
   - Ensure crawlers without full headless JS capabilities do not encounter empty `<div id="__next">` shells.

4. **URL Hierarchy & Slugs**:
   - Clean, lowercase, hyphenated URL paths.
   - Trailing slash consistency. Avoid unmanaged query parameter bloat.

5. **XML Sitemaps**:
   - Valid XML sitemap or Next.js `app/sitemap.ts` dynamic generator.
   - Sitemaps listed in robots.txt. Large sites (>50k URLs) properly partitioned via sitemap index.

6. **Core Web Vitals & Performance**:
   - Largest Contentful Paint (LCP) < 2.5s.
   - Cumulative Layout Shift (CLS) < 0.1.
   - Interaction to Next Paint (INP) < 200ms.
   - Time to First Byte (TTFB) < 800ms.

7. **Mobile Responsiveness & Viewport**:
   - Valid `<meta name="viewport" content="width=device-width, initial-scale=1">`.
   - Touch targets >= 48px, readable typography, no horizontal scroll.

8. **Security & Transport**:
   - Enforce HTTPS with strict TLS 1.3/1.2.
   - HSTS (`Strict-Transport-Security`), `X-Content-Type-Options: nosniff`, and secure CSP.

9. **Fast Indexation & Discovery (IndexNow)**:
   - Instant notification of published/updated URLs via IndexNow API for Bing and Yandex.

---

## Tool Execution

```bash
python scripts/seo/parse_html.py <url> --json
python scripts/seo/sitemap_discovery.py <url> --json
python scripts/seo/pagespeed_check.py <url>
```
