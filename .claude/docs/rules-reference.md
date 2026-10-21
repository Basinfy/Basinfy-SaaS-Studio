# Path-Specific Rules

Rules in `.claude/rules/` carry `paths:` frontmatter. Claude Code loads a
path-scoped rule **when it READS a file matching one of those globs** — not on
every tool use, and not when it creates one.

Three consequences, and none of them are optional reading:

1. **Reading, not editing.** A rule scoped to a backend or frontend folder reaches the
   model when a file there is opened. An agent that writes a brand-new file in that
   directory without opening an existing one never sees it. Most work in this
   framework creates files rather than reads them, so this is the common case,
   not the corner case.
2. **Context, not enforcement.** A loaded rule is guidance the model weighs, the
   same as `CLAUDE.md`. Anything that must hold regardless of what the model
   decides belongs in a hook — `.claude/hooks/` already enforces JSON validity
   and commit shape that way.
3. **A rule with no `paths:` loads every session**, at the same priority as
   `.claude/CLAUDE.md`. That is the lever for a rule that must always apply; it
   costs context in every session, so it is a deliberate trade, not a default.

Where a rule duplicates guidance an agent definition already carries, the two
must agree. Contradicting instructions are resolved arbitrarily, so a rule and
an agent stating different versions of the same standard is worse than either
alone.

To see which rules actually load, and why, wire the `InstructionsLoaded` hook —
`.claude/hooks/log-instructions.sh` records every instruction file and its load
reason (`session_start`, `path_glob_match`, `nested_traversal`, `include`,
`compact`) to `production/session-logs/instructions-loaded.log`.

**Globs match regardless of case.** Claude Code matches `paths:`
gitignore-style and case-insensitively.

| Rule File | Path Pattern | Enforces |
| ---- | ---- | ---- |
| `appsec-rules.md` | `src/**` | OWASP Top 10, sanitization, secrets prevention, least privilege |
| `architecture-rules.md` | `docs/architecture/**` | ADR format, tech stack alignment, system boundaries |
| `auth-security-rules.md` | `src/auth/**` · `src/middleware/**` | Session management, RBAC, tenant isolation, CSRF/CORS |
| `backend-api-rules.md` | `src/app/api/**` · `src/server/**` · `src/routes/**` | REST/RPC conventions, error handling, rate limiting, validation |
| `background-jobs-rules.md` | `src/jobs/**` · `src/workers/**` | Idempotency, queue retries, backoff, observability |
| `billing-rules.md` | `src/billing/**` · `src/app/api/webhooks/stripe/**` | Stripe webhooks, idempotency keys, subscription state machine |
| `database-rules.md` | `src/db/**` · `prisma/**` · `supabase/migrations/**` | Migrations, indices, foreign keys, transaction boundaries |
| `frontend-components-rules.md` | `src/components/**` · `src/app/**` | Accessibility (WCAG 2.1 AA), responsive layouts, state isolation |
| `prototype-rules.md` | `prototypes/**` | Relaxed standards, README required, hypothesis documented |
| `specs-prd-rules.md` | `docs/specs/**` · `docs/prd/**` | Required PRD sections, acceptance criteria, metrics |
| `styling-ui-tokens-rules.md` | `design/tokens/**` · `tailwind.config.*` · `src/styles/**` | Semantic color tokens, spacing scale, dark mode tokens |
| `test-standards.md` | `tests/**` · `**/*.test.*` · `**/*.spec.*` | Test naming, coverage requirements, fixture patterns |
| `agent-memory.md` | `.claude/agent-memory/**` | The one place an agent may write unasked — durable facts |
| `skill-authoring.md` | `.claude/skills/**` · `.claude/agents/**` | The five obligations for verdicts, defaults, skips, sourcing and derived coverage |

Each rule loads based on its glob pattern:

- **Application rules** (`appsec`, `auth-security`, `backend-api`, `frontend-components`, `database`, `billing`, `background-jobs`) match corresponding source trees.
- **Specification rules** (`specs-prd`, `architecture`, `styling-ui-tokens`) match documentation and token paths.
- **Testing rules** (`test-standards`) match test directories and spec files.

> **`skill-authoring.md` is the odd one out and deliberately so.** Every other
> rule here scopes an application or documentation directory; that one scopes the **framework's own**
> authoring paths. It exists because one failure shape kept recurring across
> unrelated subsystems — a step that could not run producing output
> indistinguishable from a step that ran and found nothing. The same mistake in
> nine places is a missing design rule, not nine mistakes.
