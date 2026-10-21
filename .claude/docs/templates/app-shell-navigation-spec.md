# App Shell & Global Navigation Spec

> Authoring guidance: `.claude/skills/saas-ux-design/references/sections-app-shell.md` (App Shell & Navigation guidance).

> **Status**: [In Design | In Review | Approved | Implemented]
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Product**: [Product name — single application navigation & app shell spec]
> **Platform Targets**: [Web desktop, responsive mobile/tablet, progressive web app]
> **Related PRDs**: [Every feature module that exposes information through the App Shell — e.g., `design/prd/billing.md`, `design/prd/dashboard.md`, `design/prd/team-rbac.md`]
> **Accessibility Tier**: Basic (WCAG 2.2 A) | Standard (WCAG 2.2 AA) | Comprehensive (WCAG 2.2 AAA) | Exemplary
> **Style Reference**: [Link to design tokens / semantic UI spec — e.g., `design/ui/design-tokens.md § 7. Navigation & App Shell Tokens`]
> **Template**: App Shell & Global Navigation Spec

> **Note — Scope boundary**: This document specifies all persistent shell and navigational elements
> that frame the SaaS application: Sidebar, Topbar, Global Navigation, Command Palette (Cmd+K),
> Breadcrumbs, Notification Center, User/Tenant Switcher, and Toast alerts. For full-page screen layouts,
> multi-step flows, data tables, and settings forms, use `ux-spec.md` instead.
> The test: if it persists across different routes and defines the frame of the app, it belongs here.

---

## 1. Navigation Philosophy

[To be designed]

**What is this SaaS application's relationship with on-screen information?**

[One-paragraph design statement — framing examples below]

**Framing examples**:
- *Minimalist / Focused*: Unobstructed canvas, content-first, navigation collapses to minimize distraction (e.g., Linear, Notion, iA Writer).
- *Dense / Pro-workspace*: Multi-pane workspace, always-visible metrics, rapid keyboard switching, high information density (e.g., Bloomberg, Datadog, AWS Console).
- *Contextual / Progressive Disclosure*: Primary controls visible; secondary and contextual actions revealed on selection or hover (e.g., Figma, Stripe Dashboard).
- *Modular / Tabular*: Clear hierarchical categories, expandable tree/group navigation with persistent status topbar (e.g., Jira, Salesforce).

**Visibility principle** — when in doubt, show or hide?

[Default resolution for ambiguous cases: HIDE / SHOW / CONTEXTUAL]

**The Rule of Necessity for this SaaS application**:

["An App Shell element earns its persistent place when ______________." — e.g., "when users need to reference it across at least 3 distinct daily workflows without clicking away"]

---

## 2. Information Architecture

> Categorize EVERY piece of global information the SaaS application displays — this is the master
> registry of global UI signals.

### 2.1 Full Information Registry

| Info Item | Source System | Update Frequency | User Decision Dependent on It | Criticality (1–5) |
|---|---|---|---|---|
| Active Workspace / Tenant | Multi-tenancy | On switch | Confirms data context before mutations | 5 |
| User Profile & Plan Status | Billing & Auth | On session load / billing webhook | Informs feature limits & access tier | 4 |
| Breadcrumb Trail | Router | On navigation | Locates position in resource hierarchy | 3 |
| Global Search / Command Bar | Indexer / Router | On shortcut (Cmd+K) | Immediate navigation to any entity | 5 |
| Notification Badge Counter | Activity / Webhook | Real-time (WebSocket / SSE) | Informs user of unread alerts / approvals | 4 |
| Background Task / Sync Status | Queue Worker | Real-time / Polling | Shows ongoing export / import progress | 3 |
| System Health / Offline Banner | Network / Healthcheck | Real-time | Warns of degraded service or offline state | 5 |

### 2.2 Categorization

- **Persistent**: Always visible on screen in standard viewport (e.g., primary navigation links, active tenant, search trigger).
- **Contextual**: Appears only when relevant context is active (e.g., bulk action bar when rows selected, unsaved changes banner).
- **On-demand**: User requests it via shortcut or click (e.g., Command Palette Cmd+K, Help drawer, Keyboard shortcuts quick reference modal).
- **Transient**: Appears automatically, signals an event, disappears (e.g., Toast notifications, copy-to-clipboard pill).

---

## 3. Layout Zones

### 3.1 Zone Diagram

