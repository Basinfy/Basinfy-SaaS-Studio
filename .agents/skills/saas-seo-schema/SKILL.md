---
name: saas-seo-schema
description: "Validate and generate Schema.org JSON-LD (`SoftwareApplication`, `Organization`, `Offer`)."
argument-hint: "[url or generate]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# Schema.org Structured Data for SaaS

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


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
