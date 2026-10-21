# Multi-Tenancy & Organization Architecture Specification

> **Status**: [Draft | In Review | Approved]
> **Owner**: `lead-engineer` / `technical-director`
> **Last Updated**: [YYYY-MM-DD]
> **Links To**: `docs/architecture/system-architecture.md`, `docs/specs/features-modules-index.md`

---

## 1. Multi-Tenancy Model

| Architectural Dimension | Specification |
|---|---|
| **Isolation Architecture** | Pooled Database with Row Level Security (RLS) & Tenant ID Columns |
| **Primary Tenant Unit** | `Workspace` (or `Organization`) |
| **Tenant Routing** | Path-based (`/w/:workspace_slug`) or Subdomain (`:tenant.saas.com`) |
| **Identity Provider** | Supabase Auth / Clerk / WorkOS (Single global user account, multiple workspace memberships) |

---

## 2. Organization & Membership Data Model

```prisma
model Workspace {
  id          String   @id @default(cuid())
  slug        String   @unique
  name        String
  plan        String   @default("free") // free | pro | enterprise
  stripeCustomerId String? @unique
  stripeSubscriptionId String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  memberships WorkspaceMembership[]
  invitations WorkspaceInvitation[]
  resources   WorkspaceResource[]

  @@index([slug])
}

model WorkspaceMembership {
  id          String   @id @default(cuid())
  workspaceId String
  userId      String
  role        String   @default("member") // owner | admin | member | billing | viewer
  createdAt   DateTime @default(now())

  workspace   Workspace @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  user        User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([workspaceId, userId])
  @@index([userId])
  @@index([workspaceId])
}
```

---

## 3. Role-Based Access Control (RBAC) Matrix

| Permission / Action | Owner | Admin | Member | Billing | Viewer |
|---|:---:|:---:|:---:|:---:|:---:|
| Delete Workspace | ✅ | ❌ | ❌ | ❌ | ❌ |
| Transfer Ownership | ✅ | ❌ | ❌ | ❌ | ❌ |
| Manage Billing & Invoices | ✅ | ✅ | ❌ | ✅ | ❌ |
| Invite / Remove Members | ✅ | ✅ | ❌ | ❌ | ❌ |
| Change Member Roles | ✅ | ✅ | ❌ | ❌ | ❌ |
| Create / Edit Core Resources | ✅ | ✅ | ✅ | ❌ | ❌ |
| Read / View Resources | ✅ | ✅ | ✅ | ✅ | ✅ |
| Export Data / Reports | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## 4. Tenant Isolation & Security Enforcement

### 4.1 Postgres Row Level Security (RLS) Policy Example
```sql
-- Enable RLS on tenant resource tables
ALTER TABLE workspace_resources ENABLE ROW LEVEL SECURITY;

-- Enforce tenant isolation via session context or membership join
CREATE POLICY tenant_isolation_policy ON workspace_resources
  FOR ALL
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_memberships 
      WHERE user_id = auth.uid()
    )
  );
```

### 4.2 Application-Layer Safeguards
1. **Never Trust Client Tenant ID**: The active `workspace_id` must be resolved server-side from the authenticated session context, URL path verification, and database membership checks.
2. **Automated Cross-Tenant Leak Tests**: Integration test suites must explicitly attempt cross-tenant reads and writes (Tenant A user attempting to read Tenant B's data) and assert an immediate 403 Forbidden or empty query result.

---

## 5. Workspace Lifecycle Management

### 5.1 Workspace Creation & Onboarding
- First workspace is automatically provisioned during user signup.
- Creator is assigned the `owner` role.
- Initial welcome sample data or templates are populated.

### 5.2 Member Invitations & Join Flow
- Admins send invites via email with unique, cryptographic 7-day tokens.
- Invitee signs in or registers; upon confirmation, the membership record is created.

### 5.3 Workspace Offboarding & Soft Deletion
- Owner triggers deletion; a 30-day grace period is initiated before permanent purge.
- Immediate cancellation of active Stripe subscriptions at period end.
- Automated GDPR data deletion job cleans up orphaned files and records.
