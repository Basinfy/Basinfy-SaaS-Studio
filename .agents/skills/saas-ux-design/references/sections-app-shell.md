> Section-authoring guidance, loaded by `/saas-ux-design` for the ACTIVE MODE ONLY.
> Never load the other two — one mode applies per invocation.

# Section Guidance — App Shell & Global Navigation Mode

**In this file:**

- Section A: Navigation & App Shell Philosophy
- Section B: Information Architecture & Global Signals
- Section C: Layout Zones
- Section D: Shell & Navigation Element Specifications
- Sections E–L: Shell States, Information Hierarchy, Visual & DOM Budget, Feedback & Notification Systems, Responsive Breakpoints, Accessibility, User Preferences & Settings, Acceptance Criteria

App shell and navigation design follows a different order from page-level UX spec mode.
Begin with navigation philosophy; do not touch layout until the information architecture is complete.

---

#### Section A: Navigation Philosophy

Ask the user to describe the SaaS application's relationship with on-screen global navigation in
1-2 sentences.

Offer framing examples to help:
- "Minimalist & Focused — workspace-first, navigation collapses to minimize distraction (e.g., Linear, Notion, Superhuman)"
- "Dense & Pro-workspace — multi-pane workspace, always-visible metrics, rapid keyboard switching (e.g., Bloomberg, Datadog, AWS Console)"
- "Contextual & Progressive Disclosure — primary controls visible; secondary actions revealed on selection or hover (e.g., Figma, Stripe Dashboard)"
- "Modular & Tabular — expandable tree/group navigation with persistent status topbar (e.g., Jira, Shopify Admin)"

This philosophy becomes the design constraint for every subsequent navigation decision.
If a proposed element conflicts with the stated philosophy, surface that conflict.

---

#### Section B: Information Architecture

Complete this before any layout work. Do not skip it.

**Step 1 — Full information registry**:
Pull all information from PRD UI & Global Requirements sections gathered in Phase 2.
Present the full list: "These are all the global signals and navigational anchors your SaaS application
needs to communicate to the user across routes."

**Step 2 — Categorization**:
For each item, categorize it:

| Category | Description |
|---|---|
| **Persistent** | Always visible, user needs it for core navigation (Sidebar, Topbar, Tenant context) |
| **Contextual** | Visible only when relevant (Bulk action bar when rows are selected, unsaved changes banner) |
| **On Demand** | User must actively request it (Command Palette `Cmd+K`, keyboard shortcut sheet, filter rail) |
| **Transient** | Appears automatically on an event, then dismisses (Toast alert, copy-to-clipboard pill) |

Use `AskUserQuestion` to step through items in groups of 3-4, not all at once.
This is the most consequential design decision in the app shell — do not rush it.

**Conflict check**: If the philosophy (Section A) says "minimalist & focused"
but the persistent list is growing long, surface the conflict explicitly:
> "The current Persistent list has [N] items. That may conflict with the minimalist
> philosophy. Options: collapse secondary items into a `Cmd+K` command menu, use progressive
> disclosure on hover, or group items into collapsible sidebar sections."

---

#### Section C: Layout Zones

Only after the information architecture is approved, design layout zones.

Base layout on:
- Which items are Persistent (they drive the permanent zone decisions)
- Natural user scanning patterns (F-pattern for web dashboards, left-to-right hierarchy)
- Responsive target viewports (Desktop wide 1440px+, Desktop standard 1024px, Tablet 768px, Mobile <768px)

Offer 2-3 zone arrangements (e.g., Vertical Sidebar + Slim Header vs. Top Bar Navigation + Secondary Left Rail).
Include rationale based on the philosophy and categorization from Section B.

---

#### Section D: App Shell Element Specifications

For each element in the layout, specify:
- Element name and category (Persistent / Contextual / On Demand / Transient)
- Content and status displayed
- Visual form (nav link with icon, combobox switcher, badge counter, search input, toast container)
- Update behavior (instant route transition, optimistic UI update, WebSocket push, background polling)
- Contextual trigger (if not always visible)
- Animation behavior (sidebar collapse transition, drawer slide-over, toast entry/exit)

Work element by element. Reference the design system tokens for spacing, typography, and colors.

---

#### Sections E–L: Shell States, Information Hierarchy, Visual Budget, Feedback & Notification, Platform Adaptation, Accessibility, User Preferences & Settings, Acceptance Criteria

These parallel the UX spec's States, Interaction, and Accessibility sections.
The guidance you need is below — **do not load `sections-ux-spec.md`; one mode
file applies per invocation.**

**App Shell States by Application Context.** Cover at least:
standard route, focus/editing mode, onboarding wizard, multi-tenant switch, admin/impersonation mode, and offline/reconnecting state — `/saas-ux-review` checks for these contexts.
Beyond the happy path, capture what changes the shell state and present it as a table for approval:

| State / Variant | Trigger | What Changes |
|---|---|---|
| Default Workspace | Normal authenticated session | Full sidebar, topbar, active route highlight |
| Focus / Canvas Mode | User enters form/editor | Sidebar collapses to 0px, topbar simplifies to Back + Save |
| Impersonation Mode | Admin logs in as customer | Prominent amber top banner, "Exit Impersonation" action |
| Offline / Degraded | Network disconnects | Non-blocking amber/red toast or banner with reconnect button |

**Information Hierarchy.** Give every persistent element a priority tier —
MUST KEEP, SHOULD KEEP, CAN HIDE or ALWAYS HIDE — with the reason, and what carries
its functionality when hidden (e.g. folded into `Cmd+K` command palette or mobile drawer).

**Visual & DOM Budget.** State the maximum cumulative layout shift (CLS target < 0.05),
navigation JavaScript bundle size budget (< 30KB gzipped), and memoization rules to prevent
rerendering the app shell during child view mutations.

**Feedback & Notification Systems.** One row per transient notification type
(Toast, In-app Banner, Notification Drawer item, Modal confirm) — trigger system, screen position,
duration, max simultaneous, priority, and **queue behavior** (what happens when 3 toasts trigger at once).
`/saas-ux-review` checks that every notification has queue/priority behavior defined.

**Platform & Viewport Adaptation.** Specify responsive layout overrides:
Desktop (expanded sidebar), Tablet (compact icon rail), Mobile (hamburger drawer + bottom tab bar for 4 top tasks).

**Accessibility (WCAG 2.2 AA).** Checklist for the app shell:
- Keyboard navigation: Global skip link (`Skip to main content`), logical tab order.
- Escape key listener to close Command Palette, dropdowns, and slide-over drawers.
- Focus traps inside open modals and command palettes.
- Text contrast: minimum 4.5:1 for all navigational labels.
- Color independence: Status indicators must use icons or text alongside colors.
- Reduced motion: Respect `@media (prefers-reduced-motion: reduce)` for transitions.
- Screen reader landmarks: `<nav>`, `<header>`, `<main>`, `<aside>`.

**User Preferences & Settings.** List user-adjustable shell settings:
theme mode (light/dark/system), default sidebar state (expanded/collapsed), density (compact/comfortable).

**Acceptance Criteria.** At least 5 checkbox criteria a QA engineer can verify
without reading another document — `/saas-story-done` closes shell stories against them.
Cover at least: responsive rendering across breakpoints, full keyboard operability (`Cmd+K`, Tab, Esc),
zero layout shift on load, WCAG contrast compliance, and notification queueing.
Section 12 of `.claude/docs/templates/app-shell-navigation-spec.md` has worked examples.
