---
name: saas-lgpd
description: "LGPD & ECA Digital compliance command center — audit, consent, DSAR, ROPA, RIPD, incidents."
argument-hint: "[audit | greenfield | legacy | incident | dsar | ropa | ripd | consent | status]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,automation` and use its output below.

# LGPD Command Center

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


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
