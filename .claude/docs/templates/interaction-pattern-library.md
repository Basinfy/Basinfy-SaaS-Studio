# Interaction Pattern Library: [Project Name]

> **Status**: [Draft | In Review | Approved]
> **Owner**: [ux-designer / frontend-engineer]
> **Last Updated**: [YYYY-MM-DD]
> **Reference**: `.claude/skills/saas-ux-design/references/sections-patterns.md`

---

## 1. Global Interaction Standards

- **Primary Input**: Desktop Mouse & Keyboard, with responsive touch support across tablet and mobile viewports.
- **Keyboard Navigation**: Full keyboard accessibility (`Tab`, `Shift+Tab`, `Enter`, `Space`, `Escape`).
- **Focus Indicators**: 2px high-contrast focus ring (`focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2`).
- **Feedback Timing**: Hover transitions < 150ms; modal/drawer slide animations < 250ms with ease-out curve.

---

## 2. Core UI Component & Interaction Patterns

| Pattern Name | Category | Description | Primary Usage Context | Status |
|---|---|---|---|---|
| Filter & Search Bar | Input / Search | Text input with instant debounced filter, category chips, and clear action. | Data tables, customer lists, audit logs | Approved |
| Data Table & Pagination | Layout / Data | Responsive table with sticky header, sortable columns, row selection, and page controls. | Dashboard, invoices, user directory | Approved |
| Slide-over Drawer | Navigation / Context | Panel sliding from right viewport edge without unmounting underlying page state. | Entity details, edit forms, activity logs | Approved |
| Multi-step Wizard | Form / Progression | Segmented progress indicator with Step validation, Back, Next, and Save & Exit actions. | Onboarding flow, workspace setup | Approved |
| Command Palette (`Cmd+K`) | Navigation / Action | Global modal overlay for fuzzy-searching routes, resources, and instant actions. | Global app shell | Approved |
| Toast Notification | Feedback / Alert | Non-blocking floating card at bottom-right viewport with status icon and auto-dismiss. | Action confirmations, background job alerts | Approved |
| Status Badge / Pill | Feedback / Display | Compact tag with semantic color and text label (e.g., Active, Pending, Past Due, Failed). | Table status cells, billing plan chips | Approved |
| Empty State | Feedback / Action | Centered illustration, explanatory message, and single primary action CTA. | Empty tables, zero search results | Approved |
| Destructive Confirm Modal | Safety / Dialog | Centered modal requiring explicit confirmation (or typing resource name) before permanent deletion. | Delete project, revoke API key, cancel plan | Approved |

---

## 3. Pattern Specifications

### Pattern: Command Palette (`Cmd+K`)
- **Trigger**: Shortcut `Cmd+K` (Mac) / `Ctrl+K` (Windows/Linux) or clicking the topbar search bar.
- **Behavior**:
  - Focus is immediately trapped in the search input.
  - Arrow keys (`Up` / `Down`) navigate results.
  - `Enter` executes the selected item (route navigation or action trigger).
  - `Escape` dismisses the modal and restores focus to previous active element.
- **Grouping**: Results grouped by `Navigation`, `Quick Actions`, and `Recent Entities`.

### Pattern: Data Table with Filter Rail
- **Layout**: Toolbar with Search + Filter chips at top; Table in center; Pagination footer at bottom.
- **Selection**: Checkbox in header selects all rows on current page; Floating bulk action bar appears when rows > 0.
- **Empty & Loading**: Skeleton rows during query fetch; custom empty state when 0 records match filters.

### Pattern: Toast Notification Queue
- **Queueing**: Maximum 3 toasts visible simultaneously; older toasts slide down and fade out.
- **Timing**:
  - Success / Info: 4000ms auto-dismiss.
  - Warning: 7000ms auto-dismiss.
  - Error: Persistent until user clicks dismiss button `X`.
- **Accessibility**: Announced to screen readers using `aria-live="polite"` (success/info) or `aria-live="assertive"` (error).
