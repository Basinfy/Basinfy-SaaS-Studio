# Roteamento de Skills Filhas

| Skill | Quando invocar | Outputs em `.lgpd/` |
|---|---|---|
| `saas-lgpd-legal-basis` | Decidir base legal de cada atividade de tratamento | `legal-basis.md` |
| `saas-lgpd-data-mapping` | Inventariar fluxos de dados pessoais | `data-map.md` |
| `saas-lgpd-ropa` | Consolidar Registro de Operações (Art. 37) | `ROPA.md` |
| `saas-lgpd-ripd` | Avaliação de impacto para alto risco (Art. 38) | `RIPD/ripd-{slug}.md` |
| `saas-lgpd-consent-schema` | Modelar consent ledger no banco (Prisma) | `consent/schema.prisma`, `consent/spec.md` |
| `saas-lgpd-dsar` | Implementar endpoints de exercício de direitos (Art. 18) | `dsar/workflow.md`, `dsar/endpoints.md` |
| `saas-lgpd-audit-logging` | Log imutável encadeado | `audit-logging.md` |
| `saas-lgpd-encryption-keys` | TDE, KMS, rotação | `security/encryption.md` |
| `saas-lgpd-anonymization` | Técnicas de anonimização e pseudonimização | `security/anonymization.md` |
| `saas-lgpd-retention-erasure` | Políticas de retenção + crypto-shredding | `retention.md` |
| `saas-lgpd-incident-response` | Runbook + comunicação ANPD (3 dias úteis) | `incidents/runbook.md`, `incidents/log.md` |
| `saas-lgpd-privacy-policy` | Política conforme Art. 9 | `policies/privacy-policy-v{N}.md` |
| `saas-lgpd-dpo-encarregado` | Designar e publicar Encarregado | `encarregado.md` |
| `saas-lgpd-dpa` | DPA com operadores (Art. 39) | `vendors/dpa-template.md`, `vendors/{vendor}.md` |
| `saas-lgpd-international-transfer` | Cláusulas-padrão (Res. 19/2024) | `transfers/{vendor}.md` |
| `saas-lgpd-vendor-audit` | Due diligence em operadores | `vendors/audit-{date}.md` |
| `saas-lgpd-eca-digital-minors` | Plataformas com menores (Lei 15.211/2025) | `eca-digital.md` |
| `saas-lgpd-legacy-retrofit` | Gap analysis em sistema legado | `gaps.md` |

## Ordem de prioridade (se tempo for limitado)

1. `saas-lgpd-legal-basis` — sem base legal não há tratamento legítimo
2. `saas-lgpd-data-mapping` — sem mapa não há ROPA, RIPD, nem retenção
3. `saas-lgpd-privacy-policy` — exposição imediata ao titular
4. `saas-lgpd-dsar` — direitos do titular = topo da agenda ANPD
5. `saas-lgpd-incident-response` — pode ser acionado a qualquer momento
6. `saas-lgpd-dpo-encarregado` — comunicação com ANPD e titulares
7. Resto

## Dependências entre skills

- `saas-lgpd-ropa` requer `saas-lgpd-data-mapping` + `saas-lgpd-legal-basis`
- `saas-lgpd-ripd` requer `saas-lgpd-ropa` + identificação de alto risco
- `saas-lgpd-dpa` requer `saas-lgpd-vendor-audit`
- `saas-lgpd-international-transfer` requer `saas-lgpd-vendor-audit`
- `saas-lgpd-eca-digital-minors` é independente mas afeta `saas-lgpd-privacy-policy` e `saas-lgpd-consent-schema`
