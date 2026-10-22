# project.yaml — Effects Map

> ## READ ONE SECTION, NEVER THIS WHOLE FILE
>
> This document is very large, far more than any one lookup needs. It is
> organised as one section per setting, headed `## <key>`, so a reader can take
> only the section it wants.
>
> **So opening it whole costs many times what you need.** To look up a setting:
>
> ```
> Grep pattern="^## modes.review_mode" path=".claude/docs/effects-map.md" -A 40
> ```
>
> Read the section for your key and stop. The same rule the skills already apply
> to their own reference files — `/saas-gate-check` loads only the row for the target
> phase and says "never load the others" — applies here, and this is the largest
> file in the framework.
>
> Cite a section of this document, never the whole file. A pointer such as "see
> effects-map.md for full schema" invites a full read of a file this size, and
> the cost of accepting that invitation is silent. Name the `## <key>` section
> you need instead.

This document defines what each `project.yaml` setting actually does across
every skill that reads it. It is the tracked, authoritative reference.

**Purpose:** When a skill reads a setting, this document is the authoritative
source for what each value means for that skill's behavior. Implementers update
this file when adding a new setting or changing how a skill responds to one.

**Format per setting:**
- Priority chain — which source wins when multiple are present
- Per-value intent — what the value means in plain terms
- Skill behavior table — exactly what changes per skill per value

**Coverage scope:** This document covers the skills most affected by each setting.
Skills not listed (e.g. `saas-ux-review`, `saas-pricing-audit`, `saas-test-flakiness`, `saas-test-helpers`,
`saas-test-setup`, `saas-load-test`, `saas-perf-profile`, `saas-launch-checklist`, `saas-release-checklist`,
`saas-skill-test`, `saas-skill-improve`, `saas-vertical-slice`) are not meaningfully affected by
`project.yaml` settings and do not need entries here. Add a skill only when its
behavior genuinely branches on a setting value.

**Local override pattern:** `project.yaml` is committed to git as the shared team
config. Per-developer overrides live in `project.local.yaml` (gitignored). Priority
chain across all settings: `project.local.yaml` → `project.yaml` → legacy mirror →
`modes.rigor` expansion → hardcoded default. The expansion step applies only to the
six knobs `rigor` fronts (`modes.workflow`, `docs.density`, `qa.level`,
`modes.story_granularity`, `modes.review_mode`, `team.size`), which for that reason have **no** hardcoded default —
see the `modes.rigor` section.
**Secrets do NOT belong in either file — use environment variables.** See the
"Local Override Pattern" section below for full design including the whitelist of
which settings can be locally overridden.

---

## Local Override Pattern — `project.local.yaml`

The `project.local.yaml` file lets each developer override specific settings for
their own use without affecting the team. The file is gitignored and never
committed.

### How it works

Priority chain (every setting): `project.local.yaml` → `project.yaml` → hardcoded default

If a setting is present in `project.local.yaml`, that value wins. If absent, the
value from `project.yaml` is used. If absent there too, the hardcoded default
takes over.

---

### Deep merge semantics

When both files set a nested value, only the explicitly-set key is overridden.
Sibling keys in the same block are preserved.

Example:

`project.yaml`:
```yaml
testing:
  strict:
    logic: true
    integration: true
    visual: false
```

`project.local.yaml` (sparse override):
```yaml
testing:
  strict:
    logic: false
```

Effective config seen by skills: `logic: false, integration: true, visual: false`.
Only the explicitly-set `logic` key is overridden; sibling keys come through from
`project.yaml`.

---

### Whitelist — which settings can be locally overridden

