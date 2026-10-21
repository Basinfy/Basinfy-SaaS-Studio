# /saas-ux-design — Section 3: Create File Skeleton

> Part of `/saas-ux-design`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 3. Create File Skeleton

**In this file:**

- Skeleton for UX Spec (screen or flow)
- Skeleton for App Shell & Navigation Design
- Skeleton for Interaction Pattern Library
- Skeleton for Accessibility Requirements

Once the user confirms, **immediately** create the output file with empty section
headers. This ensures incremental writes have a target and work survives interruptions.

Ask: "May I create the skeleton file at `design/ux/[filename].md`?" — except in
`accessibility` mode, where the path is `design/accessibility-requirements.md`
(see the mode table in Section 1; it is deliberately not under `design/ux/`).

---

### Skeleton for UX Spec (screen or flow)

```markdown
# UX Spec: [Screen/Flow Name]

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Journey Phase(s)**: [from context]
> **Platform Target**: [target platforms and input methods from 2h]
> **Template**: UX Spec

---

## Purpose & User Need

[To be designed]

---

## User Context on Arrival

[To be designed]

---

## Navigation Position

[To be designed]

---

## Entry & Exit Points

[To be designed]

---

## Layout Specification

### ASCII Wireframe

[To be designed]

### Layout Zones

[To be designed]

### Component Catalog

[To be designed]

### Information Hierarchy

[To be designed]

---

## States & Variants

[To be designed]

---

## Interaction Map

[To be designed]

---

## Data Requirements

[To be designed]

---

## Events Fired

[To be designed]

---

## Transitions & Animations

[To be designed]

---

## Input Method Completeness Checklist

[To be designed]

---

## Accessibility

[To be designed]

---

## Localization Considerations

[To be designed]

---

## Acceptance Criteria

[To be designed]

---

## Open Questions

[To be designed]
```

---

### Skeleton for App Shell & Navigation Design

```markdown
# App Shell & Global Navigation Spec

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Platform Targets**: [target platforms and input methods from 2h]
> **Template**: App Shell Design

---

## Navigation Philosophy

[To be designed]

---

## Information Architecture

### Full Information Registry

[To be designed]

### Categorization

[To be designed]

---

## Layout Zones

[To be designed]

---

## App Shell & Navigation Element Specifications

[To be designed]

---

## App Shell States by Application Context

[To be designed]

---

## Information Hierarchy

[To be designed]

---

## Visual Budget

[To be designed]

---

## Feedback & Notification Systems

[To be designed]

---

## Platform Adaptation

[To be designed]

---

## Accessibility

[To be designed]

---

## User Preferences & Settings

[To be designed]

---

## Acceptance Criteria

[To be designed]

---

## Open Questions

[To be designed]
```

---

### Skeleton for Interaction Pattern Library

```markdown
# Interaction Pattern Library

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Template**: Interaction Pattern Library

---

## Overview

[To be designed]

---

## Pattern Catalog

[To be designed]

---

## Patterns

[Individual pattern entries added here as they are defined]

---

## Gaps & Patterns Needed

[To be designed]

---

## Open Questions

[To be designed]
```

---

### Skeleton for Accessibility Requirements

Section list mirrors `.claude/docs/templates/accessibility-requirements.md` — if
the template gains or loses a section, this skeleton follows it, not the reverse.

```markdown
# Accessibility Requirements

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Template**: Accessibility Requirements

## Accessibility Tier Definition

[To be designed]

---

## Visual Accessibility

[To be designed]

---

## Motor Accessibility

[To be designed]

---

## Cognitive Accessibility

[To be designed]

---

## Auditory Accessibility

[To be designed]

---

## Platform Accessibility API Integration

[To be designed]

---

## Per-Feature Accessibility Matrix

[To be designed]

---

## Accessibility Test Plan

[To be designed]

---

## Known Intentional Limitations

[To be designed]

---

## Audit History

[To be designed]

---

## External Resources

[To be designed]

---

## Open Questions

[To be designed]
```

> **The tier commitment is the gated part.** `gate-pre-production.md` requires
> the file to exist *with an accessibility tier committed*, and
> `gate-production.md` checks that tier is addressed in every key screen spec.
> A skeleton whose Tier Definition is still `[To be designed]` satisfies the
> glob but not the gate — author that section first.

---

After writing the skeleton, update `production/session-state/active.md` with:
- Task: Designing [screen/flow name] UX spec
- Current section: Starting (skeleton created)
- File: design/ux/[filename].md (or `design/accessibility-requirements.md` in `accessibility` mode)

---
