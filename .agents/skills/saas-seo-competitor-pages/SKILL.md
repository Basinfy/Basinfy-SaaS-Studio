---
name: saas-seo-competitor-pages
description: "Generate high-converting SaaS competitor comparison and alternatives pages — 'X vs Y', 'Alternatives to X', feature comparison matrices, pricing breakdowns, and SoftwareApplication schema."
argument-hint: "[url or generate] [competitor]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS Competitor Comparison & Alternatives Pages

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

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
