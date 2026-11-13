---
name: saas-seo-geo
description: "Audit and optimize SaaS content for AI Search engines (Google AI Overviews, Perplexity, ChatGPT Search, Claude, Gemini) — citability heuristics, brand authority correlation, crawler access, and structured answer blocks."
argument-hint: "[url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Generative Engine Optimization (GEO) for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

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