```
+------------------------------------------------------------------------------------+
| Topbar (Global Search Cmd+K, Workspace Switcher, Notifications, User Menu)        |
+-------------------+--------------------------------------------+-------------------+
| Primary Sidebar   | Main Content Viewport                      | Contextual Drawer |
| (Nav Links,       | (Page Header, Breadcrumbs, Views, Tables)  | (Entity Details,  |
|  Projects,        |                                            |  Filters,         |
|  Settings)        |                                            |  Activity Feed)   |
|                   |                                            |                   |
+-------------------+--------------------------------------------+-------------------+
| System Status & Quick Help (Footer / Collapsible Bar)                              |
+------------------------------------------------------------------------------------+
| Floating Toasts & Alerts (Bottom-Right or Top-Center viewport anchor)              |
+------------------------------------------------------------------------------------+
```

### 3.2 Zone Specification Table

| Zone | Screen Position | Default Anchor | Responsive Behavior | Max Visual Weight (%) |
|---|---|---|---|---|
| Topbar | Top (y: 0, full width) | Fixed / Sticky | Persistent on desktop; simplified on mobile | 8% screen height |
| Primary Sidebar | Left (x: 0, below topbar) | Fixed / Sticky | 240px expanded; 64px icon rail; modal drawer <768px | 16% screen width |
| Main Viewport | Center | Fluid | Fluid layout (min-width: 320px, max-width: 1600px) | 70–80% screen area |
| Contextual Drawer | Right (anchored right) | Slide-over / Sticky | Hidden by default; pushes or overlays on trigger | 320–400px width |
| Notification Toasts | Bottom-right / Top-center | Fixed viewport | Stacked vertically, max 3 visible, auto-dismiss | Overlay floating |

---

## 4. App Shell Element Specifications

### 4.1 Element Overview Table

| Element Name | Zone | Persistence | Information Conveyed | Interaction |
|---|---|---|---|---|
| Tenant Switcher | Sidebar Top / Topbar | Persistent | Current organization / project context | Dropdown to switch or create tenant |
| Global Search Bar | Topbar Center | Persistent | Search input trigger with `⌘K` badge | Opens Command Palette modal |
| Primary Nav List | Sidebar Body | Persistent | Core application sections (Dashboard, Analytics, Users, Billing) | Route transition, active link highlight |
| Notification Bell | Topbar Right | Persistent | Unread count badge (dot or counter) | Opens Notification Drawer |
| User Avatar Menu | Topbar Right / Sidebar Bottom | Persistent | User name, email, avatar, role | Dropdown: Profile, Settings, Sign Out |
| Breadcrumb Bar | Viewport Header | Persistent | Route ancestry (`Org > Projects > Billing`) | Clickable parent nodes |
| Toast Container | Viewport Bottom-Right | Transient | Success / Error / Progress notifications | Click to view, dismiss button, auto-timer |

### 4.2 Element Detail Blocks

#### `[Element 1: Command Palette (Cmd+K)]`
- **Visual Design**: Centered modal overlay (`backdrop-blur-sm`, `bg-popover`), max-width 640px, rounded-xl border.
- **Trigger**: Shortcut `Cmd+K` (macOS) / `Ctrl+K` (Windows/Linux) or clicking Topbar search input.
- **Search Capabilities**: Instant fuzzy search across routes, entities (customers, invoices, projects), and quick actions (e.g. "Create API key", "Invite user").
- **States**: Empty recent searches, typing query, loading results, grouped results (Navigation, Actions, Resources), no results state.

#### `[Element 2: Workspace & Tenant Switcher]`
- **Visual Design**: Combobox button with organization logo, tenant name, plan badge (`Pro`, `Enterprise`), chevron.
- **Behavior**: Single-click opens dropdown list of available tenants, search input, "Add new organization" CTA.
- **Security Check**: Changing tenant triggers clean route re-fetch with active `tenant_id` context.

#### `[Element 3: Toast Notification System]`
- **Visual Design**: Floating card (`bg-card`, border, shadow-lg, status icon: CheckCircle, AlertTriangle, XCircle, Info).
- **Durations**: Success: 4000ms; Info: 5000ms; Warning: 8000ms; Error: Persistent until user dismissal.
- **Accessibility**: Announced via `role="status"` or `role="alert"` (`aria-live="polite"` or `"assertive"`).

---

## 5. Navigation & App Shell States by Application Context

| Application Context | Sidebar State | Topbar State | Breadcrumbs | Contextual Actions |
|---|---|---|---|---|
| Standard App Route | Expanded / Collapsed by user | Standard full | Visible | Page-specific actions |
| Focus / Editing Mode (e.g. Form, Canvas) | Collapsed / Hidden | Minimal (Back button + Save/Publish) | Simplified | Save, Discard, Preview |
| Onboarding Wizard | Hidden | Progress indicator only | Hidden | Next, Back, Skip |
| Multi-Tenant Switch / Organization Invite | Disabled / Loading overlay | Minimal | Hidden | Accept, Decline |
| Admin / Impersonation Mode | Banner warning at top | Amber background tint | Visible | "Exit Impersonation" persistent pill |
| Offline / Network Reconnecting | Standard | Offline amber/red banner | Standard | Reconnect retry button |

