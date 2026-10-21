# Skill Contract Template

> **Status — read before using this template.**
>
> The **Identity & Scope**, **Input Contract**, **Output Contract**, **Hard/Soft
> Constraints** and **Handoff Configuration** sections are live and reflect how
> contracts are authored today.
>
> The **Testing Evidence Required** and **Drift Monitoring** sections are
> **aspirational** — the runners they name (`tests/smoke-tests/`,
> `tests/golden-datasets/`, `tests/behavioral-tests/`, `tests/integration/`) and
> `production/session-state/drift-monitor.md` do **not exist**, no skill has a
> `TESTS.md`, and none of the seven shipped `CONTRACT.md` files use the ASI or
> drift machinery. Treat them as a design sketch for a future skill-quality
> system, not as steps to follow.
>
> The seven shipped contracts use a simpler shape than this template:
> `Inputs Consumed` / `Files That Must Exist` / `Preconditions` /
> `Outputs Produced` / `Output Guarantees` / `Immutability Rules`. Match an
> existing contract (e.g. `.claude/skills/saas-dev-story/CONTRACT.md`) rather than
> this template's schema-heavy form until the two are reconciled.

**Purpose:** Define formal handoff contract for a skill. Create as `.claude/skills/<skill-name>/CONTRACT.md`.

**How to Use:**
1. Copy this template
2. Replace `[SKILL_NAME]`, `[ROLE]`, `[DESCRIPTION]` with your skill's details
3. Define input/output schemas precisely
4. List hard constraints (must never violate) and soft constraints (recover if violated)
5. Include examples of valid input/output
6. Reference this contract in your SKILL.md file

---

# [SKILL_NAME] Handoff Contract

**Version:** 1.0
**Last Updated:** [DATE]
**Skill File:** `.claude/skills/[SKILL_NAME]/SKILL.md`
**Test File:** `.claude/skills/[SKILL_NAME]/TESTS.md`

---

## Identity & Scope

### Role
[ROLE] — [ONE SENTENCE DESCRIBING WHAT THIS SKILL DOES]

### Example
Story Author — Decomposes SaaS software design epics into atomic, testable user stories with clear acceptance criteria.

### Domain Boundaries
**Can Read:**
- `design/prd/` (SaaS software design documents)
- `.claude/docs/` (architectural guidance)
- `production/session-state/` (context from previous skills)

**Can Write:**
- `production/epics/[epic-slug]/` (creates new story markdown files)
- `production/qa/evidence/` (creates test evidence stubs)

**Cannot Touch:**
- The code root — `src/`, `Assets/` or `Source/` by stack (no SaaS software code)
- `assets/` (no asset modifications)
- Source data files (read-only)

---

## Input Contract

### What This Skill Receives

**Source Skill:** [PREVIOUS_SKILL_NAME] (e.g., `/saas-create-epics`)
**Format:** Markdown with structured frontmatter
**Transport:** Session context or file reference

### Required Fields

```yaml
# Example input epic (YAML frontmatter in Markdown)
epic_id: "AUTH-BASIC"
epic_goal: "Implement customer subscription checkout flow"
epic_acceptance_criteria:
  - "User can invite members to workspace"
  - "Pricing tiers are configurable"
  - "Invoice is generated on checkout success"
  - "Workspace members list updates"
target_complexity: "medium"  # low | medium | high
estimated_story_count: 3
```

### Schema Definition

```json
{
  "type": "object",
  "required": ["epic_id", "epic_goal", "epic_acceptance_criteria", "target_complexity"],
  "properties": {
    "epic_id": {
      "type": "string",
      "pattern": "^[A-Z]+(-[A-Z0-9]+)?$",
      "minLength": 2,
      "maxLength": 50
    },
    "epic_goal": {
      "type": "string",
      "minLength": 10,
      "maxLength": 500,
      "description": "High-level objective, not implementation"
    },
    "epic_acceptance_criteria": {
      "type": "array",
      "minItems": 1,
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 5,
        "maxLength": 200
      }
    },
    "target_complexity": {
      "type": "string",
      "enum": ["low", "medium", "high"]
    },
    "estimated_story_count": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
}
```

### Validation Rules

- [ ] Epic ID matches pattern `^[A-Z]+-[A-Z0-9]+$` (e.g., `AUTH-BASIC`)
- [ ] Epic goal is 10–500 characters (not too brief, not a novel)
- [ ] At least 1, at most 20 acceptance criteria
- [ ] Target complexity is one of: `low`, `medium`, `high`
- [ ] If estimated story count provided, >= 1 and <= 50

