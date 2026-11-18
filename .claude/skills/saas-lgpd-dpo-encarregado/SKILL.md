---
name: saas-lgpd-dpo-encarregado
description: "Designate and publish DPO / Encarregado governance per LGPD Art. 41 & ANPD Res. 18/2024."
argument-hint: "[scope or artifact path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, mcp__basinfy__basinfy_query_script, mcp__basinfy__basinfy_discover, mcp__basinfy__basinfy_prepare_edit, mcp__basinfy__basinfy_prepare_create, mcp__basinfy__basinfy_impact, mcp__basinfy__basinfy_remember, mcp__basinfy__basinfy_recall, Bash(basinfy *)
model: sonnet
---

# Encarregado / DPO (Art. 41 LGPD + Res. 18/2024)

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.



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

