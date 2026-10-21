#!/usr/bin/env bash
# compat-inventory.sh — every place the framework depends on something only
# Claude Code provides, listed per file with the feature it belongs to.
#
# A skill, agent, hook or setting can lean on a Claude Code mechanism without
# saying so: a question tool named in a body, a `!` line, a `${CLAUDE_...}`
# substitution, a frontmatter key, a hook payload field, an `@` import. Read one
# file at a time, these are easy to miss. This script finds each one and prints
# where it is, so a change to any of them can be seen and planned for.
#
# OBSERVATIONS, NEVER VERDICTS (CLAUDE.md, "Helpers emit observations"). A
# construct found here is not a defect: Claude Code runs every one of them. It
# prints what it found, with denominators first, and always exits 0 once it has
# run. Whether a construct should stay, move to frontmatter or be reworded is the
# reader's call.
#
# Usage: bash .claude/scripts/compat-inventory.sh [--skill <name> | --agent <name>] [project-root]
#   --skill <name>  one skill's files only (SKILL.md and everything in its folder)
#   --agent <name>  one agent file only
#   project-root    defaults to the repo root (the test suite passes fixtures)
#
# Files read, in groups:
#   skills        .claude/skills/<name>/**/*.md
#   agents        .claude/agents/*.md
#   instructions  CLAUDE.md, CLAUDE.local.md, .claude/CLAUDE.md, <top-level folder>/CLAUDE.md,
#                 .claude/rules/*.md
#   docs          .claude/docs/**/*.md
#   hooks         .claude/hooks/*.sh and .claude/statusline.sh
#   settings      .claude/settings.json (settings.local.json is personal and not read)
#
# Output:
#   ROOT: <path>
#   FILES: skills=<n> skill_files=<n> agents=<n> instructions=<n> docs=<n> hooks=<n> settings=<n>
#   FOUND_LINES: <n> in <n> of <n> files read
#   COUNT: <feature> <construct> files=<n> hits=<n>    every catalogued construct, zero included;
#                                                      a family with nothing found prints <family>:*
#   FOUND: <feature> <construct> <file>:<line>         one line per construct per source line
#
# Features and their constructs:
#   questions      AskUserQuestion
#   subagents      Agent-tool (`Agent`, "Agent tool", Agent in a tools list), Task-tool (the
#                  old name, on a line about agents), subagent_type, agent-type-list (Agent(...)
#                  in an agent's tools), cc-path:.claude/agents, cc-path:.claude/agent-memory
#   skill-loading  var:CLAUDE_SKILL_DIR and the other skill substitutions, skillOverrides,
#                  cc-path:.claude/skills, cc-path:.claude/commands
#   shell-lines    shell-line (!`cmd` or a ```! block), shared-path:.claude/scripts
#   arguments      $ARGUMENTS, $N (skills only: the text Claude Code substitutes them in)
#   frontmatter    fm:<key> (a skill key beyond name, description, license, compatibility and
#                  metadata; an agent key beyond name and description), tools-string (an
#                  agent's tools written as one comma string)
#   instructions   CLAUDE.md (each instruction file), @import (outside code), rule-file,
#                  rule-paths, cc-path:.claude/rules, cc-path:.claude/CLAUDE.md,
#                  shared-path:.claude/docs and other framework folders under .claude/
#   hooks          hook:<Event>[<matcher>] (a registration in settings), hook-payload:<field>
#                  and hook-answer:<token> (in hook scripts), var:CLAUDE_PROJECT_DIR,
#                  shared-path:.claude/hooks
#   settings       permission:<allow|deny|ask|...> (one per rule), settings:<key>,
#                  statusline-payload:<field>, cc-path:.claude/settings*.json, other var:CLAUDE_*
#   tools          TodoWrite, task-tools (TaskCreate, TaskGet, TaskList, TaskUpdate, ...)
#
# cc-path is a folder or file Claude Code itself reads; shared-path is one of the
# framework's own folders that happens to live under .claude/. Paths are reported
# where a skill, agent, instruction file, doc or the settings name them, not
# inside hook scripts.

set -u

