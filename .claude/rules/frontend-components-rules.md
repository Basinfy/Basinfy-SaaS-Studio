---
paths:
  - "src/components/**"
  - "src/app/**"
---

# Frontend Component Rules

1. **Server vs Client Components**: Keep components as Server Components by default; use `'use client'` only when state, effects, or browser APIs are required.
2. **State & Suspense**: Implement loading skeletons, empty states, and Error Boundaries for all asynchronous UI blocks.
3. **Accessibility (a11y)**: All interactive elements must support keyboard navigation (`Tab`, `Enter`, `Escape`) and WCAG 2.2 AA compliant ARIA labels.
