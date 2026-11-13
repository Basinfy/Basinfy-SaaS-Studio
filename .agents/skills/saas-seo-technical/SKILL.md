---
name: saas-seo-technical
description: "Audit technical SEO for SaaS across 9 categories — crawlability, indexability, Next.js SSR/SSG rendering, robots.txt AI bot policies, 2MB Googlebot cap, Core Web Vitals, security headers, and IndexNow."
argument-hint: "[url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

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
   - Distinct AI crawler rules: Distinguish training crawlers (`GPTBot`, `ClaudeBot`, `Bytespider`, `Google-Extended`, `Applebot-Extended`, `CCBot`, `Amazonbot`) from search citability crawlers (`OAI-SearchBot`, `Claude-SearchBot`, `PerplexityBot`), and declare `Content-Signal` preferences (`ai-train`, `search`, `ai-input`).
   - RFC 8288 `Link` headers & DNS-AID: Return `Link` headers on homepage (`api-catalog`, `service-desc`, `service-doc`, `describedby`) and publish `_agents` `SVCB`/`HTTPS`/`TXT` DNS records where applicable.
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
