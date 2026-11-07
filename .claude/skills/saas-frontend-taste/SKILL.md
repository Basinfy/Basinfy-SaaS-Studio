---
name: saas-frontend-taste
description: "Anti-slop frontend & UI design engineering — enforces Figma/x.ai quality bar, screen-by-screen layout (1440x900), anti-slop copy linting, curated palettes/typography, real product UI fragments, and headless browser verification."
argument-hint: "[screen or feature path] [--page software|tech|product|service] [--check] [--deal]"
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

Build the website and application interfaces a high-caliber company would ship: plain copy in a voice of its own, one system, one section per screen (1440x900 desktop viewport), equal left and right edges, real photographs and real product UI fragments (code diffs, interactive cards, terminal runs, live data), a hero entrance and dealt moments, quiet micro-interactions (2px card hover, 1.02 zoom on images), canvas-effect effects strictly reserved for tech/devtools/fintech/devtools, and an automated headless browser checker (`consistency.mjs`) and copy linter (`copy-lint.mjs`) verifying quality before shipping.

---

## The 9 Anti-Slop House Rules

These 9 core principles override generic frontend patterns:

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

## Phase 0: Context & Trade Classification

Determine the business archetype to calibrate the design tokens, layout, and visual assets:

| Trade Kind | Target | Visual Focus | Allowed Visuals |
|---|---|---|---|
| `software` | SaaS, AI, DevTools, Fintech | Live app frames, code diffs, terminal outputs, pipeline boards | Card loops, pulsing diagrams, 1 canvas-effect ground |
| `tech` / `hardware` | Devices, Robotics, Physical Tech | Physical hardware photography, schematics, bench photos | Explosive views, CAD renders, 1 canvas-effect ground |
| `product` | Consumer products, physical goods | High-end product photography, material swatches | Curated photos, swatch selectors, zero WebGL |
| `service` | Agencies, Consultancies, Clinics | Real team portraits, client casework, clear service list | Photography, typography moments, zero WebGL |

---

## Phase 1: Deal Tokens & Layout

Run the layout and token engine to generate the page foundation:

1. **Color & Typography**:
   - Read `library/palettes.json` and select or deal a trade-calibrated palette (`bg`, `surface`, `ink`, `muted`, `accent`, `accentInk`).
   - Read `library/type.json` and deal a typography pairing with exact tracking, weights, and Google Fonts links.
2. **Hero Layout Selection**:
   - Choose one of 11 tested hero layouts from `assets/layout/heroes.json`:
     - `split`: Headline + CTA on left, live product UI on right.
     - `centred`: Centered headline with full-width product UI frame underneath.
     - `product`: Giant product showcase with floating feature annotations.
     - `photo`: Full-bleed photographic background with crisp typographic contrast.
     - `statement`: Oversized typographic assertion with compact live ticker.
     - `triptych`: Three synchronized vertical panels showing product workflow.

---

## Phase 2: Assemble Real UI Fragments & Diagrams

For SaaS and Software applications, populate cards with real HTML/CSS components from `assets/ui/` and `assets/diagrams/`:

- **Code Review & Diff**: `assets/ui/diff-review` (interactive red/green line diffs with status badges).
- **Terminal Runner**: `assets/ui/terminal-run` (live CLI simulation with command prompts).
- **Kanban Pipeline**: `assets/ui/pipeline-board` (drag-ready status columns).
- **Metrics & Telemetry**: `assets/ui/stat` (KPI cards with trend indicators).
- **Interactive Diagrams**: `assets/diagrams/` (multi-stage pipelines with pulsing SVG connection lines).

---

## Phase 3: Automated Quality Gate Verification

Before delivering any frontend page or view, run the automated verification suite:

1. **Copy Lint**:
   ```bash
   node .claude/skills/saas-frontend-taste/scripts/copy-lint.mjs <target-page.html> --kind software
   ```
   Ensures zero FAIL status for AI buzzwords, residue markdown, or text budget violations.

2. **Multi-Viewport Consistency Checker**:
   ```bash
   node .claude/skills/saas-frontend-taste/scripts/consistency.mjs <target-page.html> --page software
   ```
   Validates in headless Chromium across 1440px, 1024px, 820px, 768px, and 390px for:
   - Section height conformity (`100svh`, `--h: 1`, `--h: 2`)
   - Zero empty visual wrappers (`[data-visual]`)
   - WCAG 2.2 AA contrast ratios
   - Equal horizontal padding and margin balance

---

## Phase 4: Sign-Off and Handoff

Deliver the verified frontend view along with:
1. Palette and font token summary.
2. Copy linter audit report (0 slop words detected).
3. Headless consistency check results (PASS across all 5 viewports).
4. Suggested next steps: `/saas-team-polish` for micro-interaction fine-tuning or `/saas-dev-story` for story completion.
