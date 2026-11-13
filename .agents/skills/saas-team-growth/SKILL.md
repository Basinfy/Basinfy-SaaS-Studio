---
name: saas-team-growth
description: "Orchestrate the growth & acquisition team — growth-director, ux-content-strategist, frontend-engineer, data-telemetry-engineer — landing page, SEO, tracking, and viral loops."
argument-hint: "[growth initiative description] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Growth & Acquisition

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the growth engineering team to build high-converting landing pages, programmatic SEO,
analytics instrumentation, lead capture, and referral loops.

**Argument check:** If no growth initiative description is provided, output:
> "Usage: `/saas-team-growth [initiative description] [--review full|lean|solo]` — Describe the acquisition or conversion feature you want to build (e.g. Landing Page redesign, Onboarding funnel optimization, Referral invite loop, Programmatic SEO directory)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **Strategy & Copy Phase**:
   - `growth-director`: Map the conversion funnel and plan keyword architecture, metadata, Open Graph tags, structured data, and the sitemap.
   - `ux-content-strategist`: High-converting headlines, value proposition hooks, social proof, and primary CTAs

2. **Frontend & Interactive Experience**:
   - `frontend-engineer`: Implement responsive landing page, interactive product demo, newsletter/signup form
   - Optimize Core Web Vitals (LCP < 2.5s, CLS = 0, INP < 200ms)

3. **Analytics & Instrumentation**:
   - `data-telemetry-engineer`: Instrument tracking events (PostHog, Segment, Mixpanel, GA4)
   - Track key conversion milestones: page view, CTA click, signup started, signup completed

4. **Review & Validation**:
   - Verify lighthouse performance score (>90), mobile responsiveness, and form submission reliability.

5. **Verdict**:
   - Output: **COMPLETE** — growth initiative designed, implemented, and tracked.