### Examples of Valid Input

```markdown
## Valid Example 1: Simple Epic

epic_id: AUTH-BASIC
epic_goal: Implement customer subscription checkout flow
epic_acceptance_criteria:
  - User can invite members to workspace
  - Pricing is configurable from external data
  - Toast confirmation appears when action triggered
  - Seat count decreases on seat removal
target_complexity: medium
estimated_story_count: 3
```

```markdown
## Valid Example 2: Large Epic

epic_id: SUBSCRIPTION-UPGRADE-FLOW
epic_goal: Implement self-serve workspace subscription upgrade workflow
epic_acceptance_criteria:
  - User upgrades workspace subscription plan via Stripe Checkout
  - Stripe webhook confirms payment and provisions new tier entitlements
  - Quota limits and feature gates unlock immediately
  - Tier upgrade resets rate limit thresholds
  - New features appear in sidebar navigation
target_complexity: high
estimated_story_count: 8
```

---

## Output Contract

### What This Skill Produces

**Destination Skill:** [NEXT_SKILL_NAME] (e.g., `/saas-dev-story`)
**Format:** Markdown with structured headers
**Location:** Typically written to `production/epics/[epic-slug]/story-NNN-[slug].md`

### Output Structure

```markdown
# Stories for [EPIC_ID]

## [STORY_ID]: [STORY_TITLE]

### Description
[1-3 paragraph description of the user story, written from user/user perspective]

### Acceptance Criteria
1. [Testable criterion 1 — imperative mood, specific observable behavior]
2. [Testable criterion 2]
3. [Testable criterion 3]
4. [Optional: criterion 4+, up to 5 per story]

### Complexity Estimate
[low | medium | high]

### Dependencies
[List other stories that should complete first, if any. Format: "EPIC_ID-N"]

---
## [STORY_ID+1]: [NEXT_STORY_TITLE]
...
```

### Schema Definition

```json
{
  "type": "object",
  "required": ["stories"],
  "properties": {
    "epic_id": { "type": "string" },
    "stories": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["story_id", "title", "description", "acceptance_criteria"],
        "properties": {
          "story_id": {
            "type": "string",
            "pattern": "^[A-Z]+-[A-Z0-9]+-[0-9]+$",
            "description": "Format: EPIC-ID-N"
          },
          "title": {
            "type": "string",
            "minLength": 5,
            "maxLength": 100,
            "description": "User-centric; action-oriented"
          },
          "description": {
            "type": "string",
            "minLength": 20,
            "maxLength": 1000,
            "description": "1-3 paragraphs, user perspective"
          },
          "acceptance_criteria": {
            "type": "array",
            "minItems": 3,
            "maxItems": 5,
            "items": {
              "type": "string",
              "minLength": 10,
              "maxLength": 200,
              "description": "Testable, imperative mood"
            }
          },
          "complexity_estimate": {
            "type": "string",
            "enum": ["low", "medium", "high"]
          },
          "dependencies": {
            "type": "array",
            "items": { "type": "string" },
            "description": "Story IDs that should complete first"
          }
        }
      }
    }
  }
}
```

### Validation Rules

- [ ] Each story has unique story ID matching pattern `^[A-Z]+-[A-Z0-9]+-[0-9]+$`
- [ ] Story IDs are sequential by epic (e.g., `AUTH-BASIC-1`, `AUTH-BASIC-2`, etc.)
- [ ] Story count matches epic estimate ± 1 (e.g., if epic estimated 3, produce 2–4)
- [ ] Each story has ≥3 and ≤5 acceptance criteria
- [ ] Acceptance criteria are in imperative mood ("User can...", "System validates...")
- [ ] No code suggestions in story description (remain abstract)
- [ ] No modification to original epic acceptance criteria (can expand, not change)
- [ ] Dependencies reference valid story IDs (not forward references)

### Examples of Valid Output