SKILL_FILTER=""
AGENT_FILTER=""
ROOT_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --skill|--agent)
      [ $# -ge 2 ] || { echo "compat-inventory: $1 needs a value" >&2; exit 2; }
      if [ "$1" = "--skill" ]; then SKILL_FILTER="$2"; else AGENT_FILTER="$2"; fi
      shift 2 ;;
    --skill=*) SKILL_FILTER="${1#--skill=}"; shift ;;
    --agent=*) AGENT_FILTER="${1#--agent=}"; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) ROOT_ARG="$1"; shift ;;
  esac
done

if [ -n "$SKILL_FILTER" ] && [ -n "$AGENT_FILTER" ]; then
  echo "compat-inventory: give --skill or --agent, not both" >&2
  exit 2
fi

if [ -n "$ROOT_ARG" ]; then
  ROOT="$ROOT_ARG"
else
  cd "$(dirname "$0")/../.." || { echo "compat-inventory: cannot reach repo root" >&2; exit 1; }
  # `pwd -W` (Git Bash) gives C:/... so the Windows Python below can open it.
  ROOT="$(pwd -W 2>/dev/null || pwd)"
fi

if [ ! -d "$ROOT/.claude" ]; then
  echo "compat-inventory: no .claude folder under $ROOT" >&2
  exit 1
fi

# Python fallback chain: python -> python3 -> py (matches yaml-helper.sh).
PYBIN=""
for candidate in python python3 py; do
  if command -v "$candidate" >/dev/null 2>&1; then
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' >/dev/null 2>&1; then
      PYBIN="$candidate"; break
    fi
  fi
done
if [ -z "$PYBIN" ]; then
  echo "compat-inventory: no python 3 interpreter found (tried python, python3, py)" >&2
  exit 1
fi

"$PYBIN" - "$ROOT" "$SKILL_FILTER" "$AGENT_FILTER" <<'PYEOF'
import json
import os
import re
import sys

root, skill_filter, agent_filter = sys.argv[1:4]

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

# Constructs that always print a COUNT line, zero included.
STATIC = [
    ("questions", "AskUserQuestion"),
    ("subagents", "Agent-tool"), ("subagents", "Task-tool"), ("subagents", "subagent_type"),
    ("subagents", "agent-type-list"),
    ("subagents", "cc-path:.claude/agents"), ("subagents", "cc-path:.claude/agent-memory"),
    ("skill-loading", "var:CLAUDE_SKILL_DIR"), ("skill-loading", "var:CLAUDE_SESSION_ID"),
    ("skill-loading", "var:CLAUDE_PLUGIN_ROOT"), ("skill-loading", "var:CLAUDE_PLUGIN_DATA"),
    ("skill-loading", "skillOverrides"),
    ("skill-loading", "cc-path:.claude/skills"), ("skill-loading", "cc-path:.claude/commands"),
    ("shell-lines", "shell-line"),
    ("arguments", "$ARGUMENTS"), ("arguments", "$N"),
    ("frontmatter", "tools-string"),
    ("instructions", "CLAUDE.md"), ("instructions", "@import"),
    ("instructions", "rule-file"), ("instructions", "rule-paths"),
    ("instructions", "cc-path:.claude/rules"), ("instructions", "cc-path:.claude/CLAUDE.md"),
    ("hooks", "var:CLAUDE_PROJECT_DIR"),
    ("settings", "cc-path:.claude/settings.json"), ("settings", "cc-path:.claude/settings.local.json"),
    ("settings", "cc-path:.claude/output-styles"),
    ("tools", "TodoWrite"), ("tools", "task-tools"),
]
# Families whose members are named by what was found; "<family>:*" prints when none was.
DYNAMIC = [("hooks", "hook"), ("hooks", "hook-payload"), ("hooks", "hook-answer"),
           ("frontmatter", "fm"), ("settings", "permission"), ("settings", "settings"),
           ("settings", "statusline-payload"), ("instructions", "shared-path"), ("settings", "var")]
STATIC_FEATURE = dict((c, f) for f, c in STATIC)

# Under .claude/: what Claude Code itself reads, and the feature each belongs to.
CC_PATHS = {"skills": "skill-loading", "commands": "skill-loading", "agents": "subagents",
            "agent-memory": "subagents", "rules": "instructions", "CLAUDE.md": "instructions",
            "settings.json": "settings", "settings.local.json": "settings", "output-styles": "settings"}
