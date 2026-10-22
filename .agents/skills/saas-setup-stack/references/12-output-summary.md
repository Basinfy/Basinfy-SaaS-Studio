# /saas-setup-stack — Section 12: Output Summary

> Part of `/saas-setup-stack`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 12. Output Summary

After setup is complete, output:

```
Engine Setup Complete
=====================
Engine:          [name] [version]
Language:        [TypeScript | Python | Go]
Knowledge Risk:  [LOW/MEDIUM/HIGH]
Reference Docs:  [created/skipped]
CLAUDE.md:       [updated]
Tech Prefs:      [created/updated]
project.yaml:    [created/updated]
Agent Config:    [verified]

Next Steps:
1. Review docs/engine-reference/<engine>/VERSION.md
```

Then print **one** Next-Steps list, matching the resolved `workflow` tier:

**`minimal` — the lean 4-step floor (you are on step 1):**
```
2. Run /saas-brainstorm to produce your one-page design/product-brief.md (the lean-tier design artifact)
3. Run /saas-create-stories to turn the brief's MVP list into stories
4. Run /saas-dev-story — first line of application code
```
(No `/saas-map-features`, `/saas-design-system`, `/saas-prototype`, or `/saas-sprint-plan` at
`minimal` — the brief replaces the PRDs and its build order is the plan.)

**`standard` / `full` — the full pipeline:**
```
2. [If from /saas-brainstorm] Run /saas-map-features to decompose your concept into individual systems
3. [If from /saas-brainstorm] Run /saas-design-system to author per-system PRDs (guided, section-by-section)
4. [If from /saas-brainstorm] Run /saas-prototype [core-workflow] to validate the core idea before writing PRDs
5. [If fresh start] Run /saas-brainstorm to discover your product concept
6. Create your first milestone: /saas-sprint-plan new
```

---

Verdict: **COMPLETE** — engine configured and reference docs populated.
