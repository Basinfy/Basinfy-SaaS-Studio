---
name: saas-seo-geo
description: "Optimize SaaS pages for AI Overviews, ChatGPT Search, Perplexity, and Claude citations."
argument-hint: "[url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Generative Engine Optimization (GEO) for SaaS

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


Optimizes SaaS landing pages, documentation, and product guides for citability across generative answer engines (Google AI Overviews, ChatGPT Search, Perplexity, Claude, Gemini).

---

## 1. Core Principles from Google AI Optimization Guide

1. **AI Optimization is Still SEO**: Generative models cite pages that are fast, accessible, authoritative, and indexable.
2. **Brand Mentions Correlate 3x Stronger with AI Citations than Backlinks**:
   - YouTube presence & video transcript mentions: ~0.737 correlation.
   - Reddit community discussions & reviews: High correlation.
   - Wikipedia / Wikidata entity entries: High correlation.
   - LinkedIn corporate & founder presence: Moderate correlation.
   - Backlink Domain Rating (DR): ~0.266 (weak correlation).

---

## 2. Citability Heuristics & Content Architecture

1. **Front-Loaded Citable Blocks**:
   - 44% of AI citations originate in the top 30% of page content.
   - Place self-contained answer blocks in the opening fold.
2. **Block Geometry (130-170 Words)**:
   - Self-contained units that can be cited without lost context.
   - Direct definition in the first 40-60 words: `"X is [definition] that enables [outcome] by [mechanism]..."`.
3. **Factual Grounding & Verifiable Data**:
   - Attribute facts to clear primary sources.
   - Avoid vague marketing jargon ("best-in-class", "revolutionary"). Use concrete numbers, metrics, latency benchmarks, or pricing.

---

## 3. AI Crawler Access Matrix

Ensure `app/robots.ts` explicitly grants access to AI search engines while protecting private SaaS endpoints:

| Crawler | Purpose | Recommended Policy |
|---|---|---|
| `OAI-SearchBot` | ChatGPT Search Indexing | **Allow** on public marketing/docs |
| `Claude-SearchBot` | Claude Search Citability | **Allow** on public marketing/docs |
| `PerplexityBot` | Perplexity Indexing | **Allow** on public marketing/docs |
| `GPTBot` | OpenAI Model Training | Disallow if training opt-out desired |
| `ClaudeBot` | Anthropic Model Training | Disallow if training opt-out desired |
| `Google-Extended` | Gemini Model Grounding | Disallow if training opt-out desired |

---

## 4. Execution Workflow

1. Fetch target URL using `python scripts/seo/parse_html.py <url> --json`.
2. Evaluate heading hierarchy (H1 -> H2 -> H3) and answer front-loading.
3. Compute citability score based on self-contained block density and factual precision.
4. Deliver concrete rewritten copy blocks formatted as high-citability snippets.
