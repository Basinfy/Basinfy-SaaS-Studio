# Skill Test Spec: /saas-asset-spec

## Skill Summary

`/saas-asset-spec` turns one target's visual needs into asset specs with AI generation
prompts. The argument names a target — `feature:<name>`, `screen:<name>` or
`brand:<name>` (an `entity:` entry from the catalog is read like a
component) — plus an optional `--review full|lean|solo`. It reads the design tokens
at `design/ui/design-tokens.md` (and stops if it is missing, unless the minimal-path
exception applies), `performance.*` and `naming.*` from `project.yaml`, and the
target's source doc. It confirms the identified asset list with the user, drafts
one `ASSET-NNN` block per asset, and after approval writes **one file per target**
to `design/assets/specs/[target-name]-assets.md`, then updates
`design/assets/asset-manifest.md`. Asset IDs run sequentially across the whole
project. A re-run for a target whose spec file exists updates that file in place
(existing blocks and IDs kept, new assets appended) after "May I update".

The resolved review mode decides who drafts: `full` spawns `design-system-director` and
`ui-motion-designer` in parallel, `lean` spawns `design-system-director` only, `solo` (the
default, via `modes.rigor: minimal`) spawns no agents; `full` is also what
`modes.rigor: full` resolves to. Every skipped agent is announced by name in
the output. These are drafting consultations, not gates. The skill produces an
artifact, not a judgement, so it has no run verdict; it closes with an
`AskUserQuestion` offering the next target or `/saas-asset-audit`.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Check 3 passes on the `BLOCKED` keyword of its Error Recovery Protocol; the skill has no run verdict by design (artifact producer), and the run closes with "Asset specs complete for **[target]**. What's next?"
- [ ] Contains "May I write" language for the spec file and "May I update" for the manifest
- [ ] Has a next-step handoff (`/saas-asset-spec [next-context]`, `/saas-asset-audit`)

---

## Director Gate Checks

No gate IDs and no `/saas-gate-check`. The review mode controls drafting agents only:

- **Full mode** (what `modes.rigor: full` resolves to): `design-system-director` and
  `ui-motion-designer` spawned in parallel
- **Lean mode**: `design-system-director` only; the output says "ui-motion-designer skipped —
  Lean mode: technical constraints not validated."
- **Solo mode** (default at `modes.rigor: minimal`): no agents; the main session
  derives specs from the design tokens, and the output names both skipped agents and
  says technical constraints were not validated

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — UI component spec in lean mode

**Fixture:**
- `project.yaml` sets `modes.rigor: standard` (review mode resolves to `lean`) and
  has `performance.*` and `naming.*` values
- `design/ui/design-tokens.md` exists with Shape Language, Color System and Section 8 Asset Standards
- `design/ui/components/tier-pro-badge.md` exists with a visual description
- No `design/assets/asset-manifest.md`

**Input:** `/saas-asset-spec ui-badge:tier-pro`

**Expected behavior:**
1. Skill reads the design tokens, project config and the component doc before asking anything
2. Skill presents the context summary ("Asset Spec: UI Badge — tier-pro")
3. Phase 2 identifies the component's assets (vector SVGs such as default, hover,
   active, disabled states; dark/light variants; icon glyphs), shows them grouped by category,
   and asks via `AskUserQuestion` before speccing
4. Lean mode: spawns `design-system-director` only, and says so: "ui-motion-designer skipped —
   Lean mode: technical constraints not validated."
5. Phase 4 presents one `ASSET-NNN` block per asset with the field table
   (Category, Dimensions, Format, Naming, Max File Size, Responsive Density), Visual
   Description, Design Token Anchors citing sections, Generation Prompt, and `Status: Needed`
6. After approval asks "May I write the spec to `design/assets/specs/tier-pro-badge-assets.md`?"
7. Creates the manifest after asking "May I update `design/assets/asset-manifest.md`?";
   IDs start at `ASSET-001`
8. Phase 6 `AskUserQuestion` offers another target or `/saas-asset-audit`

