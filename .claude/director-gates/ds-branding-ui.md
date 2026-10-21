> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# DS-BRANDING-UI — Product Branding & Visual Concept Sign-Off

Agent: `design-system-director` | Model tier: session (inherit) | Domain: Visual brand identity, iconography, logo usage, product aesthetic direction

**Trigger**: After visual identity and UI concept mockups are drafted, before high-fidelity component design

**Context to pass**:
- Branding and visual identity guidelines (`design/tokens/brand-guide.md`)
- Product concept and value proposition (`docs/specs/product-concept.md`)
- Target ICP and user persona profiles (`docs/specs/user-persona-profile.md`)

**Prompt**:
> "Review the visual branding and UI aesthetic direction for alignment with the product concept and ICP. Does the visual language convey the appropriate professional authority, trustworthiness, and modern SaaS feel? Is the icon system cohesive in stroke weight and corner radii? Are brand assets exportable in SVG/vector formats? Return APPROVED (branding aligns with product identity) or REVISE [specific visual elements requiring adjustment]."

**Verdicts**: APPROVED / REVISE
