---
name: saas-seo-drift
description: "SEO drift and regression monitoring — Git for SEO. Capture SQLite baselines, detect regressions across deployments, and enforce 17 automated comparison rules in CI/CD pipelines."
argument-hint: "baseline|compare|history <url>"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-drift/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SEO Drift & Regression Monitor for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Provides automated regression protection for on-page SEO state across SaaS application builds and production deployments.

---

## 1. Commands

| Command | Action |
|---|---|
| `/saas-seo-drift baseline <url>` | Capture 'known-good' baseline snapshot in local SQLite DB |
| `/saas-seo-drift compare <url>` | Compare current live or staging page against latest baseline |
| `/saas-seo-drift history <url>` | List historical snapshots and drift diffs |

---

## 2. Elements Captured in Baseline Snapshot

- HTTP Status Code (200, 301, 404, 500)
- HTML Body SHA-256 Hash
- Title tag string
- Meta description string
- Canonical URL string
- Meta robots directives (`noindex`, `nofollow`)
- H1, H2, H3 heading arrays
- Schema.org JSON-LD content and SHA-256 hash
- OpenGraph & Twitter tags
- Core Web Vitals (LCP, CLS, INP, Performance score)

---

## 3. The 17 Automated Drift Rules

### CRITICAL (Immediate Traffic / De-indexing Risk)
1. `schema_removed`: All structured data deleted.
2. `canonical_changed`: Canonical URL modified unexpectedly.
3. `canonical_removed`: Canonical tag completely missing.
4. `noindex_added`: Accidental `noindex` injected into production build.
5. `h1_removed`: Primary H1 heading missing.
6. `h1_changed_significantly`: H1 text altered >50%.
7. `title_removed`: Title tag deleted.
8. `status_code_error`: Page returning 4xx or 5xx.

### WARNING (Potential Negative Search Impact)
9. `title_changed`: Title tag string altered.
10. `meta_description_changed`: Meta description altered.
11. `cwv_regressed`: Core Web Vitals metric degraded by >20%.
12. `perf_score_dropped`: Overall performance score dropped by 10+ points.
13. `og_tags_removed`: Social sharing previews stripped.
14. `schema_modified`: Structured data hash altered.

### INFO (Positive or Neutral Changes)
15. `schema_added`: New structured data blocks detected.
16. `h2_structure_changed`: Subheading restructuring.
17. `html_changed`: Routine template updates.

---

## 4. CLI Execution

```bash
python scripts/seo/drift_baseline.py <url>
python scripts/seo/drift_compare.py <url>
```
