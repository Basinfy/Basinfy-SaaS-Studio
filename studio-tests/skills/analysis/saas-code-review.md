# Skill Test Spec: /saas-code-review

## Skill Summary

`/saas-code-review [file(s)] [story-path]` performs an architectural review of source
files. It reads the target files and the project coding standards (Phase 1),
resolves the stack specialists from `project.yaml` (Phase 2), checks compliance
with any referenced ADR by reading only its `## Decision` and `## Consequences`
sections (Phase 3), then evaluates six standards checks, architecture and SOLID,
and product-specific concerns (Phases 4–6). Applicable stack specialists — and
`qa-manual-tester` for Logic/Integration stories — are spawned in parallel, and every
specialist finding is recorded with file/line, evidence and a VERIFIED /
UNVERIFIED confidence (Phase 7). The report (Phase 8) ends in a verdict, first
match wins: CHANGES REQUIRED, NOT ASSESSED (nothing to review, the stack
specialist review did not run, or a report section — such as ADR Compliance on a
referenced ADR that could not be read — reads NOT ASSESSED), APPROVED WITH
SUGGESTIONS, APPROVED. It grants only `git log` from Bash. Phase 9
offers next steps via `AskUserQuestion`. The skill is read-only and invokes no
director gates.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: APPROVED, APPROVED WITH SUGGESTIONS, CHANGES REQUIRED, NOT ASSESSED
- [ ] Does NOT require "May I write" language (read-only; states that no files are written)
- [ ] Has a next-step handoff (what to do with findings)

---

## Director Gate Checks

None. Code review invokes no director gates in any review mode. It does spawn
stack specialists and `qa-manual-tester` as reviewers (Phase 7); those are not gates.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — Standards-compliant file that follows its ADR

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `specialists.code: react-specialist`, `specialists.database: null`, `specialists.ui: null`
- `src/workflow/auth_middleware.ts` meets all six Phase 4 checks:
  - Doc comments (`##`) on every public method and the class
  - Every method under cyclomatic complexity 10 and under 40 lines
  - Dependencies injected; no singletons
  - All tuning values loaded from `assets/data/`
  - Depends on interfaces, not concrete classes
- Header comment: `# Implements ADR-0004 (docs/architecture/adr-0004-health.md)`
- `docs/architecture/adr-0004-health.md` has `## Decision` and `## Consequences` sections, and the code follows the chosen approach
- The specialist reports no issues; there is nothing to suggest

**Input:** `/saas-code-review src/workflow/auth_middleware.ts`

**Expected behavior:**
1. Skill reads the source file and the coding standards
2. Skill finds the `ADR-0004` reference in the file header
3. Skill greps the ADR's `^## ` headings, then reads only the `## Decision` and `## Consequences` spans
4. `react-specialist` is spawned via `Agent` for the `.ts` file; `database: null` and `ui: null` are treated as unset and not spawned
5. Report shows ADR Compliance: COMPLIANT, Standards Compliance: 6/6 passing, Engine Specialist Findings: CLEAN, Testability: `N/A — no story path given`, and a Positive Observations section
6. Verdict is APPROVED
7. Phase 9 `AskUserQuestion` offers [A] Run `/saas-story-done` and [B] Stop here

**Assertions:**
- [ ] The ADR is read with a heading map and bounded reads of `## Decision` and `## Consequences`, not an unbounded full read
- [ ] `react-specialist` is spawned for the `.ts` file; no agent named `null` is spawned
- [ ] Standards Compliance reads `6/6 passing` and ADR Compliance reads COMPLIANT
- [ ] Testability reads `N/A — no story path given`; no `qa-manual-tester` is spawned without a story
- [ ] Positive Observations section is present
- [ ] Verdict is APPROVED and Phase 9 offers `/saas-story-done` or stop
- [ ] No file is written or edited

---

### Case 2: Changes Required — Missing doc comments and singleton usage, no ADR

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `specialists.code: react-specialist`
- `src/ui/pricing_table.tsx` has:
  - 2 public methods (`refresh_slots`, `sort_items`) without doc comments
  - `SessionManager.instance` used at lines 42 and 87
  - All other standards met
- No ADR reference in the file header, and no commit touching it names an ADR
- No story path is passed

**Input:** `/saas-code-review src/ui/pricing_table.tsx`

