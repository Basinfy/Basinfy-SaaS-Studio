---
name: saas-frontend-taste
description: "Design, refine, and verify SaaS interfaces by screen purpose, preserving existing design systems and applying the landing-page kit where it fits."
argument-hint: "[screen or feature path] [--page software|tech|devtools|product|place|service] [--check] [--deal] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-frontend-taste/../../hooks/yaml-helper.sh" resolve_config *), Bash(node *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Frontend Taste & Anti-Slop Engineering Standard

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Apply the project's design system and choose checks that match what people need to do on the target screen.

## Phase 0: Resolve Product Context and Screen Purpose

Read the existing product brief (`design/product-brief.md` or `design/prd/product-concept.md`), the relevant `design/ux/` spec, and `design/ui/design-tokens.md` when available. Inspect the target route and its shared components. Use the user's brief and existing conventions for missing context. Record the audience, main task, and constraints in the handoff or existing UX spec. Surface material conflicts between documented tokens and implementation before changing shared styles.

| Purpose | Examples | Design and verification priorities |
|---|---|---|
| Persuade | Landing page, campaign, pricing | Clear offer, decision path, credible proof, responsive calls to action. Use the landing kit for new pages or existing pages that follow its layout. |
| Operate | Dashboard, billing settings, checkout, admin | Task completion, density, permissions, keyboard and focus, loading/empty/error states, recovery and long or localized data. |
| Read | Docs, help center, policy pages | Heading structure, readable measure, navigation, link clarity, zoom and reflow, wrapping for tables and code. |
| Experience | Gallery, portfolio, showcase | Media quality and fallback, responsive composition, navigation, reduced motion and performance. |

Classify by the primary user task. For a mixed page, apply other priorities to individual sections where useful. `--page` selects the trade for the landing kit and its scripts. It does not select the screen purpose. `--deal` applies only to a new or explicitly redesigned landing-kit page that needs a palette or type pairing. For existing interfaces, start with established tokens and primitives.

For a non-kit interface, proceed directly to Phase 3 after design or implementation. For `--check`, review the existing target without modifying its source and go directly to Phase 3.

---

## The 9 Landing Kit Rules

Apply these conventions to landing-kit pages. Keep meaningful captions, instructions and status text where people need them, and honor approved content and accessibility requirements.

1. **No Captions or Explanatory Subtitles Under Visuals**: Images, renders, and UI frames speak for themselves. License credits go in a single footer line.
2. **Every Visual Must Render (Zero Empty Ground)**: Renders flawlessly across all 5 viewports: 1440px (desktop), 1024px (landscape tablet), 820px (portrait tablet), 768px (standard tablet), and 390px (mobile).
3. **One Section per Screen**: The hero stands alone on the first screen (`100svh` at 1440x900). Every subsequent section is exactly 1 or 2 screens tall. No second section heading peeking into the viewport.
4. **Equal Left and Right Content Margins**: Strict horizontal balance across the grid container (`.wrap`).
5. **Quiet Micro-Interactions**:
   - Linked cards lift 2px on hover (`translateY(-2px)`).
   - Photographs zoom 1.02–1.03x inside their overflow-hidden frames.
   - Buttons step on hover and depress on click.
   - Card loops cycle smoothly in 2.5–4.0s and pause/restart on hover.
   - Banned: 3D nauseating tilt cards, erratic floating blobs, generic auto-playing carousels.
6. **Real Product UI & Real Photography**:
   - Software/Tech leads with live HTML product fragments (code diffs with accept actions, terminal outputs, pipeline boards, metrics cards) and pulsing node-and-line diagrams.
   - Never use generic stock cartoons, floating 3D isometric purple people, or abstract placeholder vectors.
7. **Curated Full-Color Brand Icons**: Real developer and partner SVGs; never draw fake stylized icons for recognizable technologies.
8. **Effects Strictly Capped by Trade**:
   - WebGL canvas-effects and complex particle grounds are permitted ONLY for technical subjects (`software`, `tech`, `devtool`, `fintech`, `devtools`).
   - Consumer goods, professional services, agencies, and places use flat color, curated photography, and refined typography—zero WebGL.
9. **Anti-Slop Copy Standard**:
   - Strictly ban AI clichés: *"Unleash"*, *"Supercharge"*, *"Seamless"*, *"Next-gen"*, *"Revolutionize"*, *"Elevate"*, *"Delve"*, *"App-changer"*.
   - Target 60–80 words per screen outside live UI mocks.
   - Specific numbers, facts, and customer actions over marketing fluff.

---

## Phase 1: Classify the Landing Kit Trade

Determine the business archetype to calibrate the design tokens, layout, and visual assets:

| Trade Kind | Target | Visual Focus | Allowed Visuals |
|---|---|---|---|
| `software` | SaaS, AI, DevTools, Fintech | Live app frames, code diffs, terminal outputs, pipeline boards | Card loops, pulsing diagrams, 1 canvas-effect ground |
| `tech` | Devices, Robotics, Physical Tech | Physical hardware photography, schematics, bench photos | Explosive views, CAD renders, 1 canvas-effect ground |
| `devtools` | Developer tools | Real workflows, terminals and code | Interactive demos, 1 canvas-effect ground |
| `product` | Consumer products, physical goods | High-end product photography, material swatches | Curated photos, swatch selectors, zero WebGL |
| `service` | Agencies, Consultancies, Clinics | Real team portraits, client casework, clear service list | Photography, typography moments, zero WebGL |
| `place` | Venues and destinations | Photography, directions and key visitor information | Photography, maps, zero WebGL |

---

## Phase 2: Choose Landing Kit Tokens, Layout and Visuals

Run the layout and token engine to generate the page foundation:

1. **Color & Typography**:
   - Reuse the approved design tokens. When the brief calls for a new direction, use `library/palettes.json` and `library/type.json`, or run `node <skill-dir>/scripts/start.mjs deal --page <kind> --trade <trade>` to generate options. `--deal` records local kit state.
2. **Hero Layout Selection**:
   - Choose one of 11 tested hero layouts from `assets/layout/heroes.json`:
     - `split`: Headline + CTA on left, live product UI on right.
     - `centred`: Centered headline with full-width product UI frame underneath.
     - `product`: Giant product showcase with floating feature annotations.
     - `photo`: Full-bleed photographic background with crisp typographic contrast.
     - `statement`: Oversized typographic assertion with compact live ticker.
     - `triptych`: Three synchronized vertical panels showing product workflow.

---

### Assemble Real UI Fragments & Diagrams

For SaaS and Software applications, populate cards with real HTML/CSS components from `assets/ui/` and `assets/diagrams/`:

- **Code Review & Diff**: `assets/ui/diff-review` (interactive red/green line diffs with status badges).
- **Terminal Runner**: `assets/ui/terminal-run` (live CLI simulation with command prompts).
- **Kanban Pipeline**: `assets/ui/pipeline-board` (drag-ready status columns).
- **Metrics & Telemetry**: `assets/ui/stat` (KPI cards with trend indicators).
- **Interactive Diagrams**: `assets/diagrams/` (multi-stage pipelines with pulsing SVG connection lines).

---

## Phase 3: Critique and Verify the Rendered Screen

**Design critique.** Walk through the main user task. Evaluate hierarchy, action clarity, feedback and consistency against that task and the project's design system. For each issue, describe what the user encounters, the impact and the smallest useful change. Prioritize a focused refinement such as layout, copy, typography or interaction states.

**Technical audit.** Open the actual route or built artifact. Use the project's browser and accessibility tooling when available. Check relevant viewports, keyboard navigation, visible focus, accessible names, contrast, zoom and reflow. Exercise applicable loading, empty, error and success states and check long/localized content, themes and reduced motion when supported. Check performance with the project's existing tools when media, animation or large datasets are material. Use fixtures or a local test environment for actions that write data.

For landing-kit pages, run these checks from the active skill directory (`.claude/skills/saas-frontend-taste` or its `.agents/skills/` mirror). Substitute the resolved trade for `<kind>`:

1. **Copy Lint**:
   ```bash
   node <skill-dir>/scripts/copy-lint.mjs <rendered-page.html> --kind <kind>
   ```
   Use visitor-facing HTML or copy, including rendered HTML for client-rendered pages. Report unsupported copy checks as not assessed. Treat copy heuristics as review signals when the locale or context is outside their intended coverage.

2. **Multi-Viewport Consistency Checker**:
   ```bash
   node <skill-dir>/scripts/consistency.mjs <local-url-or-built-html> --page <kind>
   ```
   Validates in headless Chromium across 1440px, 1024px, 820px, 768px, and 390px for:
   - Section height conformity (`100svh`, `--h: 1`, `--h: 2`)
   - Zero empty visual wrappers (`[data-visual]`)
   - Contrast findings to verify against WCAG 2.2 AA
   - Equal horizontal padding and margin balance

---

The kit checks enforce landing-page conventions. Use the project's own technical checks for other interfaces, including dashboards and docs. Browser probes are evidence for the checks they executed. Report skipped probes and unavailable states explicitly.

## Phase 4: Sign-Off and Handoff

Deliver the verified frontend view along with:
1. Screen purpose, primary task and relevant design tokens.
2. Prioritized design findings and technical findings. Include route, viewport or state, evidence and suggested fix. Treat a blocked primary task or accessibility failure as a blocker.
3. Actual commands and browser coverage, with a verdict of **PASS**, **FAIL** or **NOT ASSESSED**. Use **FAIL** for known blockers and **NOT ASSESSED** when required verification could not run. Recheck fixed findings on the same route, viewport and state.
4. Suggested next steps: `/saas-team-polish` for micro-interaction fine-tuning or `/saas-dev-story` for story completion.

The screen-purpose and critique/audit approach is adapted from [Impeccable](https://impeccable.style/docs/).
