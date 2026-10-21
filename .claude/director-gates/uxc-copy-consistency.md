> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# UXC-COPY-CONSISTENCY — UX Writing & Content Consistency Sign-Off

Agent: `ux-content-strategist` | Model tier: session (inherit) | Domain: UI terminology, localization keys, microcopy style, clarity and accessibility

**Trigger**: During UI review, localization extraction (`/saas-localize`), or pre-release audit

**Context to pass**:
- UI string tables or component source files (`src/components/`, `src/app/`)
- Brand voice guide (`design/tokens/brand-voice-tone-guide.md`)
- Glossary of standard SaaS terminology (e.g., 'Workspace' vs 'Organization', 'Sign In' vs 'Log In')

**Prompt**:
> "Check all user-facing text, error messages, labels, and notifications for consistency and clarity. Are terms used consistently across the entire interface without synonyms creating confusion? Are button labels action-oriented and predictable (e.g., 'Create Project', not 'Submit')? Are error messages clear and instructive? Are all strings extracted into localization keys if i18n is enabled? Return CONSISTENT (copy adheres to voice and terminology guidelines) or INCONSISTENT [specific copy defects to harmonize]."

**Verdicts**: CONSISTENT / INCONSISTENT
