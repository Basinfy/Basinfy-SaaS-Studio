> Gate definition, loaded by `/saas-gate-check` for the TARGET PHASE ONLY.
> Never load the other five — one gate applies per invocation.


# Gate: Concept → Systems Design


**Required Artifacts:**
- [ ] `design/prd/product-concept.md` exists and has content
- [ ] Product pillars defined (in concept doc or `design/prd/product-pillars.md`)
- [ ] Visual Identity Anchor section exists in `design/prd/product-concept.md` (from brainstorm Phase 4 design-system-director output)

**Recommended (not blocking):**
- [ ] Concept prototype exists in `prototypes/` with a REPORT.md showing PROCEED verdict
      (`/saas-prototype [core-workflow]`) — skipping this means PRDs may be written for an
      idea that hasn't been tested. Acceptable if the concept is proven by other means.

**Quality Checks:**
- [ ] Product concept has been reviewed (`/saas-design-review` verdict not MAJOR REVISION NEEDED)
- [ ] Core loop is described and understood
- [ ] Target audience is identified
- [ ] Visual Identity Anchor contains a one-line visual rule and at least 2 supporting visual principles

## Workflow tier reductions

The checklist above is the **`full` baseline**. At lower tiers apply the
reduction for the resolved tier; items not named keep their status above.
Reductions only ever *relax* a requirement — `workflow_overrides` is the
only thing that adds one.

- **`full`** — product-concept.md + pillars + Visual Identity Anchor all required
- **`standard`** — pillars + Visual Identity Anchor → recommended; `product-concept.md` stays required
- **`minimal`** — gate target is **`design/product-brief.md`** (not `product-concept.md`); the PRD / pillars / Visual Identity Anchor checks **drop** (a brief with content = PASS). `/saas-brainstorm` writes `design/product-brief.md` at this tier (Option A); `product-concept.md` remains the `standard`/`full` concept doc.
