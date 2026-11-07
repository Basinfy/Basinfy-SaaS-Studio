# Skill Test Spec: /saas-frontend-taste

## Skill Summary

`/saas-frontend-taste` enforces anti-slop frontend and UI design engineering standards across the SaaS product. It establishes visual excellence matching benchmark platforms like Figma, Linear, Stripe, and x.ai.

It applies the 9 Anti-Slop House Rules:
1. No captions or explanatory subtitles under visuals.
2. Every visual renders (zero empty ground) across 5 viewports (1440px, 1024px, 820px, 768px, 390px).
3. One section per screen (1440x900 desktop viewport, `100svh`).
4. Equal left and right content margins.
5. Quiet micro-interactions (2px hover lift, 1.02x image zoom inside frames, button press steps).
6. Real product UI fragments (code diffs, interactive cards, terminal runs, live data) and pulsing node-and-line diagrams.
7. Curated full-color brand icons.
8. Effects strictly capped by trade (WebGL/canvas-effects tech-only).
9. Anti-slop copy standard banning marketing buzzwords (*seamless*, *unleash*, *supercharge*, *next-gen*) and targeting 60–80 words per screen.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Enforces anti-slop house rules and copy linter integration (`copy-lint.mjs`)
- [ ] Enforces multi-viewport consistency checker (`consistency.mjs`)
- [ ] Documents trade kinds (`software`, `tech`, `product`, `service`)
- [ ] Has a next-step handoff (e.g., `/saas-team-polish`, `/saas-dev-story`)

---

## Quality Gate Checks

- Verifies zero empty visual containers
- Validates WCAG 2.2 AA contrast ratios
- Enforces strict 60–80 words per screen outside live UI mocks
