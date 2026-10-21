# /saas-design-system — Phase 4: Section-by-Section Design

> Part of `/saas-design-system`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 4. Section-by-Section Design

**In this file:**

- The Section Cycle
- Section-Specific Guidance
- Section A: Overview
- Section B: User Stories & Personas
- Section C: Detailed Design (Core Rules, States, Interactions)
- Section D: Formulas
- Section E: Edge Cases
- Section F: Dependencies
- Section G: Configuration & Parameters
- Section H: Acceptance Criteria
- Optional Sections: Visual & Assets, UX Feel & Micro-interactions, UI Requirements, Cross-References, Open Questions

**Author only the sections required at the resolved tier** (§1). At `standard`,
the walk covers A (Overview), C (Detailed Design), E (Edge Cases),
F (Dependencies), H (Acceptance Criteria) — plus D (Formulas) when the system
defines numeric rules (see §1; the category is a hint, not the test); skip B (User Stories & Personas) and
G (Configuration & Parameters) unless `workflow_overrides.configuration: true` forces G. At
`full`, walk all eight (A–H). At `minimal`, the PRD is optional — if authoring
voluntarily, walk the standard set. Any `system_overrides.<system>` tier was
already folded into the resolved tier in §1.

Walk through each required section in order. For **each section**, follow this cycle:

### The Section Cycle

```
Context  ->  Questions  ->  Options  ->  Decision  ->  Draft  ->  Approval  ->  Write
```

1. **Context**: State what this section needs to contain, and surface any relevant
   decisions from dependency PRDs that constrain it.

2. **Questions**: Ask clarifying questions specific to this section. Use
   `AskUserQuestion` for constrained questions, conversational text for open-ended
   exploration.

3. **Options**: Where the section involves design choices (not just documentation),
   present 2-4 approaches with pros/cons. Explain reasoning in conversation text,
   then use `AskUserQuestion` to capture the decision.

4. **Decision**: User picks an approach or provides custom direction.

5. **Draft**: Write the section content in conversation text for review. Flag any
   provisional assumptions about undesigned dependencies.

6. **Approval**: Per the resolved `modes.automation` mode
   (`.claude/docs/automation-modes.md`):

   **In `collaborative` mode**: Immediately after the draft — in the SAME
   response — use `AskUserQuestion`. **NEVER use plain text. NEVER skip
   this step.**
   - Prompt: "Approve the [Section Name] section?"
   - Options: `[A] Approve — write it to file` / `[B] Make changes — describe what to fix` / `[C] Start over`

   **The draft and the approval widget MUST appear together in one response.
   If the draft appears without the widget, the user is left at a blank prompt
   with no path forward — this is a protocol violation in collaborative mode.**

   **In `guided` mode**: Write the section immediately after the draft with
   a brief one-line summary of what was decided. Skip the per-section widget;
   the multi-section authoring rule (no per-section confirmation) applies.

   **In `autonomous` mode**: Write the section directly and call
   `log_decision` with `Decision point: Approve [Section Name] section`,
   `Chosen: [A] Approve`, `Category: minor`.

7. **Write**: Use the Edit tool to replace the placeholder with the approved content.
   **CRITICAL**: Always include the section heading in the `old_string` to ensure
   uniqueness — never match `[To be designed]` alone, as multiple sections use the
   same placeholder and the Edit tool requires a unique match. Use this pattern:
   ```
   old_string: "## [Section Name]\n\n[To be designed]"
   new_string: "## [Section Name]\n\n[approved content]"
   ```
   Confirm the write.

8. **Registry conflict check** (Sections C and D only — Detailed Design and Formulas):
   After writing, scan the section content for entity names, item names, formula
   names, and numeric constants that appear in the registry. For each match:
   - Compare the value just written against the registry entry.
   - If they differ: **surface the conflict immediately** before starting the next
     section. Do not continue silently.
     > "Registry conflict: [name] is registered in [source PRD] as [registry_value].
     > This section just wrote [new_value]. Which is correct?"
   - If new (not in registry): flag it as a candidate for registry registration
     (will be handled in Phase 5).

After writing each section, update `production/session-state/active.md` with the
completed section name. Use Glob to check if the file exists — use Write to create
it if absent, Edit to update it if present.

