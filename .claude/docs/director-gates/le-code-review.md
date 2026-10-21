> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# LE-CODE-REVIEW — Lead Engineer Implementation Code Review

Agent: `lead-engineer` | Model tier: session (inherit) | Domain: Code quality, architecture compliance, SOLID principles, type safety, query optimization

**Trigger**: Post-implementation review (`/saas-code-review`, `/saas-story-done`)

**Context to pass**:
- Git diff of implemented code (`git diff HEAD~1` or staged changes)
- Active user story and acceptance criteria (`production/epics/*.md`)
- Engineering control manifest (`docs/architecture/control-manifest.md`)
- Coding standards (`.claude/docs/coding-standards.md`)

**Prompt**:
> "Review the implemented code against architectural standards, security rules, and code quality benchmarks. Are TypeScript types strict with zero `any` types? Are Server Components vs Client Components cleanly separated? Are database queries indexed, parameterized, and protected against N+1 problems? Is input validation strictly enforced at the API boundary using Zod/Pydantic schemas? Are error states handled gracefully with descriptive messages and proper HTTP status codes? Return APPROVE (code is clean, safe, and meets standards) or REQUEST_CHANGES [specific code improvements required]."

**Verdicts**: APPROVE / REQUEST_CHANGES
