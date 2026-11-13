---
name: saas-team-content
description: "Orchestrate the content & communication team — ux-content-strategist, technical-writer, frontend-engineer — UX writing, API docs, transactional emails, and onboarding."
argument-hint: "[content initiative description] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Content & Documentation

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

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
