# Skill Test Spec: /saas-setup-stack

## Skill Summary

`/saas-setup-stack` pins the project's stack, version and language. It accepts
`[stack]`, `[stack] [version]`, `refresh`, `upgrade [old] [new]`, or no
argument for guided selection. For Next.js it asks which language (TypeScript, C#
or Both) before showing the Technology Stack. It then:

- writes the Technology Stack and the `ENGINE-REFERENCE-IMPORT` line to
  `CLAUDE.md` after "May I write these stack settings to `CLAUDE.md`?"
- fills `.claude/docs/technical-preferences.md` (the legacy mirror: naming
  conventions, specialist routing table, input/platform, performance budgets)
  after the user approves the presented defaults
- dual-writes the `stack`, `specialists`, `naming` and `commands` blocks to
  `project.yaml` — the primary config store — after "May I write the `stack`,
  `specialists`, `naming`, and `commands` blocks to `project.yaml`?"
- updates or creates `docs/stack-reference/<stack>/`, scaffolds
  `package.json` for Next.js (never for FastAPI or Cloudflare), and reads everything
  back with `project-coherence.sh`

On a re-run it edits existing `project.yaml` blocks in place rather than
duplicating them. No director gates apply. The verdict is COMPLETE when the
stack is configured.

---

## Static Assertions (Structural)

Checked against the SKILL.md by `/saas-skill-test spec` — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: COMPLETE
- [ ] Contains "May I write" language before writing `CLAUDE.md` and before writing the `project.yaml` blocks
- [ ] Has a next-step handoff (Section 12 prints one tier-matched Next-Steps list, e.g. `/saas-brainstorm` at `minimal`)

---

## Director Gate Checks

None. `/saas-setup-stack` is a technical configuration skill. No director gates apply.

---

## Fixture Defaults

Every case's `project.yaml` sets `modes.rigor: minimal` and
`modes.automation: collaborative`, with no `project.local.yaml`, unless its own
Fixture says otherwise. Rules: `studio-tests/CLAUDE.md` §
Fixture defaults.

---

## Test Cases

### Case 1: Next.js 15 + TypeScript — Full stack configuration

**Fixture:**
- `project.yaml` has no `stack` block; `technical-preferences.md` holds only placeholders
- No `design/prd/product-concept.md` and no `design/product-brief.md`
- `docs/stack-reference/nextjs/VERSION.md` already pins 15.0
- No `package.json` at the repo root; the user approves every write

**Input:** `/saas-setup-stack nextjs 15.0`

**Expected behavior:**
1. Full-spec mode: Section 2's guided selection is skipped
2. Skill asks the Next.js language configuration question (A TypeScript / B JavaScript); user picks TypeScript
3. Skill shows the Technology Stack and asks "May I write these stack settings to `CLAUDE.md`?"
4. Technical preferences are presented with TypeScript naming (camelCase/PascalCase) and the routing table:
   `.ts` → react-specialist, `.css` → frontend-engineer, `.tsx` → nextjs-specialist
5. `commands.build` and `commands.test` are configured (`npm run build`, `npm test`)
6. Skill asks "May I write the `stack`, `specialists`, `naming`, and `commands` blocks to `project.yaml`?"
7. VERSION.md already pins 15.0 → nothing to regenerate; only its
   `Installed at pin time` row is written, from the Section 3 probe
8. Skill proposes `package.json` and asks before creating it; verdict COMPLETE

**Assertions:**
- [ ] `stack.name` is Next.js and `stack.language` is TypeScript in `project.yaml`
- [ ] `naming.variables` is `camelCase` and `naming.classes` is `PascalCase`
- [ ] Routing table includes `.ts`, `.css`, and `.tsx` entries; `specialists.code` is `react-specialist`
- [ ] "May I write" is asked before `CLAUDE.md` and before `project.yaml` are written
- [ ] Verdict is COMPLETE

---

### Case 2: FastAPI + Python — Backend-specific configuration

**Fixture:**
- Placeholders only in `technical-preferences.md`; no `stack` block in `project.yaml`
- The user supplies the version and the build target when asked

**Input:** `/saas-setup-stack fastapi`

