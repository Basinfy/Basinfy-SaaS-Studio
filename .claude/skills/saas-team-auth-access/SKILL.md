---
name: saas-team-auth-access
description: "Orchestrate auth, RBAC, session security, and multi-tenant RLS specialists end-to-end."
argument-hint: "[auth/access feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-team-auth-access/../../hooks/yaml-helper.sh" resolve_config *), mcp__basinfy__basinfy_query_script, mcp__basinfy__basinfy_discover, mcp__basinfy__basinfy_prepare_edit, mcp__basinfy__basinfy_prepare_create, mcp__basinfy__basinfy_impact, mcp__basinfy__basinfy_remember, mcp__basinfy__basinfy_recall, Bash(basinfy *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team Authentication & Access

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


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
