> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# PD-MESSAGING-TONE — UX Writing & Product Voice Sign-Off

Agent: `product-director` | Model tier: session (inherit) | Domain: Product voice, UX copywriting, onboarding messaging, customer communications

**Trigger**: After customer-facing copy, onboarding guides, or notification copy is drafted

**Context to pass**:
- Brand voice and tone guide (`design/tokens/brand-voice-tone-guide.md`)
- UI microcopy, empty states, error messages, and transactional email templates
- Target audience expectations and market context

**Prompt**:
> "Review customer-facing copy and UX messaging for clarity, empathy, and brand voice adherence. Are error messages actionable and helpful rather than blame-oriented or obscure? Does the onboarding microcopy guide users smoothly toward their first 'aha!' moment? Is terminology uniform across navigation, tooltips, and settings? Return APPROVED (copy is clear, cohesive, and on-brand) or REVISE [specific copy improvements needed]."

**Verdicts**: APPROVED / REVISE
