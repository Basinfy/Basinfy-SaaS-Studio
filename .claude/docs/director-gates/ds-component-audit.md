> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DS-COMPONENT-AUDIT — UI Component & Asset Production Quality Audit

Agent: `design-system-director` | Model tier: session (inherit) | Domain: Component visual quality, responsiveness, interactive feedback, bundle size

**Trigger**: After batch of UI components is completed (`/component-audit`, `/saas-design-review`), before release

**Context to pass**:
- Component library path (`src/components/ui/`)
- Asset bundle metrics (`public/`, icon bundles, SVGs)
- Visual test evidence or screenshot captures (`production/qa/evidence/`)

**Prompt**:
> "Review implemented UI components and asset bundles against design specifications. Do components render correctly across responsive breakpoints (375px, 768px, 1280px)? Are hover, focus-visible, and loading states visually distinct and smooth? Are SVG icons optimized (svgo) and properly sized without layout shift? Is the initial CSS/font bundle within the performance budget defined in `project.yaml`? Return PASS (components meet visual standards), CONCERNS [minor visual flaws], or FAIL [broken layouts, missing interactive states, or bundle size violations]."

**Verdicts**: PASS / CONCERNS / FAIL
