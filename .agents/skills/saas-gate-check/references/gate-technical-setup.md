> Gate definition, loaded by `/saas-gate-check` for the TARGET PHASE ONLY.
> Never load the other five — one gate applies per invocation.


# Gate: Systems Design → Technical Setup


**Required Artifacts:**
- [ ] Systems index exists at `design/prd/features-modules-index.md` with at least MVP systems enumerated
- [ ] All MVP-tier PRDs exist in `design/prd/` and individually pass `/saas-design-review`
- [ ] A cross-PRD review report exists in `design/prd/` (from `/saas-review-all-prds`)

**Quality Checks:**
- [ ] All MVP PRDs pass individual design review (8 required sections, no MAJOR REVISION NEEDED verdict)
- [ ] `/saas-review-all-prds` verdict is not FAIL (cross-PRD consistency and design theory checks pass). A NOT ASSESSED verdict does not satisfy this: that review could not compare the PRDs, so this item is NOT ASSESSED for the gate. Nor does a focus-run report (its `Focus:` line names one pass only): the other pass never ran, so the item stays open until a review runs both
- [ ] All cross-PRD consistency issues flagged by `/saas-review-all-prds` are resolved or explicitly accepted
- [ ] System dependencies are mapped in the systems index and are bidirectionally consistent
- [ ] MVP priority tier is defined
- [ ] No stale PRD references flagged (older PRDs updated to reflect decisions made in later PRDs)

## Workflow tier reductions

The checklist above is the **`full` baseline**. At lower tiers apply the
reduction for the resolved tier; items not named keep their status above.
Reductions only ever *relax* a requirement — `workflow_overrides` is the
only thing that adds one.

- **`full`** — systems-index + all MVP PRDs at 8 sections + cross-PRD review report all required
- **`standard`** — MVP PRDs validated at the **5 standard sections** (+ conditional Formulas); cross-PRD review report → recommended
- **`minimal`** — **gate not applicable** — no gate between brief and code; auto-PASS with a note (see below)

> **`minimal` "not applicable" gate.** The Systems Design → Technical Setup gate
> has no meaning at `minimal` (no PRDs exist by design). Return a PASS verdict
> with the note: *"No design gate at minimal workflow — minimal skips the
> Systems Design phase; advancing brief → code."* The Section 6 stage write still
> applies on user confirmation. Do NOT flag absent PRDs as blockers. This is the
> named exception to Section 2b's rule that a gate with no required artifacts left
> may not PASS; the director panel does not run for it.
