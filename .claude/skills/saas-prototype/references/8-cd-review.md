# Phase 8: Product Director Review

When review mode is enabled, evaluate the prototype findings against the product's core value proposition.

**Review Mode Check**:
- `solo` → skip. Note: "PD-PROTOTYPE-REVIEW skipped — Solo mode."
- `lean` → skip. Note: "PD-PROTOTYPE-REVIEW skipped — Lean mode."
- `full` → spawn `product-director` via `Agent` using gate **PD-PROTOTYPE-REVIEW** (`.claude/director-gates/pd-prototype-review.md`) if `design/product-concept.md` exists with product pillars defined.

Pass:
- The full `REPORT.md` content
- The original hypothesis
- Product pillars and core value proposition (from `design/product-concept.md`)

The product director evaluates whether the prototype provides sufficient evidence to proceed to full PRD authoring, pivot the approach, or kill the initiative.
