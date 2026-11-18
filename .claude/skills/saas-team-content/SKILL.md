---
name: saas-team-content
description: "Orchestrate UX microcopy, empty/error states, transactional emails, and API docs."
argument-hint: "[content initiative description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-team-content/../../hooks/yaml-helper.sh" resolve_config *), mcp__basinfy__basinfy_query_script, mcp__basinfy__basinfy_discover, mcp__basinfy__basinfy_prepare_edit, mcp__basinfy__basinfy_prepare_create, mcp__basinfy__basinfy_impact, mcp__basinfy__basinfy_remember, mcp__basinfy__basinfy_recall, Bash(basinfy *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Content & Documentation

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


Orchestrate the content and technical documentation team to author clear product microcopy,
transactional email sequences, OpenAPI specifications, and interactive developer docs.

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-content [content description] [--review full|lean|solo]` — Describe the content or documentation deliverable (e.g. Transactional email notification suite, Developer API reference documentation, Onboarding empty states and tooltips, Product knowledge base)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **UX Writing & Microcopy**:
   - `ux-content-strategist`: Craft clear, human, error messages, empty-state descriptions, tooltip helpers, and modal confirmations
   - Establish consistent tone of voice (helpful, concise, technically accurate)

2. **Transactional Emails**:
   - `ux-content-strategist`: Author responsive transactional emails (Welcome & verification, Workspace invite, Password reset, Invoice receipt, Usage threshold warning)
   - `frontend-engineer`: Implement email templates using React Email / HTML with responsive mobile styling

3. **API & Developer Documentation**:
   - `technical-writer`: Generate OpenAPI 3.1 schema from route handlers, write curl and SDK code examples, document error status codes and authentication schemes
   - Build developer docs navigation and search

4. **Review & Proofing**:
   - Proofread copy for clarity, internationalization compatibility, and tone consistency.

5. **Verdict**:
   - Output: **COMPLETE** — content, email templates, and documentation authored and integrated.
