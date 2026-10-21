# Phase 3: Choose Prototype Path

Choose the prototyping medium based on the core question being tested:

| SaaS Archetype / Question | Recommended Path | Rationale |
|---|---|---|
| User workflow, dashboard UI, form flow | **Interactive Web (HTML/React/Tailwind)** | Fastest feedback on UX and user clarity |
| AI pipeline, heavy processing, API integration | **API / Backend Proof of Concept** | Tests algorithmic viability and response latency |
| Pricing model, quota limits, tier economics | **Spreadsheet / Paper Simulation** | Verifies math and revenue model before touching code |

---

### Path A: Interactive Web Prototype (HTML / React / Tailwind)

**Best for**: User workflows, onboarding funnels, data visualization dashboards, form interactions, and layout responsiveness.

**Stack**:
- Standalone HTML + Tailwind CSS (via CDN) + vanilla JS / React.
- Runs instantly in any browser without build tooling (`double-click index.html`).
- Zero dependencies, easily shared via Vercel preview or static hosting.

---

### Path B: Backend / API Proof of Concept (Node.js / Python / FastAPI)

**Best for**: AI prompt chains, vector embeddings, third-party webhook ingestion, complex calculations, or background queue processing.

**Stack**:
- Lightweight script (`server.ts` or `main.py`).
- Tests technical feasibility and latency.

---

### Path C: Spreadsheets & Paper Simulation

**Best for**: Subscription pricing tiers, usage quotas, token consumption limits, and unit economics.

**Stack**:
- Calculation model or Markdown simulation table.
- 100% reversible, tests mathematical soundness before writing schema migrations.

---

### Selection Prompt

Present options to the user:
- `[A] Interactive Web prototype` — Frontend workflow, UI components, dashboard layout.
- `[B] Backend / API proof of concept` — Backend logic, AI pipeline, external API integration.
- `[C] Spreadsheet / Paper simulation` — Pricing math, quota limits, data model simulation.
