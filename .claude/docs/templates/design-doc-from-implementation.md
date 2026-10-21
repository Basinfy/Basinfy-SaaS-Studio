# [Module Name] — Reverse-Engineered Product Requirement Document (PRD)

---
**Status**: Reverse-Documented
**Source**: `[path to implementation code, e.g. src/app/api/webhooks/stripe/route.ts]`
**Date**: [YYYY-MM-DD]
**Verified By**: [User / Lead Engineer]
**Implementation Status**: [Fully implemented | Partially implemented | Needs extension]
---

> **⚠️ Reverse-Documentation Notice**
>
> This document was created **after** implementation code already existed.
> It captures verified production behavior, API contracts, database schemas, and clarified product intent
> inferred from code analysis.

---

## Summary

[2–3 sentences: what this module does, who uses it, and the business value delivered — inferred from source code.]

---

## 1. Problem Statement

**Customer Pain Point**: [What user problem or operational requirement does this code solve?]

**Scope**:
- **Included**: [Capabilities implemented in current codebase]
- **Excluded**: [Planned or out-of-scope capabilities not currently in code]

**Design Intent**:
- [Primary goal extracted from code and schemas]
- [User experience or workflow enabled by this code]

---

## 2. Success Metrics

| Metric | Measured Baseline | Target / Observed Value | Detection Source |
|---|---|---|---|
| [e.g., API Latency] | [Observed p95 latency] | [< 250ms] | Server logs |
| [e.g., Throughput] | [Current transactions/min] | [Sustained peak] | Metrics dashboard |

---

## 3. User Stories

### US-01: [Primary Workflow Story]
- **As an** [authenticated user / workspace admin],
- **I want to** [action implemented in routes/components],
- **So that** [business outcome delivered].

---

## 4. Requirements Pool

### 4.1 Functional Requirements (Extracted from Code)
- `REQ-001`: [Implemented API route or UI interaction]
- `REQ-002`: [Validation and transformation logic found in source]
- `REQ-003`: [Background job or event notification emitted]

### 4.2 Non-Functional Requirements
- `NFR-001`: Response latency and bundle size observed in build.
- `NFR-002`: WCAG 2.2 AA accessibility attributes detected in components.

---

## 5. Data Models / Schema

### 5.1 Observed Database Schema
```prisma
// Schema reverse-engineered from prisma/schema.prisma or Postgres tables
model [ModelName] {
  id          String   @id @default(cuid())
  workspaceId String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  workspace   Workspace @relation(fields: [workspaceId], references: [id])

  @@index([workspaceId])
}
```

### 5.2 Endpoint Signatures
- `[METHOD]` `[URL Path]` — `[Request Zod Schema]` -> `[Response Contract]`

---

## 6. Security & Permissions

- **Authentication Mechanism**: [Session cookie / Bearer token / Supabase Auth]
- **Authorization & RBAC**: [Roles authorized in middleware or route guards]
- **Tenant Isolation**: [Enforced via Postgres RLS or workspace_id filter]

---

## 7. Edge Cases & Error Handling

| Scenario | Handled in Code? | Observed Behavior |
|---|---|---|
| Invalid Payload | Yes | HTTP 422 with Zod error details |
| Unauthorized Access | Yes | HTTP 401 / 403 response |
| Database Error | Yes | HTTP 500 logged with request ID |

---

## 8. Acceptance Criteria (Verified Against Code)

### AC-01: [Verified Happy Path]
- **Given** [valid precondition found in tests],
- **When** [endpoint called or component rendered],
- **Then** [expected database change and HTTP response observed].
