---
name: saas-seo-schema
description: "Detect, validate, and generate Schema.org JSON-LD structured data for SaaS applications — SoftwareApplication, WebApplication, Organization, Product, Offer, BreadcrumbList, and QAPage."
argument-hint: "[url or generate]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-schema/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Schema.org Structured Data for SaaS

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Detects, validates, and authors Schema.org JSON-LD markup optimized for SaaS products, rich results in search engines, and entity resolution in AI answer engines.

---

## 1. Supported Schema Types (2026 Standards)

### ACTIVE (Recommended for SaaS):
- `SoftwareApplication` / `WebApplication`: Core for SaaS platforms (name, applicationCategory, operatingSystem, offers, aggregateRating).
- `Organization`: Company identity, logo, social profiles (`sameAs`), founder, contact points.
- `WebSite`: SearchAction for site search, publisher, name.
- `Product` & `Offer`: Subscription pricing tiers, trial periods, currency, billing frequencies.
- `BreadcrumbList`: Navigation hierarchy.
- `QAPage`: Genuine user Q&A forums (distinct from retired FAQPage).
- `ProfilePage` & `Person`: Author authority and founder credentials for E-E-A-T.

### RETIRED / DEPRECATED (Do NOT recommend for rich results):
- `FAQPage`: Retired for Google Search rich results on May 7, 2026. Keep existing markup as Info only, never count on rich snippet accordions.
- `HowTo`: Retired September 2023.
- `SpecialAnnouncement`, `CourseInfo`, `EstimatedSalary`: Retired 2025.

---

## 2. Server-Rendered React Server Component Pattern

In Next.js 14+ App Router, structured data should be rendered server-side so bots crawling without full JS execution index entities immediately:

```tsx
// components/seo/SoftwareSchema.tsx
import React from 'react';

interface SoftwareSchemaProps {
  name: string;
  description: string;
  price: string;
  currency?: string;
  ratingValue?: string;
  reviewCount?: string;
}

export function SoftwareSchema({
  name,
  description,
  price,
  currency = 'USD',
  ratingValue = '4.9',
  reviewCount = '120',
}: SoftwareSchemaProps) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name,
    description,
    applicationCategory: 'BusinessApplication',
    operatingSystem: 'Cloud',
    offers: {
      '@type': 'Offer',
      price,
      priceCurrency: currency,
      availability: 'https://schema.org/InStock',
    },
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue,
      reviewCount,
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  );
}
```

---

## 3. Tool Execution

```bash
python scripts/seo/parse_html.py <url> --json
python scripts/seo/schema_generate.py profile --script-tag
```
