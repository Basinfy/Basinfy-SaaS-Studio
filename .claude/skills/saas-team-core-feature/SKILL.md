---
name: saas-team-core-feature
description: "Orchestrate the core feature team — lead-product-manager, backend-engineer, frontend-engineer, ai-engineer, qa-tester — design through implement and validate."
argument-hint: "[core feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-team-core-feature/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Core Feature

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the specialized engineering team to deliver a primary SaaS capability from
concept through implementation and verification.

**Argument check:** If no core feature description is provided, output:
> "Usage: `/saas-team-core-feature [feature description] [--review full|lean|solo]` — Provide a description of the core SaaS workflow or feature you want to build."

When this skill is invoked with a valid argument, orchestrate the team through a structured process:

1. **Design & Spec Phase**:
   - `lead-product-manager`: Author PRD draft (`production/core-features/[feature]-prd-draft.md`)
   - `backend-engineer`: Technical architecture notes & DB schema impacts
   - `frontend-engineer`: UI state, component hierarchy, and responsive interaction spec
   - If AI-powered: `ai-engineer`: LLM prompt pipeline, context retrieval, tool schemas

2. **Cross-Discipline Alignment**:
   - Resolve data contracts (API input/output schemas with Zod/Pydantic)
   - Ensure tenant isolation and auth permissions are respected

3. **Implementation Phase**:
   - `backend-engineer`: Database migration, service logic, API endpoints (`src/app/api/...` or `api/routes/...`)
   - `frontend-engineer`: React/Next.js UI components, form hooks, optimistic updates
   - If AI-powered: `ai-engineer`: Streaming response handlers, embedding vector search

4. **Validation Phase**:
   - `qa-tester`: Integration test suite (Vitest/Pytest), E2E test scenarios (Playwright)
   - Verify acceptance criteria and error edge cases (empty states, rate limits, network failure)

5. **Closing Verdict**:
   - Output: **COMPLETE** — core feature designed, implemented, and validated.
