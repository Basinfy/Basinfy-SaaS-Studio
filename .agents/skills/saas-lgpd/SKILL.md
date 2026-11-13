---
name: saas-lgpd
description: "Direct entrypoint for LGPD privacy compliance — audit, greenfield setup, legacy retrofit, incident response, DSAR, consent ledger, ROPA, and RIPD. Use for 'auditar lgpd', 'como estamos de lgpd', 'lgpd audit', or 'compliance lgpd'."
argument-hint: "[audit | greenfield | legacy | incident | dsar | ropa | ripd | consent | status]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,automation` and use its output below.

# LGPD Command Center

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and technical documentation MUST remain in English (except Brazilian statutory compliance documents under .lgpd/).

Primary command interface for data protection and privacy compliance under Lei nº 13.709/2018 (LGPD), ANPD resolutions, and Lei nº 15.211/2025 (ECA Digital).

## Mode Routing

Parse the first argument:

- **`audit`** (default if no argument provided):
  Launches `saas-lgpd-audit` to diagnose the codebase, select Pipeline A (Greenfield), Pipeline B (Legacy), Pipeline C (Hybrid), or Pipeline D (Incident), and orchestrate the specialized sub-skills.
- **`greenfield`**:
  Triggers Pipeline A directly for new privacy-by-design architectures.
- **`legacy`**:
  Triggers `saas-lgpd-legacy-retrofit` and Pipeline B for retrofitting and gap analysis on existing systems.
- **`incident`**:
  Triggers `saas-lgpd-incident-response` immediately under critical 3-business-day notification protocol (Resolução CD/ANPD nº 15/2024).
- **`dsar`**:
  Triggers `saas-lgpd-dsar` for Data Subject Access Requests (account erasure, portability, data access, Art. 18).
- **`ropa`**:
  Triggers `saas-lgpd-ropa` for Registro das Operações de Tratamento (Art. 37).
- **`ripd`**:
  Triggers `saas-lgpd-ripd` for Relatório de Impacto à Proteção de Dados Pessoais (Art. 38).
- **`consent`**:
  Triggers `saas-lgpd-consent-schema` for Prisma append-only ledger modeling and auth integration.
- **`status`**:
  Reads and reports the current state from `.lgpd/STATUS.md` and `.lgpd/gaps.md`.
