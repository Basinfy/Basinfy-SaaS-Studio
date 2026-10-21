# Your Path

Here's your path at rigor `[value]`. Every skill still runs at any rigor; rigor changes
what's required, not what's allowed.

**`minimal`: 4 steps to running code**
1. `/saas-setup-stack`: choose and configure the stack
2. `/saas-brainstorm`: write the one-page `design/SaaS software-brief.md`
3. `/saas-create-stories`: turn the brief's MVP list into stories (no epics or sprint plan needed)
4. `/saas-dev-story`: the first line of SaaS software code

**`standard`**
- Concept: `/saas-setup-stack` → `/saas-brainstorm` → `/saas-prototype` → `/saas-design-tokens` → `/saas-gate-check`
- Systems Design: `/saas-map-features` → `/saas-design-system` (once per system) → `/saas-review-all-prds` →
  `/saas-gate-check`
- Architecture: `/saas-create-architecture` → `/saas-architecture-decision` (once per decision) →
  `/saas-create-control-manifest` → `/saas-architecture-review` → `/saas-test-setup` → `/saas-ux-design`
  (accessibility and interaction patterns) → `/saas-gate-check`
- Pre-Production: `/saas-ux-design` (App Shell and key views) → `/saas-create-epics` → `/saas-create-stories` →
  `/saas-sprint-plan` → `/saas-gate-check`
- Production: `/saas-dev-story`

Each `/saas-gate-check` moves the project one stage, and only when it passes.

**`full`:** everything in `standard`, plus `/saas-vertical-slice` and `/saas-usability-test` in
Pre-Production and `/saas-design-review` after each PRD.

**Path D with existing work** (stage `Systems Design` or later, or code on disk) gets this instead.
Print only the steps that apply, and for the brief only the one source that applies. At `minimal`:
1. `/saas-project-stage-detect`: what stage the project is at and what is missing
2. `/saas-adopt`: whether the existing files are in the format the skills read
3. `/saas-setup-stack`: only when no stack is set; leave it out when `stack` names one
4. The brief, only if `concept` is absent: `/saas-reverse-document design [code_root]` when the code
   root holds 10 or more source files (it writes the brief from the SaaS software), and then do not mention
   `/saas-brainstorm` at all; `/saas-brainstorm` only when it holds fewer

At `standard` and `full`, steps 1 to 3, then `/saas-design-system retrofit [path]`,
`/saas-architecture-decision retrofit [path]`, `/saas-architecture-review` and `/saas-gate-check`.

`minimal` is the documented floor, not a lesser mode. Its trade: no PRDs, so design
problems show up in code.
