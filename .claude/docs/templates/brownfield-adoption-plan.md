# Adoption Plan

> **Generated**: [date]
> **Project phase**: [phase]
> **Engine**: [name + version, or "Not configured"]
> **Template version**: v1.0+

Work through these steps in order. Check off each item as you complete it.
Re-run `/saas-adopt` anytime to check remaining gaps.

---

## Step 1: Fix Blocking Gaps

[One sub-section per blocking gap with problem, fix command, time estimate, checkbox]

---

## Step 2: Fix High-Priority Gaps

[One sub-section per high gap]

---

## Step 3: Bootstrap Infrastructure

[At `workflow: minimal`, replace 3a–3d with one line: "Not on the minimal path —
the brief's build order is the plan. Next: `/saas-create-stories` (or `/saas-dev-story`
once stories exist)."]

### 3a. Register existing requirements (creates tr-registry.yaml)
Run `/saas-architecture-review` — even if ADRs already exist, this run bootstraps
the TR registry from your existing PRDs and ADRs.
**Time**: 1 session (review can be long for large codebases)
- [ ] tr-registry.yaml created

### 3b. Create control manifest
Run `/saas-create-control-manifest`
**Time**: 30 min
- [ ] docs/architecture/control-manifest.md created

### 3c. Create sprint tracking file
Run `/saas-sprint-plan update`
**Time**: 5 min (if sprint plan already exists as markdown)
- [ ] production/sprint-status.yaml created

### 3d. Set authoritative project stage
Run `/saas-gate-check [current-phase]` (the gate into the phase the project is in;
at Concept there is none — Concept is the default stage, nothing to run)
**Time**: 5 min
- [ ] `project.stage` in `project.yaml` written (legacy `production/stage.txt` also updated)

---

## Step 4: Medium-Priority Gaps

[One sub-section per medium gap]

---

## Step 5: Optional Improvements

[One sub-section per low gap]

---

## What to Expect from Existing Stories

Existing stories continue to work with all template skills. New format checks
(TR-ID validation, manifest version staleness) auto-pass when the fields are
absent — so nothing breaks. They won't benefit from staleness tracking until
regenerated. Do not regenerate stories that are in progress or done.

---

## Re-run

Run `/saas-adopt` again after completing Step 3 to verify all blocking and high gaps
are resolved. The new run will reflect the current state of the project.
