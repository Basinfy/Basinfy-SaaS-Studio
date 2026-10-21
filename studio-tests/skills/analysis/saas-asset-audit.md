# Skill Test Spec: /saas-asset-audit

## Skill Summary

`/saas-asset-audit` audits the stack's asset root — `assets/` (images, icons, fonts,
media, data) on Next.js, `Assets/` on FastAPI, `Content/` on Cloudflare — for naming
convention compliance, size budgets, format standards, orphaned assets and
missing assets. It reads the design tokens or asset standards from the design docs
(Phase 1), resolves the stack and its code root and scans the asset root with
Glob (Phase 2), measures sizes and formats with the pre-approved read-only
commands (`stat`, `file`, `od`, `wc`, `du`), and checks Next.js names against its
own patterns — art `[category]_[name]_[variant]_[size].[ext]`, audio
`[category]_[context]_[name]_[variant].[ext]`, all lowercase with underscores —
and FastAPI and Cloudflare names only against a rule the design tokens states. Orphaned
and missing assets are found by searching the **code root** for asset
references; PRD-level completeness is `/saas-content-audit`'s job. The report lists
violations only, in one table per category, and names every section it could
not assess. A measurement it cannot take is `NOT ASSESSED`, never an estimate.
The skill is read-only: it writes no files and invokes no director gates.
Verdicts, first match wins: NON-COMPLIANT, WARNINGS, NOT ASSESSED, COMPLIANT —
COMPLIANT only when at least one asset was scanned and every section assessed.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLIANT, WARNINGS, NON-COMPLIANT, NOT ASSESSED
- [ ] Does NOT require "May I write" language (read-only: `allowed-tools` has no Write/Edit and the skill states it does not write files)
- [ ] Has a next-step handoff (what to do after audit results)

---

## Director Gate Checks

None. Asset auditing is a read-only analysis skill; no gates are invoked.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Happy Path — All assets follow naming conventions

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, so the asset root is `public/` and the code root `src/`
- `design/ui/design-tokens.md` Asset Standards: images WebP/PNG, ≤500KB; icons SVG, ≤50KB
- `public/illustrations/` contains: `hero-dashboard.webp`, `onboarding-flow.webp` (WebP, 250KB each)
- `public/brand/` contains: `logo.svg`, `favicon.ico` (SVG/ICO, 30KB each)
- `src/` references all four files

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Skill reads the asset standards from `design/ui/design-tokens.md` (Phase 1)
2. Skill resolves the stack to Next.js and globs `public/illustrations/**/*` and `public/brand/**/*` (Phase 2)
3. Every name matches the Phase 3 image or SVG pattern; every file is within budget and in the expected format; every file is referenced from code
4. Summary shows 4 assets scanned, 0 in every violation count and no section not assessed; the violation tables are empty
5. Verdict is COMPLIANT

**Assertions:**
- [ ] Audit covers public asset directories
- [ ] Each file is checked against the Phase 3 naming pattern and the size budget from the design tokens
- [ ] Summary reports `Total assets scanned: 4` with zero naming, size, format, orphaned and missing counts, and `Sections not assessed: none`
- [ ] Verdict is COMPLIANT
- [ ] No files are written

---

### Case 2: Non-Compliant — Images exceed size budget

**Fixture:**
- `project.yaml`: `stack.name: nextjs`
- `design/ui/design-tokens.md` asset standards: hero images WebP, ≤1MB
- `public/hero/` contains 5 correctly named WebP images, all referenced from code
- 3 of them are unoptimized at 3MB each; 2 are compressed at 500KB each

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Skill reads the 1MB image budget from the design tokens
2. Skill measures each file's size with `stat` or `du` — not by estimate
3. The Size Violations table lists the 3 oversized files with Budget, Actual and Overage
4. The 2 within-budget files do not appear in the Size Violations table; `Total assets scanned` counts all 5
5. Recommendations give each oversized file its own fix, naming the target — responsive image srcset or WebP compression setting that brings it under 1MB
6. Verdict is NON-COMPLIANT

**Assertions:**
- [ ] All 3 oversized files appear in the Size Violations table with Budget (1MB), Actual (3MB) and Overage
- [ ] Sizes come from a measuring command (`stat`/`du`), not an estimate
- [ ] Verdict is NON-COMPLIANT when any file exceeds its budget
- [ ] Each oversized file has a recommendation that names its target compression or srcset, not only "reduce size"
- [ ] The 2 within-budget files are counted in `Total assets scanned` but are not listed as violations

---

### Case 3: Format Issue — Audio alert in uncompressed format