# The framework's own folders under .claude/ (anything else defaults to instructions).
SHARED_FEATURE = {"hooks": "hooks", "scripts": "shell-lines", "statusline.sh": "settings"}
SKILL_VARS = {"CLAUDE_SKILL_DIR", "CLAUDE_SESSION_ID", "CLAUDE_PLUGIN_ROOT", "CLAUDE_PLUGIN_DATA"}
SKILL_PORTABLE = {"name", "description", "license", "compatibility", "metadata"}
AGENT_PORTABLE = {"name", "description"}

RX = {
    "AskUserQuestion": re.compile(r"\bAskUserQuestion\b"),
    "Agent-tool": re.compile(r"`Agent`|\bAgent tool\b"),
    "subagent_type": re.compile(r"\bsubagent_type\b"),
    "TodoWrite": re.compile(r"\bTodoWrite\b"),
    "task-tools": re.compile(r"\bTask(?:Create|Get|List|Update|Output|Stop)\b"),
    "shell-line": re.compile(r"(?:^|\s)!`[^`]+`|^\s*```!"),
    "skillOverrides": re.compile(r"\bskillOverrides\b"),
    "$ARGUMENTS": re.compile(r"\$ARGUMENTS\b"),
    "$N": re.compile(r"(?<![\w$\\])\$\d\b"),
}
# `Task` is also a C# type: count it only on a line about agents.
TASK_TOOL = re.compile(r"\bTask tool\b|\bTask\(\s*(?:subagent_type|description|prompt)\b")
TASK_TICKED = re.compile(r"`Task`")
TASK_CONTEXT = re.compile(r"(?i)\bsub-?agents?\b|\bagents?\b|\balias\b|\bsubagent_type\b")
VAR = re.compile(r"\$\{?(CLAUDE_[A-Z][A-Z0-9_]*)\}?")
PATH = re.compile(r"\.claude/([A-Za-z0-9_.-]+)")
IMPORT = re.compile(r"(?:^|(?<=\s))@([~\w.-]*/[\w./-]+|[\w-]+\.[A-Za-z]{1,5})\b")
CODE_SPAN = re.compile(r"`[^`]*`")
HOOK_PAYLOAD = re.compile(
    r"\b(tool_input|tool_name|tool_response|hook_event_name|session_id|transcript_path|agent_id"
    r"|agent_type|agent_transcript_path|stop_hook_active|last_assistant_message|permission_mode"
    r"|notification_type|custom_instructions)\b")
HOOK_ANSWER = re.compile(
    r"\b(hookSpecificOutput|permissionDecision(?:Reason)?|additionalContext|systemMessage"
    r"|suppressOutput|stopReason)\b|\b(exit 2)\b|(\"decision\")")
STATUS_PAYLOAD = re.compile(r"\.(model|workspace|context_window|cost|output_style)\.([a-z_]+)")


def read_lines(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read().splitlines()


def rel(path):
    return os.path.relpath(path, root).replace(os.sep, "/")


def md_files(folder):
    out = []
    for dirpath, dirs, files in os.walk(folder):
        dirs.sort()
        out += [os.path.join(dirpath, f) for f in sorted(files) if f.endswith(".md")]
    return out


found = set()   # (feature, construct, file, line)


def add(feature, construct, path, line):
    found.add((feature, construct.replace(" ", "_"), rel(path), line))


def frontmatter_lines(lines):
    """[(line number, key, value)] for the leading --- block; [] when there is none."""
    if not lines or lines[0].strip() != "---":
        return []
    out = []
    for n in range(1, len(lines)):
        if lines[n].strip() == "---":
            return out
        m = re.match(r"^([A-Za-z][\w-]*):(.*)$", lines[n])
        if m:
            out.append((n + 1, m.group(1), m.group(2).strip()))
    return []   # never closed: not frontmatter


def list_entries(value):
    v = value.strip().strip("\"'")
    if v.startswith("[") and v.endswith("]"):
        v = v[1:-1]
    out, depth, cur = [], 0, ""
    for ch in v:
        depth += ch == "("
        depth -= ch == ")"
        if ch == "," and depth == 0:
            out.append(cur.strip().strip("\"'"))
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip().strip("\"'"))
    return [e for e in out if e]


