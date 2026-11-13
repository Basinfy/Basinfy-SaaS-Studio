# Skill Test Spec: /saas-team-polish

## Skill Summary

Orchestrates the polish team:
Core Web Vitals profiling (web-perf-analyst) → micro-animations and loading skeletons (ui-motion-designer)
→ CSS hardening, contrast, and focus states (frontend-engineer) → cross-browser verification (qa-manual-tester).
Verdict is COMPLETE when performance is optimized and UI is polished.

---

## Static Assertions (Structural)

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 step/phase headings
- [ ] Contains verdict keywords: COMPLETE
- [ ] Spawns web-perf-analyst, ui-motion-designer, frontend-engineer, or qa-manual-tester
