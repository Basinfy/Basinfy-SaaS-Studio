# Quick Design Spec: [Title]

**Type**: [Tweak / Addition]
**System**: [System name]
**PRD Reference**: `design/prd/[filename].md`
**Date**: [today]

## Change Summary

[1-2 sentences describing what changes and why.]

## Motivation

[Why is this change needed? What user experience problem does it solve?
Reference the relevant MDA aesthetic or user feedback if applicable.]

## Design Delta

Current PRD says (quoting `design/prd/[filename].md`, [section]):

> [exact quote of the relevant rule or description]

This spec changes that to:

[New rule or description, written with the same precision as a PRD Detailed
Rules section. A programmer should be able to implement from this text alone.]

## New Rules / Values

[Full unambiguous statement of the replacement content. If this introduces
new states, list them. If it introduces new parameters, define their ranges.]

## Affected Systems

| System | Impact | Action Required |
|--------|--------|-----------------|
| [system] | [how it is affected] | [update PRD / update data file / no action] |

## Acceptance Criteria

- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]
- [ ] No regression: [the original behavior this must not break]

## PRD Update Required?

[Yes / No]
[If yes: which file, which section, and what the update should say.]
