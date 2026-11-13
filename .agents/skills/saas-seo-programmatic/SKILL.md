---
name: saas-seo-programmatic
description: "Plan and audit programmatic SEO for SaaS applications — directory pages, integrations, templates, and calculators with strict thin-content safeguards (<40% unique content threshold)."
argument-hint: "[url or plan]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Programmatic SaaS SEO

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Architects and audits high-volume programmatic landing pages for SaaS products (integration directories, tool calculators, template libraries, industry use-cases).

---

## 1. Proven SaaS Programmatic Archetypes

1. **Integration Directory**: `/integrations/[slug]`
   - E.g. "Connect Basinfy with Slack", "Basinfy for GitHub".
   - Structured fields: Authentication protocol (OAuth/API key), supported webhooks, triggers, sync frequencies, code snippets.
2. **Tools & Calculators**: `/tools/[slug]`
   - Free interactive calculators solving specific pain points (e.g. "SaaS Runway Calculator", "Stripe Fee Estimator").
3. **Template Library**: `/templates/[slug]`
   - Ready-to-use workflows, dashboard setups, prompt packs, or SQL schemas.
4. **Glossary / Developer Reference**: `/glossary/[term]`
   - Authoritative definitions of industry-specific terms linking back to core product features.

---

## 2. Thin Content & Scaled Content Abuse Safeguards

To prevent Google manual actions (under the March 2024 / 2025 Scaled Content Abuse policy):

| Gate Metric | Threshold | Operational Action |
|---|---|---|
| **Unique Content Ratio** | `< 40%` | ⚠️ **FLAG & REWORK**: Reject "mad-libs" variable swapping |
| **Minimum Unique Content** | `< 30%` | 🛑 **HARD STOP**: Do not publish, risk of sitewide penalty |
| **Word Count Minimum** | `< 300 words` | ⚠️ **WARN**: Insufficient value, requires supplementary data |
| **Batch Release Size** | `50 - 100 pages` | Progressive rollout with 2-3 weeks indexing verification |
| **Unjustified Volume** | `500+ pages` | 🛑 **HARD STOP**: Requires explicit user confirmation |

### Standalone Value Rule:
Every generated programmatic page must pass the test: *"Would this page provide tangible standalone value to a human user even if no other pages in the directory existed?"*

---

## 3. Next.js 14+ Implementation Pattern

```typescript
// app/integrations/[slug]/page.tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { getIntegrationBySlug } from '@/lib/integrations';

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const item = await getIntegrationBySlug(params.slug);
  if (!item) return {};

  return {
    title: `${item.name} Integration for Basinfy | Automate Workflows`,
    description: `Connect ${item.name} with your cloud architecture in minutes. Webhooks, real-time sync, and enterprise security.`,
    alternates: {
      canonical: `https://example.com/integrations/${params.slug}`,
    },
  };
}
```
