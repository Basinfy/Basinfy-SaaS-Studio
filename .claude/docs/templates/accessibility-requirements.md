# WCAG 2.2 AA Accessibility Specification & Requirements

> **Status**: [Draft | In Review | Approved]
> **Owner**: `design-system-director` / `lead-engineer`
> **Target Standard**: **WCAG 2.2 Level AA Compliance**
> **Last Updated**: [YYYY-MM-DD]
> **Links To**: `design/tokens/tokens.json`, `docs/specs/app-shell-navigation-spec.md`

---

## 1. Executive Summary

This specification enforces accessibility across all frontend interfaces, UI components, and design tokens in accordance with WCAG 2.2 Level AA. Accessibility is a first-class engineering requirement, ensuring full usability for users relying on keyboard navigation, screen readers, screen magnification, or reduced motion.

---

## 2. Principle 1: Perceivable

### 2.1 Non-Text Content (SC 1.1.1)
- All meaningful images and illustrations must have descriptive `alt` text.
- Decorative images must have `alt=""` or `aria-hidden="true"`.
- Icon-only interactive buttons (e.g. search, close, theme toggle) must include an `aria-label` or visually hidden screen reader text (`sr-only`).

### 2.2 Contrast & Distinguishability (SC 1.4.3 & 1.4.11)
- **Normal Text (< 18pt / 24px)**: Minimum contrast ratio of **4.5:1** against the background.
- **Large Text (≥ 18pt / 24px or bold ≥ 14pt / 18.66px)**: Minimum contrast ratio of **3:1**.
- **UI Components & Graphical Objects**: Minimum contrast ratio of **3:1** against adjacent colors (form input borders, focus rings, status badges).
- **Color Independence (SC 1.4.1)**: Color is never used as the sole method of conveying state. Form errors must include error icons and explicit text messages.

### 2.3 Reflow & Text Resizing (SC 1.4.4 & 1.4.10)
- Interfaces must zoom up to 200% without loss of content or functionality.
- Content must reflow smoothly down to a 320 CSS pixel width without horizontal scrolling.

---

## 3. Principle 2: Operable

### 3.1 Keyboard Accessibility & Focus Control (SC 2.1.1, 2.1.2 & 2.4.7)
- **100% Keyboard Operable**: All interactive controls (buttons, links, form inputs, dropdowns, tabs) must be reachable and operable using `Tab`, `Shift+Tab`, `Enter`, `Space`, `Escape`, and `Arrow` keys.
- **No Keyboard Traps**: Modal dialogs must trap focus within the modal while open, and release focus back to the triggering element upon `Escape` or close.
- **Visible Focus Indicator**: Focus rings must be clearly visible (minimum 2px outline with at least 3:1 contrast against background).
- **Skip Navigation**: A "Skip to main content" link must be the first focusable element on every page.

### 3.2 Time & Motion Sensitivity (SC 2.2.1, 2.2.2 & 2.3.3)
- **Notification Persistence**: Toast notifications containing actionable information must not auto-dismiss in under 6 seconds, and must pause their timer when hovered or focused.
- **Reduced Motion**: All animations and transitions must respect the `prefers-reduced-motion: reduce` CSS media query, instantly swapping animations for opacity fades or zero motion.
- **Flashing Limit**: Zero content flashes more than 3 times in any 1-second period.

### 3.3 Touch Targets & Pointer Gestures (SC 2.5.5 & 2.5.8)
- Minimum interactive target size is **24x24px** (target size minimum) with recommended **44x44px** for touch viewports.
- Any drag-and-drop interaction (e.g. Kanban reordering) must provide single-pointer button alternatives (e.g. "Move up / Move down" dropdown actions).

---

## 4. Principle 3: Understandable

### 4.1 Language & Predictability (SC 3.1.1 & 3.2.3)
- Root `<html>` element specifies valid language attribute (`lang="en"`).
- Global navigation components and menus remain in consistent order across views.

### 4.2 Form Validation & Error Prevention (SC 3.3.1, 3.3.2 & 3.3.4)
- **Clear Labels**: Every form input has an associated `<label>` (using `htmlFor` / `id`) or `aria-labelledby`.
- **Descriptive Inline Errors**: Input validation errors explicitly describe what is wrong and how to fix it (e.g. "Password must be at least 8 characters").
- **Financial & Destructive Actions**: Destructive actions (deleting workspace, canceling subscription) require explicit two-step confirmation dialogs.

---

## 5. Principle 4: Robust & Assistive Tech Support

### 5.1 ARIA Standards & Semantic HTML (SC 4.1.2)
- Native HTML5 semantic elements (`<nav>`, `<main>`, `<header>`, `<aside>`, `<footer>`, `<button>`) must be used instead of generic `<div>` click handlers.
- Custom interactive widgets must implement valid WAI-ARIA roles (`role="dialog"`, `role="combobox"`, `role="tablist"`).
- Dynamic content changes (e.g. search filter results, background job completion) must use `aria-live="polite"` regions so screen readers announce updates without interrupting.

---

## 6. Automated & Manual Verification Checklist

| Verification Category | Testing Tool | Pass Criteria |
|---|---|---|
| Automated Static Audit | `@axe-core/playwright` or `eslint-plugin-jsx-a11y` | Zero critical or serious accessibility violations in CI |
| Color Contrast Check | Lighthouse / Chrome DevTools | 100% of text and UI elements meet contrast ratios |
| Keyboard Walkthrough | Manual `Tab` / `Shift+Tab` / `Enter` / `Esc` run | Complete core workflow without touching mouse |
| Screen Reader Test | VoiceOver (macOS/iOS) or NVDA (Windows) | All interactive controls announce role, name, and state |
