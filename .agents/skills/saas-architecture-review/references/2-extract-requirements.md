# /saas-architecture-review — Phase 2: Extract Technical Requirements

> Part of `/saas-architecture-review`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 2: Extract Technical Requirements from Every PRD

### Pre-load the TR Registry

Before extracting any requirements, read `docs/architecture/tr-registry.yaml`
if it exists. Index existing entries by `id` and by normalized `requirement`
text (lowercase, trimmed). This prevents ID renumbering across review runs.

Then read the Technical Requirements Baseline in `docs/architecture/architecture.md`
if it exists. `/saas-create-architecture` numbers each requirement the registry did not
hold as `(provisional)`, from the registry's next free ID, and ADRs written from
the baseline may already cite those IDs.

For each requirement you extract, the matching rule is:
1. **Exact/near match** to an existing registry entry for the same system →
   reuse that entry's TR-ID unchanged. Update the `requirement` text in the
   registry only if the PRD wording changed (same intent, clearer phrasing) —
   add a `revised: [date]` field.
2. **Match to a provisional baseline row** (same system, same intent) → keep that
   ID when the registry holds no entry with it, active or retired: registering it
   is what makes it permanent. When the ID is taken, assign the next available one
   and list the rename (`TR-[system]-004 (provisional) → TR-[system]-006`) in the
   report, so the ADRs and stories that cite it can be updated.
3. **No match** → assign a new ID: next available `TR-[system]-NNN` for that
   system, starting from the highest existing sequence + 1, skipping any ID a
   provisional baseline row holds.
4. **Ambiguous** (partial match, intent unclear) → ask the user:
   > "Does '[new requirement text]' refer to the same requirement as
   > `TR-[system]-NNN: [existing text]'`, or is it a new requirement?"
   User answers: "Same requirement" (reuse ID) or "New requirement" (new ID).

For any requirement with `status: deprecated` in the registry — skip it.
It was removed from the PRD intentionally.

For each PRD, read it and extract all **technical requirements** — things the
architecture must provide for the system to work. A technical requirement is any
statement that implies a specific architectural decision.

Categories to extract:

| Category | Example |
|----------|---------|
| **Data structures & Schema** | "Each workspace has tenants, users, roles, and usage quotas" → Prisma / PostgreSQL schema ADR |
| **Performance constraints** | "Dashboard must render within 200ms LCP under 10k items" → pagination & caching ADR |
| **Stack & API capability** | "Real-time collaborative updates across open client tabs" → WebSockets / SSE architecture ADR |
| **Cross-system communication** | "Billing event triggers user provisioning and webhook notification" → event bus / queue worker ADR |
| **Data persistence & Isolation** | "Tenant data must be strictly isolated with audit trails" → Postgres RLS & migration strategy ADR |
| **Background processing** | "Large CSV reports and billing exports process asynchronously" → Redis / BullMQ worker ADR |
| **Platform & Auth requirements** | "Supports OAuth2, SAML SSO, and session cookies" → Auth & RBAC architecture ADR |

For each PRD, produce a structured list:

```
PRD: [filename]
System: [system name]
Technical Requirements:
  TR-[PRD]-001: [requirement text] → Domain: [Auth/Database/API/Routing/etc]
  TR-[PRD]-002: [requirement text] → Domain: [...]
```

This becomes the **requirements baseline** — the complete set of what the
architecture must cover.

---
