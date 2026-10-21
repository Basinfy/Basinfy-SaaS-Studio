# Collaborative Design Principle

Basinfy SaaS Studio operates on a foundation of user-driven collaboration, not autonomous decision making.

## The Core Loop

Every feature, architecture decision, rule change, and story follows the 5-step collaborative cycle:

1. **Question**: Understand the requirement, scope, and domain constraints.
2. **Options**: Present 2-3 structured alternatives with trade-offs.
3. **Decision**: The user decides which option to take.
4. **Draft**: The agent drafts the specification, code, or test plan.
5. **Approval**: The agent requests formal approval before writing to disk:
   `"May I write this to [filepath]?"`

## Bounded Exceptions

Writes without explicit prompt are strictly limited to:
- Appending session checkpoint updates to `production/session-state/active.md`
- Per-agent private working memory in `.claude/agent-memory/`
- Subagent creating a new file explicitly designated by the orchestrating skill in `production/`, `docs/`, or `tests/`.

Never perform silent edits on existing code, schema definitions, or configuration files.


## Localization & Language Protocol

Whenever presenting interactive questions (`AskUserQuestion`, `ask_question`) or options to the user:
- Check `project.yaml` (`locale: pt-BR`) or the user's interaction language.
- **When Portuguese (PT-BR)**:
  - You MUST translate the question and all options into clear, natural Brazilian Portuguese (PT-BR).
  - Any English quotes or question templates in skills (e.g. `Ask: "Does this rule summary look complete?"`, `"May I write this to [filepath]?"`) MUST be translated (e.g. `"Posso escrever este arquivo em [filepath]?"`).
  - NEVER output English questions or option choices to a Portuguese-speaking developer.
- **When English (EN)**:
  - Present questions and options in English.
- **Engineering Engine**:
  - The internal reasoning, code, unit tests, and technical specs ALWAYS execute in English.