---
name: saas-team-ui
description: "Orchestrate the UI team through the complete frontend pipeline — ux-designer, design-system-director, frontend-engineer, qa-manual-tester — UX spec, design tokens, responsive components, and visual testing."
argument-hint: "[UI feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-team-ui/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team UI Pipeline

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the UI design and frontend engineering team from user experience specification
through design token alignment, responsive component development, and visual validation.

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-ui [UI feature description] [--review full|lean|solo]` — Describe the screen, view, or UI pattern you want to build (e.g. Analytics dashboard with interactive charts, Multi-step onboarding modal, Team member permissions table, App shell and global navigation)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **UX Specification**:
   - `ux-designer`: Author or extend the UX specification (`design/ux/[feature].md`)
   - Record the primary task, screen purpose from `/saas-frontend-taste`, layout zones, interaction map, edge cases (empty states, loading, errors), and WCAG 2.2 accessibility checklist.

2. **Design Tokens & Visual Design**:
   - `design-system-director`: Align component with `design/ui/design-tokens.md`
   - Specify typography classes, semantic color tokens, padding/gap tokens, and responsive breakpoints

3. **Frontend Implementation & Anti-Slop Layout**:
   - `frontend-engineer`: Build accessible React/Vue components (using Tailwind CSS, Radix UI / shadcn/ui primitives):
     - Apply the `/saas-frontend-taste` criteria for the screen purpose. Use full-screen rhythm and landing-kit fragments only on landing-kit pages.
     - Ensure semantic HTML (`<nav>`, `<main>`, `<dialog>`, `<button>`)
     - Implement keyboard accessibility (Tab order, Enter/Space, Escape to close)
     - Bind component state to backend API queries/mutations

4. **Visual & Accessibility Testing**:
   - `qa-manual-tester`: Walk the primary task and review the rendered route using Phase 3 of `/saas-frontend-taste`. Report design findings and technical findings with evidence for each viewport or state tested.
   - Use project tools for responsive, keyboard, contrast and interaction checks. Apply the landing-kit scripts only when the kit's conventions apply.

5. **Verdict**:
   - **COMPLETE** when the feature is implemented and all required checks have passed. **NEEDS REVISION** when a known blocker remains. **NOT ASSESSED** when required verification could not run. Include evidence and the next action.
