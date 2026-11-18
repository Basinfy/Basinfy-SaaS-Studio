---
name: saas-content-audit
description: "Audit planned PRD entities against implemented routes, components, models, and services."
argument-hint: "[--engine <stack>] [--system <name>] [--files] [--review full|lean|solo]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,automation,workflow` and use its output below.

# Content Audit (Planned vs Built Entities)

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


Audits the completion of planned software entities and architecture resources against actual
files implemented on disk across all SaaS layers.

---

## Phase 1: Read Planned Entities

1. **Entity Registry**:
   - Read `design/registry/entities.yaml` if it exists (via `bash .claude/scripts/content-count.sh registry`).
   - Extract planned models, API endpoints, UI views, and workers.
2. **PRD Quantities**:
   - Grep `design/prd/*.md` for specified entity counts:
     - Endpoints / routes
     - Pages / screens / modals
     - Database tables / schemas
     - Background jobs / webhooks

---

## Phase 2: Scan Implemented Resources on Disk

Run `.claude/scripts/content-count.sh found` to discover implemented resources:
- **Routes**: `src/app/api/**`, `api/routes/**`, `src/pages/api/**`
- **Components**: `src/components/**`, `src/ui/**`, `src/views/**`
- **Schemas**: `prisma/schema.prisma`, `src/db/models/**`, `supabase/migrations/**`
- **Services**: `src/services/**`, `src/lib/**`, `src/workers/**`
- **Docs**: `docs/**`, `design/**`, `production/**`

---

## Phase 3: Gap Analysis & Completion Status Bands

Compare specified count ($S$) against found count ($F$):
- $F = 0$: **NOT STARTED**
- $0 < F/S < 50\%$: **EARLY**
- $50\% \le F/S < 100\%$: **IN PROGRESS**
- $F \ge S$: **COMPLETE**

Calculate:
- `total_specified`
- `total_found`
- `total_gap`
- `unbuilt_percentage`

---

## Phase 4: Output Report

Save audit findings to `production/audit/content-audit-[date].md`:
- Summary table by resource category
- Detailed gap table per system
- High-priority missing resources needed for MVP / current milestone.
