> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DS-PHASE-GATE — Design System Phase Transition Sign-Off

Agent: `design-system-director` | Model tier: session (inherit) | Domain: UI system maturity, token coverage, accessibility compliance, visual polish

**Trigger**: Phase transition check (`/saas-gate-check`)

**Context to pass**:
- Current project stage (`project.stage` in `project.yaml`)
- Target phase requirements from `.claude/docs/workflow-catalog.yaml`
- Component library status and design token adoption across `src/components/`
- Visual audit reports and WCAG compliance logs

**Prompt**:
> "Evaluate whether the design system and UI components meet the entry criteria for the target phase. For systems-design to technical-setup: Are core tokens defined and theme-switchable? For pre-production to production: Are foundational UI components (Button, Input, Modal, Table, Toast) implemented with accessible keyboard navigation? For production to polish/release: Are all screens free of raw CSS/hardcoded colors, and has WCAG AA compliance been audited? Return READY (design criteria met for target phase), CONCERNS [non-blocking visual issues to fix], or NOT READY [blocking design deficits]."

**Verdicts**: READY / CONCERNS / NOT READY
