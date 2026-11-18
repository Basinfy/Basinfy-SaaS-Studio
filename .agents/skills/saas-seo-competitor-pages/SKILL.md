---
name: saas-seo-competitor-pages
description: "Design high-converting 'X vs Y' and alternatives SaaS comparison matrices."
argument-hint: "[url or generate] [competitor]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS Competitor Comparison & Alternatives Pages

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


Generates high-intent Bottom-of-Funnel (BOFU) comparison and alternatives pages targeting users searching for software solutions with active buying intent.

---

## 1. Page Architectures

1. **"X vs Y" Direct Comparison**:
   - URL: `/vs/[competitor]` (e.g. `/vs/heroku`, `/vs/aws-amplify`).
   - Keyword target: `[Our SaaS] vs [Competitor]`.
   - Balanced, objective comparison emphasizing unique architectural advantages.
2. **"Alternatives to X" Roundup**:
   - URL: `/alternatives/[competitor]` (e.g. `/alternatives/zapier`).
   - Keyword target: `best [competitor] alternatives`, `[competitor] open source alternatives`.
3. **Feature Matrix Roundup**:
   - URL: `/compare/[category]`.
   - Comprehensive multi-column feature tables with sort/filter controls.

---

## 2. High-Converting Comparison Matrix Structure

```markdown
| Critical Capability | Our SaaS | Competitor A | Competitor B |
|---|:---:|:---:|:---:|
| Next.js 14+ Native SSR | ✅ Full | ⚠️ Partial | ❌ None |
| Sub-50ms Global Edge | ✅ Distributed | ❌ Centralized | ⚠️ Add-on |
| Self-Hosted Option | ✅ MIT Core | ❌ Closed | ❌ Closed |
| Transparent Pricing | $49/mo flat | $120/seat | Quoted sales |
```

### Fact-Checking & Accuracy Mandate
- All competitor claims must reference public pricing or documentation as of a stated date (`"Data verified as of [Month Year]"`).
- Acknowledge where the competitor excels to preserve E-E-A-T credibility and avoid misleading claims.

---

## 3. Structured Data
Embed `SoftwareApplication` and `Product` schemas detailing category, pricing tiers, and capabilities to capture SERP product snippets.
