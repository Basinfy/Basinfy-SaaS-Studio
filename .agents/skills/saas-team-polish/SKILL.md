---
name: saas-team-polish
description: "Orchestrate Core Web Vitals, motion restraint, UI contrast, and edge-case polish."
argument-hint: "[area or feature to polish] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Polish & Performance

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


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
