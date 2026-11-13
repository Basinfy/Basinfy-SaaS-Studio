---
name: saas-lgpd-international-transfer
description: Set up international data transfers per LGPD Arts. 33-36 and Resolução CD/ANPD nº 19/2024 (Cláusulas-Padrão Contratuais brasileiras). Use when user asks 'transferência internacional', 'AWS US LGPD', 'cláusulas-padrão', 'SCCs Brasil', 'data residency', or onboarding any operator outside Brazil. Outputs per-vendor transfer assessment in `.lgpd/transfers/`.
argument-hint: "[scope or artifact path]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

# Transferência Internacional de Dados

> **Interaction Localization Rule**:
> When locale: pt-BR (or user speaks Portuguese), ALL questions (AskUserQuestion / ask_question), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and technical documentation MUST remain in English (except Brazilian statutory compliance documents under .lgpd/).


Arts. 33-36 LGPD + **Resolução CD/ANPD nº 19/2024** (Cláusulas-Padrão Contratuais brasileiras).

## Hipóteses do Art. 33 (9 bases)

I. País com nível de proteção adequado (ANPD ainda não publicou lista oficial)
II. Garantias contratuais:
   (a) cláusulas contratuais específicas
   (b) **cláusulas-padrão** ← caminho mais usado, regulado pela Res. 19/2024
   (c) normas corporativas globais (BCRs)
   (d) selos/certificados/códigos de conduta
III. Cooperação jurídica internacional
IV. Proteção da vida
V. Autorização específica da ANPD
VI. Acordo de cooperação internacional
VII. Execução de política pública
VIII. Consentimento específico e destacado do titular
IX. Cumprimento de obrigação legal, contrato, etc.

## Cláusulas-Padrão (Res. 19/2024 Anexo II)

- Devem ser adotadas **integralmente, sem alteração**, exceto preenchimento de identificação
- Prazo de adoção em contratos: 12 meses (encerrou ago/2025) — atualmente obrigatório
- Estrutura: identificação, finalidades, transferências posteriores, responsabilidades, princípios, direitos do titular, medidas técnicas, lei aplicável, encerramento

## Workflow

1. Listar todos os operadores fora do Brasil (cloud US, observability, comms, etc.)
2. Para cada um, escolher hipótese do Art. 33
3. Implementar:
   - Se IIb (mais comum): assinar adendo com Cláusulas-Padrão do Anexo II
   - Se VIII: capturar consentimento específico (raro na prática)
4. Documentar em `.lgpd/transfers/{vendor}.md`
5. Citar na política de privacidade

## Template — `.lgpd/transfers/{vendor}.md`

```markdown
# Transferência Internacional — {Vendor}

- **Operador**: {nome}
- **País**: {país}
- **Finalidade**: {específica}
- **Dados transferidos**: {lista}
- **Hipótese do Art. 33**: II, (b) cláusulas-padrão
- **Cláusulas-Padrão (Res. 19/2024)**: assinadas em {data}
- **Documento**: link para PDF assinado
- **Sub-operadores autorizados**: {lista}
- **Salvaguardas adicionais**: criptografia em trânsito e em repouso, pseudonimização
- **Avaliação de adequação**: {data} — risco residual {nível}
- **Próxima revisão**: {data}
```

## Status update

```markdown
## F14b — Transferências internacionais ✓
- {N} operadores fora do BR
- {M} com cláusulas-padrão assinadas
- {X} pendentes: {lista}
- Próximo: saas-lgpd-vendor-audit (review anual)
```

