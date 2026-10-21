# Quick Feature Spec: [Title]

**Type**: New Feature / Subsystem
**Scope**: [1-2 sentence description of what this feature does and does not do]
**Date**: [YYYY-MM-DD]
**Estimated Implementation**: [hours / story points]

## Overview

[One paragraph a new team member could understand. What does this feature do,
when does it activate, and what outcome does it produce?]

## Core Business Rules

[Unambiguous rules for the feature. Use numbered lists for sequential behavior
and bullet lists for validation conditions. Be precise enough that an engineer can
implement without asking questions.]

## Configurable Parameters

| Parameter | Default | Range | Scope | Rationale |
|---|---|---|---|---|
| [parameter_name] | [value] | [min–max] | [workspace / user / global] | [why this default] |

All values must live in environment variables or configuration files (`project.yaml`), not hardcoded in source code.

## Acceptance Criteria

- [ ] [Functional criterion: handles valid payload and returns correct response]
- [ ] [Functional criterion: handles edge cases and rejects unauthorized access with 403]
- [ ] [UX criterion: meets response time and WCAG AA accessibility requirements]
- [ ] [Regression criterion: does not break existing routes or database migrations]

## Features Index

This feature is tracked in `docs/specs/features-modules-index.md`.
[If it should be added: suggest which layer and priority tier.]
[If it is too small to track: state "This feature is below features index tracking threshold — quick spec is sufficient."]
