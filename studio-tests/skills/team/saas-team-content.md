# Skill Test Spec: /saas-team-content

## Skill Summary

Orchestrates the content and documentation team:
product microcopy and error states (ux-content-strategist) → transactional email sequences (ux-content-strategist)
→ OpenAPI reference and dev docs (technical-writer) → email template rendering (frontend-engineer).
Verdict is COMPLETE when content and documentation are authored and integrated.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE
- [ ] Spawns ux-content-strategist, ux-content-strategist, technical-writer, or frontend-engineer