---

## 6. Information Hierarchy

1. **Urgent Alerts**: System downtime, billing expiration, payment failure (Top persistent alert banner).
2. **Primary Navigation**: Main route switching (Sidebar links).
3. **Workspace Context**: Active tenant and active user identity.
4. **Current Route Position**: Breadcrumbs and page header.
5. **Contextual Tools**: Filter rail, search bar, sort toggles.
6. **Transient Feedback**: Toast notifications and badge updates.

---

## 7. Visual Budget & Performance

- **Layout Shift (CLS)**: Zero cumulative layout shift on page load; sidebar width reserved via CSS variables.
- **Render Cost**: Topbar and Sidebar components memoized to avoid re-rendering during child page mutations.
- **Bundle Weight**: Navigation shell JavaScript footprint < 30KB gzipped.
- **Animation Performance**: Sidebar transition and Drawer slide-over use hardware-accelerated CSS `transform` and `opacity` (60fps guaranteed).

---

## 8. Feedback & Notification Systems

| Channel | Trigger | Presentation | Sound / Audio Alert | Persistence |
|---|---|---|---|---|
| Inline Field Error | Form validation | Red text below input + icon | None | Until field corrected |
| Toast Notification | Action completed (e.g. "Saved") | Bottom-right card | Optional subtle chime | Auto-dismiss (4s) |
| Notification Drawer | Background event (invite, comment) | Unread badge + slide drawer | Optional ping | User marks as read |
| Global Top Banner | System event (card expired, outage) | Full-width sticky banner | None | Until resolved |

---

## 9. Platform & Viewport Adaptation

| Breakpoint | Viewport Range | Sidebar Layout | Topbar Layout | Mobile Navigation |
|---|---|---|---|---|
| Desktop Wide | 1440px+ | 260px expanded | Full search + actions | N/A |
| Desktop Standard | 1024px – 1439px | 220px expanded or 64px icon rail | Full search + actions | N/A |
| Tablet | 768px – 1023px | 64px icon rail (collapsible) | Compact search icon | Slide-over drawer on menu tap |
| Mobile | < 768px | Hidden (Hamburger trigger) | Logo + Search icon + User avatar | Bottom nav bar (4 primary items) + Drawer |

---

## 10. Accessibility (WCAG 2.2 AA / AAA Compliance)

### 10.1 Keyboard Navigation & Focus Management
- Global skip link (`Skip to main content`) as first focusable element.
- Logical tab order: Topbar -> Sidebar -> Main Viewport -> Contextual Panel.
- `Escape` key closes Command Palette, Dropdowns, and slide-over Drawers.
- Visible focus rings (`focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2`).

### 10.2 Color Contrast & Theming
- Minimum 4.5:1 text-to-background contrast in both Light and Dark themes.
- Information never conveyed by color alone: icons and text labels accompany all status badges.

### 10.3 Reduced Motion
- All transitions respect `@media (prefers-reduced-motion: reduce)` by disabling slide/expand animations and using instant opacity toggles.

### 10.4 Screen Reader Landmarks
- Sidebar: `<nav aria-label="Main Navigation">`
- Topbar: `<header role="banner">`
- Main: `<main id="main-content" tabIndex="-1">`
- Breadcrumbs: `<nav aria-label="Breadcrumb">`
- Notifications: `<aside aria-label="Notifications" aria-live="polite">`

---

## 11. Configurable Parameters & Responsive Thresholds

| Parameter Name | Default Value | Configurable Range | Storage Location |
|---|---|---|---|
| `sidebar_collapsed_default` | `false` | `true` / `false` | LocalStorage / User preferences DB |
| `theme_mode` | `system` | `light` / `dark` / `system` | LocalStorage / Cookie |
| `toast_duration_ms` | `4000` | `2000` – `10000` | Frontend constants |
| `command_palette_max_results` | `10` | `5` – `25` | Client UI state |

---

## 12. Acceptance Criteria

- [ ] App Shell renders cleanly across all supported breakpoints (320px to 2560px).
- [ ] Keyboard navigation allows 100% operation without mouse input.
- [ ] Command Palette opens reliably with `Cmd+K` / `Ctrl+K` and executes navigation.
- [ ] Active route is visually distinct in the sidebar with `aria-current="page"`.
- [ ] Cumulative Layout Shift (CLS) on initial load is less than 0.05.
- [ ] Tenant switching immediately updates application state and re-scopes query caches.

---

## 13. Open Questions

1. [Question 1: Should the sidebar default to collapsed on smaller laptop screens (e.g. 13" 1280px)?]
2. [Question 2: Does the Notification Center require real-time WebSocket push or is 30s background polling sufficient for MVP?]
