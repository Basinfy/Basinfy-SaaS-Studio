> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DS-DESIGN-TOKENS — Design Tokens & UI System Sign-Off

Agent: `design-system-director` | Model tier: session (inherit) | Domain: Design tokens, color palettes, typography, spacing, semantic themes, accessibility

**Trigger**: After design system tokens are drafted (`/saas-design-system`, `/saas-asset-spec`), before UI component implementation begins

**Context to pass**:
- Design tokens path (`design/tokens/tokens.json`, `design/tokens/typography.md`, `tailwind.config.*`)
- Product pillars and brand identity statement
- WCAG 2.2 AA accessibility requirements and contrast targets
- Target platforms and responsiveness breakpoints (mobile, tablet, desktop)

**Prompt**:
> "Review these design system tokens and styling guidelines for completeness, semantic structure, and accessibility. Are color scales properly defined with light/dark mode semantic tokens? Does the typography scale follow a consistent modular ratio? Are spacing units standardized on a 4px/8px grid? Do color pairings satisfy WCAG 2.2 AA contrast ratios (4.5:1 for normal text, 3:1 for large text and UI components)? Are there ambiguous token names or missing interactive states (hover, active, focus-visible, disabled)? Return READY (tokens are production-ready), CONCERNS [specific tokens needing adjustment], or NOT READY [missing critical scales or accessibility violations]."

**Verdicts**: READY / CONCERNS / NOT READY
