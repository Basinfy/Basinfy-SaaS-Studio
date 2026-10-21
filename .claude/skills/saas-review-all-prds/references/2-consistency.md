# Phase 2: Cross-PRD Consistency Check

Verify that requirement definitions across PRDs do not contradict each other.

### Areas to Check:
1. **Data Contracts & Terminology**:
   - Are entities named consistently? (e.g. `workspace` vs `organization` vs `team`; `member` vs `user`).
   - Are IDs, roles, and status strings standardized across documents?
2. **Dependent Requirement Guarantees**:
   - If `teams.md` relies on seat limits defined in `billing.md`, does `billing.md` explicitly expose `seat_quota` and define behavior when the limit is exceeded?
   - If `notifications.md` consumes events from `auth.md`, are all auth event payloads specified?
3. **Permission & Security Contradictions**:
   - Does one PRD state that "any member can export reports", while another states "only Admin/Owner roles can export data"?
4. **Error Handling & State Sync**:
   - How do dependent systems handle transient failures (e.g. webhook delivery delays, billing grace periods)?
