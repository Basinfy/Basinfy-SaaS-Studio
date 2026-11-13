---
name: saas-team-polish
description: "Orchestrate the polish team — web-perf-analyst, ui-motion-designer, frontend-engineer, qa-manual-tester — Core Web Vitals, micro-interactions, loading states, and UI polish."
argument-hint: "[area or feature to polish] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Polish & Performance

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the specialized polish team to elevate software quality through Core Web Vitals optimization,
tasteful micro-animations, loading skeletons, accessible focus states, and responsive edge-case hardening.

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-polish [area or feature description] [--review full|lean|solo]` — Describe the area to polish (e.g. Dashboard load performance and skeletons, App shell responsive transitions, Data table hover states and keyboard navigation, Core Web Vitals pass)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **Performance & Audit Phase**:
   - `web-perf-analyst`: Measure initial metrics (Lighthouse score, initial JS bundle size, Largest Contentful Paint, Cumulative Layout Shift)
   - Profile slow database queries or unmemoized React component re-renders

2. **Micro-Interactions & Loading States**:
   - `ui-motion-designer`: Design subtle, high-end motion following `/saas-frontend-taste` quiet standards:
     - 2px hover lifts on cards (`translateY(-2px)`), 1.02x image zoom inside frames
     - Card loop cycles in 2.5–4.0s with hover pause/restart; button active press states
     - Dealt moments (cursor spotlight, animated counters, text reveals)
     - Route transitions (instant fade, no jarring flashes)
     - Skeleton loaders matching exact content layout
   - `ui-motion-designer`: Design subtle, high-end motion (framer-motion or CSS transitions):
     - Route transitions (instant fade, no jarring flashes)
     - Skeleton loaders matching exact content layout
     - Button active/loading spinner states
     - Drawer slide-over and modal backdrop blur

3. **Frontend Implementation & Hardening**:
   - `frontend-engineer`:
     - Apply dynamic imports (`next/dynamic` / lazy loading) to heavy modules (charts, rich text editors)
     - Eliminate Cumulative Layout Shift (reserve image dimensions, avoid late-injected fonts)
     - Harden dark mode color contrast and focus rings (`focus-visible:ring-2`)

4. **Cross-Browser & Device Verification**:
   - `qa-manual-tester`: Verify jank-free UI animations (fluid transitions without frame drops), mobile touch responsiveness, Safari rendering quirks, and reduced-motion fallback.

5. **Verdict**:
   - Output: **COMPLETE** — performance optimized and UI polished to enterprise standard.
