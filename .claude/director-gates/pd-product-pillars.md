> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-PRODUCT-PILLARS — Core Product Pillars Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: Product vision, core differentiators, design trade-offs, value proposition

**Trigger**: After product pillars are drafted (`/saas-brainstorm`, `docs/specs/product-pillars.md`)

**Context to pass**:
- Product pillars path (`docs/specs/product-pillars.md`)
- Product concept (`docs/specs/product-concept.md`)
- Competitive landscape analysis and market differentiation

**Prompt**:
> "Review the product pillars for clarity, distinctiveness, and decision-making power. Are there 3-5 clear, non-negotiable pillars that distinguish this SaaS from competitors? Do the pillars offer actionable guidance when trade-offs arise between speed, features, and UX? Are they specific to this product rather than generic platitudes (e.g., 'fast, reliable, easy')? Return SOUND (pillars provide clear guidance and differentiation), CONCERNS [pillars needing refinement], or UNSOUND [generic, contradictory, or unhelpful pillars]."

**Verdicts**: SOUND / CONCERNS / UNSOUND
