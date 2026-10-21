# Technical Preferences

<!-- project.yaml at the repo root is the machine-readable source of truth for
     stack, specialists, naming, performance, platform, and testing.framework.
     This file is the human-readable LEGACY FALLBACK: agents and skills resolve
     each key from project.yaml first and fall back here only when the
     project.yaml key is absent. /saas-setup-stack dual-writes both.
     Forbidden patterns and allowed libraries are NOT migrated — they live only
     in this file. Populated by /saas-setup-stack; updated as decisions are made. -->

## Engine & Language

- **Engine**: [TO BE CONFIGURED — run /saas-setup-stack]
- **Language**: [TO BE CONFIGURED]
- **Database / ORM**: [TO BE CONFIGURED]
- **API Framework**: [TO BE CONFIGURED]

## Input & Platform

<!-- Written by /saas-setup-stack. Read by /saas-ux-design, /saas-ux-review, /saas-test-setup, /saas-team-ui, and /saas-dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: [TO BE CONFIGURED — e.g., Web, Mobile Web, Desktop (Electron/Tauri)]
- **Input Methods**: [TO BE CONFIGURED — e.g., Keyboard/Mouse, Touch]
- **Primary Input**: [TO BE CONFIGURED — the dominant input for this product]
- **Touch Support**: [TO BE CONFIGURED — Full / Partial / None]
- **Platform Notes**: [TO BE CONFIGURED — any platform-specific UX constraints]

## Naming Conventions

- **Classes**: [TO BE CONFIGURED]
- **Variables**: [TO BE CONFIGURED]
- **Signals/Events**: [TO BE CONFIGURED]
- **Files**: [TO BE CONFIGURED]
- **Components**: [TO BE CONFIGURED]
- **Constants**: [TO BE CONFIGURED]

## Performance Budgets

- **P99 API Latency**: [TO BE CONFIGURED]
- **Max Bundle Size**: [TO BE CONFIGURED]
- **API Timeout**: [TO BE CONFIGURED]
- **Memory Ceiling**: [TO BE CONFIGURED]

## Testing

- **Framework**: [TO BE CONFIGURED]
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: Pricing formulas, core business logic, API endpoints, auth

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — add as dependencies are approved]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /saas-architecture-decision to create one]

## Engine Specialists

<!-- Written by /saas-setup-stack when stack is configured. -->
<!-- Read by /saas-code-review, /saas-architecture-decision, /saas-architecture-review, and team skills -->
<!-- to know which specialist to spawn for stack-specific validation. -->

- **Primary**: [TO BE CONFIGURED — run /saas-setup-stack]
- **Language/Code Specialist**: [TO BE CONFIGURED]
- **Database Specialist**: [TO BE CONFIGURED]
- **UI Specialist**: [TO BE CONFIGURED]
- **Additional Specialists**: [TO BE CONFIGURED]
- **Routing Notes**: [TO BE CONFIGURED]

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->
<!-- If a row says [TO BE CONFIGURED], fall back to Primary for that file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Application code (primary language) | [TO BE CONFIGURED] |
| Database / migration files | [TO BE CONFIGURED] |
| UI / screen files | [TO BE CONFIGURED] |
| Schema / configuration files | [TO BE CONFIGURED] |
| Native extension / plugin files | [TO BE CONFIGURED] |
| General architecture review | Primary |