**Expected behavior:**
1. Skill searches the file header and `git log --oneline -- src/ui/pricing_table.tsx` for `ADR-NNNN` references and finds none
2. Output notes: "No ADR references found — ADR compliance check skipped. For full ADR compliance review, provide the story path: `/saas-code-review [files] [story-path]`."
3. Standards Compliance shows 4/6 passing and lists the failures with line references: the two undocumented methods and the singleton at lines 42 and 87
4. Required Changes lists the missing doc comments and the singleton, with dependency injection as the fix
5. Verdict is CHANGES REQUIRED
6. Phase 9 offers [A] Fix the issues and re-run `/saas-code-review`, [B] Run `/saas-story-done` anyway with noted exceptions, [C] Stop here

**Assertions:**
- [ ] The "No ADR references found" note names the story-path form of the command
- [ ] Missing doc comments are listed with method names (`refresh_slots`, `sort_items`), not only line references
- [ ] Singleton usage is flagged with file and line numbers (42, 87)
- [ ] Standards Compliance reads `4/6 passing`
- [ ] Verdict is CHANGES REQUIRED and Phase 9 offers the three CHANGES REQUIRED options
- [ ] Skill does not edit the file

---

### Case 3: Architectural Violation — Code uses a pattern its ADR rejects

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `specialists.code: react-specialist`
- `src/core/user_settings_repository.ts` header: `# Implements ADR-0010 (docs/architecture/adr-0010-save-format.md)`
- `adr-0010-save-format.md` `## Decision`: save data goes through `SaveService` as JSON; direct `FileAccess` writes from workflow code are explicitly rejected
- `user_settings_repository.ts` writes save data with `FileAccess.open(..., FileAccess.WRITE)` directly at line 58
- Code otherwise meets all six standards checks

**Input:** `/saas-code-review src/core/user_settings_repository.ts`

**Expected behavior:**
1. Skill reads only the Decision and Consequences sections of ADR-0010
2. The direct `FileAccess` write is classified ARCHITECTURAL VIOLATION (BLOCKING) — a pattern the ADR explicitly rejects
3. ADR Compliance reads VIOLATION, listing ADR-0010, the result and the deviation with its severity
4. The violation appears under Required Changes
5. Verdict is CHANGES REQUIRED
6. Next steps: fix the implementation to comply with `docs/architecture/adr-0010-save-format.md`, or — if the design has legitimately changed — run `/saas-architecture-decision` to revise the existing ADR, not create a competing one

**Assertions:**
- [ ] The deviation is classified ARCHITECTURAL VIOLATION (BLOCKING), not ADR DRIFT or MINOR DEVIATION
- [ ] ADR Compliance reads VIOLATION and names ADR-0010
- [ ] The violation is listed under Required Changes
- [ ] Verdict is CHANGES REQUIRED
- [ ] Output says to comply with the existing ADR or revise it via `/saas-architecture-decision`, never to write a competing ADR

---

### Case 4: Edge Case — No source files at the specified path

**Fixture:**
- `project.yaml`: `stack.name: nextjs`
- `src/networking/` does not exist

**Input:** `/saas-code-review src/networking/`

**Expected behavior:**
1. Skill records its inputs as FOUND / ABSENT; the target source files are ABSENT
2. Every required input is ABSENT, so the skill stops before producing review sections
3. Output reports `NOT ASSESSED — NO DATA` as the whole verdict, naming `src/networking/` as missing
4. No specialist or `qa-manual-tester` agent is spawned
5. No review section is filled in, and the result is not presented as APPROVED

**Assertions:**
- [ ] Skill does not crash when the path does not exist
- [ ] Output names the attempted path `src/networking/`
- [ ] Verdict is `NOT ASSESSED — NO DATA`, not APPROVED
- [ ] No specialist agent is spawned when there is nothing to review

---

### Case 5: No Engine Configured — Skipped specialists announce themselves; no gate

**Fixture:**
- `project.yaml` has `modes.review_mode: full` and no `stack.name`; `.claude/docs/technical-preferences.md` reads `[TO BE CONFIGURED]`
- `src/workflow/billing_plans.ts` hardcodes a drop rate `0.05` at line 31; everything else meets the standards

**Input:** `/saas-code-review src/workflow/billing_plans.ts`

**Expected behavior:**
1. Phase 2 finds no stack configured and skips the stack specialist steps
2. Output records `Engine validation: NOT ASSESSED — no stack configured (stack.name unset in project.yaml)`
3. Engine Specialist Findings reads `N/A — no stack configured`; no stack specialist is spawned
4. Standards Compliance lists the "Configuration values loaded from data files" failure with line 31, and the fix is listed under Required Changes
5. Verdict is CHANGES REQUIRED — the known defect outranks the skipped stack review, which the report still names
6. No director gate is invoked in any review mode
7. No file is edited

