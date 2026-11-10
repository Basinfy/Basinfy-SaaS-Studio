---
name: saas-seo-sxo
description: "Diagnose and optimize Search Experience Optimization (SXO) for SaaS — identify SERP intent mismatches, align page types (tools vs blogs vs product landing pages), and eliminate conversion friction."
argument-hint: "<url> [keyword]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-sxo/../../hooks/yaml-helper.sh" resolve_config *)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Search Experience Optimization (SXO) for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

SXO bridges technical SEO and UX conversion. A page can score 100 on PageSpeed and technical SEO, yet fail completely if it delivers the wrong page type for the searcher's intent.

---

## 1. The Core SXO Insight

If Google's SERP for a target keyword awards 8 interactive calculator tools and 2 comparison matrices, an informational 3000-word blog post will almost never achieve a top rank. SXO detects this mismatch and guides the creation of the correct user-facing experience.

---

## 2. Page-Type Mismatch Diagnostic Matrix

| Target Page Type | SERP Consensual Type | Severity | Actionable SaaS Solution |
|---|---|---|---|
| Blog Post | Interactive Tool / Calculator | **CRITICAL** | Build interactive Next.js micro-tool component |
| Blog Post | Feature Comparison ("X vs Y") | **HIGH** | Restructure into comparison page with matrix |
| Product Landing Page | Educational / Informational Guide | **HIGH** | Add educational walkthrough / explainer section |
| Generic Homepage | Specific Solution / Integration | **MEDIUM** | Create dedicated landing page for integration |
| Page Matches SERP | Page Matches SERP | **ALIGNED** | Focus on Core Web Vitals, speed, and CTA friction |

---

## 3. SaaS Conversion Friction Reduction (Time-to-Value)

Audit the landing experience for signup barriers:
1. **Interactive Demo / Playground**: Allow prospective users to experience core value before requiring authentication.
2. **Above-the-Fold Friction**: Ensure primary value proposition, pricing preview, and frictionless CTA ("Start Free Trial", "Try Demo") are visible without scrolling.
3. **Pogo-Sticking Prevention**: Provide immediate answers to the search query within the first 5 seconds to reduce immediate bounce back to the search results.
