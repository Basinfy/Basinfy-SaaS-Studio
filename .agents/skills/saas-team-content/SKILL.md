---
name: saas-team-content
description: "Orchestrate UX microcopy, empty/error states, transactional emails, and API docs."
argument-hint: "[content initiative description] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

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
