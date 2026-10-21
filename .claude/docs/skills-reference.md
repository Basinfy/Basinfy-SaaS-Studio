# Available Skills (Slash Commands)

74 slash commands organized by phase. Type `/` in Claude Code to access any of them.

## Onboarding & Navigation

| Command | Purpose |
|---------|---------|
| `/saas-start` | First-time onboarding — asks where you are, then guides you to the right workflow |
| `/saas-help` | Context-aware "what do I do next?" — reads current stage and surfaces the required next step |
| `/saas-project-stage-detect` | Full project audit — detect phase, identify existence gaps, recommend next steps |
| `/saas-setup-stack` | Configure stack + version, detect knowledge gaps, populate version-aware reference docs |
| `/saas-adopt` | Brownfield format audit — checks internal structure of existing PRDs/ADRs/stories, produces migration plan |
| `/saas-settings` | View or change project config — the effective merged values, or a local override in `project.local.yaml` |

## Product Design

| Command | Purpose |
|---------|---------|
| `/saas-brainstorm` | Guided ideation using SaaS studio methods (Jobs-to-be-Done, value propositions, feature scoping) |
| `/saas-map-features` | Decompose SaaS product concept into modules and features, map dependencies, prioritize design order |
| `/saas-design-system` | Guided, section-by-section PRD authoring for a single SaaS system |
| `/saas-quick-design` | Lightweight design spec for small changes — tuning, tweaks, minor additions |
| `/saas-review-all-prds` | Cross-PRD consistency and SaaS product design holism review across all design docs |
| `/saas-propagate-design-change` | When a PRD is revised, find affected ADRs and produce an impact report |

## Art & Assets

| Command | Purpose |
|---------|---------|
| `/saas-design-tokens` | Guided, section-by-section Design Tokens authoring — creates visual identity spec before asset production begins |
| `/saas-asset-spec` | Generate per-asset visual specifications and AI generation prompts from PRDs, level docs, or character profiles |
| `/saas-asset-audit` | Audit assets for naming conventions, file size budgets, and pipeline compliance |

## UX & Interface Design

| Command | Purpose |
|---------|---------|
| `/saas-ux-design` | Guided section-by-section UX spec authoring (screen/flow, app-shell, or pattern library) |
| `/saas-ux-review` | Validate UX specs for PRD alignment, accessibility, and pattern compliance |

## Architecture

| Command | Purpose |
|---------|---------|
| `/saas-create-architecture` | Guided authoring of the master architecture document |
| `/saas-architecture-decision` | Create an Architecture Decision Record (ADR) |
| `/saas-architecture-review` | Validate all ADRs for completeness, dependency ordering, and PRD coverage |
| `/saas-create-control-manifest` | Generate flat programmer rules sheet from accepted ADRs |

## Stories & Sprints

| Command | Purpose |
|---------|---------|
| `/saas-create-epics` | Translate PRDs + ADRs into epics — one per architectural module |
| `/saas-create-stories` | Break a single epic into implementable story files |
| `/saas-dev-story` | Read a story and implement it — routes to the correct programmer agent |
| `/saas-sprint-plan` | Generate or update a sprint plan; initializes sprint-status.yaml |
| `/saas-sprint-status` | Fast 30-line sprint snapshot (reads sprint-status.yaml) |
| `/saas-story-readiness` | Validate a story is implementation-ready before pickup (READY/NEEDS WORK/BLOCKED) |
| `/saas-story-done` | 8-phase completion review after implementation; updates story file, surfaces next story |
| `/saas-estimate` | Structured effort estimate with complexity, dependencies, and risk breakdown |

## Reviews & Analysis

| Command | Purpose |
|---------|---------|
| `/saas-design-review` | Review a SaaS product design document (PRD) for completeness and consistency |
| `/saas-code-review` | Architectural code review for a file or changeset |
| `/saas-pricing-audit` | Analyze SaaS pricing tier balance data, formulas, and config — flag outliers |
| `/saas-content-audit` | Audit PRD-specified content counts against implemented content |
| `/saas-scope-check` | Analyze feature or sprint scope against original plan, flag scope creep |
| `/saas-perf-profile` | Structured performance profiling with bottleneck identification |
| `/saas-tech-debt` | Scan, track, prioritize, and report on technical debt |
| `/saas-gate-check` | Validate readiness to advance between development phases (PASS/CONCERNS/NOT ASSESSED/FAIL) |
| `/saas-consistency-check` | Scan all PRDs against the entity registry to detect cross-document inconsistencies (stats, names, rules that contradict each other) |
| `/saas-security-audit` | Audit the SaaS product for security vulnerabilities: authentication flaws, authorization bypasses, network exploits, data exposure, and input validation gaps |

## QA & Testing

