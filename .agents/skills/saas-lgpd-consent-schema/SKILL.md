---
name: saas-lgpd-consent-schema
description: "Design append-only versioned Prisma consent ledgers and auth hooks (LGPD Art. 8 & 9)."
argument-hint: "[scope or artifact path]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

# Consent Schema (Prisma + Better Auth)

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.



Implementação técnica do consentimento como base legal (Art. 7º, I e Art. 11, I), versionado, auditável e revogável.

## Princípios

1. **Append-only** — nunca update destrutivo. Revogar = inserir novo registro com `status=REVOKED`.
2. **Versionado pela política** — todo consentimento aponta para uma versão específica do texto consentido.
3. **Específico por finalidade** — uma entrada por (titular, finalidade, versão da política).
4. **Evidência forte** — hash do payload (timestamp, IP, user-agent, UI snapshot).
5. **Revogação fácil** — Art. 8º, § 5º: "O consentimento pode ser revogado a qualquer momento mediante manifestação expressa do titular, por procedimento gratuito e facilitado."

## Schema Prisma de referência

Ver `assets/consent-schema.prisma`.

## Integração com Better Auth

Better Auth permite adicionar campos custom e hooks `beforeCreate`. Use para:

```ts
// auth.ts
export const auth = betterAuth({
  database: prismaAdapter(db, { provider: "postgresql" }),
  user: {
    additionalFields: {
      dateOfBirth: { type: "date", required: true }, // ECA Digital
      parentalConsentRef: { type: "string", required: false },
    }
  },
  hooks: {
    user: {
      create: {
        before: async (user, ctx) => {
          // 1. Validar idade (ECA Digital se aplicável)
          // 2. Não criar registro de consentimento aqui — fazer em /api/consent/grant
          //    porque consentimento exige UX dedicada (não pode ser "enterrado" no signup)
          return user;
        }
      }
    }
  }
});
```

## Captura de consentimento na UI

Princípios:
- **Não pré-marcar** caixas (Art. 8º, § 4º — manifestação livre).
- **Granular por finalidade** — uma caixa por finalidade, não "concordo com tudo".
- **Linguagem clara** — leiga, sem juridiquês.
- **Link para política** — versão exata do texto consentido.
- **Idade** — se < 18, fluxo ECA Digital (ver `saas-lgpd-eca-digital-minors`).

Exemplo de payload do endpoint `/api/consent/grant`:

```json
{
  "userId": "usr_abc123",
  "policyVersionId": "policy_v3.2",
  "purposes": [
    { "purpose": "marketing_email", "granted": true },
    { "purpose": "personalization", "granted": false },
    { "purpose": "analytics", "granted": true }
  ],
  "evidence": {
    "ip": "192.0.2.1",
    "userAgent": "...",
    "locale": "pt-BR",
    "channel": "web",
    "uiSnapshotHash": "sha256:..."
  }
}
```

## Revogação

Endpoint `/api/consent/revoke`:

```ts
async function revokeConsent(userId: string, purpose: string) {
  // 1. Cria registro com status=REVOKED, revokedAt=now
  await prisma.consentRecord.create({
    data: {
      subjectId: userId,
      purpose,
      status: "REVOKED",
      revokedAt: new Date(),
      // ... mesma policyVersionId do consentimento ativo
    }
  });

  // 2. Propaga para operadores (Datadog, Mixpanel, etc.)
  await propagateRevocation(userId, purpose);

  // 3. Bloqueia tratamentos futuros
  await blockFuturePurpose(userId, purpose);
}
```

## Helper de query

```ts
// Verificar se titular consentiu uma finalidade específica
export async function hasActiveConsent(
  subjectId: string,
  purpose: string
): Promise<boolean> {
  const latest = await prisma.consentRecord.findFirst({
    where: { subjectId, purpose },
    orderBy: { grantedAt: "desc" }
  });
  return latest?.status === "GRANTED";
}
```

**Sempre use este helper antes de tratar dados em finalidade baseada em consentimento.**

## Versionamento de política

Toda mudança material no texto da política de privacidade = nova `PolicyVersion`. Consentimentos antigos **não migram automaticamente** — você precisa re-coletar para a nova versão se a mudança afetar finalidades existentes (Art. 8º, § 6º).

## Audit log

Cada operação (grant, revoke, propagate) deve gerar entrada em `AuditLogEntry` (skill `saas-lgpd-audit-logging`).

## Status update

```markdown
## F3 — Consent schema ✓
- Schema implementado em `prisma/schema.prisma`
- Endpoints: POST /api/consent/grant, POST /api/consent/revoke, GET /api/consent
- Better Auth hooks configurados
- Propagação para operadores: {lista}
- Próximo: saas-lgpd-privacy-policy
```
