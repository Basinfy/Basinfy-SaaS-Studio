---
name: saas-team-auth-access
description: "Orchestrate the authentication & access team — auth-security-specialist, backend-engineer, frontend-engineer, qa-manual-tester — auth, RBAC, multi-tenancy, sessions, and invites."
argument-hint: "[auth/access feature description] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

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
   - `auth-security-specialist`: Specify threat model, cookie security flags (`HttpOnly`, `SameSite=Lax`, `Secure`), session duration, and CSRF strategy
   - `backend-engineer`: Database migration for `User`, `Account`, `Session`, `Organization`, and `Membership` models
   - Define Row-Level Security (RLS) policies or middleware tenant guards

2. **Backend API & Middleware**:
   - `backend-engineer`: Implement OAuth callbacks, email verification token generation, password hashing (Argon2id/bcrypt), and role authorization middleware (`requireRole('admin')`)

3. **Frontend Flows**:
   - `frontend-engineer`: Login, Registration, Forgot Password, and Accept Invite screens
   - Session context provider (`useUser`, `useTenant`), protected route wrappers, and error alert banners

4. **Testing & Security Validation**:
   - `qa-manual-tester`: Test valid and invalid login attempts, token tampering, expired links, and cross-tenant access denial

5. **Verdict**:
   - Output: **COMPLETE** — authentication and access controls designed, implemented, and verified.