### Section-Specific Guidance

Each section has unique design considerations and may benefit from specialist agents:

**Every skipped spawn is announced.** When a section's review-mode check below
skips its specialist — in `lean` as well as `solo` — print that section's note
with the mode it ran in, e.g. "`product-director` not consulted — Lean mode.
Review manually before production." A section drafted without its specialist
must say so in the output, whichever mode skipped it.

---

### Section A: Overview

**Goal**: One paragraph a stranger could read and understand.

**Derive recommended options before building the widget**: Read the system's category and layer from the systems index (already in context from Phase 2), then determine the recommended option for each tab:
- **Framing tab**: keyed on the `Category` column (`Core · Core Business Workflow · Progression · Economy · Persistence · UI · Audio · Narrative · Meta`). User-facing — `Core Business Workflow`, `UI`, `Audio`, `Narrative` → `[C] Both` recommended. Internal — `Core`, `Persistence`, `Meta` → `[A]` recommended. Mixed — `Economy`, `Progression` → `[C] Both`. **Tiebreak, when Layer and Category disagree** (a `Foundation`-layer `Core Business Workflow` system is the common case): **Category wins** — the framing describes what the section is *about*, and a user-facing system stays user-facing wherever it sits in the dependency graph.
- **ADR ref tab**: Glob `docs/architecture/adr-*.md` and grep for the system name in the PRD Requirements section of any ADR. If a matching ADR is found → `[A] Yes — cite the ADR` recommended. If none found → `[B] No` recommended.
- **Personas tab**: Foundation/Infrastructure layer → `[B] No` recommended. All other categories → `[A] Yes` recommended.

Append `(Recommended)` to the appropriate option text in each tab.

**Framing questions (ask BEFORE drafting)**: Use `AskUserQuestion` with a multi-tab widget:
- Tab "Framing" — "How should the overview frame this system?" Options: `[A] As a data/infrastructure layer (technical framing)` / `[B] Through its user-facing effect (design framing)` / `[C] Both — describe the data layer and its user impact`
- Tab "ADR ref" — "Should the overview reference the existing ADR for this system?" Options: `[A] Yes — cite the ADR for implementation details` / `[B] No — keep the PRD at pure design level`
- Tab "Personas" — "Does this system have direct user-facing workflows and personas?" Options: `[A] Yes — users interact with it directly` / `[B] No — pure infrastructure, users interact with what it enables`

Use the answers to shape the draft. **In `collaborative` mode, do NOT answer
these questions yourself and auto-draft** — the widget must appear. In `guided`
and `autonomous`, this is a MINOR framing decision: select the recommended
option derived above, state it in one line, and proceed (that is the whole
point of pre-deriving recommendations). Applies to every "ask BEFORE drafting"
widget in this section walk, not just this one.

**Questions to ask**:
- What is this system in one sentence?
- How does a user interact with it? (active/passive/automatic)
- Why does this system exist — what value would the product lose without it?

**Cross-reference**: Check that the description aligns with how the systems index
describes it. Flag discrepancies.