def imports_in(lines):
    """[(line number, target)] for each @path import. Claude Code skips code fences and code
    spans, and strips block HTML comments before it reads the file, so an @path in any of
    them is text about imports, not one."""
    out, fenced, comment = [], False, False
    for n, line in enumerate(lines, start=1):
        if not comment and line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        text = ""
        while line:
            if comment:
                end = line.find("-->")
                if end == -1:
                    line = ""
                else:
                    comment, line = False, line[end + 3:]
            else:
                start = line.find("<!--")
                if start == -1:
                    text, line = text + line, ""
                else:
                    text, comment, line = text + line[:start], True, line[start + 4:]
        for target in IMPORT.findall(CODE_SPAN.sub("", text)):
            out.append((n, target))
    return out


def scan_text(path, lines, skill=False, paths=True, imports=False):
    """The line constructs every text group shares."""
    if imports:
        for n, target in imports_in(lines):
            add("instructions", "@import", path, n)
    for n, line in enumerate(lines, start=1):
        for name, rx in RX.items():
            if name in ("$ARGUMENTS", "$N") and not skill:
                continue
            if rx.search(line):
                add(STATIC_FEATURE[name], name, path, n)
        if TASK_TOOL.search(line) or (TASK_TICKED.search(line) and TASK_CONTEXT.search(line)):
            add("subagents", "Task-tool", path, n)
        for var in VAR.findall(line):
            add(var_feature(var), "var:" + var, path, n)
        if paths:
            for seg in PATH.findall(line):
                seg = seg.rstrip(".")
                if not seg:
                    continue
                if seg in CC_PATHS:
                    add(CC_PATHS[seg], "cc-path:.claude/" + seg, path, n)
                else:
                    add(SHARED_FEATURE.get(seg, "instructions"), "shared-path:.claude/" + seg, path, n)


def var_feature(var):
    if var in SKILL_VARS:
        return "skill-loading"
    if var == "CLAUDE_PROJECT_DIR":
        return "hooks"
    return "settings"


def import_targets(path, lines):
    out = []
    for _, target in imports_in(lines):
        if target.startswith("~"):
            out.append(os.path.normpath(os.path.join(os.path.expanduser("~"), target.lstrip("~/"))))
        else:
            out.append(os.path.normpath(os.path.join(os.path.dirname(path), target)))
    return out


claude = os.path.join(root, ".claude")

# --- groups ----------------------------------------------------------------
skill_dir = os.path.join(claude, "skills")
skills = {}
if os.path.isdir(skill_dir):
    for d in sorted(os.listdir(skill_dir)):
        if os.path.isfile(os.path.join(skill_dir, d, "SKILL.md")):
            skills[d] = md_files(os.path.join(skill_dir, d))
agent_dir = os.path.join(claude, "agents")
agents = {}
if os.path.isdir(agent_dir):
    for f in sorted(os.listdir(agent_dir)):
        if f.endswith(".md"):
            agents[f[:-3]] = os.path.join(agent_dir, f)

instruction_files = [p for p in (os.path.join(root, "CLAUDE.md"), os.path.join(root, "CLAUDE.local.md"),
                                 os.path.join(claude, "CLAUDE.md")) if os.path.isfile(p)]
for d in sorted(os.listdir(root)):
    p = os.path.join(root, d, "CLAUDE.md")
    if not d.startswith(".") and os.path.isfile(p):
        instruction_files.append(p)
rules_dir = os.path.join(claude, "rules")
rule_files = [os.path.join(rules_dir, f) for f in sorted(os.listdir(rules_dir))
              if f.endswith(".md")] if os.path.isdir(rules_dir) else []
doc_files = md_files(os.path.join(claude, "docs")) if os.path.isdir(os.path.join(claude, "docs")) else []
hook_dir = os.path.join(claude, "hooks")
hook_files = [os.path.join(hook_dir, f) for f in sorted(os.listdir(hook_dir))
              if f.endswith(".sh")] if os.path.isdir(hook_dir) else []
