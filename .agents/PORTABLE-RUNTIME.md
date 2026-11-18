# Portable Client Runtime Rules (`.agents/`)

Shared execution guidance for OpenAI Codex, Antigravity, Gemini CLI, Cursor, GitHub Copilot, Windsurf, Cline, and Open Agents running skills from `.agents/skills/`:

1. **Working Directory & Windows Shell**: Run shell commands from the project root. On Windows, use Git Bash when invoking `bash` helpers if default `bash` resolves to an unconfigured WSL distribution, or prefer `node .claude/runtime/studio-core.cjs` when available.
2. **Configuration & Fallbacks**: Shared studio files reside in `.claude/` (run the local Studio installer if missing). Read `.claude/docs/config-resolution.md` and apply its defaults (`locale: pt-BR`, `user_profile: founder`, `rigor: minimal`, `automation: collaborative`) when configuration cannot be resolved.
3. **Layperson / Founder Mode (`user_profile: founder`)**: Frame questions in plain business language with `(Recomendado)` / `(Recommended)` first and zero raw database/ORM jargon; apply the opinionated Golden Stack and invisible security/RLS/Stripe/LGPD guardrails automatically.
4. **Tools & Delegation**: Use the host client's native read, edit, and structured-question tools (or ask in chat and wait when structured questions are unavailable). Delegate specialist checks using role briefs in `.claude/agents/` when subagents are supported; otherwise execute checks sequentially and disclose single-session execution (reporting independent sign-offs as pending). Report missing tools or unexecuted checks explicitly.
