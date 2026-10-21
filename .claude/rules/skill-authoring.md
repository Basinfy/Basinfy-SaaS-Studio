---
paths:
  - ".claude/skills/**"
  - ".claude/agents/**"
---

# Skill & Agent Authoring Rules

1. **Valid Frontmatter**: Must specify `name`, `description`, and `allowed-tools` (skills) or `tools`/`disallowedTools`, `model`, `maxTurns` (agents).
2. **Explicit Consent**: Skills modifying project code or files must request user permission: `"May I write this to [filepath]?"`.
3. **Dynamic Configuration**: Skills must inject project configuration via `yaml-helper.sh resolve_config`.
