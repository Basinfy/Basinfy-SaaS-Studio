# Phase 4: Cross-System Scenario Walkthroughs

Walk through end-to-end customer workflows to identify edge cases that emerge only
when multiple SaaS modules interact.

### Critical Cross-System Touchpoints:
1. **Onboarding + Auth + Billing**:
   - New user signs up through an organization invite link while not having an account.
   - User signs up for a trial, trial expires mid-session, user attempts to save ongoing work.
2. **Quota Depletion + Background Processing**:
   - Customer initiates a bulk batch import of 5,000 records on a plan with 2,000 quota remaining.
   - Does the worker process 2,000 and pause, reject the whole batch, or prompt for an in-flight upgrade?
3. **Plan Downgrade + Resource Retention**:
   - Admin downgrades from Enterprise (unlimited team seats) to Starter (3 seats).
   - What happens to the remaining 10 active members? Are they suspended, converted to read-only, or selected by the admin?
4. **Account Deletion + Active Subscriptions**:
   - User triggers "Delete Organization" while an annual Stripe subscription is active.
   - Verify that Stripe webhook cancellation is dispatched and external data exports are properly purged.

### Scenario Output Table
Document each walked scenario:
- **Trigger**: User action or webhook event
- **Data Flow Across Systems**: Sequence of module interactions (e.g. `Router → Auth → Billing → Worker → DB`)
- **Observed Risk / Edge Case**: Discrepancies or missing states discovered
- **Remediation**: Recommended PRD update or architecture constraint
