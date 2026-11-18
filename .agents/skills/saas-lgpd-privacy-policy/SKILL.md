---
name: saas-lgpd-privacy-policy
description: "Draft clear, versioned LGPD Art. 9 privacy notices matched to real codebase data flows."
argument-hint: "[scope or artifact path]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

# Política de Privacidade (Art. 9 LGPD)

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.



Documento público que cumpre o dever de informação (Art. 6º, VI — transparência + Art. 9º — direito do titular ao acesso).

## 7 elementos obrigatórios (Art. 9º)

1. **Finalidade específica** do tratamento
2. **Forma e duração** do tratamento
3. **Identificação** do controlador
4. **Contato** do controlador/encarregado
5. **Uso compartilhado** de dados e finalidade
6. **Responsabilidades** dos agentes que realizam o tratamento
7. **Direitos do titular** com menção explícita ao Art. 18

Recomendado adicionar:
8. Versão, data de vigência, changelog
9. Bases legais por finalidade
10. Transferências internacionais
11. Retenção
12. Cookies e tecnologias similares
13. Mudanças e como serão comunicadas

## Linguagem

- **Clara e acessível** (não juridiquês)
- **Em português brasileiro** (ECA Digital exige se houver menores)
- **Versão resumida no topo** (TL;DR) — boa prática emergente
- **Estrutura em camadas** — resumo + detalhe expansível

## Template

Ver `assets/privacy-policy-template.md`.

## Versionamento

Toda mudança material → nova versão. Material = mudança em:
- Finalidades
- Bases legais
- Compartilhamentos novos
- Transferência internacional nova
- Retenção
- Direitos

Mudanças cosméticas (gramática, layout) — micro-versão (v1.0 → v1.0.1).

## Publicação

- Salvar em `.lgpd/policies/privacy-policy-v{N}.md`
- Publicar em URL estável: `/privacy` ou `/politica-de-privacidade`
- Versões antigas acessíveis: `/privacy/v3.1`
- Changelog visível ao titular
- Comunicar mudanças materiais aos titulares ativos (e-mail/in-app)

## ⏸ CHECKPOINT obrigatório

**NUNCA publique sem revisão jurídica.** Após produzir a versão draft:
1. Salve em `.lgpd/policies/privacy-policy-v{N}-draft.md`
2. Notifique o usuário e pause
3. Aguarde aprovação explícita antes de mover para `v{N}.md` (versão final)

## Status update

```markdown
## F4 — Privacy policy ✓
- v{N} draft em `.lgpd/policies/privacy-policy-v{N}-draft.md`
- Aguardando revisão jurídica
- Próximo (pós-aprovação): saas-lgpd-dsar
```