statusline = os.path.join(claude, "statusline.sh")
if os.path.isfile(statusline):
    hook_files.append(statusline)
settings_file = os.path.join(claude, "settings.json")
settings_files = [settings_file] if os.path.isfile(settings_file) else []

scope_note = ""
if skill_filter:
    picked_skills = {skill_filter: skills[skill_filter]} if skill_filter in skills else {}
    picked_agents, read_instr, read_rules, read_docs, read_hooks, read_settings = {}, [], [], [], [], []
    scope_note = "SCOPE: skill %s only; agents, instructions, docs, hooks and settings not read" % skill_filter
elif agent_filter:
    picked_agents = {agent_filter: agents[agent_filter]} if agent_filter in agents else {}
    picked_skills, read_instr, read_rules, read_docs, read_hooks, read_settings = {}, [], [], [], [], []
    scope_note = "SCOPE: agent %s only; skills, instructions, docs, hooks and settings not read" % agent_filter
else:
    picked_skills, picked_agents = skills, agents
    read_instr, read_rules, read_docs = instruction_files, rule_files, doc_files
    read_hooks, read_settings = hook_files, settings_files

notes = []

# --- skills ----------------------------------------------------------------
for name, files in picked_skills.items():
    for path in files:
        lines = read_lines(path)
        scan_text(path, lines, skill=True)
        if os.path.basename(path) == "SKILL.md" and os.path.dirname(path) == os.path.join(skill_dir, name):
            for n, key, value in frontmatter_lines(lines):
                if key not in SKILL_PORTABLE:
                    add("frontmatter", "fm:" + key, path, n)
                if key == "allowed-tools":
                    for e in list_entries(value):
                        if e == "Agent" or e.startswith("Agent("):
                            add("subagents", "Agent-tool", path, n)
                        elif e == "Task" or e.startswith("Task("):
                            add("subagents", "Task-tool", path, n)

# --- agents ----------------------------------------------------------------
for name, path in picked_agents.items():
    lines = read_lines(path)
    scan_text(path, lines)
    for n, key, value in frontmatter_lines(lines):
        if key not in AGENT_PORTABLE:
            add("frontmatter", "fm:" + key, path, n)
        if key == "tools":
            v = value.strip()
            if v and not v.startswith("["):
                add("frontmatter", "tools-string", path, n)
            for e in list_entries(value):
                if e.startswith("Agent("):
                    add("subagents", "agent-type-list", path, n)
                if e == "Agent" or e.startswith("Agent("):
                    add("subagents", "Agent-tool", path, n)
                elif e == "Task" or e.startswith("Task("):
                    add("subagents", "Task-tool", path, n)

# --- instructions and docs -------------------------------------------------
imported, queue = set(), [(p, 0) for p in read_instr]
while queue:   # Claude Code follows imports four hops deep at most
    path, depth = queue.pop(0)
    if depth >= 4:
        continue
    for target in import_targets(path, read_lines(path)):
        if target not in imported and os.path.isfile(target):
            imported.add(target)
            queue.append((target, depth + 1))
# An imported file no other group reads (an stack reference, say) is instruction text too.
grouped = {os.path.normpath(p) for p in read_instr + read_rules + read_docs}
read_instr = read_instr + sorted(p for p in imported if os.path.normpath(p) not in grouped)

for path in read_instr:
    lines = read_lines(path)
    if os.path.basename(path) in ("CLAUDE.md", "CLAUDE.local.md"):
        add("instructions", "CLAUDE.md", path, 1)
    scan_text(path, lines, imports=True)
for path in read_rules:
    lines = read_lines(path)
    add("instructions", "rule-file", path, 1)
    scan_text(path, lines, imports=os.path.normpath(path) in imported)
    for n, key, value in frontmatter_lines(lines):
        if key == "paths":
            add("instructions", "rule-paths", path, n)
for path in read_docs:
    scan_text(path, read_lines(path), imports=os.path.normpath(path) in imported)