**Fixture:**
- `project.yaml`: `stack.name: nextjs`
- `design/ui/design-tokens.md` asset standards: images WebP ≤500KB; icons SVG ≤50KB; audio MP3/WebM ≤100KB
- `public/sounds/alert_notification.wav` exists (WAV format, 6MB), referenced from code
- `public/brand/logo.svg` exists (SVG format, 20KB), referenced from code

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Skill applies the Phase 3 format standards
2. Skill identifies the WAV file's format with `file` or a header read
3. The Format Violations table lists `alert_notification.wav` with expected MP3/WebM and actual WAV
4. `public/brand/logo.svg` does not appear in any violation table; both files are within their size budgets
5. Recommendations name the target format for the audio file (re-encode as MP3 or WebM)
6. Verdict is WARNINGS (a format issue is correctable)

**Assertions:**
- [ ] `alert_notification.wav` appears in the Format Violations table with Expected Format MP3/WebM and Actual Format WAV
- [ ] The recommendation for the audio file names MP3 or WebM as its target format
- [ ] Verdict is WARNINGS (not NON-COMPLIANT) for a format issue alone
- [ ] `public/brand/logo.svg` is not listed in any violation table
- [ ] Skill does not modify or convert any asset files

---

### Case 4: Missing Asset — Referenced by code but absent from assets/

**Fixture:**
- `project.yaml`: `stack.name: nextjs`; `design/ui/design-tokens.md` sets image budgets
- `public/illustrations/` holds 3 other correctly named illustrations, within budget and referenced from code
- `src/components/user_avatar.tsx` loads `/public/brand/logo.svg`
- `public/illustrations/enterprise/` is empty — the file does not exist
- `design/prd/billing.md` also names `enterprise-dashboard-preview.webp`, which no code references

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Skill searches code for asset references (Phase 3 "Missing assets") and checks each path exists
2. `enterprise-hero.webp` is not found
3. The Missing Assets table lists Reference Location `src/components/user_avatar.tsx` and the Expected Path
4. The PRD-only name `enterprise-dashboard-preview.webp` is not reported — the missing-asset check searches code, not PRDs
5. Verdict is NON-COMPLIANT
6. Next steps point to `/saas-content-audit` for the PRD cross-check

**Assertions:**
- [ ] The Missing Assets table lists `src/components/user_avatar.tsx` as the reference location and `public/brand/logo.svg` as the expected path
- [ ] The PRD-only asset name is not reported as missing
- [ ] Verdict is NON-COMPLIANT when a code-referenced asset is missing
- [ ] Next steps name `/saas-content-audit` for PRD-vs-asset completeness
- [ ] Skill does not create or add placeholder assets

---

### Case 5: No Data — No assets and no asset standards

**Fixture:**
- `project.yaml`: `stack.name: nextjs`, `modes.review_mode: full`
- `assets/` does not exist
- `design/ui/design-tokens.md` does not exist; no design doc defines asset standards

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Skill runs its insufficient-input check before producing a report: records each input as FOUND or ABSENT
2. Every required input is ABSENT, so the skill stops
3. Verdict is `NOT ASSESSED — NO DATA`, naming what was missing and which skill produces it
4. The skill does not report COMPLIANT and does not render zero-count violation tables as a clean pass
5. No director gate is invoked in any review mode; no file is written and no write is offered

**Assertions:**
- [ ] Inputs are listed as FOUND / ABSENT before any report section
- [ ] Verdict is `NOT ASSESSED — NO DATA`, not COMPLIANT
- [ ] The report names the missing inputs (`assets/`, asset standards) and the skill that produces the standards (`/saas-design-tokens`)
- [ ] No director gate is invoked, even with review mode `full`
- [ ] No "May I write" prompt appears and no file is written

---

### Case 6: Zero Assets — Standards exist, nothing to audit

**Fixture:**
- `project.yaml`: `stack.name: nextjs`
- `design/ui/design-tokens.md` asset standards: images WebP ≤500KB; icons SVG ≤50KB
- `assets/` does not exist; `src/` holds workflow code that loads no asset yet

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. The design tokens is FOUND, so the insufficient-input check does not stop the run
2. Phase 2 globs `assets/` and matches nothing: `Total assets scanned: 0`
3. Naming, Size, Format and Orphaned are `NOT ASSESSED — no assets under assets/`, and the Summary lists them; the missing-asset search runs and finds no reference
4. Verdict is NOT ASSESSED — zero violations over zero files is not compliance

**Assertions:**
- [ ] `Total assets scanned` is 0 and the four file checks are NOT ASSESSED with that reason
- [ ] Verdict is NOT ASSESSED, not COMPLIANT
- [ ] No file is written

---

### Case 7: No Standards — Assets exist, no size budget anywhere

**Fixture:**
- `project.yaml`: `stack.name: nextjs`
- `design/ui/design-tokens.md` does not exist; no design doc states asset standards
- `assets/art/ui/` holds 3 correctly named power-of-two PNGs; `src/` references all three

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Assets are FOUND and standards ABSENT, so the skill runs rather than stopping
2. Naming, Format, Orphaned and Missing are checked; none finds a violation
3. Size is `NOT ASSESSED — no size budget set`, and the report names `/saas-design-tokens` as the skill that writes the standards
4. The Summary lists Size under Sections not assessed
5. Verdict is NOT ASSESSED, naming Size

