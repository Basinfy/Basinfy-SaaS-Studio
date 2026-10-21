---
name: saas-consistency-check
description: "Scan PRDs against the entity registry for cross-document conflicts. Index-first approach (Basinfy when .basinfy/ exists, else Grep) targets conflicting sections."
argument-hint: "[full | since-last-review | entity:<name> | item:<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash "*/.claude/skills/saas-consistency-check/../../hooks/yaml-helper.sh" resolve_config *), Bash(git log *), Bash(bash .claude/scripts/registry.sh validate*)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation,workflow,system_overrides`



# Consistency Check

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Detects cross-document inconsistencies by comparing all PRDs against the
entity registry (`design/registry/entities.yaml`). Uses an index-first approach (Basinfy smart indexing when `.basinfy/` exists, Grep fallback):
reads the registry once, then targets only the PRD sections that mention
registered names — no full document reads unless a conflict needs investigation.

**This skill is the write-time safety net.** It catches what `/saas-design-system`'s
per-section checks may have missed and what `/saas-review-all-prds`'s holistic review
catches too late.

**When to run:**
- After writing each new PRD (before moving to the next system)
- Before `/saas-review-all-prds` (so that skill starts with a clean baseline)
- Before `/saas-create-architecture` (inconsistencies corrupt downstream ADRs)
- On demand: `/saas-consistency-check entity:[name]` to check one entity specifically

**Output:** Conflict report + optional registry corrections

---

Every `AskUserQuestion` call follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

**`workflow`** (see `.claude/docs/workflow-modes.md`), applied per PRD at its
**effective** tier — the `system_overrides` row for that PRD's system (its
filename stem) when the block lists one, else the project value:
- `full` — full entity-registry cross-check against all PRD sections.
- `standard` — cross-check against the required sections only. The report's
  Scope line says so, and each value stated for a registered name outside those
  sections is listed as not checked at this tier (Phase 3 applies this).
- `minimal` — not meaningful (no PRDs to check).

## Phase 1: Parse Arguments and Load Registry

**Modes:**
- No argument / `full` — check all registered entries against all PRDs
- `since-last-review` — check only PRDs modified since the last review report
- `entity:<name>` — check one specific entity across all PRDs
- `item:<name>` — check one specific item across all PRDs

**Load the registry:**

```
Read path="design/registry/entities.yaml"
```

If the file does not exist or has no entries:
> "Entity registry is empty. Run `/saas-design-system` to write PRDs — the registry
> is populated automatically after each PRD is completed. Nothing to check yet."

Verdict: **NOT ASSESSED — entity registry empty**. Stop: nothing was compared,
so there is no PASS to give and nothing to write.

Build four lookup tables from the registry:
- **entity_map**: `{ name → { source, attributes, referenced_by } }`
- **item_map**: `{ name → { source, value_gold, weight, ... } }`
- **formula_map**: `{ name → { source, variables, output_range } }`
- **constant_map**: `{ name → { source, value, unit } }`

Count total registered entries. Report:
```
Registry loaded: [N] entities, [N] items, [N] formulas, [N] constants
Scope: [full | since-last-review | entity:name]
```

For `entity:<name>` or `item:<name>`, if the registry has no entry by that name
the verdict is **NOT ASSESSED — `<name>` is not in the registry**: list the
closest registered names and stop. Checking an unregistered name compares
nothing, and that is not a PASS.

---

## Phase 2: Locate In-Scope PRDs

```
Glob pattern="design/prd/*.md"
```

Exclude the docs that live in `design/prd/` but are not system PRDs:
`product-concept.md`, `features-modules-index.md`, `product-pillars.md`, `core business workflow-tags.md`,
`entity-registry.md`, `fixture-swap-ledger.md`, `brand-voice-tone-guide.md` and any
`prd-cross-review-*.md` (the report `/saas-review-all-prds` writes here).

For `since-last-review` mode:
```bash
git log --name-only --pretty=format: -- design/prd/ | grep "\.md$" | sort -u
```
Limit to PRDs modified since the most recent `design/prd/prd-cross-review-*.md`
file's creation date.

Report the in-scope PRD list before scanning. **If the list is empty** — no system
PRDs exist, or `since-last-review` found none changed — the verdict is
**NOT ASSESSED — no PRDs in scope**: say which filter produced zero, and stop.
A scan of nothing finds no conflicts, and that is not a PASS.

---

## Phase 3: Grep-First Conflict Scan

For each registered entry, grep every in-scope PRD for the entry's name.
Do NOT do full reads — extract only the matching lines and their immediate
context (-C 3 lines).

This is the core optimization: instead of reading 10 PRDs × 400 lines each
(4,000 lines), you grep 50 entity names × 10 PRDs (50 targeted searches,
each returning ~10 lines on a hit).