**Expected behavior:**
1. Stack-only mode: version looked up and confirmed with the user
2. Language is Python 3.11+; CLAUDE.md Language is `Python`
3. Naming: snake_case functions/modules, PascalCase Pydantic models
4. Routing: `.py` → fastapi-specialist, `requirements.txt`/`pyproject.toml` → backend-engineer
5. `commands.build` and `commands.test` configured (`pip install -r requirements.txt`, `pytest`)
6. User is instructed to initialize environment via `uv` or `poetry`
7. Verdict is COMPLETE

**Assertions:**
- [ ] Stack field is set to FastAPI and Language to Python
- [ ] Naming conventions reflect Python PEP 8 conventions
- [ ] Routing table includes `.py` entries
- [ ] No FastAPI project files are blindly overwritten
- [ ] Verdict is COMPLETE

---

### Case 3: Cloudflare Workers — Serverless edge API configuration

**Fixture:**
- Placeholders only; no `stack` block in `project.yaml`
- The session runs on Windows (`uname -s` is neither `Linux` nor `Darwin`)

**Input:** `/saas-setup-stack cloudflare`

**Expected behavior:**
1. Stack selection: Cloudflare Workers with TypeScript
2. CLAUDE.md Language reads `TypeScript`
3. `project.yaml` gets `stack.frontend: "cloudflare"` and `stack.language: "TypeScript"`
4. Routing: TypeScript handlers → cloudflare-specialist; `wrangler.toml` → cloud-infra-engineer
5. Commands: `wrangler deploy --dry-run` and `vitest`
6. Performance budgets for edge worker latency and bundle size are configured
7. Verdict is COMPLETE

**Assertions:**
- [ ] Stack field is set to Cloudflare Workers and `stack.language` is `TypeScript`
- [ ] Routing table includes edge component and API entries
- [ ] cloudflare-specialist is assigned for worker handlers
- [ ] `commands` carry valid wrangler and test commands
- [ ] Verdict is COMPLETE

---

### Case 4: Re-run on a Configured Project — blocks edited in place

**Fixture:**
- `project.yaml` already has `stack` (Next.js 15.0), `specialists`, `naming`, a
  `modes` block, and a `commands` block missing its `smoke` key
- `package.json` exists at the repo root
- `docs/stack-reference/nextjs/VERSION.md` pins 15.0

**Input:** `/saas-setup-stack nextjs 15.0`

**Expected behavior:**
1. Skill reads `project.yaml` before editing it
2. Each existing block is edited in place; `commands.smoke` is added to the
   partial block; no second copy of any block is appended
3. `modes` and every other non-stack block are preserved untouched
4. The existing `package.json` is not overwritten — the skill says so and skips
5. VERSION.md pins the same version → nothing to regenerate: Engine Version,
   Project Pinned and Last Docs Verified are left as they are, and only the
   `Installed at pin time` row is written with the Section 3 probe result
6. Verdict COMPLETE

**Assertions:**
- [ ] No block is duplicated in `project.yaml`, and the missing `commands.smoke` key is added
- [ ] `modes` (and all other non-stack content) is unchanged
- [ ] `package.json` is not overwritten
- [ ] For a same-version pin, Engine Version, Project Pinned and Last Docs Verified are untouched and `Installed at pin time` is written
- [ ] Verdict is COMPLETE

---

### Case 5: Director Gate Check — No gate; setup-stack is a utility skill

**Fixture:**
- Fresh project with no stack configured

**Input:** `/saas-setup-stack nextjs`

**Expected behavior:**
1. Skill completes full stack configuration
2. No director agents are spawned at any point
3. No gate IDs appear in output

**Assertions:**
- [ ] No director gate is invoked
- [ ] No gate skip messages appear
- [ ] Verdict is COMPLETE without any gate check

---

### Case 6: Installed Editor Older Than the Chosen Version — ask, then record

**Fixture:**
- As Case 1; `docs/stack-reference/nextjs/VERSION.md` pins 4.7
- `nextjs --version` reports `4.5.1.stable`
- The user picks "pin the newer one and upgrade later"