# --- hooks -----------------------------------------------------------------
for path in read_hooks:
    is_status = os.path.normpath(path) == os.path.normpath(statusline)
    for n, line in enumerate(read_lines(path), start=1):
        for var in VAR.findall(line):
            add(var_feature(var), "var:" + var, path, n)
        if is_status:
            for a, b in STATUS_PAYLOAD.findall(line):
                add("settings", "statusline-payload:%s.%s" % (a, b), path, n)
            continue
        for field in HOOK_PAYLOAD.findall(line):
            add("hooks", "hook-payload:" + field, path, n)
        for token, exit2, decision in HOOK_ANSWER.findall(line):
            add("hooks", "hook-answer:" + (token or ("exit-2" if exit2 else "decision")), path, n)

# --- settings --------------------------------------------------------------
for path in read_settings:
    lines = read_lines(path)
    scan_text(path, lines)

    def line_of(needle, start=0):
        for i in range(start, len(lines)):
            if needle in lines[i]:
                return i + 1
        return 0

    try:
        data = json.loads("\n".join(lines))
    except ValueError as exc:
        notes.append("%s does not parse as JSON (%s); only its text was read" % (rel(path), exc))
        continue
    if not isinstance(data, dict):
        notes.append("%s is not a JSON object; only its text was read" % rel(path))
        continue
    hooks_at = line_of('"hooks"')
    for event, groups in (data.get("hooks") or {}).items():
        at = line_of('"%s"' % event, max(hooks_at - 1, 0)) or hooks_at
        for group in groups if isinstance(groups, list) else []:
            matcher = (group.get("matcher") or "") if isinstance(group, dict) else ""
            add("hooks", "hook:%s%s" % (event, "[%s]" % matcher if matcher else ""), path, at)
    perms = data.get("permissions") or {}
    perms_at = line_of('"permissions"')
    cursor = max(perms_at - 1, 0)
    for kind, value in perms.items():
        if isinstance(value, list):
            for rule in value:
                at = line_of(json.dumps(rule, ensure_ascii=False), cursor) or perms_at
                cursor = max(at, cursor)
                add("settings", "permission:" + kind, path, at)
        else:
            add("settings", "permission:" + kind, path, line_of('"%s"' % kind, max(perms_at - 1, 0)) or perms_at)
    for key in data:
        if key not in ("$schema", "hooks", "permissions"):
            add("skill-loading" if key == "skillOverrides" else "settings", "settings:" + key, path,
                line_of('"%s"' % key) or 1)

# --- report ----------------------------------------------------------------
n_skill_files = sum(len(v) for v in picked_skills.values())
read_count = (n_skill_files + len(picked_agents) + len(read_instr) + len(read_rules) + len(read_docs)
              + len(read_hooks) + len(read_settings))
print("ROOT: %s" % root)
print("FILES: skills=%d skill_files=%d agents=%d instructions=%d docs=%d hooks=%d settings=%d"
      % (len(picked_skills), n_skill_files, len(picked_agents), len(read_instr) + len(read_rules),
         len(read_docs), len(read_hooks), len(read_settings)))
print("FOUND_LINES: %d in %d of %d files read" % (len(found), len({f[2] for f in found}), read_count))
if scope_note:
    print(scope_note)
if skill_filter and skill_filter not in skills:
    print("NOT FOUND: skill %s is not a folder in .claude/skills/" % skill_filter)
if agent_filter and agent_filter not in agents:
    print("NOT FOUND: agent %s is not a file in .claude/agents/" % agent_filter)
for note in notes:
    print("NOTE: %s" % note)

counts = {}
for feature, construct, path, line in found:
    c = counts.setdefault((feature, construct), [set(), 0])
    c[0].add(path)
    c[1] += 1
rows = {(f, c): (len(v[0]), v[1]) for (f, c), v in counts.items()}
for feature, construct in STATIC:
    rows.setdefault((feature, construct), (0, 0))
for feature, family in DYNAMIC:
    if not any(c.startswith(family + ":") and c not in STATIC_FEATURE for (_, c) in rows):
        rows[(feature, family + ":*")] = (0, 0)
for (feature, construct), (nf, nh) in sorted(rows.items()):
    print("COUNT: %s %s files=%d hits=%d" % (feature, construct, nf, nh))
for feature, construct, path, line in sorted(found, key=lambda f: (f[2], f[3], f[0], f[1])):
    print("FOUND: %s %s %s:%d" % (feature, construct, path, line))
PYEOF
exit 0