**Assertions:**
- [ ] Output contains the `Engine validation: NOT ASSESSED — no stack configured` line
- [ ] Engine Specialist Findings reads `N/A — no stack configured` and no stack specialist agent is spawned
- [ ] The hardcoded value is reported under Standards Compliance with its line reference
- [ ] Verdict is CHANGES REQUIRED, not NOT ASSESSED and never APPROVED
- [ ] No director gate is invoked, even with review mode `full`
- [ ] No code edits are made

---

### Case 5b: No Engine Configured, Clean File — NOT ASSESSED, never APPROVED

**Fixture:**
- `project.yaml` has no `stack.name`; `.claude/docs/technical-preferences.md` reads `[TO BE CONFIGURED]`
- `src/workflow/subscription_tiers.ts` meets all six Phase 4 checks and raises no architecture, SOLID or product-specific concern

**Input:** `/saas-code-review src/workflow/subscription_tiers.ts`

**Expected behavior:**
1. Phase 2 records `Engine validation: NOT ASSESSED — no stack configured`; no stack specialist is spawned
2. Nothing is listed under Required Changes or Suggestions
3. Verdict is NOT ASSESSED, naming the stack specialist review that did not run
4. Phase 9 offers the NOT ASSESSED options, naming `/saas-setup-stack` as the way to make the review complete

**Assertions:**
- [ ] Verdict is NOT ASSESSED, not APPROVED — a review that skipped the stack check has not approved the code
- [ ] The verdict names the stack specialist review as what did not run
- [ ] Phase 9 does not offer `/saas-story-done`; it names `/saas-setup-stack`

### Case 6: Referenced ADR missing — the section's NOT ASSESSED reaches the verdict

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `specialists.code: react-specialist`
- `src/workflow/rate_limiter.ts` meets all six Phase 4 checks and raises no
  architecture, SOLID or product-specific concern; the specialist reports it clean
- Its header reads `# Implements ADR-0008 (docs/architecture/adr-0008-stamina.md)`,
  and no such file exists

**Input:** `/saas-code-review src/workflow/rate_limiter.ts`

**Expected behavior:**
1. Phase 3 finds the `ADR-0008` reference but cannot read the ADR
2. ADR Compliance reads `NOT ASSESSED — ADR-0008 could not be read`
3. Nothing is listed under Required Changes or Suggestions
4. Verdict is NOT ASSESSED, naming the ADR Compliance section and ADR-0008

**Assertions:**
- [ ] ADR Compliance reads NOT ASSESSED and names ADR-0008 — not `NO ADRS FOUND`, not COMPLIANT
- [ ] Verdict is NOT ASSESSED, never APPROVED: a section that could not be assessed reaches the verdict
- [ ] Variant — the file names no ADR at all: ADR Compliance reads `NO ADRS FOUND`, and the verdict is APPROVED (a missing reference is not an unreadable one)

---

## Protocol Compliance

- [ ] Reads the target file(s) and the coding standards before reviewing (Phase 1)
- [ ] Reads the `specialists` block from `project.yaml`, falling back to `technical-preferences.md`; a `null` specialist is skipped, never spawned
- [ ] Every specialist finding in the report carries file/line, evidence, and VERIFIED or `UNVERIFIED — specialist claim`
- [ ] Does not edit any source files (read-only skill)
- [ ] No director gates are invoked
- [ ] Verdict, first match: CHANGES REQUIRED, NOT ASSESSED, APPROVED WITH SUGGESTIONS, APPROVED — never an approval when the stack specialist review did not run or any report section reads NOT ASSESSED
- [ ] `allowed-tools` grants `Bash(git log *)` and the scoped `yaml-helper.sh resolve_config` pattern, not bare `Bash` — the skill is read-only: it runs `git log` and the config resolver, nothing else
- [ ] Phase 9's prompt and option branches use the same verdict vocabulary as the Phase 8 report

---

## Coverage Notes

- Batch review of a directory is not tested separately; the same checks apply
  file by file.
- The `qa-manual-tester` testability review (Logic and Integration stories, story path
  passed as the last argument) is not given its own case.
- Test-file existence checks are the domain of `/saas-test-evidence-review`.