```markdown
# Stories for AUTH-BASIC

## AUTH-BASIC-1: User Can Sign In with Magic Link

### Description
The user manages a multi-tenant workspace and can invite team members with specific roles. When the invite form is submitted, the system sends an email invitation and assigns the designated role upon acceptance.

### Acceptance Criteria
1. User selects role from workspace settings
2. Invite action triggers when submit button clicked
3. Confirmation toast appears (accessible announcement)
4. Seat count decrements if user removes active member

### Complexity Estimate
low

### Dependencies
(none)

---

## AUTH-BASIC-2: Session Tokens & Expirations Are Configurable

### Description
All session duration and token expiry values (access token TTL, refresh token grace period) come from external configuration or environment variables. This allows operators to adjust security policies without redeploying code.

### Acceptance Criteria
1. Access token TTL loaded from `config/auth.json` or `ACCESS_TOKEN_TTL_SECONDS`
2. Refresh token rotation window loaded from `config/auth.json`
3. Changing configuration changes token lifecycle immediately on next token issue
4. Missing configuration triggers warning log and falls back to safe defaults (15 min access, 7 day refresh)

### Complexity Estimate
medium

### Dependencies
- AUTH-BASIC-1
```

---

## Hard Constraints (Must Never Violate)

Violations automatically trigger intervention/rejection.

- ❌ **Do not modify epic goals** — story must not contradict or rewrite the input epic's goal
- ❌ **Do not change acceptance criteria sources** — if epic says "pricing is configurable", don't remove this criteria
- ❌ **Do not write SaaS software code** — stories remain abstract, no code suggestions like `user.checkout()`
- ❌ **Do not modify input epic file** — treat as read-only immutable
- ❌ **Do not produce invalid story IDs** — must match pattern `EPIC-ID-N`
- ❌ **Do not produce stories without acceptance criteria** — minimum 3 required
- ❌ **Do not skip or merge stories** — if epic estimated 5 stories, deliver 4–6, not 2–3
- ❌ **Do not create circular dependencies** — story cannot depend on later stories

**Enforcement:** Schema validation + assertion checks in test runner. Failures block handoff.

---

## Soft Constraints (Recover if Violated)

Violations warn and attempt recovery; don't block.

- ⚠️ **Exceeded story count estimate** — if epic estimated 3, produced 6: log warning and continue (likely not a fatal error, but note for analysis)
- ⚠️ **Story description too brief** — < 20 characters: resample with examples and continue
- ⚠️ **Acceptance criteria phrasing unclear** — not imperative mood: ask for clarification or resample
- ⚠️ **Tone inconsistency** — some stories formal, others casual: resample to match baseline tone
- ⚠️ **Missing complexity estimates** — only partially provided: fill missing with median of provided values
- ⚠️ **Vague dependencies** — circular or invalid references: log and continue (downstream can validate)

**Enforcement:** Detected during behavioral tests; logged to drift monitor. Do not block handoff, but flag for review.

---

## Handoff Configuration

### Receives From
**Upstream Skill:** `/saas-create-epics` (or equivalent epic-generation skill)

**How Data Arrives:**
- Option 1: Epic content passed as context string
- Option 2: Epic file path provided; skill reads it
- Option 3: Epic data in structured YAML/JSON

**Immutability at Boundary:**
- Epic goal — read-only, not modified
- Acceptance criteria sources — read-only, can expand but not contradict
- Epic ID — read-only, referenced in story IDs

### Delivers To
**Downstream Skill:** `/saas-dev-story` (or equivalent story-to-task skill)

**How Data Handed Off:**
- Option 1: Story markdown written to `production/epics/[epic-slug]/story-NNN-[slug].md`
- Option 2: Story content passed as context string to next skill
- Option 3: Story metadata indexed in central registry

**What Downstream Must Receive:**
- All story IDs and content
- Acceptance criteria unchanged (downstream may add technical notes, not change criteria)
- Dependencies preserved

**What Downstream Cannot Change:**
- Story IDs
- Story titles (can add context/notes, not rename)
- Acceptance criteria (can add implementation guidance, not modify criteria)

### Rollback Procedure

If downstream skill (`/saas-dev-story`) fails to consume stories:

1. **Fail Signal:** Downstream returns error (e.g., "story validation failed")
2. **Rollback Action:** Discard any partial work in downstream; return to this skill's output
3. **Recovery:** This skill does NOT re-run; upstream skill decides whether to provide different epic
4. **No State Mutation:** Story file remains unchanged; epic remains unchanged; no side effects

---

## Testing Evidence Required

Every story skill output must pass this test suite before handoff:

### T1: Schema Validation (Deterministic)
- [ ] Output parses as valid Markdown
- [ ] Output validates against output schema (JSON schema above)
- [ ] Story IDs follow pattern `EPIC-ID-N`
- [ ] Each story has ≥3 acceptance criteria
- [ ] No hard constraint violations (assertion checks)

**Test File:** `tests/smoke-tests/schema-validate.sh`

