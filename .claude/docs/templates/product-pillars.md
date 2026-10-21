# Product Pillars: [Product Name]

## Document Status
- **Version**: 1.0
- **Last Updated**: [YYYY-MM-DD]
- **Approved By**: `product-director`
- **Status**: [Draft | Under Review | Approved]

---

## What Are SaaS Product Pillars?

Product pillars are the 3 to 5 non-negotiable strategic principles that define this SaaS application's identity and guide every technical, design, marketing, and business decision.

If a proposed feature, architecture choice, or UI element contradicts a pillar, it does not belong in the product.

### Criteria of an Effective Product Pillar
1. **Actionable & Decisive**: A good pillar helps the team choose between two desirable attributes (e.g. "Instantaneous Local-First Latency" over "Complex Cloud-Side Transformations").
2. **Constraining**: If a pillar never forces you to say "no" to a feature request, it is too vague. Good pillars kill distractions.
3. **Cross-Functional**: A true pillar shapes engineering architecture, UX interactions, pricing strategy, and documentation alike.
4. **Memorable**: The team should be able to state the pillars from memory during design reviews and sprint planning.

---

## SaaS Industry Reference Benchmarks

| Product | Benchmark Pillars | Strategic Trade-Off Enforced |
|---|---|---|
| **Linear** | Uncompromising Speed; Keyboard-First Navigation; Opinionated Workflows | Sacrificed infinite customization in favor of sub-50ms interactions and strict agile discipline. |
| **Stripe** | Developer Joy & Ergonomics; Five-Nines Reliability; Backward Compatibility | Extreme investment in SDKs, documentation, and zero-breaking-change API versioning. |
| **Notion** | Lego-Block Modularity; Canvas Simplicity; Universal Information Architecture | Replaced rigid databases and docs with modular nesting blocks that work across devices. |
| **Figma** | Collaborative Real-Time by Default; Browser-Native WebAssembly; Zero Sync Steps | Sacrificed desktop OS native widgets to build pure WebGL/Wasm canvas running inside the browser. |
| **Supabase** | Open-Source Postgres Standards; Zero Proprietary Lock-In; Instant Developer Velocity | Avoided proprietary black-box database primitives in favor of standard SQL and Postgres extensions. |

---

## Core Product Pillars for [Product Name]

### Pillar 1: [e.g., Time-To-Value & Radical Simplicity]
- **Core Principle**: "A user must achieve their first meaningful business outcome within 3 minutes of signup without reading documentation."
- **What It Dictates**: Zero-config smart defaults, wizard-free onboarding, streamlined 1-click integrations.
- **What It Forbids**: Lengthy required form fields, mandatory sales calls for trials, complex upfront multi-step configurations.
- **Decision Test**: "Does this addition increase or decrease the time to first value?"

### Pillar 2: [e.g., Enterprise-Grade Reliability & Tenant Isolation]
- **Core Principle**: "Data isolation and high availability are non-negotiable prerequisites, not post-launch add-ons."
- **What It Dictates**: Strict Postgres Row Level Security, idempotent event webhooks, automated backups, and 99.9% uptime SLA.
- **What It Forbids**: Cross-tenant data leakage risks, unindexed database queries, single points of failure in background queues.
- **Decision Test**: "Can this component fail without impacting tenant data integrity or availability?"

### Pillar 3: [e.g., Transparent Value-Based Pricing]
- **Core Principle**: "Pricing directly scales with the demonstrable business value delivered to the customer."
- **What It Dictates**: Clear usage tiers, self-serve upgrades, no hidden feature paywalls on basic security or exports.
- **What It Forbids**: Dark patterns, surprise auto-renewals with penalties, artificially throttling essential compliance features.
- **Decision Test**: "Does the customer clearly understand why their bill increases as their usage grows?"

### Pillar 4: [e.g., Keyboard-First Productivity & Fluid UX]
- **Core Principle**: "Power users can operate the entire platform without touching a mouse."
- **What It Dictates**: Command menu (`Cmd+K`), comprehensive shortcut map, instant optimistic UI updates.
- **What It Forbids**: Slow loading spinners on internal navigations, dialogs with trap focus, hidden navigation links.
- **Decision Test**: "Can a user execute the primary workflow using keyboard commands alone?"
