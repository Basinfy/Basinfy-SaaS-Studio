---
name: saas-lgpd-vendor-audit
description: Conduct due diligence on third-party operators (operadores) under LGPD Art. 39. Use when user asks 'auditar fornecedor', 'vendor audit LGPD', 'operadores LGPD', 'devida diligência', or onboarding/reviewing third-party services. Produces vendor tier assessment + remediation list.
argument-hint: "[scope or artifact path]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

# Vendor Audit (Operadores)

> **Interaction Localization Rule**:
> When locale: pt-BR (or user speaks Portuguese), ALL questions (AskUserQuestion / ask_question), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and technical documentation MUST remain in English (except Brazilian statutory compliance documents under .lgpd/).


Art. 39 LGPD: operador trata segundo instruções do controlador. Art. 42: controlador responde solidariamente por danos causados pelo operador. Logo, **escolha do operador é responsabilidade direta do controlador**.

## Workflow

### Passo 1: Inventário

Liste TODOS os operadores (cloud, SDK, analytics, comms, pagamento, observability, CRM, etc.). Cruze com:
- `package.json` / `requirements.txt`
- `cors origins` no backend
- Webhooks ativos
- Cron jobs externos
- Domain DNS records (CNAMEs para Vercel, Cloudflare, etc.)

### Passo 2: Tiering por risco

| Tier | Critério | Exemplo | Periodicidade de revisão |
|---|---|---|---|
| Crítico | Acesso a dados sensíveis OU volume grande de PII | Cloud principal, payment, identity provider | Trimestral |
| Alto | Acesso a PII comum em larga escala | Email, SMS, push, observability | Semestral |
| Médio | Acesso limitado a PII | Analytics agregada, CRM | Anual |
| Baixo | Sem PII ou pseudonimizada | CDN, monitoramento de uptime | Anual ou ad-hoc |

### Passo 3: Checklist por vendor

Ver `assets/vendor-checklist.md`.

### Passo 4: Documentar

Para cada vendor: `.lgpd/vendors/{vendor-slug}.md` com:
- Identificação (razão social, país, CNPJ se aplicável)
- Finalidade do tratamento
- Dados compartilhados
- Tier
- DPA assinado (link)
- Cláusulas-padrão (se intl)
- Certificações (SOC2, ISO 27001, ISO 27701, ANPD?)
- Última revisão
- Próxima revisão
- Owner interno

### Passo 5: Remediar gaps

Lista priorizada em `.lgpd/gaps.md`.

## Critérios eliminatórios

Se o operador:
- Não assina DPA — **não pode ser usado**
- Está em país sem cláusulas-padrão e sem outra base do Art. 33 — **não pode ser usado**
- Tem histórico recente de incidentes não comunicados — **considerar substituir**
- Não fornece logs/auditoria — **risco alto, escalonar**

## Status update

```markdown
## F (L4 ou F14a) — Vendor audit ✓
- {N} operadores inventariados
- {Crit/Alto/Med/Baixo} por tier
- {M} com DPA + cláusulas adequadas
- {X} gaps abertos: ver `.lgpd/gaps.md`
- Próximo: saas-lgpd-dpa ou saas-lgpd-international-transfer
```