### T2: Golden Dataset Consistency (Stochastic)
- [ ] Input: Known good epic (golden dataset)
- [ ] Output: Compare to baseline stories (golden dataset)
- [ ] Metric: Semantic similarity >= 0.85 (embedding cosine distance)
- [ ] Pass: If similarity OK, stories are consistent

**Test File:** `tests/golden-datasets/` (stores expected outputs)

### T3: Format Stability (Stochastic)
- [ ] Run skill on same input 5 times
- [ ] Measure format consistency across runs
- [ ] Metric: All 5 outputs match structure (no sections added/removed)
- [ ] Pass: If all 5 runs have same format

**Test File:** `tests/behavioral-tests/format-stability.sh`

### T4: Handoff Integration (Integration)
- [ ] Downstream skill (`/saas-dev-story`) accepts this output
- [ ] No schema validation errors from downstream
- [ ] Downstream produces valid task output
- [ ] Pass: If downstream accepts >95% of stories

**Test File:** `tests/integration/story-to-devstory.sh`

### Acceptance Criteria for Handoff

**This skill is READY TO HAND OFF when:**
- ✅ All hard constraints pass (schema validation, assertion checks)
- ✅ Semantic similarity to golden dataset >= 0.85
- ✅ Format stability across 5 runs (all match structure)
- ✅ Downstream skill accepts output (integration test passes)
- ✅ Drift monitor ASI >= 0.75 (no degradation)

**Blocking Issues:**
- ❌ Hard constraint violation → must fix before handoff
- ❌ Similarity < 0.85 → investigate drift, resample or adjust
- ❌ Downstream rejection → fix schema or content

---

## Drift Monitoring

### Agent Stability Index (ASI) Components

**For `/saas-create-stories`, we measure:**

1. **Response Consistency (30%)** — Are story formats stable across runs?
   - Measure: Embedding similarity of 5 runs on same input (cosine distance)
   - Baseline: >= 0.88 (established on 10 historical stories)
   - Alarm: < 0.85 for 3 consecutive runs

2. **Tool Usage Patterns (25%)** — Does the skill use consistent patterns?
   - Measure: Tool calls, templates, references consistent
   - Baseline: Same design docs referenced, same patterns followed
   - Alarm: New patterns emerge without explanation

3. **Acceptance Criteria Quality (25%)** — Acceptance criteria stable and testable?
   - Measure: Phrasing in imperative mood, specific, testable
   - Baseline: 0 vague criteria per story (e.g., no "should work")
   - Alarm: >1 vague criterion per story

4. **Behavioral Boundaries (20%)** — Skill stays in lane?
   - Measure: No code suggestions, no modified epic goals, no assets touched
   - Baseline: 0 violations per output
   - Alarm: Any violation

**ASI Calculation:**
```
consistency_score = avg_embedding_similarity across 5 runs
tool_score = 1.0 if patterns consistent, 0.8 if slight drift, 0.6 if major change
criteria_score = 1.0 if all testable, 0.8 if 1 vague, 0.6 if >1 vague
boundary_score = 1.0 if no violations, 0.0 if any violation

ASI = (0.30 * consistency) + (0.25 * tool) + (0.25 * criteria) + (0.20 * boundary)
```

**Monitoring:**
- Measure after every 5 story skill invocations
- Log to `production/session-state/drift-monitor.md`
- Alert if ASI < 0.75 for 3 consecutive windows

---

## Glossary & References

**Immutable:** Data that cannot be changed after being read. At skill boundaries, input is immutable (protect source epic).

**Handoff:** Moment when one skill's output becomes another skill's input. Must be machine-validated.

**Hard Constraint:** Rule that must never be violated. Violation blocks handoff.

**Soft Constraint:** Rule that should be followed. Violation warns but doesn't block; recovery attempted.

**ASI (Agent Stability Index):** Four-dimensional metric measuring skill consistency across 4 dimensions. Threshold 0.75.

**Drift:** Progressive degradation of skill behavior over time or repeated invocations.

**Semantic Similarity:** Embedding-based comparison of two texts (0.0 = completely different, 1.0 = identical meaning). Used instead of exact string matching for LLM outputs.

**Golden Dataset:** Curated set of real inputs and expected outputs used as regression test baseline.

**Schema Validation:** Checking output against JSON/Markdown schema. Deterministic, machine-verifiable.

---

**Template Version:** 1.0
**Last Updated:** 2026-03-26
**Audience:** Skill authors creating new skills or upgrading existing ones to include contracts