**Assertions:**
- [ ] Asset list is confirmed with `AskUserQuestion` before any spec is generated
- [ ] Only `design-system-director` is spawned (no `ui-motion-designer` in lean mode)
- [ ] The output names `ui-motion-designer` as skipped and says technical constraints were not validated
- [ ] Each asset block has the field table, Design Token Anchors (by section), a Generation Prompt and `Status: Needed`
- [ ] "May I write" names `design/assets/specs/tier-pro-badge-assets.md`
- [ ] Manifest is created with a Progress Summary and IDs starting at `ASSET-001`
- [ ] Phase 6 offers `/saas-asset-audit` among the next steps

---

### Case 2: No Design Tokens — Skill stops before speccing

**Fixture:**
- `project.yaml` sets `modes.rigor: standard`
- `design/prd/billing.md` exists with a Visual/Audio Requirements section
- `design/ui/design-tokens.md` does NOT exist
- `design/product-brief.md` does NOT exist

**Input:** `/saas-asset-spec system:core workflow`

**Expected behavior:**
1. Phase 1 reads for `design/ui/design-tokens.md` and finds nothing
2. The minimal-path exception does not apply (no product brief)
3. Skill stops with: "No design tokens found. Run `/saas-design-tokens` first — asset specs are
   anchored to the design tokens's visual rules and asset standards."
4. No asset identification, no agents, no files

**Assertions:**
- [ ] The "No design tokens found. Run `/saas-design-tokens` first" message is shown
- [ ] No asset list is presented and no `Agent` call is made
- [ ] No spec file or manifest is written
- [ ] Specs are not generated with invented style rules

---

### Case 3: Manifest Already Exists — IDs continue and shared assets are reused

**Fixture:**
- `project.yaml` sets `modes.rigor: standard`; design tokens exists
- `design/assets/asset-manifest.md` exists; the highest ID is `ASSET-014`, and
  `ASSET-012` (Generic Notification Bell Icon) is specced for the Core Workflow system in
  `design/assets/specs/core workflow-assets.md`
- `design/prd/notifications.md` Visual/Audio section lists a notification bell icon and a modal toast animation

**Input:** `/saas-asset-spec system:notifications`

**Expected behavior:**
1. Skill reads the manifest and globs `design/assets/specs/*.md` for shareable assets
2. Context summary lists the shared asset found in another spec
3. The bell icon reuses `ASSET-012` instead of creating a duplicate, with a note like
   "ASSET-012 (Generic Notification Bell Icon) already specced for Core Workflow system. Reusing for Notifications"
4. The new modal toast animation is numbered `ASSET-015`
5. After "May I write" for `design/assets/specs/notifications-assets.md`, the skill asks
   "May I update `design/assets/asset-manifest.md`?", appends a Notifications context
   block, and updates the Progress Summary counts

**Assertions:**
- [ ] The bell icon references `ASSET-012`; no duplicate icon spec is created
- [ ] The new asset's ID is `ASSET-015` (project-wide sequence, not restarted per target)
- [ ] The manifest is appended to, not recreated, after a "May I update" ask
- [ ] Progress Summary counts are updated

---

### Case 4: Several Assets in One Target — One file, per-asset revision before write

**Fixture:**
- `project.yaml` sets `modes.rigor: standard`; design tokens exists; no manifest
- `design/prd/billing.md` Visual/Audio section names an empty-state illustration (SVG), a status
  badge pill (UI) and a notification tone (audio)

**Input:** `/saas-asset-spec system:core workflow`

**Expected behavior:**
1. Phase 2 lists all three assets grouped under SVG, UI and Audio and asks the user to confirm
2. Phase 4 presents `ASSET-001` to `ASSET-003`; the audio asset carries a
   description of its sonic character and no image generation prompt
3. User picks `[B] Revise a specific asset` for the badge pill; the skill revises
   it inline and re-presents without re-spawning agents
4. User approves all; the skill asks "May I write" **once**, for
   `design/assets/specs/core workflow-assets.md`, which holds all three assets

**Assertions:**
- [ ] One "May I write" ask covers all three assets in one file (not one ask or file per asset)
- [ ] The audio asset has no image generation prompt
- [ ] The minor revision does not re-spawn `design-system-director`
- [ ] All three `ASSET-NNN` blocks are in `design/assets/specs/core workflow-assets.md`