**Assertions:**
- [ ] No size is judged against an invented budget
- [ ] The Size section is `NOT ASSESSED — no size budget set` and `/saas-design-tokens` is named
- [ ] Verdict is NOT ASSESSED, not COMPLIANT

---

### Case 8: Cloudflare Project — Assets under `Content/`

**Fixture:**
- `project.yaml`: `stack.name: cloudflare`, so the code root is `Source/<Module>/`
- `design/ui/design-tokens.md` asset standards: textures ≤4MB; no naming convention stated
- `public/illustrations/` holds `dashboard_mockup.webp` (2.5MB) and `analytics_graph.webp` (2.1MB)
- `assets/` does not exist
- `src/components/user-avatar.tsx` loads `/public/avatars/user_default.svg`

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Phase 2 globs `public/**/*.svg` and `public/**/*.webp`, not `assets/`: `Total assets scanned: 2`
2. Both sizes are measured against the 4MB texture budget; neither is over
3. The PascalCase names are not checked against the Next.js lowercase patterns; with no naming rule in the design tokens, Naming is `NOT ASSESSED — no naming rule for Cloudflare`, and `/saas-design-tokens` is named
4. Format is NOT ASSESSED (an Cloudflare asset file does not keep its source format) and Orphaned is NOT ASSESSED (Cloudflare assets are referenced from other assets, not only from code)
5. The code reference resolves to an existing asset, so Missing has no finding
6. Verdict is NOT ASSESSED, naming Naming, Format and Orphaned

**Assertions:**
- [ ] The scan covers `Content/` and counts 2 assets, not 0
- [ ] No naming violation is raised from the Next.js lowercase patterns
- [ ] Naming, Format and Orphaned are each listed as NOT ASSESSED with a reason
- [ ] Verdict is NOT ASSESSED, never COMPLIANT and never a report of zero assets

---

### Case 9: Engine Unresolved — Stop before scanning

**Fixture:**
- `project.yaml` has no `stack.name`; `.claude/docs/technical-preferences.md` reads `[TO BE CONFIGURED]`
- Both `src/` and `Source/` exist, so the tree does not decide the stack
- `design/ui/design-tokens.md` has asset standards; `assets/art/` holds PNG files

**Input:** `/saas-asset-audit`

**Expected behavior:**
1. Phase 2 cannot resolve the stack or its code root per `.claude/docs/code-root-resolution.md`
2. The skill stops with `NOT ASSESSED — stack unresolved`, naming `/saas-setup-stack`
3. No asset root is guessed, so the Next.js naming patterns are not applied and no section is reported clean

**Assertions:**
- [ ] Verdict is `NOT ASSESSED — stack unresolved`, not COMPLIANT
- [ ] Output names `/saas-setup-stack`
- [ ] No violation table is filled from an assumed `assets/` layout

---

## Protocol Compliance

- [ ] Reads the design tokens or asset standards design docs before scanning (Phase 1)
- [ ] Resolves the stack and its code root, then scans that stack's asset root with Glob (`assets/` subfolders on Next.js, `Assets/` on FastAPI, `Content/` on Cloudflare); an unresolved stack stops the run as NOT ASSESSED
- [ ] Report uses one table per category: Naming (File, Expected Pattern, Issue), Size (File, Budget, Actual, Overage), Format (File, Expected Format, Actual Format), Orphaned (File, Last Modified, Size, Recommendation), Missing (Reference Location, Expected Path)
- [ ] A size or format it cannot measure is `NOT ASSESSED`, never an estimate, and every section not assessed is named with its reason
- [ ] Each recommendation names the change for its violation (target resolution or compression, corrected name, target format)
- [ ] Does not modify any asset files and writes no report file
- [ ] No director gates are invoked
- [ ] Verdict, first match: NON-COMPLIANT, WARNINGS, NOT ASSESSED, COMPLIANT — COMPLIANT only with at least one asset scanned and every section assessed

---

## Coverage Notes

- The skill does not check import metadata (Next.js `.import` files, FastAPI `.meta`
  files, Cloudflare import settings); a missing import setting is not reported.
- Orphan detection on Next.js (an asset no code references) is not given its own
  case; it uses the same code search as Case 4 in the other direction. On FastAPI
  and Cloudflare it is NOT ASSESSED (Case 8).
- FastAPI follows Case 8's naming and orphan rules, with Format still checked on
  the source files under `Assets/`; it is not tested separately.
- `/saas-asset-audit` checks compliance against code references; `/saas-content-audit`
  checks completeness against the PRDs. Case 4 pins that boundary.
- An audio duration budget is not measurable with the skill's tools, so it makes
  that check NOT ASSESSED; Case 1's fixture sets none, and the path is not given
  its own case.
