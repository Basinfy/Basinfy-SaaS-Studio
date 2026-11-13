---
name: saas-seo-content
description: "Audit and optimize SaaS content quality — E-E-A-T, value messaging, feature vs benefit articulation, readability, AI text humanization, and invisible Unicode watermark removal."
argument-hint: "[url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS Content Quality & E-E-A-T Optimization

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

Evaluates and polishes SaaS marketing copy, feature documentation, and blog content to satisfy Google's Helpful Content System and E-E-A-T standards.

---

## 1. The SaaS E-E-A-T Framework

1. **Experience**: Demonstrable hands-on usage (real UI screenshots, code snippets, CLI output, benchmark charts).
2. **Expertise**: Author credentials, developer background, technical explanations of underlying architecture and operational workflows.
3. **Authoritativeness**: Citations, industry standards alignment, references to primary RFCs or documentation.
4. **Trust**: Transparent pricing, clear refund/trial terms, visible company contact details, HTTPS, security badges.

---

## 2. Benefit-Driven SaaS Messaging

Transform feature-heavy developer jargon into high-converting, user-centric value statements:

- *Feature-centric (Weak)*: "We have an event-driven Kafka stream with distributed workers."
- *Benefit-centric (High-Converting)*: "Process 50,000 real-time events per second without dropping a single customer transaction."

---

## 3. AI Text Humanization & Watermark Cleanup

Detects and strips low-value AI cliches and machine watermarks:
- Strip typical AI phrases ("In today's fast-paced digital world", "delve into", "testament to", "unlock your potential").
- Remove zero-width spaces (`\u200B`, `\u200C`, `\u200D`, `\uFEFF`) and invisible tracking artifacts.
- Enforce active voice and varied sentence rhythm.

---

## 4. CLI Execution

```bash
python scripts/seo/content_quality.py <url>
python scripts/seo/content_humanize.py <file.md>
```
