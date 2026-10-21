# User Journey & Flow Specification: [Flow Name]

> **Status**: [Draft | In Review | Approved]
> **Owner**: [ux-designer / lead-product-manager]
> **Flow Type**: [Onboarding | Checkout & Upgrade | Team Member Invite | Resource Creation | Export & Reporting]
> **Primary Persona**: [Target Persona, e.g., Workspace Admin, Developer, End-User]

---

## 1. Flow Overview & Success Metric

- **Trigger Event**: [What initiates this flow — e.g. User clicks "Upgrade Plan", user accepts email invitation]
- **User Goal**: [What the user wants to accomplish — e.g. Invite 3 teammates and assign roles]
- **Business Goal**: [Desired business outcome — e.g. Increase workspace seat utilization and conversion]
- **Primary Metric**: [e.g. Flow completion rate > 80%, average time to complete < 90 seconds]

---

## 2. Step-by-Step Flow Chart

```
[Trigger: Click "Invite Members"]
             │
             ▼
[Step 1: Input Modal — Enter Emails & Select Role]
             │
             ├── (Validation Error: Invalid Email) ──► [Show Inline Field Error]
             │
             ▼ (Valid Emails)
[Step 2: Quota & Billing Check]
             │
             ├── (Quota Exceeded) ──► [Show Upgrade Confirmation Banner]
             │
             ▼ (Quota Available)
[Step 3: Server Action — Dispatch Invites & Write DB Records]
             │
             ▼
[Step 4: Success Toast Notification & Table Update]
```

---

## 3. Detailed Step Specifications

### Step 1: Input & Configuration
- **Screen / View**: Modal dialog overlay (`bg-popover`, max-width 480px).
- **User Action**: Type email addresses (comma or Enter separated) and select role from dropdown (`Admin`, `Member`, `Viewer`).
- **Input Validation**: RFC 5322 email regex, deduplication of emails against existing workspace members.

### Step 2: System Validation & Quota Guard
- **API Call**: `POST /api/teams/invites/validate`
- **Permissions Required**: `requirePermission('members:invite')`
- **Edge Case**: If current plan seat count is reached, prompt:
  > "You've reached your 5-seat limit on the Starter plan. Add seats for $15/seat/month to invite more members. [Confirm & Add Seats] [Cancel]"

### Step 3: Execution & Confirmation
- **API Call**: `POST /api/teams/invites`
- **Background Worker**: Queue transactional invite emails with secure single-use token (expires in 7 days).
- **Client Response**: Modal closes immediately; optimistic UI adds pending member row with status badge `Invited`; Toast confirms: `"3 invitations sent successfully."`

---

## 4. Edge Cases & Error States

| Edge Case | System Behavior | User Communication |
|---|---|---|
| User already a member | Exclude from new invite batch | Warning note: `"john@example.com is already in this workspace."` |
| Email deliverability failure | Worker marks invite as `Failed` | Alert in Team Settings: `"Delivery bounced. [Resend Invite]"` |
| Expired invite token | Landing page explains expiration | Clean error screen: `"This invite link has expired. Request a new one."` |
| Network disconnect mid-flow | Retry with exponential backoff | Toast alert: `"Connection lost. Retrying automatically..."` |

---

## 5. Analytics Instrumentation

| Event Name | Trigger Moment | Payload Properties |
|---|---|---|
| `invite_modal_opened` | User clicks invite button | `workspace_id`, `current_member_count` |
| `invite_batch_submitted` | User clicks "Send Invites" | `workspace_id`, `invite_count`, `roles_assigned` |
| `invite_upgrade_prompted` | Quota exceeded during flow | `workspace_id`, `plan_id`, `seats_requested` |
| `invite_batch_succeeded` | API returns 200 OK | `workspace_id`, `success_count` |
