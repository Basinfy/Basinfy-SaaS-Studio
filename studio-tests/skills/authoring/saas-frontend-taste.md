# Skill Test Spec: /saas-frontend-taste

## Skill Summary

`/saas-frontend-taste` adapts frontend design and verification to the screen's primary task. It preserves existing tokens and applies the landing-kit layout and copy conventions where they fit.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Resolves the primary task from existing product, UX and token documents when available.
- [ ] Distinguishes screen purpose from the landing-kit trade.
- [ ] Scopes `copy-lint.mjs` and `consistency.mjs` to landing-kit pages.
- [ ] Has a next-step handoff (e.g., `/saas-team-polish`, `/saas-dev-story`)

---

## Quality Gate Checks

- A new kit landing page uses its trade and checks the rendered page across five viewports.
- A billing settings screen keeps approved tokens and checks keyboard, failure and recovery states without applying full-screen section rules.
- A documentation page checks headings, navigation and reflow without requiring a hero or imagery.
- An unreachable route produces `NOT ASSESSED` when no blocker is already known. `--check` leaves target source intact.