**Input:** `/saas-setup-stack nextjs 4.7`

**Expected behavior:**
1. Section 3 probes the installed editor and finds 4.5.1 — a mismatch
2. Skill states both versions and asks, offering three options: pin the
   installed version, pin the newer one and upgrade later, or pin the newer one
   deliberately
3. The answer is recorded; the skill does not pick for the user
4. VERSION.md already pins 4.7, so nothing is regenerated, but its
   `Installed at pin time` row is written with 4.5.1
5. Verdict COMPLETE

**Assertions:**
- [ ] Both versions are stated and all three options are offered
- [ ] The skill waits for the user's choice rather than picking silently
- [ ] `Installed at pin time` records 4.5.1 — the same-version branch does not skip it
- [ ] Engine Version, Project Pinned and Last Docs Verified are not restamped

---

### Case 7: Next.js not on PATH — the probed executable goes into `commands.*`

**Fixture:**
- As Case 1, on Windows; `node` is resolved via standard environment discovery
- The probe finds `node.exe`, which reports `v20.12.0`
- The user selects the standard Next.js fullstack template

**Input:** `/saas-setup-stack nextjs 15`

**Expected behavior:**
1. Section 3 reads the version from the executable it found — it does not report "no stack installed"
2. `build`, `test`, `run` and `smoke` each record valid SaaS commands:
   `build: 'npm run build'`
3. `test` runs the configured test runner (`npm test`)
4. `stack.version` records the framework version
5. Verdict COMPLETE

**Assertions:**
- [ ] No `commands.*` value names bare `nextjs`
- [ ] Every Next.js command value is a single-quoted scalar and none holds both quote types
- [ ] `stack.path` records the editor executable
- [ ] Variant — the probe finds nothing and the user does not know where Next.js is: bare `nextjs` is kept under a `# TODO: nextjs is not on PATH here` comment, and the skill says the commands will not run until the path is set

---

### Case 8: A skipped question is not an answer

**Fixture:**
- Fresh project: no stack configured, no `project.yaml` stack block
- The stack question comes back skipped: the user closes it, or a headless run
  returns every question as skipped
- The sandbox carries the framework's `CLAUDE.md`. The rule this case checks is
  stated there ("A skipped or dismissed question is not an answer") and in
  `.claude/docs/automation-modes.md`, not in `/saas-setup-stack`'s own files; a rule
  `CLAUDE.md` loads counts as the skill's own (`/saas-skill-test` spec mode, Step 3),
  so a sandbox without it is set up wrong, not a skill FAIL

**Input:** `/saas-setup-stack`

**Expected behavior:**
1. The skill does not choose an stack, language or version itself
2. It asks again in plain text, saying what is waiting on the answer, and waits
3. Nothing is written to `CLAUDE.md`, `project.yaml`, `technical-preferences.md`
   or `VERSION.md` before the user answers
4. In a run where nobody can answer, it stops and reports what is waiting

**Assertions:**
- [ ] No stack, language or version is picked on the user's behalf
- [ ] The question is asked again in plain text
- [ ] No file is written before an answer arrives

---

## Protocol Compliance

- [ ] Presents draft configuration before asking to write
- [ ] Asks "May I write" before writing `CLAUDE.md` and the `project.yaml` blocks; technical preferences are written only after the user approves the presented defaults
- [ ] Respects stack argument when provided (skips guided selection)
- [ ] Dual-writes `project.yaml` and `technical-preferences.md`, then reads `project.yaml` back to confirm they agree
- [ ] On re-run, edits existing `project.yaml` blocks in place without duplicating them
- [ ] Writes appropriate build and test commands into `commands.*` matching the chosen SaaS stack
- [ ] Writes the Section 3 probe into VERSION.md's `Installed at pin time` row whatever the outcome
- [ ] Verdict is COMPLETE after configuration is written

---

## Coverage Notes

- The `refresh` and `upgrade` subcommands (Sections 10–11) are not tested here.
- Section 6 is a lookup against the skill's own coverage table, asserted in Case 1.
- A probe that cannot run reports `installed version NOT DETERMINED` — never "no stack installed"; not separately tested.
