---
name: saas-seo-content
description: "Audit and optimize SaaS content quality — E-E-A-T, value messaging, feature vs benefit articulation, readability, AI text humanization, and invisible Unicode watermark removal."
argument-hint: "[url]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/saas-seo-content/../../hooks/yaml-helper.sh" resolve_config *)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,review_mode,automation`

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
