---
paths:
  - "design/tokens/**"
  - "tailwind.config.*"
  - "src/styles/**"
---

# Styling & Semantic Tokens Rules

1. **Tailwind Semantic Tokens**: Use CSS variables and semantic design tokens (`bg-background`, `text-foreground`, `border-border`, `primary`, `muted`).
2. **No Magic Numbers**: Avoid arbitrary inline styles (`style={{ margin: 17 }}`) or one-off values when tokens exist.
3. **Dark / Light Mode**: Ensure all color combinations provide minimum 4.5:1 contrast in both dark and light modes.
