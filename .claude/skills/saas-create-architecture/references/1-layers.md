# /saas-create-architecture — Phase 1: System Layer Mapping

> Part of `/saas-create-architecture`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 1: System Layer Mapping

Map every system from `features-modules-index.md` into an architecture layer. The standard
SaaS architecture layers are:

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │  ← UI, App Shell, menus, VFX, audio
├─────────────────────────────────────────────┤
│  FEATURE LAYER                              │  ← core business workflows, background workers, AI pipelines
├─────────────────────────────────────────────┤
│  CORE DOMAIN LAYER                          │  ← business logic, services, domain models
├─────────────────────────────────────────────┤
│  FOUNDATION LAYER                           │  ← engine integration, save/load,
│                                             │    scene management, event bus
├─────────────────────────────────────────────┤
│  PLATFORM LAYER                             │  ← OS, hardware, engine API surface
└─────────────────────────────────────────────┘
```

The Platform layer is the engine and cloud platform the application runs on, not code the project
writes. No PRD system goes in it, so it has no epic, stories or control-manifest
rules: a system that wraps a platform or engine API belongs in Foundation.

For each PRD system, ask:
- Which layer does it belong to?
- What are its module boundaries?
- What does it own exclusively? (data, state, behaviour)

Present the proposed layer assignment and ask for approval before proceeding to
the next section. Record the approved layer map in
`production/session-state/active.md`; it goes into the document at Phase 7.

**Engine awareness check**: For each system assigned to the Core and Foundation
layers, flag if it touches a HIGH or MEDIUM risk engine domain. Show the relevant
stack reference excerpt inline.

---
