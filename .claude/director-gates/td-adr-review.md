> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-ADR-REVIEW — Technical Director Architecture Decision Record Review

Agent: `technical-director` | Model tier: session (inherit) | Domain: Architectural governance, trade-off analysis, technology selection, ADR immutability

**Trigger**: When an ADR is proposed or updated (`/saas-architecture-decision`)

**Context to pass**:
- ADR document path (`docs/architecture/adr-*.md`)
- Architecture blueprint (`docs/architecture/system-architecture.md`)
- Tech stack and performance constraints from `project.yaml`

**Prompt**:
> "Review this Architecture Decision Record for technical rigor, trade-off depth, and strategic alignment. Does the context section clearly state the driving problem without bias? Are at least two viable alternatives honestly evaluated with pros and cons? Are negative consequences, security implications, and operational overhead transparently addressed? Return ACCEPTED (decision is technically sound and justified) or REJECTED [flawed rationale, unaddressed risks, or unacceptable consequences]."

**Verdicts**: ACCEPTED / REJECTED
