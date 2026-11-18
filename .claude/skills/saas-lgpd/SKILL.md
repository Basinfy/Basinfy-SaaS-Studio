---
name: saas-lgpd
description: "LGPD & ECA Digital compliance command center — audit, consent, DSAR, ROPA, RIPD, incidents."
argument-hint: "[audit | greenfield | legacy | incident | dsar | ropa | ripd | consent | status]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-lgpd/../../hooks/yaml-helper.sh" resolve_config *), mcp__basinfy__basinfy_query_script, mcp__basinfy__basinfy_discover, mcp__basinfy__basinfy_prepare_edit, mcp__basinfy__basinfy_prepare_create, mcp__basinfy__basinfy_impact, mcp__basinfy__basinfy_remember, mcp__basinfy__basinfy_recall, Bash(basinfy *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation`

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