| Command | Purpose |
|---------|---------|
| `/saas-qa-plan` | Generate a QA test plan for a sprint or feature |
| `/saas-smoke-check` | Run critical path smoke test gate before QA hand-off |
| `/saas-load-test` | Generate a load test protocol for high-concurrency API and endurance sessions |
| `/saas-regression-suite` | Map test coverage to PRD critical paths, identify fixed bugs without regression tests |
| `/saas-test-setup` | Scaffold the test framework and CI/CD pipeline for the project's stack |
| `/saas-test-helpers` | Generate stack-specific test helper libraries for the test suite |
| `/saas-test-evidence-review` | Quality review of test files and manual evidence documents |
| `/saas-test-flakiness` | Detect non-deterministic (flaky) tests from CI run logs |
| `/saas-skill-test` | Validate skill files for structural compliance and behavioral correctness |
| `/saas-skill-improve` | Improve a skill using a test-fix-retest loop — diagnose, propose fix, rewrite, verify |

## Production

| Command | Purpose |
|---------|---------|
| `/saas-milestone-review` | Review milestone progress and generate status report |
| `/saas-retrospective` | Run a structured sprint or milestone retrospective |
| `/saas-bug-report` | Create a structured bug report |
| `/saas-bug-triage` | Read all open bugs, re-evaluate priority vs. severity, assign owner and label |
| `/saas-reverse-document` | Generate design or architecture docs from existing implementation |
| `/saas-usability-test` | Generate a structured usability test report or analyze existing usability test notes |

## Release

| Command | Purpose |
|---------|---------|
| `/saas-release-checklist` | Generate and validate a pre-release checklist for the current build |
| `/saas-launch-checklist` | Complete launch readiness validation across all departments |
| `/saas-changelog` | Auto-generate changelog from git commits and sprint data |
| `/saas-patch-notes` | Generate user-facing patch notes from git history and internal data |
| `/saas-hotfix` | Emergency fix workflow with audit trail, bypassing normal sprint process |
| `/saas-post-launch-monitor` | Prepare focused post-launch monitoring and telemetry tracking for issues discovered after GA release |

## Creative & Content

| Command | Purpose |
|---------|---------|
| `/saas-prototype` | Concept prototype — throwaway build right after brainstorm to validate core idea (Phase 1) |
| `/saas-vertical-slice` | Pre-Production validation — production-quality end-to-end build before committing to Production (Phase 4) |
| `/saas-onboard` | Generate contextual onboarding document for a new contributor or agent |
| `/saas-localize` | Localization workflow: string extraction, validation, translation readiness |

## Team Orchestration

Coordinate multiple agents on a single feature area:

| Command | Coordinates |
|---------|-------------|
| `/saas-team-core-feature` | lead-product-manager + backend-engineer + ai-engineer + ui-motion-designer + pricing-economist + qa-manual-tester |
| `/saas-team-content` | ux-content-strategist + technical-writer + onboarding-specialist + user-flow-architect |
| `/saas-team-ui` | ux-designer + frontend-engineer + design-system-director + accessibility-auditor |
| `/saas-team-release` | release-manager + qa-lead + devops-engineer + delivery-producer |
| `/saas-team-polish` | web-perf-analyst + ui-motion-designer + pricing-economist + qa-manual-tester |
| `/saas-team-growth` | growth-director + pricing-economist + ui-motion-designer + backend-engineer |
| `/saas-team-auth-access` | user-flow-architect + ux-content-strategist + onboarding-specialist + design-system-director + database-architect + qa-manual-tester |
| `/saas-team-billing` | sre-observability-engineer + billing-engineer + data-telemetry-engineer + customer-success-ops + technical-writer |
| `/saas-team-qa` | qa-lead + qa-manual-tester + backend-engineer + delivery-producer |

## Overlap with Claude Code's bundled skills

Claude Code ships its own skills, and one name collides with SAAS_STUDIO's.

| You type | You get | Use it for |
|---------|---------|-----------|
| `/saas-code-review` | **SAAS_STUDIO's** — project skills take the bare name | Architectural review against this project's coding standards, SOLID, testability and the control manifest. Knows about ADRs, stories and `docs/architecture/`. |
| `/review` | **Claude Code's bundled** review — the alias of its `/saas-code-review`, which SAAS_STUDIO's skill shadows | Reviewing a pull request or a plain diff for correctness bugs, with no knowledge of SAAS_STUDIO's design documents or gates. |

Both are useful; they answer different questions. Reach for the SAAS_STUDIO one during
`/saas-dev-story` and before `/saas-story-done`, because it checks the things the gates
later check. Reach for the bundled one when you want a general review of a diff
that has nothing to do with a story.

SAAS_STUDIO does **not** turn the bundled skills off. `disableBundledSkills` would
remove all of them, including `/debug`, `/security-review` and `/simplify`,
which are worth keeping. If you want a bundled skill hidden, use
`skillOverrides` in your own `.claude/settings.local.json` rather than disabling
the whole set.
