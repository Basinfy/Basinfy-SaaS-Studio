---
name: saas-team-lgpd
description: "Orchestrate the privacy & data protection team — dpo-privacy-specialist, database-architect, auth-security-specialist, frontend-engineer, appsec-engineer, qa-manual-tester — LGPD compliance, consent ledgers, DSAR, and privacy-by-design."
argument-hint: "[privacy feature or audit scope] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Team LGPD & Privacy Engineering

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and technical documentation MUST remain in English (except Brazilian statutory compliance documents under .lgpd/).

Orchestrate the multidisciplinary privacy engineering and compliance team to implement end-to-end LGPD compliance (Lei 13.709/2018), ANPD regulations, and ECA Digital (Lei 15.211/2025).

**Argument check:** If no description is provided, output:
> "Usage: `/saas-team-lgpd [privacy feature or audit scope] [--review full|lean|solo]` — Describe the privacy feature or compliance scope (e.g. Full greenfield privacy-by-design setup, Legacy database gap analysis & ROPA, Consent ledger with Prisma, DSAR account deletion & data export endpoints, Incident response drill, Cookie banner & privacy preferences center)."

When this skill is invoked with a valid argument, orchestrate the team:

1. **Governance & Legal Assessment**:
   - `dpo-privacy-specialist`: Identify data processing activities, map legal bases (Art. 7/11), conduct LIA for legitimate interest, prepare ROPA (Art. 37) and RIPD/DPIA (Art. 38) where high risk is detected. Update `.lgpd/STATUS.md`.

2. **Data Modeling & Storage Controls**:
   - `database-architect` & `prisma-drizzle-specialist`:
     - Model append-only `ConsentLedger` schema in Prisma with versioning and timestamp hashes.
     - Implement data isolation, crypto-shredding keys, retention schedule, and secure cascading soft/hard delete for data subject requests.
   - `appsec-engineer`:
     - Enforce KMS encryption, AES-256-GCM, TLS 1.3, Argon2id, and immutable hash-chained audit logging (`.lgpd/audit-logging.md`).

3. **Authentication & Identity Verification**:
   - `auth-security-specialist`:
     - Secure authentication for DSAR requests to prevent unauthorized identity impersonation.
     - Enforce ECA Digital age gating and parental verification links (Lei 15.211/2025).

4. **Frontend Privacy UI & Preferences**:
   - `frontend-engineer`:
     - Build granular, un-prechecked consent checkboxes on registration/forms.
     - Implement self-serve Data Subject Access Request (DSAR) portal (`/settings/privacy`) for export (JSON) and account erasure.
     - Create accessible Cookie Preferences Manager and banner.

5. **Quality Assurance & SLA Verification**:
   - `qa-manual-tester`:
     - Verify DSAR automated workflows adhere to statutory SLAs (15 calendar days maximum).
     - Test consent revocation reactivity (ensuring marketing emails or third-party tracking cease immediately).
     - Verify zero plain-text PII in application logs and crash dumps.

6. **Verdict**:
   - Output: **COMPLETE** — privacy engineering controls implemented, living artifacts updated in `.lgpd/`, and verified against ANPD standards.
