> Gate definition. The spawning skill passes this file's path to the director agent; the AGENT reads it — the parent session should not.

# TD-STACK-RISK — Technical Director Tech Stack & Dependency Risk Audit

Agent: `technical-director` | Model tier: session (inherit) | Domain: Tech stack selection, library stability, vendor lock-in, supply chain security

**Trigger**: During stack selection (`/saas-setup-stack`), when adding major framework dependencies

**Context to pass**:
- Stack definition in `project.yaml` (`stack.*`)
- Dependency manifests (`package.json`, `pnpm-lock.yaml`, `requirements.txt`)
- License compliance and vulnerability scanner outputs

**Prompt**:
> "Assess the technical risk, community longevity, and supply-chain safety of the selected stack and dependencies. Are chosen frameworks actively maintained with clear LTS roadmaps? Does the stack create catastrophic vendor lock-in that cannot be abstracted or migrated? Are there unpatched CVEs, deprecated transitive dependencies, or viral licenses? Return LOW (stable, mainstream, low-risk stack), MEDIUM (manageable risks with identified mitigations), or CRITICAL [unacceptable vulnerabilities, dead packages, or unviable operational lock-in]."

**Verdicts**: LOW / MEDIUM / CRITICAL
