---
name: saas-design-tokens
description: "Author the Design Tokens & Semantic UI Spec — visual identity, color scales, typography, and component styling gating UI production. Run before /saas-map-features."
argument-hint: "[--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-design-tokens/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation,workflow,docs.density`

Resolved above — use as-is; `--review` overrides `review_mode`. No block →
defaults in `.claude/docs/config-resolution.md`.

# Design Tokens & Semantic UI Spec

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

The **Design Tokens & Semantic UI Spec** establishes the foundational design language,
semantic color system, typography scale, spacing tokens, and component styling for the entire
SaaS application. It gates all UI and frontend asset development.

---

## Phase 0: Parse Arguments and Context Check

Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`docs.density`**: controls per-section depth:
- `terse` (minimal rigor) = bulleted tokens and values with concise rationale
- `balanced` (standard rigor) = token tables with component usage guidance
- `thorough` (high rigor) = full visual rationale, accessibility contrast calculations, and CSS code blocks

**`workflow`**:
- `full` — all 8 design token sections required.
- `standard` — sections 1–4 required; sections 5–8 as appropriate for the scope.
- `minimal` — core tokens (colors, typography, spacing).

**Context Check**:
Read `design/product-concept.md` or `design/product-brief.md`. If neither exists, prompt:
> "No product concept found. Run `/saas-brainstorm` first to establish product pillars and target audience."

---

## Phase 1: Framing

Identify the product's primary design direction:
1. **Target Audience & Market**: B2B enterprise, developer tool, consumer SaaS, fintech, or creator economy.
2. **Visual Archetype**:
   - *Technical / Utilitarian*: Monospace accents, high-contrast borders, dense grids (e.g. Linear, Vercel, Supabase).
   - *Minimalist / Swiss*: Strong typography, generous white space, restrained palette (e.g. Notion, iA Writer).
   - *Enterprise / Polished*: Accessible neutrals, prominent brand accent, structured tables (e.g. Stripe, Salesforce).
   - *Friendly / Modern*: Soft curves, vibrant accents, micro-illustrations (e.g. Loom, Slack, Mailchimp).

---

## Phase 2: Core Token Foundation (Sections 1–4)

### Section 1: Design Philosophy & Personality
Define 3-4 visual design principles (e.g., "Clarity over Decoration", "Speed in Every Interaction", "Calm and Focused Workspaces").

### Section 2: Semantic Color System
Define hex, HSL, or OKLCH values for:
1. **Primitives**: Neutral scale (50 to 950), Brand primary scale (50 to 950).
2. **Semantic Tokens (Light & Dark themes)**:
   - `background` and `foreground`
   - `card`, `card-foreground`
   - `popover`, `popover-foreground`
   - `primary`, `primary-foreground`
   - `secondary`, `secondary-foreground`
   - `muted`, `muted-foreground`
   - `accent`, `accent-foreground`
   - `destructive`, `destructive-foreground`
   - `border`, `input`, `ring`
   - `status`: Success (green), Warning (amber), Error (red), Info (blue).
3. **Contrast Validation**: Verify all text on background pairings satisfy WCAG 2.2 AA (minimum 4.5:1 for normal text, 3:1 for large text).

### Section 3: Typography System
Define font stacks and scales:
1. **Font Families**:
   - Sans: Primary UI font (e.g. Inter, Geist, Plus Jakarta Sans, system-ui).
   - Mono: Code and numeric tables (e.g. Geist Mono, JetBrains Mono).
2. **Type Scale**:
   - `xs`: 12px / 16px line-height
   - `sm`: 14px / 20px line-height (standard body)
   - `base`: 16px / 24px line-height (lead body)
   - `lg`: 18px / 28px line-height
   - `xl`: 20px / 28px line-height (H4)
   - `2xl`: 24px / 32px line-height (H3)
   - `3xl`: 30px / 36px line-height (H2)
   - `4xl`: 36px / 40px line-height (H1)
3. **Font Weights**: Regular (400), Medium (500), Semibold (600), Bold (700).

### Section 4: Spacing, Grid & Elevation
1. **Spacing Scale**: 4px base (4, 8, 12, 16, 24, 32, 48, 64px).
2. **Radius Tokens**: `radius-sm` (4px), `radius-md` (8px), `radius-lg` (12px), `radius-xl` (16px), `radius-full` (9999px).
3. **Elevation & Shadows**: `shadow-xs`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-modal`.
4. **Z-Index Scale**: Base (0), Dropdown (50), Sticky (100), Modal Backdrop (200), Modal (201), Toast (300).

---

## Phase 3: Component Systems & Standards (Sections 5–8)

### Section 5: Component Styling & Variants
Specify visual standards for core UI building blocks:
- **Buttons**: Primary (solid brand), Secondary (outline), Ghost, Destructive, Link. All states: default, hover, active, focus-visible, disabled, loading (with spinner).
- **Inputs & Forms**: Focus rings, error borders, floating labels, helper text styling.
- **Badges & Tags**: Status pills (Success, Warning, Info, Neutral) with consistent padding and typography.
- **Cards & Containers**: Surface colors, border contrast, subtle hover lifts.

### Section 6: Iconography & Visual Assets
1. **Icon Set**: Selected library (e.g. Lucide React, Heroicons, Radix Icons).
2. **Stroke Width & Sizes**: 16px (inline/small), 20px (standard UI), 24px (features/large).
3. **Empty State & Marketing Visuals**: Style guide for empty state illustrations, avatars, and hero graphics.

### Section 7: Navigation & App Shell Tokens
1. **Sidebar Tokens**: Background, active route highlight, collapsed icon rail width (64px), expanded width (240px).
2. **Topbar Tokens**: Height (56px/64px), border color, backdrop blur (`backdrop-blur-md`).
3. **Command Palette (`Cmd+K`)**: Modal overlay blur, search item highlight token, shortcut badge styling.

### Section 8: Web Asset Standards & Export Formats
1. **File Format Rules**:
   - Vector icons & logos: SVG (optimized with SVGO, remove hardcoded dimensions/fills).
   - Product screenshots & graphics: WebP / AVIF (fallback PNG).
   - Fonts: WOFF2 with `font-display: swap`.
2. **File Size Budgets**:
   - SVGs: < 30KB
   - Product images / banners: < 200KB
   - Total initial CSS bundle: < 50KB gzipped
3. **Code Export**:
   - Generate Tailwind config tokens (`tailwind.config.ts`) or CSS variables (`globals.css`).

---

## Phase 4: Save & Export

Write the completed specification to `design/ui/design-tokens.md` (and generate `src/styles/tokens.css` or Tailwind theme values if source directory exists).

---

## Phase 5: Design System Director Sign-Off

Execute review check with `design-system-director` agent:
1. Are all color pairings accessible (WCAG 2.2 AA compliant)?
2. Is the type scale cohesive with appropriate line heights?
3. Are light and dark theme tokens fully balanced?

Output Verdict:
- **APPROVED**: Design tokens complete and approved for UI production.
- **NEEDS REVISION**: List exact token discrepancies to resolve.
