---
name: saas-team-auth-access
description: "Orchestrate the authentication & access team — security-engineer, backend-engineer, frontend-engineer, qa-tester — auth, RBAC, multi-tenancy, sessions, and invites."
argument-hint: "[auth/access feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-team-auth-access/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Authentication & Access

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Orchestrate the authentication, authorization, and multi-tenancy team to build secure login,
RBAC permissions, session handling, team invites, and organization switching.

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-auth-access [feature description] [--review full|lean|solo]` — Describe the auth or access feature (e.g. Email+Password auth with magic links, Google/GitHub OAuth, Organization invite & RBAC, Multi-tenant Row-Level Security, Session revocation)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **Security & Data Modeling**:
   - `security-engineer`: Specify threat model, cookie security flags (`HttpOnly`, `SameSite=Lax`, `Secure`), session duration, and CSRF strategy
   - `backend-engineer`: Database migration for `User`, `Account`, `Session`, `Organization`, and `Membership` models
   - Define Row-Level Security (RLS) policies or middleware tenant guards

2. **Backend API & Middleware**:
   - `backend-engineer`: Implement OAuth callbacks, email verification token generation, password hashing (Argon2id/bcrypt), and role authorization middleware (`requireRole('admin')`)

3. **Frontend Flows**:
   - `frontend-engineer`: Login, Registration, Forgot Password, and Accept Invite screens
   - Session context provider (`useUser`, `useTenant`), protected route wrappers, and error alert banners

4. **Testing & Security Validation**:
   - `qa-tester`: Test valid and invalid login attempts, token tampering, expired links, and cross-tenant access denial

5. **Verdict**:
   - Output: **COMPLETE** — authentication and access controls designed, implemented, and verified.
