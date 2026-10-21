# /saas-gate-check — Sections 7 and 8: Next Step and Follow-Up

> Part of `/saas-gate-check`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 7. Closing Next-Step Widget

**In this file:**

- 7. Closing Next-Step Widget: per gate, and the `workflow: minimal` route
- 8. Follow-Up Actions

After the verdict is presented and any stage update is complete (project.yaml + stage.txt), close with a structured next-step prompt using `AskUserQuestion`.

**Tailor the options to the gate that just ran.** The argument names the phase
being entered, so `/saas-gate-check systems-design` is the Concept → Systems Design gate.

**At `workflow: minimal`, skip the menus below.** They walk the phase ladder, and
the minimal route is not the ladder: offer the first incomplete step of
`paths.minimal` instead (the `--path minimal` rows from Section 3):
`/saas-setup-stack`, then `/saas-brainstorm` (or `/saas-reverse-document design [code root]`
when the code root already holds the application: it writes the brief from what is
built), then `/saas-create-stories`, then `/saas-dev-story` on the next story — the route
`/saas-help` gives.

For **Concept → Systems Design** (`/saas-gate-check systems-design`) PASS — option [A] is
`/saas-map-features` when `design/prd/features-modules-index.md` does not exist yet (many
projects write it during Concept, as the workflow catalog orders it), otherwise
`/saas-design-system [first system in the index's design order]`:
```
Gate passed. What would you like to do next?
[A] Run /saas-map-features — decompose the concept into systems and a design order (recommended next step)
    — or, when the systems index already exists: Run /saas-design-system [first system] — author its PRD
[B] Revisit the concept first — return here when it is settled
[C] Stop here for this session
```

For **Systems Design → Technical Setup** (`/saas-gate-check technical-setup`) PASS:
```
Gate passed. What would you like to do next?
[A] Run /saas-create-architecture — produce your master architecture blueprint and ADR work plan (recommended next step)
[B] Design more PRDs first — return here when all MVP systems are complete
[C] Stop here for this session
```

> **Note for the Systems Design → Technical Setup PASS**: `/saas-create-architecture` is the required next step before writing any ADRs. It produces the master architecture document and a prioritized list of ADRs to write. Running `/saas-architecture-decision` without this step means writing ADRs without a blueprint — skip it at your own risk.

For **Technical Setup → Pre-Production** (`/saas-gate-check pre-production`) PASS:
```
Gate passed. What would you like to do next?
[A] Run /saas-create-control-manifest — generate the layer rules manifest from your Accepted ADRs (first, if docs/architecture/control-manifest.md does not exist yet)
[B] Run /saas-vertical-slice — build the Vertical Slice (do this before writing epics — validate fun first)
[C] Write more ADRs first — run /saas-architecture-decision [next-system]
[D] Stop here for this session
```

> **Note for the Technical Setup → Pre-Production PASS**: The Pre-Production sequence is deliberately ordered
> to validate value proposition before committing to detailed planning:
>
> 1. `/saas-create-control-manifest` — extract technical rules from Accepted ADRs, if not done yet (`/saas-create-epics` requires it at `full`)
> 2. `/saas-vertical-slice` — build the Vertical Slice **FIRST**, before writing epics or stories
> 3. Usability test → `/saas-usability-test` — at least 1 documented session, 3+ better before committing the full team. `/saas-gate-check production` treats the slice as recommended: skipped → CONCERNS, unevaluated → NOT ASSESSED
> 4. `/saas-ux-design [screen]` — UX specs for landing page, core App Shell, navigation (if not done)
> 5. `/saas-create-epics layer:foundation` then `/saas-create-epics layer:core` — plan after value proposition is validated
> 6. `/saas-create-stories [epic-slug]` for each epic
> 7. `/saas-sprint-plan new`
>
> **Why prototype before epics?** If the prototype reveals the core loop needs to change,
> epics written before that discovery will be partially wrong. Validate fun cheaply first,
> then plan in detail. This is the #1 lesson from GDC postmortem data.

