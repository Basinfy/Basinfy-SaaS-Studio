# Full Concept Flow (`workflow: standard` or `full`)

**In this file:** Start · Phase 1 Product Discovery · Phase 2 Concept & Positioning · Phase 3 Core SaaS Workflows · Phase 4 Pillars & Boundaries · Phase 5 ICP & Personas · Phase 6 Scope & Technical Feasibility · Phase 7 Write the Product Concept · Phase 8 Next Steps

The output is `design/prd/product-concept.md`, written from `.claude/docs/templates/product-concept.md`. Ask at each phase; never generate the whole concept silently. You facilitate, the user decides.

## Start

1. The text typed after the skill name may hold an industry or category hint (`b2b-fintech`, `dev-tools`, `ai-crm`, `workflow-automation`). `open` or nothing: start from scratch.
2. If `design/prd/product-concept.md` or `design/prd/product-pillars.md` exists, read it by section and resume or build on it instead of restarting.

## Phase 1: Product Discovery & Customer Pain

Start with the customer and the market pain:
- The exact customer pain point: what manual friction, wasted hours, or compliance risk do they experience today?
- The current alternatives: spreadsheets, internal scripts, or legacy enterprise software.
- What makes incumbent solutions fail: why do users abandon them or seek alternatives (slow UI, rigid pricing, lack of APIs)?
- Timeline and launch goal: target time to market (e.g. 4-week MVP, 12-week GA).

Sum the answers up as a **Product Opportunity Brief** (3 to 5 sentences), read it back and confirm it.

## Phase 2: Concept Generation & Competitive Positioning (Standard Engineering SOP)

Generate **three** distinct SaaS concepts from the brief, each with:
- **Working Title** & **Elevator Pitch** (1-2 sentences: "For [ICP] who [pain point], [Product] is a [category] that [outcome], unlike [alternative].")
- **The Core Value Action / "Aha!" Moment**: the specific user interaction where instant value is unlocked.
- **Unfair Advantage / Differentiator**: why this is 10x faster, cheaper, or easier to adopt.
- **Estimated Scope & Launch Horizon** (Small / Medium / Large).

### Competitive Analysis Matrix
Draft a structured comparison table evaluating 2-3 direct competitors and 1 status-quo alternative:
| Competitor | Core Strengths | Critical Weaknesses / Gaps | Pricing Model | Our Strategic Differentiator |
|---|---|---|---|---|
| Incumbent A | [Breadth] | [Complex setup, high price] | [\$150/user/mo] | [Instant onboarding, modern UX] |
| Point Tool B | [Single feature] | [No integrations, no API] | [\$29/mo] | [Full-stack workflow, webhooks] |
| Spreadsheets | [Free, familiar] | [Manual, unscalable] | [\$0] | [Automated, audit-trailed] |

### Competitive Positioning Quadrant (2x2 Matrix)
Draft a Mermaid `quadrantChart` mapping market positioning:
- X-axis: "High Complexity / Slow Setup" --> "Low Friction / Instant Value"
- Y-axis: "Niche Feature Depth" --> "Comprehensive Platform Power"
- Show where competitors sit and where our product dominates (Quadrant 1).

Present all three concepts and positioning, then ask: "Which concept resonates with you? You can pick one, combine elements, or request fresh directions."

## Phase 3: Core SaaS Workflows & Retention Loops

For the chosen concept, define the user journey:
1. **Onboarding & First Value (< 3 minutes)**: self-serve signup, tenant provisioning, instant "Aha!" moment.
2. **Daily / Weekly Retention Loop**: dashboards, automated alerts, periodic batch actions, team collaboration.
3. **Monetization & Expansion Loop**: free-tier limit reached, self-serve Stripe checkout, seat expansion, plan upgrade.

## Phase 4: Product Pillars & Non-Negotiables

Draft **3 to 5 product pillars**, each with a name, one-sentence definition, and a design test ("When debating X or Y, this pillar picks __").
Add **3 or more anti-pillars**: "We will NOT do [thing] because it would compromise [pillar]."

## Phase 5: Ideal Customer Profile (ICP) & Target Personas

Define the buying and usage personas:
- **Economic Buyer**: VP/Director who signs off on budget and security compliance.
- **Primary Operator**: Day-to-day power user who executes workflows and demands speed.
- **Collaborator / Viewer**: Stakeholders who review reports, dashboards, or audits.

## Phase 6: Scope Tiers & Technical Feasibility

- **Delivery Stack**: Next.js (App Router), FastAPI, Cloudflare Workers, or Go microservices.
- **Database & Multitenancy**: PostgreSQL with Row-Level Security (RLS) and connection pooling.
- **Scope Tiers (P0 / P1 / P2)**:
  - **P0 (MVP Launch Blocker)**: core value loop, auth, tenant workspace, self-serve Stripe billing, production deployment.
  - **P1 (Beta Fast-Follow)**: team invites, role-based access control (RBAC), integrations (Slack, Zapier), usage analytics.
  - **P2 (Enterprise Scale)**: SSO (SAML/Okta), audit logging, custom tenant domains, dedicated compliance certifications.

## Phase 7: Write the Concept Document

Write the full document to `design/prd/product-concept.md` adhering to the template format.

## Phase 8: Next Steps
1. `/saas-setup-stack`: pin stack version and reference documentation.
2. `/saas-map-features`: map system features and create systems index.
3. `/saas-design-system`: author PRDs for each core module.
4. `/saas-create-architecture`: author system architecture blueprint and ADRs.
5. `/saas-create-stories`: generate implementation-ready stories sorted by topological dependencies.
6. `/saas-dev-story`: build and test stories with autonomous reflection.