**In a PRD whose effective tier is `standard`, compare only hits under a
required section.** The effective tier is per PRD: `system_overrides.<stem>`
replaces the project tier for that PRD in either direction (a `full` row makes
every section compared). Grep each such PRD once for `^## ` to get its headings
and line numbers, and file every name hit under the nearest heading above it:
only hits under Problem Statement, Requirements Pool / Detailed Design, Formulas, Edge
Cases, Dependencies, Data Models, Security or Acceptance Criteria are compared — plus Configuration Parameters when
`project.yaml` sets `workflow_overrides.configuration_parameters: true` (or `workflow_overrides.tuning_knobs: true`).
Any other hit (Configuration Parameters without the flag, User Personas, any other section) raises no finding and is not logged;
list each one that states a value (name, PRD, section) on the report's
`Not checked at this tier` line.

### 3a: Entity Scan

For each entity in entity_map:

```
Grep pattern="[entity_name]" glob="design/prd/*.md" output_mode="content" -C 3
```

For each PRD hit, extract the values mentioned near the entity name:
- any numeric attributes (counts, costs, durations, ranges, rates)
- any categorical attributes (types, tiers, categories)
- any derived values (totals, outputs, results)
- any other attributes registered in entity_map

Compare extracted values against the registry entry.

**Conflict detection:**
- Registry says `[entity_name].[attribute] = [value_A]`. PRD says `[entity_name] has [value_B]`. → **CONFLICT**
- Registry says `[item_name].[attribute] = [value_A]`. PRD says `[item_name] is [value_B]`. → **CONFLICT**
- PRD mentions `[entity_name]` but doesn't specify the attribute. → **NOTE** (no conflict, just unverifiable)

### 3b: Item Scan

For each item in item_map, grep all PRDs for the item name. Extract:
- sell price / value / gold value
- weight
- stack rules (stackable / non-stackable)
- category

Compare against registry entry values.

### 3c: Formula Scan

For each formula in formula_map, grep all PRDs for the formula name. Extract:
- variable names mentioned near the formula
- output range or cap values mentioned

Compare against registry entry:
- Different variable names → **CONFLICT**
- Output range stated differently → **CONFLICT**

### 3d: Constant Scan

For each constant in constant_map, grep all PRDs for the constant name. Extract:
- Any numeric value mentioned near the constant name

Compare against registry value:
- Different number → **CONFLICT**

---

## Phase 4: Deep Investigation (Conflicts Only)

For each conflict found in Phase 3, do a targeted full-section read of the
conflicting PRD to get precise context:

```
Read path="docs/specs/[conflicting_prd].md"
```
(Or use Grep with wider context if the file is large)

Read it by section: check if `.basinfy/` exists: if present, use the Basinfy Protocol (`basinfy_search` then `basinfy_read`); otherwise find the conflicting section's heading with the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Basinfy Protocol (`basinfy_search` / `basinfy_read` if `.basinfy/` exists) or the Grep tool (pattern `^#`, content mode) and Read that range with offset and limit.

Confirm the conflict with full context. Determine:
1. **Which PRD is correct?** Check the `source:` field in the registry — the
   source PRD is the authoritative owner. Any other PRD that contradicts it
   is the one that needs updating.
2. **Is the registry itself out of date?** If the source PRD was updated after
   the registry entry was written (check git log), the registry may be stale.
3. **Is this a genuine design change?** If the conflict represents an intentional
   design decision, the resolution is: update the source PRD, update the registry,
   then fix all other PRDs.

For each conflict, classify:
- **🔴 CONFLICT** — same named entity/item/formula/constant with different values
  in different PRDs. Must resolve before architecture begins.
- **⚠️ STALE REGISTRY** — source PRD value changed but registry not updated.
  Registry needs updating; other PRDs may be correct already.
- **ℹ️ UNVERIFIABLE** — entity mentioned but no comparable attribute stated.
  Not a conflict; just noting the reference.

---

## Phase 5: Output Report

```
## Consistency Check Report
Date: [date]
Registry entries checked: [N entities, N items, N formulas, N constants]
PRDs scanned: [N] ([list names])
Scope: [all PRD sections | required sections only — workflow: standard | per PRD — name each PRD whose effective tier differs, and its tier]
Not checked at this tier: [each value stated outside the required sections (name, PRD, section) — or "none"; omit when every PRD is at `full`]

---

### Conflicts Found (must resolve before architecture)

🔴 [Entity/Item/Formula/Constant Name]
   Registry (source: [prd]): [attribute] = [value]
   Conflict in [other_prd].md: [attribute] = [different_value]
   → Resolution needed: [which doc to change and to what]

---

### Stale Registry Entries (registry behind the PRD)

⚠️ [Entry Name]
   Registry says: [value] (written [date])
   Source PRD now says: [new value]
   → Update registry entry to match source PRD, then check referenced_by docs.

---

### Unverifiable References (no conflict, informational)

ℹ️ [prd].md mentions [entity_name] but states no comparable attributes.
   No conflict detected. No action required.

---

### Clean Entries (no issues found)

✅ [N] registry entries verified across all PRDs with no conflicts.

---

Verdict: PASS | CONFLICTS FOUND | NOT ASSESSED
```