For all other gates, offer the two most logical next steps for that phase plus "Stop here".

---

## 8. Follow-Up Actions

Based on the verdict, suggest specific next steps:

- **No design tokens?** → `/saas-design-tokens` to create the visual identity specification
- **Design tokens exist but no asset specs?** → `/saas-asset-spec system:[name]` to generate per-asset visual specs and generation prompts from approved PRDs
- **No product concept?** → `/saas-brainstorm` to create one
- **No systems index?** → `/saas-map-features` to decompose the concept into systems
- **Missing design docs?** → `/saas-reverse-document` or delegate to `lead-product-manager`
- **Small design change needed?** → `/saas-quick-design` for changes under about one week of implementation (bypasses full PRD pipeline)
- **No UX specs?** → `/saas-ux-design [screen name]` to author specs, or `/saas-team-ui [feature]` for full pipeline
- **UX specs not reviewed?** → `/saas-ux-review [file]` or `/saas-ux-review all` to validate
- **No accessibility requirements doc?** → `/saas-ux-design accessibility` to write `design/accessibility-requirements.md`
- **No interaction pattern library?** → `/saas-ux-design patterns` to initialize it
- **Concept or a PRD not reviewed?** → `/saas-design-review [doc]`
- **PRDs not cross-reviewed?** → `/saas-review-all-prds` (run after all MVP PRDs are individually approved)
- **Cross-PRD consistency issues?** → fix flagged PRDs, then re-run `/saas-review-all-prds`
- **No test framework?** → `/saas-test-setup` to scaffold the framework for your engine
- **No QA plan for current sprint?** → `/saas-qa-plan sprint` to generate one before implementation begins
- **Missing ADRs?** → `/saas-architecture-decision` for individual decisions
- **No master architecture doc?** → `/saas-create-architecture` for the full blueprint
- **ADRs missing stack compatibility sections?** → Re-run `/saas-architecture-decision`
  or manually add Engine Compatibility sections to existing ADRs
- **Missing control manifest?** → `/saas-create-control-manifest` (requires Accepted ADRs)
- **Missing epics?** → `/saas-create-epics layer: foundation` then `/saas-create-epics layer: core` (requires control manifest)
- **Missing stories for an epic?** → `/saas-create-stories [epic-slug]` (run after each epic is created)
- **Stories not implementation-ready?** → `/saas-story-readiness` to validate stories before developers pick them up
- **Tests failing?** → delegate to `lead-engineer` or `qa-manual-tester`
- **No usability test data?** → `/saas-usability-test`
- **No usability test sessions beyond the minimum?** → Additional sessions give more reliable signal. 3+ total is recommended before committing the full team. Use `/saas-usability-test` to structure findings.
- **No Difficulty Curve doc?** → Author `design/usage-limits-quota-model.md` by hand from the template at `.claude/docs/templates/usage-limits-quota-model.md`. (`/saas-quick-design` is a related session but writes to `design/quick-specs/`, not to this path — use it to think the curve through, then copy the outcome here.)
- **No customer journey map?** → Author `design/customer-journey-map.md` by hand from the template at `.claude/docs/templates/customer-journey-map.md`.

> **Neither of these has a skill that writes it — do not name one.**
> "`/saas-ux-design` Phase 2b" is the step that *reads* `design/customer-journey-map.md`,
> so it lands the user back at the check that just failed. `/saas-quick-design`
> writes `design/quick-specs/[name]-[date].md` and leaves this gate still
> failing. Say plainly that both docs are hand-authored from their templates.
- **Need a quick sprint check?** → `/saas-sprint-status` for current sprint progress snapshot
- **Performance unknown?** → `/saas-perf-profile`
- **Not localized?** → `/saas-localize`
- **No security audit, or open CRITICAL/HIGH findings?** → `/saas-security-audit` (after fixes, `/saas-security-audit quick` to confirm)
- **Ready for release?** → `/saas-launch-checklist`

---
