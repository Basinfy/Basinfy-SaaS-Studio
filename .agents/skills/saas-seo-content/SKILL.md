---
name: saas-seo-content
description: "Audit SaaS copy for E-E-A-T, benefit clarity, AI-slop removal, and Unicode watermark cleanup."
argument-hint: "[url]"
user-invocable: true
---

<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run commands from the project root (use Git Bash on Windows if `bash` points to an unavailable WSL distro). Shared studio files live in `.claude/`; follow `.agents/PORTABLE-RUNTIME.md` and `.claude/docs/config-resolution.md` for client tools, delegation, and approval rules.

Run `bash .claude/hooks/yaml-helper.sh resolve_config --keys locale,review_mode,automation` and use its output below.

Resolved above — use as-is; `--review` overrides `review_mode` for this run.

# SaaS Content Quality & E-E-A-T Optimization

> **Locale & User Profile**: Match `locale` (`pt-BR` → natural Brazilian Portuguese questions/options, overriding English examples; `en` → English) and `user_profile` (`founder` → plain business language with `(Recomendado)` first, zero tech jargon; `developer` → technical). Keep code/tests in English.


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