**Verdict:**
- **CONFLICTS FOUND** — one or more conflicts detected. List resolution steps.
- **NOT ASSESSED** — nothing was compared: the entity registry is empty or the
  named entity is not in it (Phase 1), or no PRDs were in scope (Phase 2). Say
  which.
- **PASS** — no conflicts. Registry and PRDs agree on all checked values, across at least one PRD.

---

## Phase 6: Registry Corrections

**Re-read before you write.** Phase 1 read the registry before the scans, and
another skill or session may have changed it since. Before each Edit, read the
current `design/registry/entities.yaml`, find the entry in its section, and
anchor the Edit on the entry's current text, never on what Phase 1 saw. Append
a new entry after the last existing entry of its section.

If stale registry entries were found, ask:
> "May I update `design/registry/entities.yaml` to fix the [N] stale entries?"

For each stale entry:
- Update the `value` / attribute field
- Set `revised:` to today's date
- Add a YAML comment with the old value: `# was: [old_value] before [date]`

If new entries were found in PRDs that are not in the registry, ask:
> "Found [N] entities/items mentioned in PRDs that aren't in the registry yet.
> May I add them to `design/registry/entities.yaml`?"

Only add entries that appear in more than one PRD (true cross-system facts).

**Never delete registry entries.** Set `status: deprecated` if an entry is removed
from all PRDs.

After writing, run `bash .claude/scripts/registry.sh validate` and fix every row
about an entry this write added or changed (a DUPLICATE, STATUS or LAYOUT row,
or a PATH_MISSING row for a path it named) before the verdict; name rows about
other entries to the user rather than fixing them unasked. If the script is
missing or prints nothing, say the registry check did not run, then re-read the
entries you wrote against the rules in the file's header.

After writing: Verdict: **COMPLETE** — consistency check finished.
If conflicts remain unresolved: Verdict: **BLOCKED** — [N] conflicts need manual resolution before architecture begins.

### 6b: Append to Reflexion Log

If any 🔴 CONFLICT entries were found (regardless of whether they were resolved),
ask: "May I append [N] entries to `docs/consistency-failures.md` (creating it if
absent)?" On yes, append an entry for each conflict; on no, say the conflicts
were not logged.

```markdown
### [YYYY-MM-DD] — /saas-consistency-check — 🔴 CONFLICT
**Domain**: [system domain(s) involved]
**Documents involved**: [source PRD] vs [conflicting PRD]
**What happened**: [specific conflict — entity name, attribute, differing values]
**Resolution**: [how it was fixed, or "Unresolved — manual action needed"]
**Pattern**: [generalised lesson, e.g. "Quota values defined in billing PRD were not
referenced in economy PRD before authoring — always check entities.yaml first"]
```

If `docs/consistency-failures.md` does not exist, create it with this header before appending:

```markdown
# Consistency Failure Log

<!-- Auto-maintained by /saas-consistency-check. Do not edit manually. -->
<!-- One entry per detected conflict, in chronological order. -->

| Date | PRD A | PRD B | Conflict Type | Status |
|------|-------|-------|---------------|--------|
```

Then append the new conflict entries. Never skip logging on your own — a missing file is not a reason to lose conflict history; only the user's "no" is.

---

## Phase 7: Session State and Closing

Silently append to `production/session-state/active.md` (create the file if it does not exist):

```
<!-- CONSISTENCY-CHECK: [date] | PRDs checked: [N] | Conflicts found: [N] | Log: docs/consistency-failures.md -->
```

> **Point at `docs/consistency-failures.md` — the file Phase 6 actually appends
> to.** A breadcrumb is a pointer left for a future session to follow. One that
> names a file nothing writes sends that session looking for conflict history it
> will never find, and nothing errors along the way. Never invent a report
> filename here.

Then close with an `AskUserQuestion` widget:

- **Prompt**: "Consistency check complete — [N] conflicts found. What next?"
- **Options**:
  - `[A] Fix the highest-priority conflict now`
  - `[B] Run /saas-design-review on the most conflicted PRD`
  - `[C] Stop here`

In collaborative and guided modes, never end the skill with plain text — always
close with this widget. In autonomous mode, print the findings and recommended
next step, then record via `log_decision` (no widget).

---

## Recovery / Reference

- **If PASS**: Run `/saas-review-all-prds` for holistic design-theory review, or
  `/saas-create-architecture` if all MVP PRDs are complete.
- **If CONFLICTS FOUND**: Fix the flagged PRDs, then re-run
  `/saas-consistency-check` to confirm resolution.
- **If STALE REGISTRY**: Update the registry (Phase 6), then re-run to verify.
- Run `/saas-consistency-check` after writing each new PRD to catch issues early,
  not at architecture time.
