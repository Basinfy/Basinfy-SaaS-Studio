---
name: saas-lgpd-dpo-encarregado
description: Designate and publish the Encarregado (DPO) per LGPD Art. 41 + Resolução CD/ANPD nº 18/2024. Use when user asks 'designar DPO', 'encarregado LGPD', 'quem é o DPO', or as part of audit pipeline. Note ATPP exemption (Res. 2/2022 Art. 11) but recommend designation anyway as best practice.
argument-hint: "[scope or artifact path]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

# Encarregado / DPO (Art. 41 LGPD + Res. 18/2024)

> **Interaction Localization Rule**:
> When locale: pt-BR (or user speaks Portuguese), ALL questions (AskUserQuestion / ask_question), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and technical documentation MUST remain in English (except Brazilian statutory compliance documents under .lgpd/).


## Quem pode ser

- **Pessoa natural OU pessoa jurídica** (Res. 18/2024, Art. 3º + 12)
- Não precisa de certificação formal
- Não precisa residir no Brasil
- Pode ser interno ou externo (outsourced DPO é prática comum em ATPP)
- **Vedado conflito de interesse** (Res. 18/2024, Art. 2º, II) — diretor jurídico ou de TI pode ter conflito; avaliar

## Atribuições mínimas (Art. 41, § 2º)

1. Aceitar reclamações e comunicações dos titulares
2. Receber comunicações da ANPD
3. Orientar funcionários e contratados sobre práticas
4. Executar demais atribuições do controlador

## Atribuições expandidas (Res. 18/2024, Arts. 15-16)

- Auxiliar na elaboração de ROPA, RIPD, DPAs
- Auxiliar na comunicação de incidentes
- Auxiliar em transferência internacional
- Auxiliar no programa de governança em privacidade (Art. 50 LGPD)
- Promover privacy-by-design

## Divulgação obrigatória

- **No site, em local de destaque** (Res. 18/2024, Art. 9º)
- Nome completo (se PF) ou nome empresarial + responsável técnico (se PJ)
- Canal de contato (e-mail é o mínimo; portal é melhor)
- Em PT-BR (Res. 18/2024, Art. 13)
- Não é necessário comunicar a ANPD proativamente — ato formal deve estar disponível "quando solicitado" (Res. 18/2024, Art. 3º, § 2º)

## ATPP — dispensa formal

Res. 2/2022, Art. 11 dispensa designação para ATPP de baixo risco, mas exige **canal de comunicação**. Recomendação: designar mesmo assim — custo baixo, proteção alta.

## Template — `.lgpd/encarregado.md`

```markdown
# Encarregado pela Proteção de Dados

**Designado por**: {ato formal — ata, contrato, resolução}
**Data de designação**: {data}
**Tipo**: PF / PJ
**Nome**: {nome completo ou nome empresarial}
**Responsável técnico** (se PJ): {nome}
**Contato**:
- E-mail: encarregado@dominio.com.br
- Telefone: (XX) XXXX-XXXX
- Portal: https://dominio.com.br/encarregado

**Atribuições conferidas**: ver Res. 18/2024 + atribuições internas definidas no anexo

**Conflito de interesse avaliado em**: {data}
**Conclusão**: sem conflito identificado

**Divulgação**: publicada em https://dominio.com.br/privacidade#encarregado
```

## Status update

```markdown
## F11 — Encarregado ✓
- Designado: {nome}
- Tipo: PF/PJ
- Publicado em: {URL}
- Canal ativo: {e-mail}
- Próximo: saas-lgpd-ripd (se alto risco) ou saas-lgpd-vendor-audit
```