---

### Case 5: Director Gate Check — Solo default, brief instead of design tokens

**Fixture:**
- `project.yaml` has no `modes` block (review mode resolves to `solo` via `modes.rigor: minimal`)
- `design/product-brief.md` exists with a Visual & UI direction line
- No `design/ui/design-tokens.md`
- No user profile for `user-avatar` in `design/assets/entity-inventory.md`

**Input:** `/saas-asset-spec component:user-avatar`

**Expected behavior:**
1. The minimal-path exception applies: the skill does not stop, and states at the top
   "Anchored to the brief's one-line design direction; there is no design tokens, so colour,
   shape and asset-standard rules below are proposals, not constraints."
2. `/saas-design-tokens` is offered once, as optional
3. No profile found → `AskUserQuestion`: "No profile found for **user-avatar**. Describe it
   briefly" with Describe / Skip / Stop options
4. Solo mode: no `Agent` calls; the output announces "design-system-director and
   ui-motion-designer skipped — Solo mode: specs derived in this session; technical
   constraints not validated."
5. No gate IDs appear and `/saas-gate-check` is not invoked

**Assertions:**
- [ ] Skill continues without an design tokens and says the specs are anchored to the brief
- [ ] Missing profile triggers the "Describe it briefly" question rather than a failure
- [ ] No `design-system-director` or `ui-motion-designer` is spawned
- [ ] Both skipped agents are named in the output, which says technical constraints were not validated
- [ ] If the spec is written, its header names `design/product-brief.md` as the design direction (no `> **Design Tokens**:` line), each asset carries a `**Brief anchor:**` line instead of Design Token Anchors, and no Design Tokens section or §8 tier is cited
- [ ] No gate IDs appear — the skip note names agents, not gates

---

### Case 6: Re-run on an Existing Spec — Updated in place, not overwritten

**Fixture:**
- `project.yaml` sets `modes.rigor: standard`; design tokens exists
- `design/assets/specs/tier-pro-badge-assets.md` exists with `ASSET-001` to
  `ASSET-004` (badge-light, badge-dark, badge-icon, badge-glow); the manifest's highest ID
  is `ASSET-009`
- `design/ui/components/tier-pro-badge.md` has since gained a hover animation state
  ability

**Input:** `/saas-asset-spec ui-badge:tier-pro`

**Expected behavior:**
1. Phase 1 reads the existing spec file for this target as well as the component doc
2. Phase 2 proposes only what is new — the hover state vector and animated pulse SVG — and
   confirms the list with the user
3. The new assets are numbered `ASSET-010` and `ASSET-011` (project-wide sequence)
4. The skill shows what changes, then asks "May I update
   `design/assets/specs/tier-pro-badge-assets.md`?" — not "May I write"
5. `ASSET-001` to `ASSET-004` are kept unchanged in the file; the new blocks are appended

**Assertions:**
- [ ] The existing spec file is detected and read before the asset list is proposed
- [ ] The ask is "May I update", naming the existing file
- [ ] Existing blocks and IDs are preserved; the file is not overwritten wholesale
- [ ] New assets continue the project-wide ID sequence (`ASSET-010`, `ASSET-011`)

---

## Protocol Compliance

- [ ] Reads the design tokens, project config and source doc before asking the user anything
- [ ] Never specs assets before the user confirms the asset list
- [ ] Spawns agents strictly per the resolved review mode (`--review` overrides for one run), and names every skipped agent in the output
- [ ] Surfaces any design-system-director / ui-motion-designer conflict instead of silently resolving it
- [ ] Asks "May I write" before a new spec file, "May I update" before changing an existing one, and "May I update" before the manifest
- [ ] Assigns asset IDs sequentially across the project, reading the manifest first

---

## Coverage Notes

- The no-argument flow (pick the next "Needed" item from
  `design/assets/entity-inventory.md`, or build the inventory in Phase 0b) is not
  separately tested.
- `screen:` targets and full-mode parallel spawning with a surfaced
  design-system-director / ui-motion-designer conflict are not separately tested.
- Agent BLOCKED handling (Error Recovery Protocol: always produce a partial spec)
  is not separately tested.
