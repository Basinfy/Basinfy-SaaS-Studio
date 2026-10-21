# /saas-smoke-check — Phase 4: Run Manual Smoke Checks

> Part of `/saas-smoke-check`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 4: Run Manual Smoke Checks

**In this file:**

- Checklist source: name it in the report
- Batch 1 — Core stability
- Batch 2 — Sprint changes and regression
- Batch 3 — Data integrity and performance
- Platform batches: Desktop, Tablet, Mobile

Draw the smoke test checklist from, in priority order (and name the one you used in the report):
1. The QA plan's "Smoke Test Scope" section (if QA plan was found in Phase 1)
2. `production/qa/smoke-tests.md` (if it exists)
3. `tests/smoke/` directory contents (if it exists)
4. The standard fallback list below (used only when none of the above exist)

**Name the source you used in the report**, on its own line — *"Checklist source:
`production/qa/smoke-tests.md`"*, or *"Checklist source: standard fallback list —
no QA plan scope, no `production/qa/smoke-tests.md`, no `tests/smoke/`."* The
fallback is a real fallback, so nothing is silently skipped here, but without
that line a report drawn from the generic list reads the same as one drawn from
this project's own smoke definitions. `/saas-gate-check` validates a smoke report's
claims against the repo, and it cannot weigh them without knowing what the
checklist was drawn from.

Tailor batches 2 and 3 to the actual systems identified from the sprint or QA
plan. Replace bracketed placeholders with real workflow names from the current
sprint's stories.

Use `AskUserQuestion` to batch-verify. Keep to at most 3 calls.

**Batch 1 — Core stability (always run):** one call, two questions — an empty
failure list means nothing unless somebody launched the build.
```
question: "Did you launch the current build this session?"
multiSelect: false
options:
  - "Yes — I launched it and checked the items below"
  - "No — I have not launched the current build this session"

question: "Core stability — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Application does not boot or crashes before rendering main landing/dashboard"
  - "New product / session fails to start"
  - "Main navigation or dashboard does not respond to inputs"
  - "Crash or hang observed during basic navigation"
```

For any selected item, ask the user to briefly describe what failed before generating the report.

If the build was **not launched**, the Batch 1 checks could not be executed:
record them as `NOT RUN — build not launched this session`, skip Batches 2 and
3 and any platform batch (say so — they need a running build), and ignore the
unselected failure list. The verdict is then NOT ASSESSED unless something else
FAILED.

**Batch 2 — Sprint changes and regression (always run):**
```
question: "Sprint changes and regression — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "[Primary workflow this sprint] — FAILED"
  - "[Second notable change this sprint, if any] — FAILED"
  - "Regression in a previous sprint's feature — FAILED"
  - "Other unexpected breakage observed — FAILED"
```

For any selected item, ask the user to briefly describe what broke before generating the report.

**Batch 3 — Data integrity and performance (run unless `quick` argument):**
```
question: "Data integrity and performance — select any items that FAILED or were skipped (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Database persistence / hydration — FAILED (data loss or corruption observed)"
  - "Database persistence / hydration — N/A (persistence layer not yet implemented)"
  - "API latency or UI rendering drops observed — FAILED"
  - "Performance not checked this session"
```

For any FAILED item selected, ask the user to describe what broke before generating the report.

Record each response verbatim for the Phase 5 report.

**Platform Batches** *(run only if `--platform` argument was provided)*:

**Desktop platform** (`--platform desktop` or `--platform all`):
```
question: "Desktop Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Desktop layout / viewport rendering — FAILED (describe issue after)"
  - "Keyboard navigation / shortcuts — FAILED (describe issue after)"
  - "Mouse click / hover / form inputs — FAILED (describe issue after)"
  - "Window resizing / breakpoint responsiveness — FAILED (describe issue after)"
```

For any selected item, ask the user to briefly describe what failed before generating the report.

**Tablet platform** (`--platform tablet` or `--platform all`):
```
question: "Tablet Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Tablet layout / responsive breakpoints (768px-1024px) — FAILED (describe what is clipped after)"
  - "Touch scrolling / tap gesture responsiveness — FAILED (describe issue after)"
```

For any selected item, ask the user to briefly describe what failed before generating the report.

**Mobile platform** (`--platform mobile` or `--platform all`):
```
question: "Mobile Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Touch navigation / drawers / navigation menu — FAILED (describe issue after)"
  - "Mobile viewport (<640px) / responsive text wrapping — FAILED (describe what breaks after)"
  - "Mobile keyboard input / form field zoom & focus — FAILED (describe issue after)"
  - "Performance / low-bandwidth mobile loading — FAILED (describe after)"
```

For any selected item, ask the user to briefly describe what failed before generating the report.

---