**Design vs. implementation boundary**: Overview questions must stay at the behavior
level — what the system *does*, not *how it is built*. If implementation questions
arise during the Overview (e.g., "Should this use an Autoload singleton or a signal
bus?"), note them as "→ becomes an ADR" and move on. Implementation patterns belong
in `/saas-architecture-decision`, not the PRD. The PRD describes behavior; the ADR
describes the technical approach used to achieve it.

---

### Section B: User Stories & Personas

**Goal**: The user target — who the user is, what problems they solve, and their core workflows.

**Derive recommended option before building the widget**: Read the system's category and layer from Phase 2 context:
Keyed on the `Category` column (`Core · Core Business Workflow · Progression · Economy · Persistence · UI · Audio · Narrative · Meta`):
- User-facing — `Core Business Workflow`, `UI`, `Audio`, `Narrative` → `[A] Direct` recommended
- Internal — `Core`, `Persistence`, `Meta` → `[B] Indirect` recommended
- Mixed — `Economy`, `Progression` → `[C] Both` recommended

**When Layer and Category disagree, Category wins** — same tiebreak as the
Framing tab above.

Append `(Recommended)` to the appropriate option text.

**Framing question (ask BEFORE drafting)**: Use `AskUserQuestion`:
- Prompt: "Is this system something the user engages with directly, or infrastructure they experience indirectly?"
- Options: `[A] Direct — user actively uses or experiences this feature` / `[B] Indirect — user experiences the business outcome, not the system directly` / `[C] Both — has a direct interface layer and infrastructure beneath it`

Use the answer to frame the User Stories & Personas section appropriately. Do NOT assume the answer.

**Questions to ask**:
- What user persona or business role does this serve?
- What benchmark products nail this experience? What specifically creates it?
- Is this a "system users interact with daily" or "infrastructure that runs invisibly in the background"?

**Cross-reference**: Must align with the product pillars. If the system serves a pillar,
quote the relevant pillar text.

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note: "`product-director` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this is a section with HIGH implementation risk (Sections D and H only). For other sections, draft without the agent.
- `full` → spawn as described below.

**Agent delegation (MANDATORY)**: After the framing answer is given but before drafting,
spawn `product-director` via `Agent`:
- Provide: system name, framing answer (direct/indirect/both), product pillars, any reference products the user mentioned, the product concept summary
- Ask: "Shape the User Value Framing for this system. What user pain or desire should it serve? What key user moment should we anchor to? What tone and language fits the product's established positioning? Be specific — give me 2-3 candidate framings."
- Collect the product-director's framings and present them to the user alongside the draft.

**Do NOT draft Section B without first consulting `product-director`.** The framing
answer tells us *what kind* of fantasy it is; the product-director shapes *how it's
described* — tone, language, the specific user moment to anchor to.

---

### Section C: Detailed Design (Core Rules, States, Interactions)

**Goal**: Unambiguous specification a programmer could implement without questions.

This is usually the largest section. Break it into sub-sections:

1. **Core Rules**: The fundamental business rules and workflows. Use numbered rules for sequential
   processes, bullets for properties.
2. **States and Transitions**: If the system has states, map every state and
   every valid transition. Use a table.
3. **Interactions with Other Systems**: For each dependency (upstream and downstream),
   specify what data flows in, what flows out, and who owns the interface.

**Questions to ask**:
- Walk me through a typical use of this system, step by step
- What are the decision points the user faces?
- What can the user NOT do? (Constraints are as important as capabilities)

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note naming them: "`[the Section 6 routing table's Primary and Supporting Agents for this category]` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this is a section with HIGH implementation risk (Sections D and H only). For other sections, draft without the agent.
- `full` → spawn as described below.

**Agent delegation (MANDATORY)**: Before drafting Section C, spawn specialist agents via `Agent` in parallel:
- Look up the system category in the routing table (Section 6 of this skill)
- Spawn the Primary Agent AND Supporting Agent(s) listed for this category
- Provide each agent: system name, product concept summary, pillar set, dependency PRD excerpts, the specific section being worked on
- Collect their findings before drafting
- Surface any disagreements between agents to the user via `AskUserQuestion`
- Draft only after receiving specialist input

**Do NOT draft Section C without first consulting the appropriate specialists.** A `database-architect` reviewing rules and schema logic will catch design gaps the main session cannot.

**Cross-reference**: For each interaction listed, verify it matches what the
dependency PRD specifies. If a dependency defines a value or formula and this
system expects something different, flag the conflict.

---

### Section D: Formulas

**Goal**: Every mathematical formula, with variables defined, ranges specified,
and edge cases noted.

**Completion Steering — always begin each formula with this exact structure:**

```
The [formula_name] formula is defined as:

`[formula_name] = [expression]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| [name] | float/int | [min–max] | data file / calculated / constant | [what it represents] |

**Output Range:** [min] to [max] under normal play; [behaviour at extremes]
**Example:** [worked example with real numbers]
```

Do NOT write `[Formula TBD]` or describe a formula in prose without the variable
table. A formula without defined variables cannot be implemented without guesswork.

> **These columns match `templates/guidance/prd-guide.md`
> exactly; do not rename them.** The `Source` column carries
> the coding-standards rule *"core business workflow values must be data-driven (external
> config), never hardcoded"* into the design document — a variable marked
> `data file` is a configurable parameter, one marked `constant` is a deliberate exception,
> and the distinction is invisible under a `Symbol` column. Put a symbol, where
> one helps, in the expression itself.

**Questions to ask**:
- What are the core calculations this system performs?
- Should scaling be linear, logarithmic, or stepped?
- What should the output ranges be at early/growth/enterprise scale?

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note: "`database-architect` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this is a section with HIGH implementation risk (Sections D and H only). For other sections, draft without the agent.
- `full` → spawn as described below.

**Agent delegation (MANDATORY)**: Before proposing any formulas or balance values, spawn specialist agents via `Agent` in parallel:
- **Always spawn `database-architect`**: provide Core Rules from Section C, tuning goals from user, balance context from dependency PRDs. Ask them to propose formulas with variable tables and output ranges.
- **For economy/cost systems, also spawn `billing-engineer`**: provide placement costs, upgrade cost intent, and progression goals. Ask them to validate cost curves and ratios.
- Present the specialists' proposals to the user for review via `AskUserQuestion`
- The user decides; the main session writes to file
- **Do NOT invent formula values or balance numbers without specialist input.** A user without balance design expertise cannot evaluate raw numbers — they need the specialists' reasoning.

**Cross-reference**: If a dependency PRD defines a formula whose output feeds into
this system, reference it explicitly. Don't reinvent — connect.

---

### Section E: Edge Cases

**Goal**: Explicitly handle unusual situations so they don't become bugs.

**Completion Steering — format each edge case as:**
- **If [condition]**: [exact outcome]. [rationale if non-obvious]

Example (adapt terminology to the product domain):
- **If [resource] reaches 0 while [protective condition] is active**: hold at minimum until condition ends, then apply consequence.
- **If two [triggers/events] fire simultaneously**: resolve in [defined priority order]; ties use [defined tiebreak rule].

Do NOT write vague entries like "handle appropriately" — each must name the exact
condition and the exact resolution. An edge case without a resolution is an open
design question, not a specification.

**Questions to ask**:
- What happens at zero? At maximum? At out-of-range values?
- What happens when two rules apply at the same time?
- What happens if a user finds an unintended interaction? (Identify degenerate strategies)

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note: "`database-architect` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this is a section with HIGH implementation risk (Sections D and H only). For other sections, draft without the agent.
- `full` → spawn as described below.

**Agent delegation (MANDATORY)**: Spawn `database-architect` via `Agent` before finalising edge cases. Provide: the completed Sections C and D, and ask them to identify edge cases from the formula and rule space that the main session may have missed. For narrative systems, also spawn `ux-content-strategist`. Present their findings and ask the user which to include.

**Cross-reference**: Check edge cases against dependency PRDs. If a dependency
defines a floor, cap, or resolution rule that this system could violate, flag it.

---

### Section F: Dependencies

**Goal**: Map every system connection with direction and nature.

This section is partially pre-filled from the context gathering phase. Present the
known dependencies from the systems index and ask:
- Are there dependencies I'm missing?
- For each dependency, what's the specific data interface?
- Which dependencies are hard (system cannot function without it) vs. soft
  (enhanced by it but works without it)?

**Cross-reference**: This section must be bidirectionally consistent. If this system
lists "depends on Billing", then the Billing PRD should list "depended on by [this
system]". Flag any one-directional dependencies for correction.

---

### Section G: Configuration & Parameters

**Goal**: Every admin- or user-configurable parameter, environment setting, and feature flag, with safe ranges and fallback behaviors.

**Questions to ask**:
- What values should operators/admins be able to configure without code changes?
- For each parameter, what breaks if it's set too high? Too low?
- Which parameters interact with each other? (Changing A makes B irrelevant)

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Derive the parameters from Section D's variable table yourself. Add a note: "`database-architect` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless Section D defines a formula whose parameters interact (changing one makes another inert).
- `full` → delegate as described below.

**Agent delegation**: If formulas are complex, delegate to `database-architect`
to derive configuration parameters from the formula variables.

> This delegation names `database-architect`, the same agent Section D's guard
> already tells a `solo` run to skip. Without the guard above, `solo` skips the
> specialist for the formulas and then consults it for the parameters derived from
> those same formulas.

**Cross-reference**: If a dependency PRD lists configuration parameters that affect this system,
reference them here. Don't create duplicate parameters — point to the source of truth.

---

### Section H: Acceptance Criteria

**Goal**: Testable conditions that prove the system works as designed.

**Completion Steering — format each criterion as Given-When-Then:**
- **GIVEN** [initial state], **WHEN** [action or trigger], **THEN** [measurable outcome]

Example (adapt terminology to the product domain):
- **GIVEN** [initial state], **WHEN** [user action or system trigger], **THEN** [specific measurable outcome].
- **GIVEN** [a constraint is active], **WHEN** [user attempts an action], **THEN** [feedback shown and action result].

Include at least: one criterion per core rule from Section C, and one per formula
from Section D. Do NOT write "the system works as designed" — every criterion must
be independently verifiable by a QA tester without reading the PRD.

> **When Section D was not authored** (Formulas optional at this tier because the
> system defines no numeric rule), there are no formulas to cover and the
> criteria come from Section C alone — say so in one line rather than silently
> writing fewer criteria. **If Section D was skipped but Section C states a
> quantity** — a rate, threshold, cost or curve — that is the §1 test being met
> after the fact: stop, tell the user Formulas is required for this system, and
> author it before finalising the criteria. A criterion cannot verify a number
> the PRD never defines.
>
> **That escalation applies at `standard` only.** It re-runs §1's *conditional*
> Formulas test, and §1 disables that conditional at `minimal` outright — *"the
> conditional Formulas rule does NOT re-apply at minimal"*. At `minimal` a
> Section C quantity is expected and does **not** pull Formulas back in: state
> the value inline in Core Rules so it stays implementable, and move on. At
> `full`, Section D is unconditionally required, so the case cannot arise. Read
> without this scope, the two rules contradict each other for any `minimal`
> system that defines a rate — which is most of them.

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note: "`qa-lead` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this is a section with HIGH implementation risk (Sections D and H only). For other sections, draft without the agent.
- `full` → spawn as described below.

**Agent delegation (MANDATORY)**: Spawn `qa-lead` via `Agent` before finalising acceptance criteria. Provide: the completed PRD sections C, D, E, and ask them to validate that the criteria are independently testable and cover all core rules and formulas. Surface any gaps or untestable criteria to the user.

**Questions to ask**:
- What's the minimum set of tests that prove this works?
- What performance budget does this system get? (frame time, memory)
- What would a QA tester check first?

**Cross-reference**: Include criteria that verify cross-system interactions work,
not just this system in isolation.

---

### Optional Sections: Visual & Assets, UX Feel & Micro-interactions, UI Requirements, Cross-References, Open Questions

These five are the template sections that are **not** among §1's eight. They are
governed here, not by the tier: §1's per-tier lists decide the *required* set,
and this block decides the rest independently. Adding a section here therefore
never changes a tier's section count.

Visual & Assets and UX Feel & Micro-interactions are **REQUIRED** for some categories — not optional.
Determine the requirement level before asking:

**Keyed on the `Category` column of `features-modules-index.md`** — the nine values
`templates/features-modules-index.md` defines. Every one of the nine appears below
exactly once, so nothing falls through:

**Visual & Assets is REQUIRED (mandatory — do not offer to skip) for:**
- `Core Business Workflow` — primary application workflows, user actions, data processing: everything the user operates
- `UI` — dashboard, navigation, forms, modal dialogs
- `Content` — marketing copy, documentation, transactional messaging
- `Integration` — third-party connections and webhooks

> **`Core Business Workflow` belongs in this list.** It is the category `/saas-map-features` assigns
> to primary product functionality — the core value driver in SaaS software.

For required systems: **spawn `design-system-director` via `Agent`** before drafting this section. Provide: system name, product concept, product pillars, design tokens sections 1–4 if they exist. Ask them to specify: (1) visual hierarchy and feedback requirements for this system's events, (2) any component animation or visual style constraints, (3) which design tokens principles most directly apply to this system. Present their output; do NOT leave this section as `[To be designed]` for visual systems.

**Review mode check** (apply before spawning):
- `solo` → skip this agent spawn. Draft the section without the specialist. Add a note: "`design-system-director` not consulted — Solo mode. Review manually before production."
- `lean` → skip unless this system's visual feedback is central to it (a `Core Business Workflow` or `UI` system whose events the user reads to operate). Otherwise draft without the agent.
- `full` → spawn as described above.

> This block applies even though the spawn above is worded as mandatory (*"do
> NOT leave this section as `[To be designed]`"*). `director-gates.md`'s *"solo
> → no director gates anywhere"* governs director **gates**, not specialist
> spawns, so it does not settle this spawn — this block does.

**UX Feel & Micro-interactions is REQUIRED (mandatory — do not offer to skip) for `Core Business Workflow` and
`UI`** — the categories whose systems the user directly operates, where
responsiveness, loading skeletons, latency feedback, and transition snappiness are design targets rather than polish. It is
optional for the other seven. Feel *"drives performance budgets, interaction feedback architecture, and state timing. Retrofitting
feel targets after implementation is expensive."*

**Cross-References is REQUIRED whenever the Dependencies section names another
PRD.** The rule is derived, not category-keyed: if this document references
another system's feature, parameter, or business rule anywhere, that reference belongs in the
table. Where Dependencies names nothing, write *"None — this system references no
other PRD"* rather than leaving the placeholder. `/saas-review-all-prds` Phase 2c
reads this table when it exists.

For the remaining categories — `Foundation`, `Core`, `Billing`,
`Integration`, `Meta` — UI/UX styling notes are optional: offer the optional sections
after the required sections.

> **At `minimal`, force nothing.** §1 says a voluntary `minimal` PRD is *"exactly
> the 5 standard sections"*, which contradicts a category rule that makes
> Visual/Audio or UI Polish & Microcopy mandatory. §1 wins: at `minimal` both drop to
> optional and the whole set goes through the widget below.

Use `AskUserQuestion`:
- "The required sections for this workflow tier are complete. Which of the
  remaining template sections do you want to define?"
  - Options: "All of them", "Just Cross-References and open questions", "Skip — I'll add these later"
  - List in the question only the ones still outstanding: Visual/Audio, UI Polish & Micro-interactions, UI Requirements, Cross-References, Open Questions **minus** any this
    system's category or dependencies already made mandatory above. Offering to
    skip a section the rules just made required is how a mandatory section gets
    skipped.
  - **Recommended option**: "All of them" when the system has any dependency,
    UI surface or user-facing feedback; "Just Cross-References and open
    questions" otherwise. `autonomous` needs a marked recommendation to pick:
    without one an unattended run has nothing to choose by and skips.

  Do **not** state a section count here. The required set is tier-dependent
  (§1: 8 at `full`, 5 + conditional Formulas at `standard`, 5 at a voluntary
  `minimal`), so a fixed "8 required sections are complete" is false on every
  run below `full` — it tells a `standard`-tier user that 8 sections exist when
  6 have been authored.

For **Visual/Audio** (non-required systems): Coordinate with `design-system-director` and `growth-director` if detail is needed. Often a brief note suffices at the PRD stage.

> **Asset Spec Flag**: After the Visual/Audio section is written with real content, output this notice:
> "📌 **Asset Spec** — Visual/Audio requirements are defined. After design tokens are approved, run `/saas-asset-spec system:[system-name]` to produce per-asset visual descriptions, dimensions, and generation prompts from this section."

For **UI Requirements**: Coordinate with `ux-designer` for complex UI systems.
After writing this section, check whether it contains real content (not just
`[To be designed]` or a note that this system has no UI). If it does have real
UI requirements, output this flag immediately:

> **📌 UX Flag — [System Name]**: This system has UI requirements. In Phase 4
> (Pre-Production), run `/saas-ux-design` to create a UX spec for each screen or
> App Shell element this system contributes to **before** writing epics. Stories that
> reference UI should cite `design/ux/[screen].md`, not the PRD directly.
>
> Note this in the systems index for this system if you update it.

For **Open Questions**: Capture anything that came up during design that wasn't
fully resolved. Each question should have an owner and target resolution date.

---