Only personal-experience settings can be locally overridden. Project-wide facts
(stack, stage, naming conventions, what's required on disk) are locked to
`project.yaml` because divergence between developers would break team coordination.

The rule for deciding which side a setting belongs on:

> **If a setting affects what artifacts exist or what they look like on disk,
> it must be locked to `project.yaml`. If a setting only changes your personal
> experience (which agents spawn for you, whether you get prompts, your local
> CI bypass), it can be locally overridden.**

**Locally overridable** (personal experience only — no effect on artifacts on disk):

| Setting | Why local override makes sense |
|---------|-------------------------------|
| `modes.review_mode` | How much AI review you personally want |
| `modes.automation` | How often the AI prompts you |
| `modes.automation_always_ask` | Your personal safety categories |
| `team.size` | Which agents spawn for your reviews (review depth differs, artifacts don't) |
| `testing.strict.*` (each type) | Whether failures block your local work (CI still enforces project.yaml defaults) |
| `performance.enforce` | Whether budget violations block your local work (CI enforces project defaults) |
| `features.session_state` | Your session tracking preference |
| `features.token_budget_warn_at` | Your personal cost threshold |
| `features.read_guard` | Whether your whole-file reads of large design docs are refused |
| `features.read_guard_kb` | The size over which they are |
| `updates.check` | Whether you see the new-release line; turning it off for you leaves it on for teammates |

**Locked to `project.yaml`** (project-wide — would create artifact divergence if local):

| Setting | Why it must be project-wide |
|---------|----------------------------|
| `schema_version`, `framework.*` | File metadata, not preferences — **exempt from the report below**, since a `project.local.yaml` carrying `schema_version: 1` is correct as written |
| `project.name`, `version`, `genre`, `kind`, `stage` | Project identity |
| `stack.*`, `specialists.*` | Whole team must use same stack |
| `naming.*` | Code conventions must be consistent across team |
| `platform.*` | Product facts (what platforms it targets) |
| `performance.p99_latency_ms`, `max_bundle_size_kb`, `api_timeout_ms`, `memory_ceiling_mb` | Product budgets, shared targets |
| `accessibility.target` | Product commitment, project-wide |
| `cadence.*` | Sprint/milestone length affects team coordination |
| `modes.rigor` | Fronts the four below — locked for the same reason they are |
| `modes.workflow` and `workflow_overrides` | Affects which sections are required in authored docs |
| `modes.story_granularity` | Affects how big stories are in repo — team must be consistent |
| `docs.density` | Affects how deep authored docs are — team must produce consistent docs |
| `qa.level` | Affects what test evidence stories must include on disk |
| `qa.coverage_minimum` | Project quality bar |
| `strict_gate_checks` | Affects whether `project.stage` advances — a project-wide write |
| `commands.*` | Build/test commands are project facts |
| `testing.framework` | Whole project uses one framework |

> **A locked key written into `project.local.yaml` by hand is reported, not
> swallowed.** `/saas-settings --local` refuses to write one, but the
> file is meant to be hand-edited and that path had no guard: `modes.rigor: full`
> there is a real key with a legal value, so enum validation passes it, and then
> resolution never consults the local file for that path — the setting vanishes
> and the user sees the default they were trying to override, with no error
> anywhere. Every check validated the **value**; nothing validated the
> **location**. `validate_local_scope` in `yaml-helper.sh` now names such keys on
> `resolve_config`'s `notes:` line. It **warns and never reconciles**: it does not
> edit the file, does not begin honouring the key, and does not change
> resolution — a locked setting decides which artifacts exist on disk, so
> applying one quietly would produce exactly the divergence this table prevents.
> A clean file stays silent — you are only told when a key is actually in the
> wrong place.

---

### `/saas-settings --local` flag behavior

```
/saas-settings workflow=minimal               → writes to project.yaml (team-wide)
/saas-settings --local automation=autonomous  → writes to project.local.yaml (just you)
```

**Behavior rules:**

- Default (no flag): writes to `project.yaml`
- `--local` flag: writes to `project.local.yaml` (creates it if absent)
- `--local` on a locked setting → error:
  > *"`<setting>` cannot be locally overridden — it's a project-wide setting.
  > Use `/saas-settings <setting>=<value>` (no `--local`) to change it for the whole team."*
- Writing to `project.yaml` when the same setting is currently locally overridden → warning:
  > *"This setting is currently locally overridden in `project.local.yaml`.
  > Writing to `project.yaml` will not affect your effective value."*

---

### Schema validation on read

When skills or hooks read either file:

| Issue | Behavior |
|-------|----------|
| Unknown key (typo or stale setting) | Session-start warning: *"`project.local.yaml` has unknown key `modes.automaton` — typo? Ignored."* Does NOT block (forwards-compat with future settings). |
| Invalid value not in enum (e.g. `automation: chaotic`) | Hard error: skill exits with explanation of valid values. |
| Type mismatch (e.g. integer field set to a string) | Hard error: skill exits with type expected. |

---

### Creation and error handling

| Scenario | Behavior |
|----------|----------|
| `/saas-start` on fresh project | Creates `project.yaml` only. Does NOT create `project.local.yaml`. |
| `/saas-settings --local <x>=<y>` when local.yaml doesn't exist | Creates `project.local.yaml` containing just that setting. |
| `project.local.yaml` exists but `project.yaml` doesn't | Hard error: *"`project.yaml` missing — run `/saas-start` to create one. Local overrides require a base."* |
| Both files exist | Read `project.yaml` first, deep-merge `project.local.yaml` on top. Normal operation. |
| Both files set the same key | `project.local.yaml` wins. No prompting. |

---

### Two-developer clash scenarios — and why the whitelist prevents them

**File-level conflict (`project.yaml`):**
Standard git merge conflict. Each developer's `project.local.yaml` is gitignored
and never collides with another developer's. Normal git workflow handles team-wide
changes.

**Logical inconsistency (prevented by whitelist):**

Example of what the whitelist prevents:

> Sarah sets `modes.workflow: minimal` locally to skip PRD requirements. She
> doesn't write PRDs because her local mode doesn't require them. Mike runs
> `/saas-gate-check` with the team's `project.yaml` value, `standard`; gate-check sees missing
> PRDs and fails.

This can't happen because `modes.workflow` is locked to `project.yaml`. Same
for `qa.level`, `docs.density`, `strict_gate_checks`, `naming.*`, and every
other setting that affects what artifacts exist on disk.

Personal experience settings (`automation`, `review_mode`, `team.size`,
`testing.strict.*`, `performance.enforce`) can diverge freely without affecting
anyone else.

---

### Stricter reviewer reviewing a looser reviewer's work

A common worry: "what if my teammate has stricter review settings than me?
Will their `/saas-gate-check` or `/saas-design-review` flag things in my work?"

The answer depends on which kind of difference you're talking about:

**Different review depth, same project requirements (HEALTHY):**

- Teammate A: local `review_mode: full`, `automation: collaborative`, `testing.strict.logic: true`
- Teammate B: local `review_mode: solo`, `automation: autonomous`, `testing.strict.logic: false`
- Both bound by the same project.yaml-locked settings (e.g. `workflow: standard`, `qa.level: standard`)

B writes a PRD that meets `workflow: standard` (all 5 required sections present).
B's `/saas-design-review` runs with `review_mode: solo` — fast advisory check, no
specialists spawned. B moves on.

Later A reviews the same PRD with `review_mode: full` — spawns 5–15 specialists,
finds polish opportunities and edge cases B's lighter review missed. A files
findings as PR comments or follow-up issues. B addresses the ones that matter.

**This is normal team collaboration.** Different reviewers catching different
things is the value of having multiple reviewers. The artifacts on disk are the
same; only review depth differs. Nothing about this scenario creates project-state
divergence.

**Different requirements (PREVENTED by the whitelist):**

If `qa.level` were locally overridable:

- B sets `qa.level: minimal` locally. B's stories don't include test evidence.
- B's `/saas-story-done` accepts the story without evidence. Story marked Complete on disk.
- A pulls. A's `qa.level: standard` requires evidence. A's `/saas-story-done` would have rejected it.
- A's next `/saas-gate-check` fails because evidence is missing across multiple of B's "Complete" stories.

This is the artifact divergence problem. To prevent it, `qa.level` is locked to
`project.yaml`. The team agrees together on what's required; individuals override
only their personal experience, never the team's standards.

**The pattern to remember:**

| Difference type | Outcome |
|----------------|---------|
| Different review depth (review_mode, team.size) | Stricter reviewer surfaces more findings — healthy. Artifacts unchanged. |
| Different local strictness on failures (testing.strict.*, performance.enforce) | Stricter dev's local /saas-story-done blocks earlier — they fix it locally. CI uses project.yaml defaults so team-wide quality bar stays. |
| Different artifact requirements (workflow, qa.level, docs.density, etc.) | **Can't happen — these are locked.** Team agrees once in project.yaml. |

---

### CI behavior

CI environments have no `project.local.yaml` — the file is gitignored and never
present in a fresh clone. CI therefore always runs against `project.yaml`
defaults: strict project standards, no developer-specific overrides.

This is intentional and important:

| Setting | Local default for fast iteration | CI default (`project.yaml`) |
|---------|----------------------------------|------------------------------|
| `modes.review_mode` (locally overridable) | `solo` for one developer | `lean` (a team's usual choice — phase gates always run) |
| `testing.strict.logic` (locally overridable) | `false` for fast WIP commits | `true` (failing tests block CI) |
| `modes.automation` (locally overridable) | `autonomous` for solo flow | `collaborative` (the team's collab protocol, but CI doesn't ask questions anyway — this is mostly a no-op on CI) |

A developer can iterate locally with relaxed gates, but CI catches issues using
the strict project defaults. The team's quality bar is enforced at the CI level
regardless of any individual developer's local config.

---

### Secrets — never in either file

`project.yaml` and `project.local.yaml` are for **preferences and configuration**,
never for **secrets**. API keys, tokens, and credentials belong in:

- **Environment variables** (preferred for production/CI)
- **`.env` file** (gitignored, local dev)
- **OS keychain** (when integrating with services that support it)

When a skill needs an API key (e.g. `/saas-asset-spec` calling Midjourney), it reads
from the environment, not from `project.yaml`. `project.yaml` only stores **which**
generator is used (`art.generator: midjourney`), not the API key for it.

CI environments typically have no `project.local.yaml` (gitignored, not in the
clone) — so CI always runs against `project.yaml` defaults. This is correct
behavior: strict project defaults for CI, looser developer overrides for local work.

---

## modes.review_mode

**Controls:** How many specialist and director agents are spawned during skill execution  
**Values:** `full` | `lean` | `solo`  
**Default:** *none* — supplied by `modes.rigor` (`minimal`, the default, yields `solo`; `standard` yields `lean`; `full` yields `full`)  
**Set by:** `/saas-settings`, or `migrate-v1-config.sh` (which `/saas-adopt` runs) when it carries over a v1.0 `production/review-mode.txt`. `/saas-start` and `/saas-adopt` never write it themselves — unset, it follows `modes.rigor`  
**Read by:** See skill table below

**Priority chain (all skills):** inline argument flag → `modes.review_mode` in `project.yaml` → `production/review-mode.txt` (legacy fallback) → `modes.rigor` expansion (no terminal default; `minimal`→`solo`, `standard`→`lean`, `full`→`full`)

> **design-review follows the standard chain.** `modes.review_mode` controls
> design-review depth, its inline flag is `--review` for consistency with every
> other review-mode-aware skill, and with nothing set it follows `modes.rigor` like
> them: `solo` at `minimal` (the default), `lean` at `standard`.

> **Hotfix / day-one-patch exception:** These skills are emergency or release-critical
> pipelines. They are never gated by `review_mode` — all agents always run.

> **`review_mode` in the nine `team-*` orchestrators.** `review_mode` sets
> director-gate depth: `full` spawns every director gate a pipeline names, `lean`
> skips director gates unless they are PHASE-GATE type, and `solo` skips gate
> spawning entirely. No team pipeline spawns a PHASE-GATE (`/saas-gate-check` is their
> only spawner), so in the orchestrators
> `lean` and `solo` behave the same, and `full` adds two things:
> `/saas-team-release`'s technical-director release sign-off, and, at
> `team.size: small`, `/saas-team-content`'s `localization-lead` and `onboarding-specialist`.
>
> Outside the orchestrators, the skills in the *Core skills* table below read
> `review_mode` as that table documents.

---

### Value intent

| Value | Intent |
|-------|--------|
| `full` | All director and specialist gates active. Best for teams, learning, or anyone who wants thorough AI feedback on every decision. |
| `lean` | Phase gates only — per-skill director sign-offs skipped. The `rigor: standard` value. Balances quality with token cost. |
| `solo` | No gates, no director spawns (a pipeline's own review, such as `/saas-team-content`'s CD-CONSISTENCY, still runs). Fastest. For confident solo iteration. The default, from `rigor: minimal`. |

---

### Core skills (currently review-mode aware)

| Skill | full | lean | solo |
|-------|------|------|------|
| **design-review** | 5–15 specialist agents spawned in Phase 3b | No specialist agents — single-session analysis only | Phases 1–4 only, no delegation, no next-steps prompt |
| **gate-check** | Director panel runs in parallel — **width set by `modes.workflow`**, not by this axis | Director panel runs in parallel — same width rule; phase gates always run | Artifact existence checks only, no directors spawned |
| **design-system** | All section specialists + CD-PRD-ALIGN sign-off gate | Specialists for Sections D and H only (+ G when its knobs interact, + Visual/Audio when visual feedback is central); CD-PRD-ALIGN skipped | No section specialists; CD-PRD-ALIGN skipped |
| **design-tokens** | All section specialists + AD-DESIGN-SYSTEM-TOKENS sign-off gate | All section specialists, AD-DESIGN-SYSTEM-TOKENS skipped | All section specialists, AD-DESIGN-SYSTEM-TOKENS skipped |
| **architecture-decision** | Stack specialist + TD-ADR gate | Stack specialist; TD-ADR skipped | Stack specialist; TD-ADR skipped |
| **create-architecture** | TD-ARCHITECTURE + LP-FEASIBILITY agents, in parallel | Both skipped | Both skipped |
| **brainstorm** | CD-PILLARS, AD-CONCEPT-VISUAL, TD-FEASIBILITY, PR-SCOPE | All skipped | All skipped |
| **map-features** | TD-SYSTEM-BOUNDARY, PR-SCOPE, CD-SYSTEMS | All skipped | All skipped |
| **story-done** | QL-TEST-COVERAGE + LP-CODE-REVIEW | Both skipped | Both skipped |
| **sprint-plan** | PR-SPRINT feasibility check | Skipped | Skipped |
| **create-epics** | PR-EPIC scope check | Skipped | Skipped |
| **create-stories** | QL-STORY-READY + test case specs | Skipped | Skipped |
| **prototype** | PD-USABILITY-REVIEW review — APPROVE keeps the recommendation; CONCERNS and REJECT go to the user, who decides | Skipped — the recommendation stands unreviewed | Skipped — the recommendation stands unreviewed |
| **milestone-review** | PR-MILESTONE feasibility check | Skipped — no producer verdict | Skipped — no producer verdict |
| **usability test-report** | PD-USABILITY-REVIEW creative assessment | Skipped | Skipped |
| **story-readiness** | QL-STORY-READY acceptance criteria check | Skipped | Skipped |
| **create-control-manifest** | TD-MANIFEST (technical-director) review | Skipped | Skipped |
| **propagate-design-change** | TD-CHANGE-IMPACT (technical-director) review | Skipped | Skipped |

---

### Skills that do not read `modes.review_mode`

These skills run the same way at `full`, `lean` and `solo`. None of them takes a
`--review` flag.

| Skill | What runs at every level |
|-------|--------------------------|
| **review-all-prds** | Phase 2 consistency pass and Phase 3 design-theory pass, in parallel |
| **architecture-review** | The primary stack specialist is consulted after the stack audit (recorded as NOT ASSESSED when no stack is configured) |
| **dev-story** | Core programmer routing, plus the stack specialist's check of every code story |
| **code-review** | Language, database, and UI specialists when a stack is configured, plus `qa-manual-tester` for Logic and Integration stories |
| **security-audit** | `security-stacker` is spawned to run the audit |

---

### Team orchestration skills (pipeline behavior — different relationship)

Team skills are execution pipelines, not review gates. In them `review_mode` sets
only director-gate depth; `team.size` picks the agents (see `## team.size`), and a
pipeline's own review steps run in every mode.

| Skill | full | lean | solo |
|-------|------|------|------|
| **All nine `team-*`** | Every director gate the pipeline names | PHASE-GATE-type gates only | No director gates |
| **team-release** | + technical-director release sign-off before the go/no-go call | Sign-off not run — recorded as `not run (review_mode: lean)` | Sign-off not run — recorded as `not run (review_mode: solo)` |
| **team-content** | CD-CONSISTENCY; at `team.size: small`, + `localization-lead` and `onboarding-specialist` | CD-CONSISTENCY; at `small`, `ux-content-strategist` + `copywriter` only | CD-CONSISTENCY still runs when `ux-content-strategist` is active |

---

### Special cases and notes

- **gate-check** is the only skill where `full` and `lean` behave identically —
  phase gates always run. Only `solo` skips them. This is intentional: phase
  gates are the minimum quality bar, not optional extras. **How many directors
  run is a separate axis** — `modes.workflow` sets panel width (`minimal` → PR
  only, `standard` → TD + PR, `full` → all four), because directors are
  Opus-tier and a small project should not pay for the same four-director panel
  as a large one. Width never softens a verdict: the strictest verdict from
  whoever ran still wins, and `/saas-gate-check` names the perspectives it skipped.
- **design-tokens** always spawns its section specialists regardless of mode — only
  the final sign-off gate is controlled by `review_mode`. Specialist delegation is
  mandatory for the authoring output to be useful, and that has not changed.
  **design-system** is different: `lean` keeps the specialists for its high-risk
  sections only (D and H, plus G and Visual/Audio when they matter) and `solo`
  drafts every section without one, and each skipped spawn is announced by name.
  What sets `design-tokens`'s **spawn count** is therefore not `review_mode`
  but (a) `modes.workflow`, via how many sections get authored at all — `standard`
  requires sections 1–4, not all 9, and Phase 1 recommends the tier's set — and
  (b) batching consecutive sections that call the *same* agent with the *same*
  input into one delegation (2–4, and 5–6). Unbatched, sections 5 and 6 spawn
  `design-system-director` twice with the identical `sections 1–4` brief. Every section is
  still specialist-authored; per-section approval and write-to-file are unchanged.
- **dev-story** core engineer routing (backend-engineer, frontend-engineer, etc.)
  always runs regardless of mode — only the optional stack-specialist escalation
  for HIGH risk stories is gated.
- **hotfix** and **day-one-patch** are exempt — all agents always run.
- When a gate is skipped, skills emit: `"[GATE-ID] skipped — [mode] mode."` before
  proceeding. This is consistent across all skills.

---

## modes.rigor

**Controls:** How much process the project carries overall — the single question
`/saas-start` asks that sets the six knobs below
**Values:** `minimal` | `standard` | `full`
**Default:** `minimal` — see the rationale block above `_yaml_helper_defaults`
in `.claude/hooks/yaml-helper.sh`. Short version: the heavier tier costs more to
reach working code without producing a better result.
**Set by:** `/saas-start` (Phase 4: inferred from the user's description, shown, saved on a yes), `/saas-settings`
**Read by:** nothing directly — it is read *through* the six knobs it supplies

**Priority chain:** `modes.rigor` in `project.yaml` → hardcoded default `minimal`
(**locked** — not overridable from `project.local.yaml`, like the four *on-disk*
knobs it fronts — `modes.workflow`, `docs.density`, `qa.level`,
`modes.story_granularity` — because those five change what artifacts exist on
disk. The two personal-experience knobs it also fronts, `modes.review_mode` and
`team.size`, stay locally overridable.)

---

### Expansion table

| `modes.rigor` | `modes.workflow` | `docs.density` | `qa.level` | `modes.story_granularity` | `modes.review_mode` | `team.size` |
|---|---|---|---|---|---|---|
| `minimal` *(default)* | `minimal` | `terse` | `minimal` | `coarse` | `solo` | `individual` |
| `standard` | `standard` | `balanced` | `standard` | `balanced` | `lean` | `individual` |
| `full` | `full` | `thorough` | `full` | `fine` | `full` | `studio` |

### It fronts, it does not replace

The expansion sits **below every explicit source and above the terminal
default**:

```
project.local.yaml → project.yaml → legacy file → rigor expansion → default
```

That ordering is the back-compat guarantee, and it is what makes the migration
free. Three consequences worth stating plainly:

- **An existing `project.yaml` behaves identically.** If it already sets
  `docs.density: terse`, step 2 answers before the expansion is consulted — so
  the value and its reported source (`project.yaml`) are unchanged whether or not
  `rigor` is present. No migration, no `schema_version` bump.
- **Overrides go both ways.** Unlike the `workflow_overrides` **boolean flags** —
  which are additive and stricter-only — an explicit knob may be *looser* than
  the rigor level implies.
  (`workflow_overrides.system_overrides` is also two-directional — it replaces a tier; only the flags are stricter-only.)
  Inheriting the stricter-only rule would make "comprehensive but compact"
  inexpressible, which is the one off-diagonal the docs have always cited.
- **`modes.workflow` keeps `workflow_overrides.system_overrides`.** Per-system
  tiers still beat the rigor-derived project tier. `workflow` was fronted rather
  than folded away precisely because it drives ~5 distinct behaviors and owns the
  only per-system override mechanism.

The six fronted knobs therefore have **no entry in `_yaml_helper_defaults`**. A
terminal default there would answer before the expansion and make `rigor` a no-op
for anyone who had not also set the sub-knob.

### Provenance

Derived values report their source as `rigor:<level>`, so the vocabulary is
`{project.local.yaml, project.yaml, <legacy path>, rigor:<level>, default,
unset}`. `/saas-settings` renders this as `(derived from rigor: standard)` and
force-appends the five to its view-all list — none of them is a leaf of either
YAML file, so enumerating file leaves alone would hide exactly the settings the
user just chose.

---

## modes.workflow

**Controls:** How much design documentation is required before code can begin —
the tradeoff between token/time cost of documentation and speed of reaching
working code  
**Values:** `full` | `standard` | `minimal`  
**Default:** *none* — supplied by `modes.rigor` (`minimal`, the default, yields `minimal`; `standard` yields `standard`; `full` yields `full`)  
**Set by:** `/saas-start` (via `modes.rigor`), `/saas-settings`  
**Read by:** See skill tables below

**Priority chain:** `modes.workflow` in `project.yaml` → `modes.rigor` expansion → *(no hardcoded default)*

> **Why the middle level is `standard`, not `indie`.** A developer-type label
> would conflate "type of developer" with "level of process". `standard`
> describes the *amount of process*, not the user, and pairs cleanly with
> `minimal` and `full`.

> **Permissive, not restrictive:** `workflow` controls what is REQUIRED —
> not what is ALLOWED. Any skill can be run at any workflow level. The
> setting changes what gate-check enforces and what completeness checks
> validate, not what the user can invoke.

> **`minimal` floor:** Even in minimal mode, stack choice and a filled
> **`design/product-brief.md`** are required before code starts — the brief's
> build-order field is the plan, so there is no separate `sprint-plan` step.
> Both take minutes and prevent real problems downstream. Everything else can
> be skipped.

> **Escape hatches via `workflow_overrides`:** Users who want *almost* the
> standard set with one extra requirement (e.g. always force Edge Cases) use
> `workflow_overrides` rather than escalating to `full`. See next section.

---

### Value intent

| Value | Token/time cost | Required before code | Best for |
|-------|----------------|---------------------|----------|
| `full` | High | All 8 PRD sections per system, full architecture, all ADRs, design tokens, UX specs per screen | Projects where design correctness matters more than speed — teams, commercial titles, learning the full pipeline |
| `standard` | Balanced | 5 PRD sections per system, one architecture doc, critical ADRs, product concept, systems index | Projects that have outgrown a brief — several interacting systems, or a design someone else has to implement |
| `minimal` | Low | One-page `design/product-brief.md` + stack choice (build order in the brief = the plan; no separate sprint plan) | **Default.** Get to code fast — small scope, hackathons, or the design already in your head. Raise it when the project grows |

**standard required PRD sections:** Overview, Detailed Rules, Edge Cases, Dependencies,
Acceptance Criteria.
**standard conditional:** Formulas — required when the system **defines numeric
rules**: rates, curves, thresholds, costs, quotas, tier allocations, or any value a
pricing or capacity pass would tune. Optional only when the system defines no such value.

> **The test is what the system defines, not what it is called.** The `Category`
> column in `features-modules-index.md` is a *hint* — `Core Business Workflow`, `Economy` and
> `Progression` systems almost always qualify — but it is not the test, and a
> `Core`, `UI` or `Persistence` system that defines a numeric rule qualifies too.
>
> Do not restate it as "required when system category is core feature, economy,
> progression, or AI". Those four tokens are not the vocabulary `/saas-map-features`
> writes: `templates/features-modules-index.md` defines the categories as `Core ·
> Core Business Workflow · Progression · Economy · Persistence · UI · Audio · Narrative ·
> Meta`, and lists **billing and auth as example systems under `Core Business Workflow`**. A
> billing system categorised exactly as the template instructs therefore matched
> none of the four, and Formulas was silently dropped for the system most likely
> to need it. `coding-standards.md` and `rules/design-docs.md` already stated the
> "has math" test; the skills are reconciled to them rather than the other way
> round.

> **Edge Cases is required at `standard`.** Skipping it consistently produces
> "wait, what happens if X is null?" debt during implementation. These 5
> required sections are the minimum that produces implementable code.

> **Design tokens is conditional in `standard`.** It is required only if visual
> asset stories exist in the project. Code-focused projects can skip it
> entirely at `standard` level.

---

### Authoring skills

| Skill | full | standard | minimal |
|-------|------|----------|---------|
| **design-system** | All 8 sections required | 5 required sections + conditional Formulas; User Stories & Personas, Configuration Parameters skipped | Not required — product brief replaces PRDs. Can still be run voluntarily. |
| **design-tokens** | All 9 sections required | Required only if visual asset stories exist; sections 1–4 minimum when required | Not required. Can still be run voluntarily. |
| **create-architecture** | Full architecture — all layers, module ownership, data flow, API boundaries, full ADR audit | Simplified — system layer map + critical ADR list only | Not required. Can still be run voluntarily. |
| **ux-design** | UX spec required per screen | Core screens only (dashboard, settings, primary product workflow) | Not required. Can still be run voluntarily. |
| **map-systems** | Required before design-system | Required before design-system | Not required |
| **architecture-decision** | All ADRs on required ADR list must be completed | Critical ADRs only — Foundation layer systems | Not required |

---

### Review and validation skills

| Skill | full | standard | minimal |
|-------|------|----------|---------|
| **design-review** | All 8 sections validated — any missing section blocks approval | 5 required sections validated; missing optional sections warned but do not block | Not applicable — no PRDs to review |
| **review-all-prds** | Validates all 8 sections across all PRDs | Validates 5 required sections across all PRDs; optional sections surfaced as advisory only | Not applicable |
| **architecture-review** | Full traceability matrix — all PRDs, all ADRs | Reduced scope — architecture doc + critical ADRs only | Not applicable |
| **consistency-check** | Full entity registry cross-check against all PRD sections | Entity registry check against required sections only | Not meaningful — no PRDs to check |
| **content-audit** | Full content count audit against all PRD specs | Limited audit — only specs in required sections counted | Cannot run — no systems index exists |

---

### Phase gate enforcement (gate-check)

`gate-check` is where workflow has the most visible impact — the artifact
checklists differ per phase per mode.

| Gate | full | standard | minimal |
|------|------|----------|---------|
| Concept → Systems Design | product-concept.md, pillars, Visual Identity Anchor | product-concept.md only | `design/product-brief.md` only (content check, not section check) |
| Systems Design → Technical Setup | systems-index, all MVP PRDs reviewed (8 sections), cross-PRD review | systems-index, 5-section PRDs reviewed, cross-PRD review optional | Not applicable — no gates between brief and code; the gate PASSes with that note |
| Technical Setup → Pre-Production | stack, design tokens sections 1–4+, 3+ ADRs, architecture, UX specs started | stack, design tokens only if visual assets, critical ADRs, architecture | stack configured (required floor) |
| Pre-Production → Production | sprint plan, complete design tokens, epics, UX specs, control manifest; Vertical Slice + its usability test recommended (absent → CONCERNS) | epics, sprint plan; complete design tokens, UX specs, control manifest recommended; Vertical Slice recommended | the brief's Build order + stories under `production/epics/`; the Vertical Slice items drop — the core business workflow runs end to end, checked on the current build |
| Production → Polish | core features, tests, smoke check, QA sign-off, 3+ usability tests | core features, smoke check, functional end to end, 1+ usability test, no open S1 bugs | smoke check, functional end to end, no open S1 bugs |
| Polish → Release | all features, content complete, localization (`/saas-localize qa` per locale), QA, smoke, no open S1–S3 bugs, newest `/saas-security-audit` with no open CRITICAL/HIGH | all features, smoke, no open S1 bugs, the security audit | smoke, no open S1 bugs |

<!-- gate-check reconciliation: at `full` and `standard` the Vertical Slice
     keeps its long-standing "recommended, not blocking → CONCERNS if absent;
     FAIL if built-and-broken" status — the tier table never upgrades it to a
     hard blocker. At `minimal` its items drop, and two checks on the current
     build replace them. The genuinely-required floor item at this gate is the
     sprint plan at `standard`/`full`; at `minimal` there is no separate
     sprint-plan step — the brief's Build order plus stories is the floor at
     `minimal`. -->

**Director panel width** (`/saas-gate-check` Section 4b) is workflow's second effect
here. Directors are Opus-tier, so the panel is sized to the project rather than
fixed at four:

| `workflow` | Panel | Directors |
|---|---|---|
| `full` | 4 | `product-director`, `technical-director`, `producer`, `design-system-director` |
| `standard` | 2 | `technical-director`, `producer` |
| `minimal` | 1 | `producer` |

`review_mode` remains the axis that decides *whether* the panel runs at all
(`solo` skips it entirely); workflow decides only how wide it is. Narrowing
never softens a verdict — the strictest verdict from whoever ran still wins, and
`/saas-gate-check` names the perspectives that did not run.

---

### Planning and implementation skills

| Skill | full | standard | minimal |
|-------|------|----------|---------|
| **create-epics** | Requires all PRDs approved (8 sections) | Requires 5-section PRDs approved | **Skipped** (Option A) — no separate epic doc. `/saas-create-stories` reads `design/product-brief.md` directly and synthesizes the implicit epic container itself. |
| **create-stories** | Requires all ADRs on required list present | Requires critical ADRs present | No ADR requirement |
| **dev-story** | Requires TR registry + governing ADR — blocks without them, and on a `Proposed`, `Deprecated` or `Superseded` ADR; a missing control manifest warns | TR registry optional; blocks only on a referenced ADR that is missing, `Proposed`, `Deprecated` or `Superseded` | No TR registry or ADR required — implements against `design/product-brief.md`; a referenced ADR that is missing, `Proposed`, `Deprecated` or `Superseded` still blocks |
| **story-readiness** | Full TR registry + ADR + control manifest validation; any referenced ADR that is missing, `Proposed`, `Deprecated` or `Superseded` BLOCKS | TR registry optional; critical ADR check, and any referenced ADR that is missing, `Proposed`, `Deprecated` or `Superseded` BLOCKS | Acceptance-criteria check (the brief stands in for the PRD); any referenced ADR that is missing, `Proposed`, `Deprecated` or `Superseded` still BLOCKS |
| **story-done** | Full PRD traceability + ADR consistency check | 5-section PRD traceability check | Acceptance criteria check only |
| **qa-plan** | Full test plan derived from all 8 PRD sections | Test plan from 5 required sections | Test plan from acceptance criteria only |
| **regression-suite** | Critical paths mapped from all sections including Edge Cases | Critical paths from required sections (including Edge Cases) | Smoke test coverage only |
| **release-checklist** | Open S1, S2 or S3 bug in `production/qa/bugs/` fails its Quality Gates item | Open S1 fails; open S2/S3 listed as risks | Open S1 fails; open S2/S3 listed as risks |
| **launch-checklist** | Zero open S1–S3 bugs, no exceptions | Zero open S1; S2 or a documented exception | Zero open S1; S2 or a documented exception |
| **team-release** | qa-lead verifies no open S1–S3 bugs | qa-lead verifies no open S1 bugs | qa-lead verifies no open S1 bugs |

---

### Support skills

| Skill | full | standard | minimal |
|-------|------|----------|---------|
| **project-stage-detect** | Checks for all doc types; missing design tokens or UX specs flagged as gaps | Adjusts expectations — design tokens only flagged if visual-asset stories exist; non-core UX specs not flagged | `design/product-brief.md` + stack present = normal state; no gaps flagged for absent PRDs |
| **adopt** | Full format compliance audit across all doc types | Audit scope reduced to required docs only | `design/product-brief.md` format check only |
| **reverse-document** | Generates full 8-section PRD from code | Generates 5-section PRD from code | Generates `design/product-brief.md` from code |
| **propagate-design-change** | Full cascading impact analysis across all ADRs | Checks critical ADRs for references only | Not applicable |
| **help** | Full artifact detection — surfaces all missing docs as next steps | Adjusts "what's missing" to required docs only — optional docs not surfaced as gaps | `design/product-brief.md` + stack present = next step is code |

---

### Workflow change mid-project

When `workflow` changes via `/saas-settings`, the skill emits an informational note:

> "Workflow changed from [old] to [new]. Run `/saas-content-audit` to see what's now
> required or extra. No automatic migration — existing files stay in place."

No documents are auto-deleted, auto-generated, or blocked. The setting only affects
*new* enforcement going forward.

---

## workflow_overrides

**Controls:** Opt-in granular requirements that override the chosen workflow level
**Location:** **top level of `project.yaml`** — a sibling of `modes:`, *not* a child of it
**Values:** object with sub-flags (see below)
**Default:** all false / empty
**Set by:** `/saas-settings`
**Read by:** `/saas-design-system`, `/saas-design-review`, `/saas-design-tokens`, `/saas-gate-check`, `/saas-review-all-prds`, `/saas-qa-plan`

> **Why the location is called out.** `resolve_config` reads
> `workflow_overrides.system_overrides.*` from the document root
> (`yaml-helper.sh`), and all 14 consuming skill files grep the same top-level
> path. Nested under `modes:` it is still valid YAML, so nothing errors — the
> setting is simply never read. If you copied a `workflow_overrides` block from
> anywhere, check its indentation: it belongs at the document root, never under
> `modes:`.

**Priority chain:** the three `workflow_overrides` **boolean flags**
(`edge_cases`, `tuning_knobs`, `design_tokens_strict`) are *additive* on top of the
chosen `workflow` level — they make things stricter, never looser. None of them
has a value that opts out of a requirement the workflow level imposes.

> **`workflow_overrides.system_overrides` is not a flag and is not additive — it replaces a tier in both directions.**
> This rule does not extend to it. On a
> `full` project, `system_overrides.catalog: minimal` really does drop that
> system's required sections to zero. Intended — see
> `.claude/docs/workflow-modes.md § workflow_overrides`. Stating the additive
> rule over the whole key is wrong: the guarantee never held for
> `system_overrides`, so do not rely on it as a safety net.

---

### Fields

```yaml
workflow_overrides:
  edge_cases: false          # force Edge Cases section required (no-op at standard since already required; relevant at minimal)
  configuration_parameters: false  # force Configuration Parameters section required (relevant at standard, no-op at full)
  design_tokens_strict: false    # force all 9 design tokens sections required regardless of asset stories
  system_overrides: {}       # per-system tier overrides — see below
```

### Per-system overrides

```yaml
workflow_overrides:
  system_overrides:
    billing: full              # billing PRD requires full (8 sections) regardless of project workflow
    auth: full
    notifications: minimal     # notifications needs no PRD — the product brief covers it (minimal = no required sections)
```

`system_overrides` is a map of `system_name: workflow_level`. The named system uses the override; all other systems use the project-level `workflow`.

---

### Affected skills

| Skill | How workflow_overrides changes behavior |
|-------|----------------------------------------|
| **design-system** | Reads `system_overrides[system_name]` first; falls back to project `workflow`. Applies override-specific section requirements. |
| **design-review** | Same lookup — validates against the override tier, not the project default, for the named system. |
| **design-tokens** | If `design_tokens_strict: true`, requires all 9 sections regardless of `workflow` level. |
| **gate-check** | Considers `system_overrides` when validating that all required PRDs are complete. A system at `system_overrides.core feature: full` blocks the gate until all 8 sections exist for core feature. |
| **review-all-prds** | Validates each PRD against its effective tier (project workflow + any system override). |

---

## modes.automation

**Controls:** Whether skills ask for decisions and approval before acting, or
recommend and proceed — the tradeoff between user control and speed  
**Values:** `collaborative` | `guided` | `autonomous`  
**Default:** `collaborative`  
**Set by:** `/saas-start`, `/saas-settings`  
**Read by:** All 68 skills that use `AskUserQuestion` or write files

**Priority chain:** `modes.automation` in `project.yaml` → hardcoded default

> **Unlike review_mode and workflow, this setting is not a per-skill table.**
> It defines universal interaction rules that apply across all skills. A
> per-skill breakdown would repeat the same answer 68 times.

> **Overrides COLLABORATIVE-DESIGN-PRINCIPLE.md:** `guided` and `autonomous`
> modes intentionally relax the Q→O→D→Draft→Approval protocol defined in that
> document. This is opt-in. `collaborative` preserves the protocol exactly.

> **Safety net — `automation_always_ask`:** Even in `autonomous` mode, certain
> categories of decision can be configured to always prompt. See next section.

---

### Value intent

| Value | Speed | Control | What changes |
|-------|-------|---------|--------------|
| `collaborative` | Slowest | Full — every decision is the user's | Current behavior. Q→O→D→Draft→Approval strictly followed. |
| `guided` | Balanced | High — major decisions are the user's, minor ones proceed automatically | AI states recommendation and proceeds for minor decisions. AskUserQuestion reserved for major/irreversible decisions. |
| `autonomous` | Fastest | Low — AI decides, logs, and proceeds | No AskUserQuestion (except categories in `automation_always_ask`). No draft review. No write approval. All decisions logged to decision log. |

---

### Universal rules per mode

#### collaborative (current behavior — no change)

- `AskUserQuestion` called for every multi-option decision
- 2–4 options presented with pros/cons for every design choice
- Full draft shown and approved before every file write
- "May I write this to [filepath]?" asked before every write
- "May I create [filepath] with skeleton?" asked before skeleton creation
- Section-by-section approval in multi-section authoring skills
- Multi-file changes require explicit approval of the full changeset

#### guided

- `AskUserQuestion` called for **major decisions only** (see classification below)
- Minor decisions: AI states recommendation inline and proceeds — e.g.
  *"Going with a static utility pattern here — it fits the existing architecture.
  Continuing unless you want to change direction."*
- Updates to existing files: draft shown briefly before writing — proceeds after a
  short summary, does not wait for explicit "yes"
- "May I write?" asked for **new files only**, and a new file waits for the answer
  — updates to existing files proceed directly
- Still presents options for major decisions but caps at 2 choices with a clear
  recommendation
- Multi-section authoring: writes each approved section immediately, no per-section
  confirmation prompt

#### autonomous

- No `AskUserQuestion` calls **except** for categories listed in `automation_always_ask`
- No draft review
- No "May I write?" prompts — writes directly
- Picks the recommended option for every decision without presenting alternatives
- All decisions logged immediately to `production/session-logs/decision-log.md`
  with: timestamp, skill, decision point, option chosen, reasoning
- User reviews decision log post-session to audit choices made

#### every mode — a question with no answer

- A question that comes back skipped, dismissed or empty is **not an answer**, in
  every mode and on every tool (a closed question, a headless run that returns
  every question as skipped, a reply that picks nothing)
- Nothing is written, no mode or setting changes and no option is picked on its
  behalf; the question is asked again in plain text, naming what waits on it
- `autonomous`: a question the mode did not require is decided and logged as
  usual; an `automation_always_ask` category or an exempt skill asks again
- Where nobody can answer (CI, headless), the skill stops and reports what is
  waiting rather than choosing

---

### Major vs minor decision classification (guided mode)

**Major — always use AskUserQuestion in guided mode:**

| Decision type | Example |
|---------------|---------|
| Choosing a system name or document path | "What should we call this system?" |
| Mutually exclusive design directions | "Real-time WebSockets or polling?" |
| Any choice that gates downstream work | Stack choice, architecture approach |
| Scope changes | "Cut this feature or slip the deadline?" |
| Any decision that can't be changed without significant rework | Core business workflow architecture |

**Minor — AI recommends and proceeds in guided mode:**

| Decision type | Example |
|---------------|---------|
| Which section to work on next | "Moving to Edge Cases next" |
| Optional section inclusion | "Adding a Visual Notes section — fits the system" |
| Formatting and structure choices | Heading levels, table vs prose |
| Adding detail to an already-decided direction | Sub-options within an approved approach |
| Next-step routing after a phase completes | "Running design-review now" |

---

### Affected skills by category

**Authoring skills — highest impact.** Each pauses 10–15 times per document in
`collaborative`. Drops to 2–3 in `guided`, zero in `autonomous`.

`brainstorm`, `design-system`, `design-tokens`, `create-architecture`, `ux-design`,
`map-systems`, `architecture-decision`, `create-epics`, `create-stories`,
`sprint-plan`, `prototype`

**Review skills — medium impact.** Pause after presenting findings to ask what
to do next. In `guided` routing decisions proceed automatically. In `autonomous`
the recommended path is taken and logged.

`design-review`, `architecture-review`, `gate-check`, `review-all-prds`,
`story-readiness`, `story-done`, `milestone-review`, `usability test-report`

**Team orchestration skills — medium impact.** Pause between phases for
check-in. In `guided` the pipeline advances automatically unless BLOCKED. In
`autonomous` the full pipeline runs end to end.

`team-core-feature`, `team-ui`, `team-growth`, `team-qa`, `team-release`,
`team-auth-access`, `team-billing`, `team-content`, `team-polish`

**Implementation skills — lower impact.** Pause for architectural questions
before writing code. In `guided` only genuinely ambiguous decisions stop. In
`autonomous` the conventional approach is picked and logged.

`dev-story`, `code-review`

**Setup and utility skills — lowest impact.** Pause for initial configuration
or routing questions. In `guided` defaults are applied automatically. In
`autonomous` recommended defaults are taken without prompting.

`start`, `adopt`, `setup-stack`, `retrospective`, `localize`, `propagate-design-change`,
`asset-spec`, `smoke-check`, `qa-plan`, `story-readiness`

---

### Exemptions — skills that ignore the automation setting

These skills always behave as `collaborative` regardless of the setting.
The reasons are noted.

| Skill | Why always collaborative |
|-------|--------------------------|
| **hotfix** | Emergency decisions — user must approve scope and risk before any action |
| **gate-check** | Results must be reviewed — a gate verdict without user acknowledgement defeats the purpose |
| **day-one-patch** | Release-critical — every action needs explicit sign-off |
| **setup-stack** | One-time irreversible choice that affects the entire project |

---

### Decision log format (autonomous mode)

Written to `production/session-logs/decision-log.md` — append-only.

```markdown
## [timestamp] — [skill-name]

**Decision point:** [what was being decided]
**Options considered:** [list of options that would have been presented]
**Chosen:** [what was picked]
**Reason:** [one-line rationale]
**Category:** [scope_changes | file_deletions | schema_changes | etc., or "minor"]
```

If the file does not exist, it is created. It is never truncated — each session
appends to the existing log.

---

## modes.automation_always_ask

**Controls:** Decision categories that ALWAYS trigger AskUserQuestion regardless of automation mode
**Values:** list of category names
**Default:** `[scope_changes, file_deletions, schema_changes]`
**Set by:** `/saas-settings`
**Read by:** All skills that respect `modes.automation`

> **Makes `autonomous` safe.** Without this, `autonomous` is "AI does literally
> everything, no questions asked." With it, AI does most things but stops on
> destructive or irreversible decisions you specifically named.

---

### Recognized categories

| Category | Examples of decisions in this category |
|----------|----------------------------------------|
| `scope_changes` | Cutting a feature, slipping a deadline, splitting/merging an epic, removing acceptance criteria |
| `file_deletions` | Removing a story, deleting a PRD, removing a system, removing a test file |
| `schema_changes` | Changes to project.yaml, story template, control manifest, ADR template, PRD template |
| `architecture_decisions` | New ADR creation, ADR replacement, system boundary changes |
| `version_bumps` | Engine version change, framework version bump, dependency major version change |
| `external_calls` | Invoking external APIs (asset gen, AI services) when in autonomous mode |

The list is a YAML list of these strings. Skills check whether the current decision falls into one of the configured categories and prompt regardless of `automation` value.

---

### Affected skills

| Skill | Categories typically triggered |
|-------|--------------------------------|
| **scope-check** | `scope_changes` |
| **propagate-design-change** | `schema_changes`, `architecture_decisions` |
| **architecture-decision** | `architecture_decisions` |
| **setup-stack** | `version_bumps`, `schema_changes` |
| **story-done** | `file_deletions` (when removing/replacing test files) |
| **asset-spec** | `external_calls` (when calling external generators) |

---

## modes.story_granularity

**Controls:** How big each story is and how many stories per epic/sprint
**Values:** `coarse` | `balanced` | `fine`
**Default:** *none* — supplied by `modes.rigor` (`minimal`, the default, yields `coarse`; `standard` yields `balanced`; `full` yields `fine`)
**Set by:** `/saas-start` (via `modes.rigor`), `/saas-settings`
**Read by:** `/saas-create-stories`, `/saas-sprint-plan`, `/saas-sprint-status`, `/saas-story-readiness`

**Priority chain:** `modes.story_granularity` in `project.yaml` → `modes.rigor` expansion → *(no hardcoded default)*

---

### Value intent

| Value | Story shape | Stories per sprint | Best for |
|-------|-------------|-------------------|----------|
| `coarse` | 1 story = 1 feature. 3–5 days work each. 5–10 ACs per story. The default, from `rigor: minimal`. | 2–4 | Solo devs, prototyping, "I know what I'm building" |
| `balanced` | 1 story = 1 task. 1–2 days work each. 2–4 ACs per story. The `rigor: standard` value. | 6–10 | Most projects |
| `fine` | 1 story = 1 AC. Hours of work each. Easy code review. Frequent /saas-story-done. | 15–25 | Teams, learning, anything needing fine handoffs |

---

### Affected skills

| Skill | coarse | balanced | fine |
|-------|--------|----------|------|
| **create-stories** | Each story carries 5–10 ACs covering an entire feature | Each story carries 2–4 ACs covering one task | Each story carries 1 AC; story name = AC restatement |
| **sprint-plan** | Allocates 2–4 stories per sprint based on velocity. | Allocates 6–10 stories per sprint. | Allocates 15–25 stories per sprint. |
| **sprint-status** | Burn-down reads in feature-sized chunks. | Burn-down reads in task-sized chunks. | Burn-down reads in AC-sized chunks. |

---

## docs.density

**Controls:** How deep each section in authored docs goes — independent of which sections are required
**Values:** `terse` | `balanced` | `thorough`
**Default:** *none* — supplied by `modes.rigor` (`minimal`, the default, yields `terse`; `standard` yields `balanced`; `full` yields `thorough`)
**Set by:** `/saas-start` (via `modes.rigor`), `/saas-settings`
**Read by:** `/saas-design-system`, `/saas-design-tokens`, `/saas-create-architecture`, `/saas-ux-design`, `/saas-map-features`, `/saas-brainstorm`

**Priority chain:** `docs.density` in `project.yaml` → `modes.rigor` expansion → *(no hardcoded default)*

> **Distinct from `workflow`, but not independent by default.** `workflow`
> controls which sections exist; `density` controls how deep each section goes.
> `modes.rigor` sets both together, so the diagonal (`rigor: full` → 8
> sections *and* thorough prose) is what you get without asking. The off-diagonal
> is still reachable and is the reason `rigor` overrides both ways: `rigor: full`
> + an explicit `docs.density: terse` gives "all sections but each is compact" —
> the "comprehensive but tight" mode, which neither knob expresses alone.

---

### Value intent

| Value | Per-section output style |
|-------|--------------------------|
| `terse` | Bullet points. 2–5 lines per section. Skip rationale and narrative framing. Skip preambles like "In this application..." Just facts needed to implement. The default, from `rigor: minimal`. |
| `balanced` | Paragraphs with light rationale. Examples where helpful. The `rigor: standard` value. |
| `thorough` | Full prose. Rationale for every decision. Examples, alternatives considered, design history. |

---

### Combination matrix with workflow

|  | docs.density: terse | balanced | thorough |
|---|---|---|---|
| **workflow: minimal** | Product brief in bullets *(default)* | Product brief in prose | Product brief + rationale |
| **workflow: standard** | 5 sections, bullets | 5 sections, paragraphs | 5 sections + examples |
| **workflow: full** | 8 sections, bullets *(comprehensive but compact)* | 8 sections, paragraphs *(current full)* | 8 sections + rationale + examples |

---

### Affected skills

| Skill | terse | balanced | thorough |
|-------|-------|----------|----------|
| **design-system** | Each PRD section is 2–5 bullets. Skip User Stories & Personas preambles. | Paragraphs with key decisions explained. | Full prose, decision history, alternatives considered. |
| **design-tokens** | Each design tokens section is a bulleted list of constraints + references. | Paragraphs explaining each visual choice. | Full prose including style explorations, references, rationale per choice. |
| **create-architecture** | Layer diagrams + decision bullets. No essays. | Diagrams + paragraph explanations of layer choices. | Full prose with rationale, trade-offs, alternatives considered per layer. |
| **ux-design** | Wireframe descriptions + interaction bullets. | Wireframes + paragraph descriptions of flows. | Full prose including user research summaries, alternative flow considerations. |
| **map-systems** | One-line system descriptions. | Brief paragraph per system + dependency notes. | Full system-by-system rationale + relationship analysis. |
| **brainstorm** | Pillar bullets + concept bullets. | Pillars + concept with brief rationale. | Pillars + concept + extensive rationale + alternatives. |

---

## testing.framework

**Controls:** Which test framework the project uses — drives test-runner commands and per-stack assumptions in CI
**Values:** stack-specific (see table)
**Default:** auto-populated by `/saas-setup-stack` based on stack choice
**Set by:** `/saas-setup-stack`, `/saas-settings`
**Read by:** `/saas-test-helpers` — the only skill that references it. `/saas-qa-plan`, `/saas-dev-story`, `/saas-regression-suite`, `/saas-test-setup` and `/saas-smoke-check` do **not** name the key, despite being plausible readers.
  *(Derived by grep. A helper-based read such as `session_state_enabled()` would not show up, so treat this list as the verified floor, not a ceiling.)*

**Priority chain:** `testing.framework` in `project.yaml` → stack default

> **Migrated from `technical-preferences.md`.**

---

### Engine defaults

| Engine | Default test framework | Alternatives |
|--------|------------------------|--------------|
| Next.js | `vitest` | `jest`, `playwright` |
| FastAPI | `pytest` | `unittest`, `httpx` |
| Cloudflare | `vitest` | `miniflare`, `wrangler` |

---

### Affected skills

| Skill | How `testing.framework` is used |
|-------|--------------------------------|
| **qa-plan** | Test plan tailored to framework's idioms (assertion style, fixture pattern, parameterized tests) |
| **dev-story** | Test framework name passed to programmer subagent in implementation brief |
| **regression-suite** | Test file naming and discovery patterns match framework conventions |
| **test-setup** | Scaffolds the right test layout for the stack (Vitest under `tests/` for Next.js; `tests/` with pytest for FastAPI; `tests/` with Vitest for Cloudflare) |
| **smoke-check** | Invokes framework-appropriate test runner |

---

## testing.strict

**Controls:** Whether failing or missing test evidence blocks a story from
closing, or produces a warning and lets work continue — per test type
**Values:** map of `{logic, integration, visual, ui, config}` → `true | false`
**Default:** `{logic: true, integration: true, visual: true, ui: true, config: false}`
**Set by:** `/saas-settings`
**Read by:** `story-done`, `story-readiness`, `gate-check`, `smoke-check`, `dev-story`, `test-evidence-review`

> **Per-type, not a single bool.** A global `testing.strict: true|false` forces
> all-or-nothing: either all test failures block or none do. Per-type matches how
> most teams actually work — strict logic and visual gates, an advisory smoke check.

> **Composes with `qa.level`:** `qa.level` controls whether evidence is REQUIRED.
> `testing.strict` controls whether failures BLOCK when evidence exists. If
> `qa.level: minimal`, the strict map is effectively ignored (no evidence required
> means nothing to be strict about).

---

### Value intent per type

| Type | `true` | `false` |
|------|--------|---------|
| `logic` (formulas, AI, state machines) | Unit test failures BLOCK — story cannot close | Failures WARN — story can close with warning |
| `integration` (multi-system) | Integration test failures BLOCK | Failures WARN |
| `visual` (animation, VFX, feel) | Missing/failing screenshot evidence BLOCKS (default) | Advisory only — story can close |
| `ui` (menus, app shell, screens) | Missing screenshot of the screen BLOCKS (default) | Advisory only — story can close |
| `config` (balance tuning) | Failing smoke check BLOCKS | Advisory only — story can close (default) |

---

### Affected skills

| Skill | strict.[type]: true | strict.[type]: false |
|-------|---------------------|----------------------|
| **story-done** | Story of that type cannot close on test/evidence failure | Story can close; warning logged in story file |
| **story-readiness** | Validates test requirements exist before implementation — blocks if absent | Validates but does not block — surfaces as warnings |
| **gate-check** | CI failures of that type block phase transition | CI failures of that type surfaced as concerns, not blockers |
| **smoke-check** | Failing smoke (config strict) blocks QA handoff | Failing smoke flagged but handoff proceeds |
| **dev-story** | References test requirements — flags story as unverifiable if absent | References test requirements — advisory only |
| **test-evidence-review** | A gap in that type's evidence is a BLOCKING item (the run ends CONCERNS) | The gap is ADVISORY |

> **Unset-key resolution.** Each skill reads `testing.strict.<type>`; if absent
> it reads `testing.strict` as a plain boolean (legacy form); if still absent it
> falls back to a hardcoded default. For `story-done`, `story-readiness`,
> `gate-check`, and `dev-story` the hardcoded default is the per-type default map
> above (logic/integration/visual/ui strict, config advisory). **`smoke-check` is
> the exception**: it is a build-health gate, so an unset `testing.strict.config`
> defaults to *strict* (a FAIL blocks QA hand-off) — preserving its v1.0 behavior.
> Only an explicit `testing.strict.config: false` makes a failing smoke advisory.

---

## qa.level

**Controls:** What test evidence is required to mark stories Done
**Values:** `minimal` | `standard` | `full`
**Default:** *none* — supplied by `modes.rigor` (`minimal`, the default, yields `minimal`; `standard` yields `standard`; `full` yields `full`)
**Set by:** `/saas-start` (via `modes.rigor`), `/saas-settings`
**Read by:** `/saas-story-done`, `/saas-story-readiness`, `/saas-dev-story`, `/saas-smoke-check`, `/saas-gate-check`, `/saas-qa-plan`, `/saas-regression-suite`, `/saas-team-qa`, `/saas-test-evidence-review`, `/saas-create-stories`, `/saas-retrospective`, `/saas-test-setup`

**Priority chain:** `qa.level` in `project.yaml` → `modes.rigor` expansion → *(no hardcoded default)*

> **Different axis from `testing.strict`.** `qa.level` = what evidence is required.
> `testing.strict` = do failures block. A user wanting "minimal QA" sets
> `qa.level: minimal` and the strict map becomes effectively a no-op.

---

### Value intent

| Aspect | minimal | standard | full |
|--------|---------|----------|------|
| Logic stories | No test required, no gap flagged | Unit test required (strict.logic controls block) | Unit test, and every acceptance criterion covered |
| Integration stories | No test required | Integration test or usability test doc required | Same + regression coverage |
| Visual stories | Screenshot + lead sign-off required — the look is never waived (strict.visual controls block) | Same | Same |
| UI stories | Screenshot of each screen touched required — never waived (strict.ui controls block) | Same | Same |
| Config/Data stories | No evidence required | Smoke check advisory | Smoke check required (blocking unless `testing.strict.config: false`) |
| /saas-story-done test gate | Acceptance criteria only, except the UI and Visual/Feel screenshot, which is never waived | Enforced per story type | Enforced for every story type |
| /saas-gate-check phase enforcement | No test gates | Logic + integration must pass | Full coverage + regression suite |
| /saas-dev-story routing prompt | No "Test required: ..." line | Per-type test requirement included | Per-type, and every criterion must be covered |
| Regression suite required by | Never | Polish stage | Production stage |
| Best for | Hackathons, throwaway prototypes, fast iteration | Most projects | Enterprise, regulated compliance, mission-critical systems |

---

### Affected skills

| Skill | minimal | standard | full |
|-------|---------|----------|------|
| **story-done** | Acceptance criteria check only — no test evidence required, except the UI and Visual/Feel screenshot, which is never waived | Per-type evidence required; strictness from `testing.strict`; more than half the criteria untested blocks | Per-type evidence required; a Config/Data smoke report blocks by default; any untested criterion blocks |
| **story-readiness** | No test requirement validated, except the UI and Visual/Feel screenshot requirement | Test requirement per story type validated | Test requirement + coverage target validated |
| **dev-story** | Routing prompt has no "Test required" line | Per-type test requirement passed to programmer agent | Per-type requirement, and every criterion must be covered by a test |
| **smoke-check** | Optional; with no automated tests (WAIVED), `commands.smoke` (else `commands.build`) when set and the launch and critical-path checks carry the verdict; a build nobody launched is NOT ASSESSED | Required before phase transition | Required before every commit |
| **gate-check** | No test enforcement at phase transitions | Logic + integration tests must pass | Full coverage check + regression suite |
| **qa-plan** | Skipped entirely or minimal smoke plan | Full plan per story type | Full plan + coverage targets per system |
| **regression-suite** | Not generated | Generated at Polish stage entry | Generated at Production stage entry |
| **team-qa** | A Logic, Integration or Config/Data story without a test is WAIVED; its acceptance-criteria walk in manual QA is its evidence | The automated test is the evidence for those types | Same |
| **test-evidence-review** | A story with no test evidence is WAIVED, not MISSING; gaps in existing tests are ADVISORY; screenshots never waived | Per-type evidence reviewed; BLOCKING/ADVISORY from `testing.strict` | Same |

---

## qa.coverage_minimum

**Controls:** Minimum code coverage percentage enforced at `qa.level: full`
**Values:** integer 0–100, or `null` for unset
**Default:** `null`
**Set by:** `/saas-settings`
**Read by:** `/saas-gate-check` only. `/saas-story-done` does not reference the key, and no CI runner reads it.
  *(Derived by grep. A helper-based read such as `session_state_enabled()` would not show up, so treat this list as the verified floor, not a ceiling.)*

**Priority chain:** `qa.coverage_minimum` in `project.yaml` → no enforcement if `null`

> **Only meaningful at `qa.level: full`.** Ignored at minimal and standard. A
> non-null value at standard or minimal level emits a warning at session-start:
> *"coverage_minimum is set but qa.level is not full — value will not be enforced."*

> **Implementation is stack-specific.** Coverage measurement is different per stack:
> - Next.js: vitest coverage report (v8 / istanbul json/markdown export)
> - FastAPI: pytest-cov coverage report (xml / coverage.py report)
> - Cloudflare: vitest coverage report
> SAAS_STUDIO does not unify these — gate-check reads the stack-appropriate report.

---

## strict_gate_checks

> ### RESERVED - NOT IMPLEMENTED
>
> **No skill or hook reads this setting. Setting it has no effect.** Everything
> below describes the intended design, not current behaviour.
>
> The value is not checked when you set it, and nothing reads it.

**Controls:** Whether phase gate failures block stage transition or just warn
**Values:** `true` | `false`
**Default:** `true`
**Set by:** `/saas-settings`
**Read by:** nothing yet (intended reader: `/saas-gate-check`)

**Priority chain:** `strict_gate_checks` in `project.yaml` → hardcoded default of `true`

> **Different from `review_mode: solo`.** `review_mode: solo` skips the gate
> *entirely* — directors don't even run. `strict_gate_checks: false` runs the
> gate normally but treats the verdict as advisory.

---

### Value intent

| Value | Behavior |
|-------|----------|
| `true` | Default. FAIL or BLOCKING-CONCERNS verdict stops the stage transition. `project.stage` is not advanced. User must address findings and re-run gate. |
| `false` | All gate verdicts are advisory. `/saas-gate-check` still runs and reports findings. `project.stage` advances on user confirmation regardless of verdict. |

---

### Affected skills

| Skill | true | false |
|-------|------|-------|
| **gate-check** | FAIL verdict stops execution before writing new stage; CONCERNS verdict prompts user but defaults to "stay at current stage." | All verdicts surfaced as informational; user is asked "advance anyway?" with default Yes. |

---

## team.size

**Controls:** Which agents are active by default — solo devs shouldn't get studio-grade gating on every change
**Values:** `individual` | `small` | `studio`
**Default:** *none* — supplied by `modes.rigor` (`minimal`/`standard` yield `individual`, `full` yields `studio`)
**Set by:** `/saas-start` (via `modes.rigor`), `/saas-settings`
**Read by:** All `team-*` skills, `/saas-gate-check`, all skills that spawn agents via `Agent`

**Priority chain:** `team.size` in `project.local.yaml` → `project.yaml` → the `modes.rigor` expansion (`full` → `studio`, else `individual`) → no terminal default. Locally overridable — it is a personal-experience knob, not an on-disk artifact.

> **`individual` at `minimal`/`standard`, `studio` at `full`.** SAAS_STUDIO's audience is
> overwhelmingly solo indie developers, so the two lighter rigor tiers resolve
> `team.size` to `individual` — a `minimal` (default) or `standard` project gets one active agent
> per role, not 15 (directors and leads included). Only `rigor: full` opts into the
> full `studio` roster; a smaller team on a big project sets `team.size: small`
> explicitly, which wins over the rigor-derived value.

> **Different axis from `workflow`.** `workflow` controls *what docs are required.*
> `team.size` controls *which agents exist to make them.* A solo dev on
> `workflow: full` still doesn't need all 49 agents — they need the same coverage
> from a smaller active set.

---

### Active agent set per value

| Value | Active set | Notes |
|-------|-----------|-------|
| `individual` | Core 8: `delivery-producer`, `lead-product-manager`, `backend-engineer`, stack-specialist (stack-driven), `ui-motion-designer`, `pricing-economist`, `qa-manual-tester`, `technical-writer`. **Default.** | Directors and lead-* run only on explicit invocation (e.g. via `/saas-architecture-decision`). Specialists outside the core 8 routed through their nearest core agent. Each `team-*` skill names its own set per value, which can sit outside the core 8 (`team-release` runs `release-manager`); each skill's own `team.size` list is authoritative, and the Affected skills table below mirrors it. |
| `small` | Core 15: directors (PD, TD, DP) + leads (LPM, LE, QL, UXC) + lead-product-manager + database-architect + stack-specialist + ui-motion-designer + pricing-economist + qa-manual-tester + ux-designer + technical-writer | `team-*` skills add their `small` set (below); most reach their full pipeline only at `studio`. |
| `studio` | All 49 agents available. Stack sub-specialists (e.g. `python-backend-specialist` separate from `fastapi-specialist`) routed when relevant. The adversarial review pass in `team-core-feature`, `team-ui` and `team-polish`. | Enterprise apps, full org chart orchestration, large teams with parallel work. |

---

### Affected skills

| Skill | individual | small | studio |
|-------|------|-------|--------|
| **team-core-feature** | Single agent (backend-engineer) runs the pipeline; ai-engineer escalated only if AI work flagged | Default pipeline as documented | Default + the primary stack specialist may use its sub-specialists + adversarial review pass (Phase 5's qa-manual-tester looks for how it breaks) |
| **team-content** | technical-writer only; ux-content-strategist invoked only on explicit pillar conflict | ux-content-strategist + technical-writer, + localization-lead and onboarding-specialist at `review_mode: full` | All narrative/content agents, whatever the review mode |
| **team-ui** | frontend-engineer + ux-designer | + accessibility-auditor + design-system-director | + stack UI specialist + adversarial review pass (Phase 4's reviewers look for where it fails its spec) |
| **team-growth** | pricing-economist only | + growth-director + ui-motion-designer + backend-engineer | + accessibility-auditor + the primary stack specialist |
| **team-auth-access** | user-flow-architect only | + database-architect + appsec-engineer + qa-manual-tester | + ux-content-strategist + onboarding-specialist + accessibility-auditor |
| **team-qa** | qa-manual-tester only; qa-lead invoked at phase gates only | qa-lead + qa-manual-tester pipeline | qa-lead + per-story qa-manual-tester spawn + sign-off |
| **team-release** | release-manager only | + delivery-producer + devops-engineer + qa-lead + customer-success-ops | + appsec-engineer + data-telemetry-engineer + localization-lead + web-perf-analyst, and cloud-infra-engineer when the product has realtime multi-user features |
| **team-polish** | web-perf-analyst + ui-motion-designer; no backend engineer is active, so Phase 2's optimisation list is handed to `/saas-dev-story` | + pricing-economist + qa-manual-tester + frontend-engineer (implements Phase 2's optimisation list) | frontend-engineer, as at small, + adversarial review pass (Phase 5's qa-manual-tester looks for how it breaks) |
| **team-billing** | sre-observability-engineer + billing-engineer | + data-telemetry-engineer + customer-success-ops | + technical-writer + ux-content-strategist |
| **gate-check** | Panel width is `modes.workflow`'s axis, not this one (gates always run) — `team.size` affects only specialist depth within each director's review | Same as individual for directors; specialists within directors' reviews use small set | Same plus stack sub-specialists |
| **architecture-decision** | TD-ADR (in `full` review mode) + the primary stack specialist | Same | Same — no sub-specialist or adversarial reviewer at any size |

---

### Special cases

- `team.size` does not decide whether directors run: `/saas-gate-check`'s panel follows `review_mode` and `modes.workflow`, and no `team-*` pipeline spawns a director phase gate. In a team skill, a "phase gate" is one of the decision points its own pipeline lists, whatever the `automation` mode.
- `individual` does not disable agents — it just changes which are active by default. Any agent can still be invoked by name.
- When `team.size: individual` and a non-core agent is needed (e.g. `realtime-websockets-specialist` for a real-time collaboration story), the skill emits an informational note and routes through the nearest active core agent.

---

## platform.collaboration

**Controls:** Whether the project includes real-time multi-user collaboration — determines
which specialists are routed and which architecture sections are required  
**Values:** `true` | `false`  
**Default:** none — unset is not `false`  
**Set by:** `/saas-settings`  
**Read by:** `security-audit`, `team-release` (and the `appsec-engineer` agent)

**Priority chain:** `platform.collaboration` in `project.yaml` → unset (`platform.*` is locked to `project.yaml`, so `project.local.yaml` cannot set it). Nothing writes it except `/saas-settings`, so on most projects it is unset: `/saas-security-audit` and `/saas-team-release` ask whether the application has real-time collaborative / multi-tenant features rather than reading unset as `false`.

> **Distinct from `platform.online`.** `collaboration` is *real-time collaboration / multi-user
> specifically* (realtime specialist, websocket architecture, sync protocols).
> `platform.online` covers everything else online (APIs, auth, webhooks,
> telemetry). See next section.

> **This is a project attribute, not a mode.** It describes what the application is,
> not how the pipeline operates. It lives in `platform` alongside `targets`,
> `primary_input`, and `touch_support` — not in `modes`.

---

### Value intent

| Value | Meaning |
|-------|---------|
| `true` | Application has real-time collaboration or multi-user state. `/saas-security-audit` runs its realtime/websocket category and rates a HIGH finding as release-blocking; `/saas-team-release` adds `cloud-infra-engineer`'s sign-off. |
| `false` | No real-time collaboration. `/saas-security-audit` skips the realtime category and says so; `/saas-team-release` does not spawn `cloud-infra-engineer`. |

---

### Affected skills

| Skill | collaboration: true | collaboration: false |
|-------|--------------------|---------------------|
| **security-audit** | Includes realtime review — websocket auth, room isolation, message integrity | Realtime review skipped, and the report says so |
| **team-release** | `cloud-infra-engineer` included in release sign-off pipeline | `cloud-infra-engineer` excluded |

No other skill reads this key: `/saas-dev-story`, `/saas-create-architecture` and `/saas-gate-check`
decide concurrency scope from the story, PRD or architecture in front of them.

---

## platform.online

**Controls:** Whether the project has any online features (databases, auth, telemetry, billing, APIs)
**Values:** `true` | `false`
**Default:** none — unset is not `false`
**Set by:** `/saas-settings`
**Read by:** `security-audit`, `team-release` (and the `appsec-engineer` agent)

**Priority chain:** `platform.online` in `project.yaml` → unset (`platform.*` is locked to `project.yaml`, so `project.local.yaml` cannot set it). Nothing writes it except `/saas-settings`: `/saas-security-audit` and `/saas-team-release` ask rather than reading unset as `false`.

> **Independent of `platform.collaboration`.** A single-tenant web app with cloud
> storage and analytics is `online: true, collaboration: false`. The two settings
> have different specialist routing implications.

---

### Value intent

| Value | Meaning |
|-------|---------|
| `true` | Project includes online services (cloud databases, external APIs, auth, billing, webhooks). `/saas-security-audit` runs Category 2 (network and external integrations — including secrets hygiene and token checks) when this or `platform.collaboration` is true or unset; `/saas-team-release` adds an `appsec-engineer` sign-off. |
| `false` | Project is fully offline/local. `/saas-security-audit` skips Category 2 only when `platform.collaboration` is also false. |

---

### Affected skills

| Skill | online: true | online: false |
|-------|--------------|---------------|
| **security-audit** | Category 2 (network/integrations) runs — API auth, token validation, rate limits, HTTPS/TLS hygiene | Category 2 skipped only when `platform.collaboration` is also false |
| **team-release** | `appsec-engineer` sign-off when the application is online or stores user data | No online-driven security sign-off |

No other skill reads this key: `/saas-create-architecture`, `/saas-dev-story`, `/saas-team-billing`
and `/saas-gate-check` decide online scope from the documents in front of them.

---

## platform.cert_tier

> ### WIRED — this setting is live
>
> `/saas-launch-checklist` and `/saas-release-checklist` both resolve it and branch on its
> four values — `none` emits no compliance section, `gdpr` privacy and data governance,
> `soc2` enterprise security controls, `hipaa` healthcare compliance — and ask which
> tiers are in scope when it is unset.

**Controls:** Compliance target — scopes what `/saas-launch-checklist` asks for
**Values:** `none` | `gdpr` | `soc2` | `hipaa`
**Default:** *none* — unset stays unset, so the skills ask
**Set by:** `/saas-settings` — nothing else writes it, so it stays unset (and the skills ask) until you set it
**Read by:** `/saas-launch-checklist`, `/saas-release-checklist`

**Priority chain:** `platform.cert_tier` in `project.yaml` → unset (no default is
substituted: unset is a missing decision, `none` is a made one, and the skills
must tell them apart)

---

### Value intent

| Value | Required compliance | Best for |
|-------|---------------------|----------|
| `none` | No compliance audit | Internal tools, MVPs, hackathons (an explicit choice — unset is not `none`) |
| `gdpr` | Data privacy, cookie consent, user data export & deletion, DPA | European customers, B2C/B2B web apps |
| `soc2` | RBAC, immutable audit logging, encryption at rest & in transit, change management | Enterprise SaaS, B2B procurement |
| `hipaa` | Protected Health Information (PHI) safeguards, BAA contracts, audit controls | Healthcare and med-tech applications |

---

### Affected skills

| Skill | none | gdpr | soc2 | hipaa |
|-------|------|------|------|-------|
| **launch-checklist** | Internal launch only — no external requirements | + GDPR data subject rights, privacy policy, cookie consent checks | + SOC 2 Type II readiness, access logging, least-privilege audit | + PHI encryption verification, audit trail integrity, BAA verification |
| **release-checklist** | Smoke pass + version bump only | + Data retention and privacy endpoints verified | + Audit logs and security controls verified | + PHI access controls verified |

---

## accessibility.target

> ### RESERVED - NOT IMPLEMENTED
>
> **No skill or hook reads this setting. Setting it has no effect.** Everything
> below describes the intended design, not current behaviour.
>
> The value is checked for valid spelling when you set it, and then ignored.
> The accessibility-auditor routing and the Polish-stage audit described
> below **do not happen at any level** — `/saas-team-ui`, `/saas-team-auth-access`,
> `/saas-team-polish` and `/saas-gate-check` do not read this setting, and `/saas-start`
> does not ask for it.

**Controls:** Accessibility commitment level — routes accessibility specialist and gates audit requirements
**Values:** `none` | `standard` | `aaa`
**Default:** `none`
**Set by:** `/saas-settings`
**Read by:** nothing yet (intended readers: `/saas-team-ui`, `/saas-team-auth-access`, `/saas-team-polish`, `/saas-gate-check`)

**Priority chain:** `accessibility.target` in `project.yaml` → hardcoded default of `none`

> **Default is `none`, not `standard`.** Most SAAS_STUDIO users are solo founders and startup
> teams — defaulting to `standard` would auto-spawn the accessibility specialist
> for projects where it's overhead. `/saas-start` does not ask about it; you set it with
> `/saas-settings`.

---

### Value intent

| Value | Required features | Specialist routing |
|-------|-------------------|--------------------|
| `none` | None enforced | `accessibility-auditor` not spawned |
| `standard` | Colorblind-safe palette, captions for any video content, keyboard navigation | `accessibility-auditor` runs in team-ui, team-core-feature |
| `aaa` | Full Web Accessibility Guidelines (WCAG 2.1 AAA): contrast, keyboard navigation, screen reader, cognitive categories | `accessibility-auditor` runs in all team-* skills; mandatory audit at Polish stage |

---

### Affected skills

| Skill | none | standard | aaa |
|-------|------|----------|-----|
| **team-ui** | accessibility-auditor not spawned | accessibility-auditor included for App shell/menu reviews | accessibility-auditor included for every screen + accessibility audit pass |
| **team-core-feature** | accessibility-auditor not spawned | accessibility-auditor reviews core views for contrast and semantic markup | accessibility-auditor reviews for full keyboard/screen-reader/cognitive considerations |
| **team-polish** | No accessibility pass | Final accessibility pass added | Full accessibility audit required before completion |
| **gate-check** | No accessibility check at any stage | Polish gate checks for the standard required features | Polish gate requires full Web Content Accessibility Guidelines (WCAG 2.1 AA) compliance audit |

---

## cadence.sprint_length and cadence.milestone_length

> ### RESERVED - NOT IMPLEMENTED
>
> **No skill or hook reads this setting. Setting it has no effect.** Everything
> below describes the intended design, not current behaviour.
>
> No reference anywhere outside this file.

**Controls:** Default sprint and milestone durations for planning
**Values:**
- `sprint_length`: `1w` | `2w` | `3w` | `4w` | `none`
- `milestone_length`: `4w` | `6w` | `8w` | `12w`
**Defaults:** `sprint_length: 2w`, `milestone_length: 8w`
**Set by:** `/saas-settings`
**Read by:** nothing yet (intended readers: `/saas-sprint-plan`, `/saas-milestone-review`, `/saas-sprint-status`, future velocity tracking)

**Priority chain:** `cadence.*` in `project.yaml` → hardcoded defaults

> **`none` for `sprint_length`** means continuous-flow / kanban-style — no sprint boundaries.
> `/saas-sprint-plan` is then invoked manually as needed. Velocity tracking
> is per-week rather than per-sprint.

---

### Affected skills

| Skill | What changes |
|-------|--------------|
| **sprint-plan** | Capacity calculated as `sprint_length × team.size velocity baseline`. `none` makes the skill emit a continuous-flow plan instead. |
| **milestone-review** | Milestone window for retrospective scope = `milestone_length`. |
| **sprint-status** | Burn-down chart x-axis spans `sprint_length`. |
| **retrospective** | Sprint retro fires at `sprint_length` cadence (or weekly when sprint_length is `none`). |

---

## performance.target_framerate and performance.frame_budget_ms

**Controls:** The frame-rate target and its per-frame millisecond budget
**Values:** integers (e.g. `60`, `16.67`)
**Default:** none — unset means no budget was ever committed to
**Set by:** the user, by hand or via `/saas-settings`
**Read by:** `/saas-perf-profile`, `/saas-gate-check`, `/saas-team-polish`

## performance.draw_call_limit and performance.memory_ceiling_mb

**Controls:** Per-frame draw-call ceiling and total memory ceiling
**Values:** integers
**Default:** none — unset means no budget was ever committed to
**Set by:** the user, by hand or via `/saas-settings`
**Read by:** `/saas-perf-profile`, `/saas-gate-check`, `/saas-team-polish`

> **Every setting needs its own `## ` heading in this file, not just a table
> row.** The dead-settings audit derives what it checks from those headings, so
> a setting mentioned only inside a table is invisible to it — it can neither be
> reported DEAD if it loses its reader, nor caught if it gains one. A setting
> outside the audit's field of view is exactly how a documented-but-dead entry,
> or a working-but-listed-as-dead one, survives unnoticed.
>
> **Unset is not zero and not a default.** A budget nobody set is not a budget
> that was met — `/saas-perf-profile` must report `NOT ASSESSED` for a metric with no
> committed target rather than measuring against a placeholder. A headroom figure
> computed against an invented budget, with no profiler data behind it, reads as
> a pass and is not one; see obligations 1 and 2 in `.claude/rules/skill-authoring.md`.

## performance.enforce

**Controls:** Whether performance budget violations warn or block
**Values:** `warn` | `block` | `off`
**Default:** `warn`
**Set by:** `/saas-settings`
**Read by:** `/saas-perf-profile`, `/saas-gate-check`, CI runner

**Priority chain:** `performance.enforce` in `project.local.yaml` → `project.yaml` → hardcoded default of `warn`, resolved by `resolve_config --keys performance.enforce`

> **Read it from the resolved block, never from `project.yaml` directly.** The key is on the `/saas-settings --local` whitelist. `/saas-perf-profile` Phase 0 and `/saas-gate-check` Section 3 are the two readers the table above promises — a key that is enum-validated, accepted and displayed while nothing reads it is exactly the failure this warning guards against.

> **Mirrors the `testing.strict` pattern.** Defines what happens when a budget
> defined in `performance.target_framerate`, `frame_budget_ms`, `draw_call_limit`,
> or `memory_ceiling_mb` is exceeded.

---

### Value intent

| Value | Behavior |
|-------|----------|
| `warn` | Default. Profile runs flag violations as findings. CI logs them but doesn't fail. `/saas-gate-check` surfaces them as concerns, not blockers. |
| `block` | Profile failures block CI. `/saas-gate-check` treats violations as FAIL verdict (Polish stage onward). |
| `off` | Performance budgets are informational only — no profile runs gated, no findings surfaced. |

---

## project.stage

**Controls:** The current development phase — determines which gate-check
validates and what artifacts are expected to exist  
**Values:** `Concept` | `Systems Design` | `Technical Setup` | `Pre-Production` | `Production` | `Polish` | `Release`  
**Default:** `Concept`  
**Set by:** `/saas-gate-check` on a PASS, or on a CONCERNS the user explicitly accepts (the accepted risks are recorded); a FAIL never advances it — never set manually  
**Read by:** `gate-check`, `project-stage-detect`, `help`, `day-one-patch`, `team-release`, `launch-checklist`, `release-checklist`, `map-systems`, `team-qa`, `adopt`

> **Stage count:** This document uses the
> 7-stage reality implemented by gate-check:
> `Concept | Systems Design | Technical Setup | Pre-Production | Production | Polish | Release`

> **This is a project attribute, not a mode.** It records where the project is
> in its lifecycle. Only `/saas-start` (at onboarding) and `/saas-gate-check` write it —
> `/saas-gate-check` on a PASS verdict with user confirmation, or on a CONCERNS
> verdict whose risks the user explicitly accepts (they are recorded); a FAIL never advances it.
> Never write it manually mid-session except to correct an incorrect auto-detect.

> **Legacy fallback + dual-write.** Stage is read from `project.stage` in
> `project.yaml` first, then legacy `production/stage.txt`, then artifact
> auto-detection. When `/saas-gate-check` advances the stage it dual-writes BOTH
> `project.yaml` and `production/stage.txt`, so hooks that have not migrated
> still resolve correctly. `/saas-start` also dual-writes the initial stage. The
> legacy `.txt` file is retired at `.claude/scripts/migrate-v1-config.sh --finalize`.

---

### Stage progression and gate requirements

Each row is the gate that must be passed to advance FROM that stage.

| From stage | Key artifacts required to pass | gate-check writes |
|------------|-------------------------------|-------------------|
| **Concept** | `product-concept.md`, design pillars, Visual Identity Anchor | `Systems Design` |
| **Systems Design** | `features-modules-index.md`, all MVP PRDs reviewed, cross-PRD consistency check | `Technical Setup` |
| **Technical Setup** | Stack configured, design tokens, 3+ ADRs, architecture doc, traceability index, test framework, accessibility and interaction-pattern docs | `Pre-Production` |
| **Pre-Production** | Epics defined, first sprint plan, UX specs, control manifest | `Production` |
| **Production** | Core features implemented, main workflows functional, smoke check passes, QA sign-off | `Polish` |
| **Polish** | All features complete, content complete, localization, security audit, no open S1–S3 bugs | `Release` |

Gates adjust per `modes.workflow` — see `modes.workflow` section for what is
required at `standard` and `minimal` levels.

---

### Affected skills

| Skill | How it uses stage |
|-------|------------------|
| **gate-check** | Reads current stage to determine which gate to validate. Writes next stage on PASS, or on a CONCERNS the user explicitly accepts. |
| **project-stage-detect** | Reads `project.stage` first — if set, uses it as authoritative. Falls back to heuristic detection only if absent. |
| **help** | Uses stage to determine "where are you in the pipeline" and surfaces the correct next steps. |
| **sprint-status** | Displays current stage in status summary. |
| **day-one-patch** | Proceeds only when the stage is `Release` or `Polish`; otherwise says it is not appropriate yet. |
| **team-release** | Stops before Phase 1 unless the stage is `Release` ("run `/saas-gate-check release` first"); proceeding takes an explicit override, recorded in the go/no-go record and the report. Never writes the stage. |

---

## project.kind

> ### RESERVED - NOT IMPLEMENTED
>
> **No skill or hook reads this setting. Setting it has no effect.** Everything
> below describes the intended design, not current behaviour.
>
> No reference anywhere outside this file.

**Controls:** What type of project this is — routes skill subsets
**Values:** `saas` | `tool` | `api` | `library`
**Default:** `saas`
**Set by:** `/saas-start`, `/saas-setup-stack`
**Read by:** Many skills (advisory routing — see below)

**Priority chain:** `project.kind` in `project.yaml` → hardcoded default of `saas`

---

### Value intent

| Value | Meaning | What's deactivated |
|-------|---------|-------------------|
| `saas` | Default. Full SAAS_STUDIO framework applies. | Nothing |
| `tool` | Internal developer or admin tool | Skip public landing, pricing, billing |
| `api` | Backend service or microservice | Skip frontend design tokens, focus on OpenAPI & contracts |
| `library` | Reusable package or SDK | Emphasize unit tests + API design; no deployment pipeline |

---

### Affected skills

| Skill | saas | tool | api | library |
|-------|------|------|-----|---------|
| **brainstorm** | Full product-concept output | Tool concept output (user, problem, solution) | API concept (endpoints, consumers) | Library concept (API surface, consumers) |
| **design-tokens** | Required at appropriate workflow level | Minimal design system | Skipped | Skipped |
| **map-features** | Full feature decomposition | Tool subsystems | API endpoint & service map | Module export map |
| **usability-test** | Required at appropriate stages | Skipped or internal testing | Skipped | Consumer integration testing |
| **setup-stack** | Full web stack setup | CLI / script tooling setup | Backend stack setup | Package scaffolding |

---

## stack.name and specialists

**Controls:** Which stack-specific specialist agents are routed to for code
implementation, review, and architecture validation  
**Values:** `Next.js` | `FastAPI` | `Cloudflare`  
**Default:** `[UNSET]` — must be configured via `/saas-setup-stack`  
**Set by:** `/saas-setup-stack`  
**Read by:** `dev-story`, `code-review`, `architecture-decision`, `create-architecture`, `team-core-feature`, `team-ui`, `team-growth`

> **Currently stored in `technical-preferences.md`**, not `project.yaml`. After
> YAML expansion, `stack.name` and the specialist routing table move to
> `project.yaml specialists` block. Skill behavior is unchanged — only the
> source file changes.

> **This is a project attribute, not a mode.** Engine choice drives specialist
> routing the same way `platform.collaboration` drives network routing — skills
> respond to a fact about the project, not a process preference.

---

### Specialist routing by stack

| Engine | Language/code specialist | Database specialist | UI specialist | Additional specialists |
|--------|--------------------------|---------------------|---------------|----------------------|
| **Next.js** | `react-specialist` (TypeScript) or `tailwind-shadcn-specialist` (C#) — driven by `stack.language` | `supabase-specialist` | `nextjs-specialist` | `prisma-drizzle-specialist` |
| **FastAPI** | `fastapi-specialist` | `go-specialist` | `auth-security-specialist` | `queue-worker-specialist`, `python-backend-specialist` |
| **Cloudflare** | `cloudflare-specialist` | `cloudflare-specialist` | `email-messaging-specialist` | `aws-specialist`, `docker-k8s-specialist`, `realtime-websockets-specialist` |
| **[UNSET]** | No specialist spawned — warning emitted | No specialist spawned | No specialist spawned | None |

---

### Affected skills

| Skill | How stack.name is used |
|-------|------------------------|
| **dev-story** | Routes code stories to a programmer agent, then hands the changed files to the language specialist (the generic stack specialist when none is set) for an stack-API check. |
| **code-review** | Routes review to language, database, or UI specialist based on file type being reviewed. |
| **architecture-decision** | Loads `docs/stack-reference/[stack]/VERSION.md` before authoring. Spawns stack specialist to validate ADR for API correctness and post-cutoff compatibility. |
| **create-architecture** | Includes stack-specific constraints and patterns in architecture doc based on stack choice. |
| **team-core-feature / team-ui / team-growth** | Spawn the stack specialist their pipeline names: team-core-feature the primary stack specialist (from `team.size: small`), team-ui the stack UI specialist (`specialists.ui`, at `studio`), team-growth the primary stack specialist (at `studio`). The other six `team-*` skills spawn none. |

---

## commands

> **Live since the run-and-observe step.** This block was RESERVED — written by
> `/saas-setup-stack`, read by nothing — through most of v1.1. `test`, `smoke` and
> `build` gained readers as the parse-check and smoke gates landed; `run` gained
> its reader last, when `/saas-dev-story` Phase 6 step 4 started launching the application to
> look at it. The per-skill table at the bottom is now current behaviour, not
> intent. `validate-push.sh` was once named as a reader and never was.

**Controls:** Explicit shell commands to build, test, run, and smoke-test the project
**Values:** strings — shell-executable commands
**Default:** `[UNSET]` — populated by `/saas-setup-stack` with stack-typical defaults
**Set by:** `/saas-setup-stack`, `/saas-settings`
**Written by:** `/saas-setup-stack`, `/saas-settings`. **Read by:** `test` — `/saas-smoke-check`, `/saas-hotfix` (narrowed to the affected suite), `/saas-bug-report` (verify mode, narrowed to the affected suite), `/saas-post-launch-monitor` (targeted fix and, when set, the broader regression — NOT ASSESSED if unset), `/saas-dev-story` (Next.js parse-check executable resolution), `/saas-test-setup` (the `<Project>.` filter root on Cloudflare), `project-coherence.sh`; `smoke` — `/saas-dev-story` (FastAPI parse check), `/saas-smoke-check` (build check when tests are WAIVED); `build` — `/saas-smoke-check` (build check when tests are WAIVED and `smoke` is unset), `project-coherence.sh`; `run` — `/saas-dev-story` (Phase 6 step 4, the run-and-observe step). `/saas-launch-checklist` and `/saas-regression-suite` name these commands but do not run them.
  *(Derived by grep. A helper-based read would not show up, so treat this list as the verified floor, not a ceiling.)*

**Priority chain:** `commands.*` in `project.yaml` → stack-typical default → no command available

> Why explicit: Without this block, SAAS_STUDIO has to guess stack-typical conventions
> for invoking the project. Better to be explicit per-project — covers cases where
> projects customize their build (e.g., a Next.js project using vitest for tests but
> a custom export script for builds).

---

### Fields

Each command can be a simple string (used on all OSes) or an OS-aware map:

**Simple form** (one command, used on every OS):
```yaml
commands:
  build: "npm run build"
  test:  "npm test -- --run"
  run:   "npm run dev"
  smoke: "npm run build && npm test"
```

Note that `build` executes the production build check for CI/CD or preview deployments.

**OS-aware form** (different commands per OS):
```yaml
commands:
  build:
    default: "npm run build"
    windows: "npm run build"
    macos:   "npm run build"
  test:
    default: "npm test -- --run"
  run:
    default: "npm run dev"
  smoke:
    default: "npm run build && npm test"
```

**Resolution rule:** if the value is a string, use it as-is on any OS. If the
value is a map, skills/hooks read the current OS and pick the matching key
(`linux`, `windows`, `macos`). Fall back to `default` if no OS-specific key
matches.

This solves the Windows/Linux/macOS path-and-binary-name differences without
breaking the whitelist (commands stays locked to project.yaml — the OS-specific
keys are inside the locked file, not a local override).

| Field | Purpose |
|-------|---------|
| `build` | Full project build for CI or release. `/saas-smoke-check` runs it only as the WAIVED-path build check when `commands.smoke` is unset; `project-coherence.sh` (which `/saas-smoke-check` runs first) checks the build command it names, and `/saas-launch-checklist` only asks whether the build produces a valid artifact. |
| `test` | Run the full test suite. Run by `/saas-smoke-check` and, narrowed to the affected suite, by `/saas-hotfix`, `/saas-bug-report` (verify mode) and `/saas-post-launch-monitor`; `project-coherence.sh` checks the runner it names. `/saas-regression-suite` does **not** run it. |
| `run` | Launch the **web application development server** locally. Used by `/saas-dev-story` Phase 6 step 4 to observe the feature and verify functionality; see `.claude/docs/run-and-observe.md` for details. |
| `smoke` | Minimal "does it boot?" check. Run by `/saas-dev-story` as the FastAPI parse check (Phase 6 step 2), and by `/saas-smoke-check` as the build check when `qa.level: minimal` waives tests. |

---

### Stack defaults

When `/saas-setup-stack` runs, it populates `commands` based on stack choice.

| Stack | build | test | run | smoke |
|-------|-------|------|-----|-------|
| Next.js | `npm run build` | `npm test` | `npm run dev` | `npm run build -- --dry-run` |
| FastAPI | `python -m build` | `pytest` | `uvicorn main:app --reload` | `python -c "import main"` |
| Cloudflare | `wrangler deploy --dry-run` | `vitest run` | `wrangler dev` | `wrangler types` |

Users override per-project as needed via `/saas-settings commands.<field>=<value>` or by editing `project.yaml` directly.

---

### Affected skills

| Skill | How `commands` is used |
|-------|------------------------|
| **smoke-check** | Runs `commands.test`, or the stack's default when it is unset; on Cloudflare it builds the editor target first. Critical path for QA hand-off. |
| **launch-checklist** | Emits a checklist **item** asking whether the build produces a valid artifact. It does **not** run `commands.build`; the verification is a human step. |
| **validate-push.sh** | Does **not** read `commands.*`. It warns on pushes to protected branches (`main`/`master`/`release/*`) and runs no build or smoke command — the block path in it is commented out, so it never fails a push. |
| **dev-story** | Phase 6 step 2 is the parse check: `.claude/scripts/ts-parse-check.sh` on Next.js, `commands.smoke` on FastAPI, the editor-target build on Cloudflare. Phase 6 step 4 runs `commands.run` — the local application launch — to observe the feature and verify functionality (`.claude/docs/run-and-observe.md`). |
| **regression-suite** | Maps coverage by **globbing test filenames**. It does **not** invoke `commands.test`, so coverage here means "a test file exists", never "a test passed". |

---

## naming

**Controls:** Code naming conventions for the project
**Values:** see field list below
**Default:** stack-specific (auto-populated by `/saas-setup-stack`)
**Set by:** `/saas-setup-stack`, `/saas-settings`
**Read by:** `/saas-adopt`, `/saas-architecture-review`, `/saas-asset-spec`,
`/saas-create-architecture`, `/saas-create-control-manifest`, `/saas-dev-story`,
`/saas-vertical-slice` — each reads `naming.*` from `project.yaml` and feeds the
conventions into a brief, manifest or spec. **NOT by `/saas-code-review` and NOT by
`validate-commit.sh`**.
  *(Reader list derived by grep, so treat it as the verified floor rather than
  a ceiling — a skill reading the value through a helper would not show up.)*

> **These conventions are guidance, not a gate.** They reach your project by
> being passed into briefs, manifests and specs for whoever writes the code.
> Nothing checks the result: `/saas-code-review` does not validate files against them
> and `validate-commit.sh` does not warn on violations — neither contains any
> naming logic. If you need enforcement, it has to be added.
>
> **Asset filenames.** `validate-assets.sh` warns when a file under Next.js's
> `assets/` has an uppercase letter, a space or a hyphen in its name (it expects
> lowercase with underscores), and it takes no config input. `/saas-asset-spec`
> specifies asset names from `naming.*`. FastAPI's `Assets/` and Cloudflare's `Content/`
> are not naming-checked: those stacks name assets in PascalCase. On Next.js-C#,
> where `/saas-setup-stack` sets `naming.files: PascalCase`, the hook warns on assets
> named exactly as `/saas-asset-spec` specified them. `naming.files` describes
> **source** files by its own examples (`BillingController.cs`), and no key governs
> asset filenames, so treat the hook's naming warning as advisory there.

> **Moved from `technical-preferences.md`**, which is being deleted. Naming
> conventions are project-level facts shared by everyone on the project, so they
> belong in `project.yaml` alongside the rest of your structured config.

---

### Fields

| Field | Values | Next.js default | FastAPI default | Cloudflare default |
|-------|--------|---------------|---------------|----------------|
| `classes` | `PascalCase` \| `snake_case` \| `camelCase` | PascalCase | PascalCase | PascalCase |
| `variables` | `snake_case` \| `camelCase` | snake_case | camelCase | camelCase |
| `constants` | `SCREAMING_SNAKE` \| `PascalCase` | SCREAMING_SNAKE | SCREAMING_SNAKE | SCREAMING_SNAKE |
| `signals` (Next.js) / `events` (FastAPI, Cloudflare) | `past_tense` \| `on_event_name` | past_tense | on_event_name | OnEventName |
| `files` | `snake_case` \| `PascalCase` \| `kebab-case` | snake_case | PascalCase | PascalCase |
| `scenes` / `prefabs` | `snake_case` \| `PascalCase` | snake_case | PascalCase | PascalCase |

> **`signals` vs `events`:** Next.js uses signals natively; FastAPI uses C# events
> or UnityEvents; Cloudflare uses delegates and dynamic multicast. The field stays
> named `signals` in project.yaml for consistency across stacks — interpret as
> "event-like callbacks" regardless of stack.

---

### Affected skills

| Skill | How naming is used |
|-------|--------------------|
| **dev-story** | Passes the naming conventions to the programmer subagent as part of the implementation context |
| **create-control-manifest** | Emits the conventions as manifest rows (classes, variables, signals/events, files, constants) |
| **asset-spec** | Specifies asset naming per the configured convention |
| **create-architecture** / **architecture-review** | Read as project config alongside `performance.*` |
| **vertical-slice** / **adopt** | Read as project config; `/saas-adopt` audits conformance at MEDIUM severity |

No skill or hook validates code *against* these conventions — see the note above.

---

## features.session_state

**Controls:** Whether the harness runs a full session tracking pipeline (hooks,
log files, `active.md` checkpoint) or relies on
skeleton-first output files for recovery  
**Values:** `off` | `on`  
**Default:** `on`  
**Set by:** `/saas-settings`  
**Read by:** Five hooks — `session-start.sh` (its recovery preview only),
`pre-compact.sh`, `session-stop.sh`, `log-agent.sh` and `log-agent-stop.sh`. No skill reads it, and neither does `statusline.sh`.

> **`on` is the recommended setting.** Long-form skills write self-describing
> skeleton files upfront, which covers much of mid-task recovery on its own; the
> session pipeline adds the checkpoint preview at session start, the session
> archive and the subagent tally. Turn it `off` only to save that preview's
> tokens.

> **Priority chain:** `features.session_state` in `project.local.yaml` →
> `project.yaml` → hardcoded default of **`on`**. Hooks read it via
> `session_state_enabled()` in `yaml-helper.sh` and exit early when `off`.
> Skills do not read it: `/saas-dev-story` and `/saas-story-done` update the checkpoint in
> `active.md` whatever its value.

> **The default is `on`, deliberately.** `.claude/docs/context-management.md`
> tells you to rely on `production/session-state/active.md` as your
> crash-recovery checkpoint, so defaulting this off would quietly take away
> recovery, the session archive and the subagent tally. What `off` saves — the
> checkpoint preview, at most ~750 tokens per session start — is an explicit
> opt-out (`/saas-settings features.session_state=off`), never a silent default.

> **`session-start.sh` is gated per-block, not at the top.** Its sprint,
> milestone and git context is not part of the session-state pipeline; only the
> `active.md` recovery preview is gated. Its check also fails OPEN — that hook
> sources `yaml-helper.sh` conditionally, and an undefined function is falsey,
> which would suppress the recovery checkpoint invisibly.

---

### Value intent

| Value | Intent |
|-------|--------|
| `off` | Recovery via skeleton-first output files. Long-form skills write a complete skeleton (all section headers, empty bodies) before starting. If context clears or compacts, the agent reads the skeleton + relevant docs and resumes. The five session-state hooks do nothing, so no logs; skills still update the checkpoint in `active.md`, but session start does not show it. Saves at most ~750 tokens per session start. |
| `on` | Full session tracking. Session-stop archival, compaction log and agent audit log all active. Adds the checkpoint preview to each session start, capped at 25 lines or 3,000 characters (at most ~750 tokens). Compaction hooks log to disk and add nothing to Claude's context. |

---

### Hook behavior

> **Implementation note:** The feature flag check lives inside each hook script,
> not at the harness level. Every session-state-aware hook calls
> `session_state_enabled()` from `yaml-helper.sh` at its top (an awk read of
> `project.local.yaml`, then `project.yaml`) and exits silently with no output if
> the value is `off` — except `session-start.sh`, which skips only its recovery
> preview. This ensures
> the harness always fires the hook — the hook decides whether to act.

| Hook | session_state: off | session_state: on |
|------|--------------------|-------------------|
| **session-start.sh** | Runs normally (git/sprint context) — skips the `active.md` checkpoint preview | Runs fully, including the `active.md` checkpoint preview |
| **detect-gaps.sh** | Runs unchanged — gap detection is independent of session state | Runs unchanged |
| **pre-compact.sh** | No-op — exits silently (no compaction-log append) | Appends one line to `compaction-log.txt` and prints nothing (PreCompact output never reaches Claude; `session-start.sh` restores context) |
| **session-stop.sh** | No-op — exits silently | Archives `active.md` to `session-log.md` when it has changed, appends commits and uncommitted file names, writes the spawn tally to `session-cost.md`; prints nothing |
| **log-agent.sh** | No-op — exits silently | Appends to agent-audit.log |
| **log-agent-stop.sh** | No-op — exits silently | Appends to agent-audit.log |

---

### File existence by mode

| File | session_state: off | session_state: on |
|------|--------------------|-------------------|
| `production/session-state/active.md` | Still written by skills; session start does not show it | Written by skills; session start shows its checkpoint |
| `production/session-logs/session-log.md` | Not written | Append-only archive of each session's `active.md` |
| `production/session-logs/compaction-log.txt` | Not written | Append-only timestamp log of compaction events |
| `production/session-logs/agent-audit.log` | Not written | Append-only log of agent spawn/complete events |

---

### Skeleton-first pattern (session_state: off recovery mechanism)

Long-form skills must write a skeleton file as their first action — before any
section discussion begins. The skeleton contains all section headers with empty
bodies and a `<!-- STATUS: incomplete -->` marker per section.

```markdown
# Billing System — PRD

## Overview
<!-- STATUS: incomplete -->

## User Stories & Personas
<!-- STATUS: incomplete -->

## Detailed Rules
<!-- STATUS: incomplete -->
...
```

As each section is approved and written, the marker changes to `<!-- STATUS: done -->`.
On recovery (after /clear or compaction), the agent reads the skeleton, identifies
which sections are `done` vs `incomplete`, reads relevant ADRs and the systems index,
and resumes at the first `incomplete` section. No `active.md` needed.

**Skills required to implement skeleton-first:**

| Skill | Output file | Skeleton written when |
|-------|-------------|----------------------|
| **design-system** | `design/prd/[system].md` | Before Phase 1 (section discussion) |
| **design-tokens** | `design/tokens/design-system-tokens.md` | From `.claude/docs/templates/design-system-tokens.md`, after asking, when section 1 is approved |
| **create-architecture** | `docs/architecture/architecture.md` | Not skeleton-first: written once at Phase 7 after its ask (an existing document is updated in place) |
| **ux-design** | `design/ux/[screen].md` | Before screen discussion |
| **create-stories** | `production/epics/[epic-slug]/story-NNN-[slug].md` | Not skeleton-first: written in Step 6, after the ask names every file |
| **create-epics** | `production/epics/[epic-slug]/EPIC.md` | Not skeleton-first: written after its per-epic "May I write `production/epics/[epic-slug]/EPIC.md` and add its row to `production/epics/index.md`" ask |
| **map-features** | `design/prd/features-modules-index.md` | Before feature enumeration |
| **brainstorm** | `design/prd/product-concept.md` (`standard`/`full`) · `design/product-brief.md` (`minimal`) | Before concept discussion |

> **Note on agents:** `onboarding-specialist` and `ux-content-strategist` are agents, not
> invocable skills — they do not have SKILL.md files. Long-form output from these
> agents is produced via the skills above (design-system, design-tokens, etc.) which
> are responsible for skeleton-first enforcement.

---

### Status line behavior

> **Stage detection is always independent of session state.** `statusline.sh`
> auto-detects stage from `project.yaml` `project.stage` or artifact heuristics regardless
> of `session_state` value, and so is the breadcrumb: `statusline.sh` never reads
> `session_state`. (At `workflow: minimal` the status line shows the story count
> instead of the stage.)

| Feature | session_state: off | session_state: on |
|---------|--------------------|-------------------|
| Context % display | Always shown | Always shown |
| Model display | Always shown | Always shown |
| Stage display | From project.yaml or heuristics — except at `workflow: minimal`, where `Minimal · <done>/<total> stories` (or `Minimal · brief` before any story exists) replaces it | Same |
| Epic/Feature/Task breadcrumb | Parsed from the `<!-- STATUS -->` block in `active.md` (not gated) | Parsed from the `<!-- STATUS -->` block in `active.md` |

---

### Affected skills

Skills interact with session state in two ways: **inference** (reading `active.md`
to resolve a missing argument) and **extraction** (appending a SESSION EXTRACT
block after completing work). Neither is gated: no skill reads `session_state`,
so both happen whatever its value.

#### Inference — skills that read `active.md` to fill in missing arguments

When `active.md` holds nothing to infer from, these skills must receive the
argument explicitly. If called without an argument, they should prompt the user
rather than fail silently.

| Skill | What it infers from `active.md` | Fallback when nothing is found |
|-------|----------------------------------|---------------------|
| **dev-story** | Active story path (when no arg given) | Prompt user for story path |
| **story-done** | In-progress story path (when no arg given) | Prompt user for story path |
| **team-release** | Target version (when no arg given) | Prompt user for version |
| **team-qa** | Active sprint (when no arg given) | Prompt user for sprint file |
| **help** | Current task and STATUS block for context-aware suggestions | Responds without session context — surfaces next steps from sprint/epics only |

#### Extraction — skills that write session state to active.md

These skills write a structured block after completing work, whatever
`session_state` is. `/saas-dev-story` and `/saas-story-done` overwrite
the `<!-- CHECKPOINT -->` block; the others append a SESSION EXTRACT.

| Skill | What it writes to active.md |
|-------|-----------------------------|
| **dev-story** | Checkpoint: story path, next step, blockers, files changed, run result |
| **story-done** | Checkpoint: verdict, story path, next story, tech debt count |
| **architecture-review** | Verdict, TR coverage counts, new TR-IDs, PRD flags, ADR gaps, report path |
| **prototype** | Prototype scope, current phase, key decisions |
| **vertical-slice** | Slice concept, current phase, blocked items |
| **team-qa** | QA phase comment, blocking issues |
| **map-systems** | Task record: systems enumerated, current phase |

---

### Token cost summary

| Scenario | session_state: off | session_state: on |
|----------|--------------------|-------------------|
| Per session start | ~500 tokens (git/sprint context only) | ~500–1,250 tokens (+ checkpoint preview, at most ~750) |
| Per compaction event | 0 (compaction hook output never reaches Claude) | 0 (logged to disk only) |
| Per session end | 0 | File I/O only (no conversation tokens) |
| Recovery after /clear | Read skeleton + 2–3 docs (~1,000–3,000 tokens) | Read `active.md` (~200–500 tokens) |

> **Note:** The `off` recovery cost (reading skeleton + docs) is paid only when
> recovery is actually needed. The `on` session-start cost is paid every session
> whether recovery is needed or not.

---

## features.token_budget_warn_at

> ### RESERVED - NOT IMPLEMENTED
>
> **No skill or hook reads this setting. Setting it has no effect.** Everything
> below describes the intended design, not current behaviour.
>
> The value is not checked when you set it, and nothing reads it.
> Nothing warns at any threshold.

**Controls:** Context usage threshold at which session warnings fire
**Values:** float between 0.0 and 1.0
**Default:** `0.7` (warn at 70%)
**Set by:** `/saas-settings`
**Read by:** nothing yet (intended readers: `session-start.sh`, `statusline.sh`)

**Priority chain:** `features.token_budget_warn_at` in `project.yaml` → hardcoded default of `0.7`

> Surfaces a warning when session context usage exceeds the threshold. Helps
> cost-conscious users hit `/clear` before runaway sessions. Set to `1.0` to
> disable.

---

### Behavior

| Threshold | What fires |
|-----------|-----------|
| Below `warn_at` | No warning |
| At or above `warn_at` | `statusline.sh` shows context usage in yellow; next session-start hook emits a one-line note: *"Last session reached [X]% context — consider /clear if continuing work."* |
| At 90%+ | Yellow becomes red regardless of `warn_at` value |

---

## features.read_guard

**Controls:** Whether a whole-file Read of a large design doc is refused  
**Values:** `on` | `off`; `true` and `false` also work  
**Default:** `on`  
**Set by:** `/saas-settings`  
**Read by:** `validate-read.sh` (PreToolUse Read), through `.claude/scripts/read-guard.sh check`

> **Priority chain:** `features.read_guard` in `project.local.yaml` →
> `project.yaml` → default **`on`**.

A Read with no offset and no limit of a file under `design/`, `docs/architecture/`
or `production/session-state/` that is over `features.read_guard_kb` is refused.
The refusal lists the doc's headings with their line numbers, so the next call
reads one section with offset and limit. A ranged read always passes, so no skill
can get stuck behind the guard; images and PDFs are never checked. It blocks
rather than warns because a warning would let the whole read happen, and the
read is the cost.

---

## features.read_guard_kb

**Controls:** The size over which `features.read_guard` refuses a whole-file read  
**Values:** a whole number of KB (1 KB = 1,024 bytes)  
**Default:** `40`  
**Set by:** `/saas-settings`  
**Read by:** `validate-read.sh`, through `.claude/scripts/read-guard.sh check`

> **Priority chain:** `features.read_guard_kb` in `project.local.yaml` →
> `project.yaml` → default **`40`**. A value that is not a whole number is
> ignored, and `read-guard.sh check` names it on its `threshold` row.

By file size, not lines: token cost follows bytes, and one table row can be 2 KB.
40 KB is about 10,000 tokens and sits above every shipped template (the largest is
33 KB).

---

## updates.check

**Controls:** Whether session start tells you that a newer Claude Code SaaS
Studio release is out  
**Values:** `true` | `false`  
**Default:** `true`  
**Set by:** `/saas-settings` (`/saas-settings --local updates.check=false` turns it off
for you only)  
**Read by:** `session-start.sh`, through `update-check.sh`

> When a newer release is out, session start shows one line: *"Update: Claude
> Code SaaS Studio 1.1.0 is out (this project has 1.0.0). What changed and how
> to upgrade: <release page> — to stop this notice: /saas-settings --local
> updates.check=false"*. Nothing is downloaded or changed; upgrading stays your
> call (`UPGRADING.md`).

> **Priority chain:** `updates.check` in `project.local.yaml` → `project.yaml` →
> default **`true`**. A value other than `true` or `false` is skipped and named
> in the session-start schema errors. The check is also off whenever the `CI`
> environment variable is set: nobody reads session start there.

---

### How it checks

- At most once a day, a background job asks GitHub for the latest release
  and stores the answer in `~/.cache/saas-studio/latest-release`
  (under `$XDG_CACHE_HOME` when that is set). The file is per user and outside
  every project, so `git status` stays clean and one check covers every project
  on the machine.
- Session start only reads that file. It makes no network call and never waits;
  a new answer shows from the next session on.
- Offline, or with neither `curl` nor `wget`, it stays silent. The cache keeps
  the last answer, plus an `error=` line saying why the last check failed.
- Pre-releases are never offered.
- The version compared is the one the framework's own hook files carry, not
  `framework.version`: an upgrade that keeps your `project.yaml` leaves that
  number behind, and the line would announce the release you already have.
- With `false`, nothing is read and nothing is requested.

---

## schema_version

**Controls:** Which version of the project.yaml schema this file conforms to
**Values:** integer
**Default:** `1` (for v1.1 of SAAS_STUDIO)
**Set by:** `/saas-start`, `/saas-adopt`
**Read by:** All skills and hooks that parse project.yaml (for migration safety)

> Lets future SAAS_STUDIO versions detect and migrate old project.yaml files. The
> migration logic compares `schema_version` in the file against the current
> SAAS_STUDIO's expected version. If newer, warn. If older, run migrations.

---

### Migration behavior

| project.yaml schema_version | Current SAAS_STUDIO expects | Behavior |
|----------------------------|---------------------|----------|
| Matches expected | — | Normal operation |
| Lower than expected | — | `/saas-adopt` warns and offers migration; skills run with deprecation warnings |
| Higher than expected | — | All skills warn: "This project.yaml was created by a newer SAAS_STUDIO version. Some settings may be ignored." |
| Missing | — | Treated as legacy (pre-v1.1); migration prompted on next `/saas-start` or `/saas-adopt` |

---

## framework

**Controls:** Tracks which SAAS_STUDIO version created or last touched this project
**Values:** `framework.version` (semver string) + `framework.last_upgraded` (ISO date)
**Default:** stamped in the template's `project.yaml` at each release
**Set by:** the template; `/saas-start` (through `set-stage.sh`), `/saas-setup-stack` and `/saas-gate-check` write the block into a `project.yaml` they create, and `migrate-v1-config.sh` (which `/saas-adopt` runs) writes `framework.version` into the one it builds
**Read by:** no skill branches on it — it is file metadata, not a behavioural setting. It appears in `/saas-start`, `/saas-gate-check`, `/saas-settings` and `/saas-setup-stack` as part of the `project.yaml` block they **write or display**, and in `yaml-helper.sh`.
  *(The four skills above were verified to name it; whether each reads it or merely emits it was NOT separated, so this says 'appears in', not 'read by'.)*

---

### Fields

```yaml
framework:
  version: "1.2.0"
  last_upgraded: "2026-10-18"
```

| Field | Purpose |
|-------|---------|
| `version` | The SAAS_STUDIO version that created the project (or was last updated to — see `UPGRADING.md`). |
| `last_upgraded` | ISO date of the most recent template update. |

---

### Affected skills

None. No skill or hook reads `framework.version` or `last_upgraded` — `/saas-adopt`
does not consult them and no hook checks their age. They record which template
version the project came from; `UPGRADING.md` is the upgrade path.

---

## Migration from v1.0 → v1.1

When a v1.0 SAAS_STUDIO project upgrades to v1.1, migration tooling (run via `/saas-adopt`)
converts legacy files to `project.yaml`. This section specifies the intended
behavior.

### Detection

A project is detected as needing migration when:
- `project.yaml` does **NOT** exist at the repo root, AND
- One or more legacy files exists:
  - `production/stage.txt`
  - `production/review-mode.txt`
  - `.claude/docs/technical-preferences.md`

### Preservation

| Legacy source | Migrates to |
|---------------|-------------|
| `production/stage.txt` (single line) | `project.stage` |
| `production/review-mode.txt` (single line) | `modes.review_mode` |
| `.claude/docs/technical-preferences.md` → "Engine & Language" section | `stack.name`, `stack.version`, `stack.language` |
| `technical-preferences.md` → "Input & Platform" section | `platform.targets`, `platform.primary_input`, `platform.touch_support` |
| `technical-preferences.md` → "Naming Conventions" section | `naming.classes`, `naming.variables`, `naming.constants`, `naming.signals`, `naming.files`, `naming.scenes` |
| `technical-preferences.md` → "Performance Budgets" section | `performance.target_framerate`, `performance.frame_budget_ms`, `performance.draw_call_limit`, `performance.memory_ceiling_mb` |
| `technical-preferences.md` → "Testing" section | `testing.framework`, `qa.coverage_minimum` (bare number only — prose is reported for manual entry) |
| `technical-preferences.md` → "Engine Specialists" section | `specialists.code`, `specialists.database`, `specialists.ui`, `specialists.additional` |

**Value rename — `review_mode: none` → `solo`.** v1.0 used `none` for the "no
director reviews" tier; v1.1 renamed that tier to `solo` (the enum is
`full | lean | solo`). Migration **coerces** a legacy `none` to `solo` and reports
the rename in the migration report's Warnings. This is the one documented value
rename, so it is mapped-and-flagged rather than preserved raw: writing `none`
verbatim would produce an enum-invalid `project.yaml` that `resolve_config` rejects
and falls back to the `modes.rigor` value — at `standard` that is `lean`, reviews *on* —
inverting the user's intent. The
`--finalize` preservation check applies the same mapping so it does not falsely
refuse. Every *other* non-v1.1 stage/review value is a fork, not a rename:
preserved raw and flagged for manual resolution, never coerced.

Settings absent from the legacy files (new v1.1 settings like `qa.level`,
`docs.density`, `team.size`, etc.) get hardcoded defaults from the v1.1 schema.

### Cleanup (optional, non-destructive)

Migration is **non-destructive in v1.1**: legacy files are NOT auto-deleted.
Migration produces `project.yaml` and leaves the legacy files in place. Hooks
and skills read `project.yaml` first; they fall back to the legacy file if a
specific key is missing.

Legacy files are deleted only when the user runs
`.claude/scripts/migrate-v1-config.sh --finalize` (driven by `/saas-adopt`, which
detects a v1.0 project automatically at Phase 2g). The cleanup step verifies
that every legacy file's content has been preserved in `project.yaml` before
deleting.

### Failure modes

| Problem | Behavior |
|---------|----------|
| Legacy file is malformed (can't parse) | Migration emits warning per file, leaves it untouched, continues with the others. `project.yaml` gets the parseable values + defaults for the rest. |
| Parsed value doesn't match v1.1 enum (e.g. `stage: Alpha` from a fork) | Migration writes the raw value with a `_migration_warning` comment in `project.yaml`. User resolves manually. |
| Both `project.yaml` AND a legacy file exist (split-brain) | Migration tooling refuses to run. Error: "Both project.yaml and legacy files exist — resolve which is authoritative before migrating." |
| Custom sections in forked `technical-preferences.md` | Custom content logged to `production/migration-report.md` as "not migrated — please integrate manually." |

### Migration report

Every migration run writes `production/migration-report.md`:

- Source files detected
- Values preserved (per file → per setting)
- Defaults applied (for v1.1-new settings)
- Warnings encountered (malformed, mismatched enums, etc.)
- Manual review items

User reads the report before running `--finalize`.

---

## Complete example `project.yaml`

A full project.yaml with every setting, showing sensible defaults for a solo
Next.js project. Use this as the reference shape when authoring or migrating.

```yaml
schema_version: 1

framework:
  version: "1.2.0"
  last_upgraded: "2026-10-18"

project:
  name: "Acme SaaS"
  category: "B2B Analytics"
  version: "0.1.0"
  stage: Concept             # Concept | Systems Design | Technical Setup | Pre-Production | Production | Polish | Release
  kind: saas                 # saas | tool | api | library

modes:
  review_mode: lean          # full | lean | solo
  workflow: standard         # minimal | standard | full
  automation: collaborative  # collaborative | guided | autonomous
  automation_always_ask:     # decision categories that always prompt regardless of mode
    - scope_changes
    - file_deletions
    - schema_changes
  story_granularity: balanced  # coarse | balanced | fine

# TOP-LEVEL, not nested under `modes:` — resolve_config reads
# `workflow_overrides.system_overrides.*` from the document root
# (yaml-helper.sh), and every skill greps the same top-level path.
# Nesting it under `modes:` parses as valid YAML and is silently never read.
workflow_overrides:
  edge_cases: false          # force PRD Edge Cases section required
  configuration_parameters: false  # force PRD Configuration Parameters section required
  design_tokens_strict: false    # force all 9 design tokens sections regardless of asset stories
  system_overrides: {}       # { billing: full, auth: minimal }

docs:
  density: balanced          # terse | balanced | thorough

testing:
  framework: vitest          # stack-specific — auto-populated by /saas-setup-stack
  strict:
    logic: true              # unit test failures BLOCK story closure
    integration: true        # integration test failures BLOCK
    visual: true             # missing screenshot BLOCKS
    ui: true                 # missing screenshot BLOCKS
    config: false            # advisory only

qa:
  level: standard            # minimal | standard | full
  coverage_minimum: null     # integer 0-100; only enforced at level: full

strict_gate_checks: true     # phase gate failures block stage transition

team:
  size: individual           # individual | small | studio

platform:
  collaboration: false       # real-time collaboration / multi-user
  online: true               # any online features (APIs, auth, telemetry)
  targets: [Web]             # [Web, Mobile, Desktop]
  primary_input: "Keyboard/Mouse"
  touch_support: "None"      # Full | Partial | None
  cert_tier: none            # none | soc2 | hipaa | gdpr

stack:
  name: "Next.js"            # Next.js | FastAPI | Cloudflare — set by /saas-setup-stack
  version: "14.2"
  language: "TypeScript"     # TypeScript | Python
  framework: "App Router"
  styling: "Tailwind CSS"

specialists:                 # auto-populated by /saas-setup-stack
  frontend: "react-specialist"
  database: "supabase-specialist"
  ui: "nextjs-specialist"
  orm: ["prisma-drizzle-specialist"]

naming:
  classes: PascalCase        # PascalCase | snake_case | camelCase
  variables: camelCase
  constants: SCREAMING_SNAKE
  functions: camelCase
  files: kebab-case
  routes: kebab-case

accessibility:
  target: none               # none | standard | aaa

cadence:
  sprint_length: "2w"        # 1w | 2w | 3w | 4w | none
  milestone_length: "8w"     # 4w | 6w | 8w | 12w

performance:
  ttfb_ms: 200
  lcp_ms: 2500
  fid_ms: 100
  cls: 0.1
  enforce: warn              # warn | block | off

commands:                    # simple string OR OS-aware map per command
  build: "npm run build"
  test: "npm test -- --run"
  run: "npm run dev"
  smoke: "npm run build && npm test"

features:
  session_state: on          # off | on
  token_budget_warn_at: 0.7  # 0.0-1.0; warn at this context % usage
  read_guard: on             # on | off; true and false also work. Refuse whole-file reads of large design docs
  read_guard_kb: 40          # the size, in KB, over which they are refused

updates:
  check: true                # false: no new-release line at session start
```

And a minimal sparse `project.local.yaml` example — a single developer who wants autonomous mode locally:

```yaml
modes:
  automation: autonomous
features:
  session_state: on
```

Only the overridden keys are present; everything else cascades from `project.yaml`.
See "Local Override Pattern" section for full whitelist of what can/cannot be overridden locally.
