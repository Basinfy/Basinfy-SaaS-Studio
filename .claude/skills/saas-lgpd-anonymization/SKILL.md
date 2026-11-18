---
name: saas-lgpd-anonymization
description: "Implement LGPD Art. 5/13 anonymization and pseudonymization for analytics and exports."
argument-hint: "[scope or artifact path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, mcp__basinfy__basinfy_query_script, mcp__basinfy__basinfy_discover, mcp__basinfy__basinfy_prepare_edit, mcp__basinfy__basinfy_prepare_create, mcp__basinfy__basinfy_impact, mcp__basinfy__basinfy_remember, mcp__basinfy__basinfy_recall, Bash(basinfy *)
model: sonnet
---

# Anonimização e Pseudonimização

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.



## Diferença crítica

| | Anonimização (Art. 5º, XI) | Pseudonimização (Art. 13, § 4º) |
|---|---|---|
| Reversível? | Não, considerando meios técnicos razoáveis | Sim, com info adicional segregada |
| Status LGPD | Fora do escopo (Art. 12) | Continua sendo dado pessoal |
| Uso típico | Estatísticas públicas, datasets de pesquisa | Analytics interna, logs, redução de exposição |
| Risco residual | Baixíssimo (re-identificação) | Médio (depende da segurança da chave) |

## Técnicas

### Pseudonimização
- **Tokenização determinística**: substitui PII por token; mapping mantido em vault separado
- **Hashing com salt** (cuidado — sem salt aleatório, é reversível por força bruta para campos de baixa entropia como CPF)
- **Format-preserving encryption** quando o formato precisa ser mantido

### Anonimização
- **Generalização**: idade exata → faixa (25-34); CEP → cidade
- **Supressão**: remoção de campos identificadores
- **Perturbação**: adicionar ruído aleatório
- **k-anonymity (k ≥ 5)**: cada combinação de quasi-identificadores aparece em ≥ k registros
- **l-diversity, t-closeness**: refinamentos para resistir a ataques de inferência
- **Differential privacy (ε pequeno)**: garantia matemática contra re-identificação

## Pipeline típico de analytics

```
[Postgres prod] → ETL com pseudonimização (token PII) → [Analytics DW] → Generalização + k-anonymity → [Dashboards públicos]
```

## Anti-padrões

- ❌ "Removemos o nome" e mantemos CPF, e-mail, endereço — **não é anonimização**
- ❌ Hash de CPF sem salt único — facilmente reversível (~210 milhões de combinações)
- ❌ ID interno como "pseudônimo" se está exposto em URLs e logs — não é pseudonimização
- ❌ Agregação só por região quando dataset tem campos suficientes para inferência cruzada

## Implementação

Ver `assets/anonymization-recipes.md` para receitas concretas em SQL e Python.

## Re-identificação — teste obrigatório

Antes de declarar um dataset "anonimizado":
1. **Linkage attack**: tente combinar com dataset público
2. **Inference attack**: estime atributo sensível a partir dos outros
3. **Singling out**: existe registro único na base?

Se algum passa → dataset ainda é dado pessoal.

## Status update

```markdown
## F (legacy L6) — Anonimização ✓
- Pipelines de analytics revisados
- {N} datasets passados por pseudonimização
- {M} datasets passados por anonimização (k=5+)
- Vault de tokens isolado
- Próximo: saas-lgpd-dsar (legacy) ou conforme pipeline
```

