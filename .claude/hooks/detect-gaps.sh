#!/bin/bash

# --- work from the project root ----------------------------------------------
# Every path below is repo-relative, so a hook invoked with a working directory
# that is not the repo root would silently read and write the WRONG TREE --
# returning a near-empty result instead of the session-recovery block, and
# creating stray trees such as docs/production/session-logs/ on write.
#
# PRECEDENCE IS LOAD-BEARING. A cwd that IS a project root carries real
# information and must win: a caller sitting inside another project means that
# project, not this one. Resolving to the script's own location first would
# override them. So, in order:
#   1. cwd holds project.yaml   -> cwd   (a project root)
#   2. cwd holds .claude/       -> cwd   (a project root not yet configured),
#      unless cwd is itself named .claude: a stray .claude/.claude/ would
#      make .claude/ a root, and the hooks would write .claude/production/
#   3. CLAUDE_PROJECT_DIR       -> that  (populated in the hook environment),
#      unless it names a .claude folder, for the same reason as rule 2
#   4. this script's location   -> <root>/.claude/hooks/../.. by construction
# Rule 4 always works and needs no environment at all; rules 1-2 stop it from
# overriding a caller that legitimately means somewhere else.
#
# NOT an upward search: that resolves a nested project to its parent's config.
if [ -f "project.yaml" ] || { [ -d ".claude" ] && [ "${PWD##*/}" != ".claude" ]; }; then
  SAAS_STUDIO_ROOT="$PWD"
elif [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}" ] && case "${CLAUDE_PROJECT_DIR%/}" in */.claude|*\\.claude) false ;; *) true ;; esac; then
  SAAS_STUDIO_ROOT="$CLAUDE_PROJECT_DIR"
else
  SAAS_STUDIO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
fi
[ -n "$SAAS_STUDIO_ROOT" ] && cd "$SAAS_STUDIO_ROOT" 2>/dev/null || true

# Hook: detect-gaps.sh
# Event: SessionStart
# Purpose: Detect missing documentation when code/prototypes exist
# Cross-platform: Windows Git Bash compatible (uses grep -E, not -P)

# Exit on error for debugging (but don't fail the session)
set +e

echo "=== Checking for Documentation Gaps ==="

# --- Check 0: Fresh project detection (suggests /saas-start) ---
FRESH_PROJECT=true

# Check if stack is configured (project.yaml first, fall back to technical-preferences.md)
if [ -f "project.yaml" ] && [ -f ".claude/hooks/yaml-helper.sh" ]; then
  source .claude/hooks/yaml-helper.sh
  ENGINE_NAME=$(get_yaml_key project.yaml stack.frontend 2>/dev/null)
  [ -z "$ENGINE_NAME" ] && ENGINE_NAME=$(get_yaml_key project.yaml stack.frontend 2>/dev/null)
  [ -z "$ENGINE_NAME" ] && ENGINE_NAME=$(get_yaml_key project.yaml framework.name 2>/dev/null)
  if [ -n "$ENGINE_NAME" ]; then
    FRESH_PROJECT=false
  fi
fi
if [ "$FRESH_PROJECT" = true ] && [ -f ".claude/docs/technical-preferences.md" ]; then
  ENGINE_LINE=$(grep -E "^[[:space:]]*-[[:space:]]+\*\*(Engine|Stack)\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
  if [ -n "$ENGINE_LINE" ] && ! echo "$ENGINE_LINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
    FRESH_PROJECT=false
  fi
fi

# Check if a design / spec record exists.
if [ -f "docs/specs/product-concept.md" ] || [ -f "docs/specs/product-brief.md" ] || [ -f "design/product-brief.md" ] || [ -f "design/prd/product-concept.md" ] || [ -f "design/product-brief.md" ]; then
  FRESH_PROJECT=false
fi

# Check if source code exists across common roots
for _root in src app pages server api lib Assets Source; do
  [ -d "$_root" ] || continue
  SRC_CHECK=$(find "$_root" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.sql" -o -name "*.prisma" -o -name "*.ts" -o -name "*.cs" \) 2>/dev/null | head -1)
  if [ -n "$SRC_CHECK" ]; then
    FRESH_PROJECT=false
    break
  fi
done

# --- Check 0b: v1.0 project — legacy config present, project.yaml absent ---
# The migration story depends on users discovering /saas-adopt; UPGRADING.md only
# reaches people who read it. An unconfigured technical-preferences.md template
# does not count as legacy data (same rule as migrate-v1-config.sh), and legacy
# config also means the project is not fresh — the NEW PROJECT banner below
# would be wrong for it.
if [ ! -f "project.yaml" ]; then
  LEGACY_FILES=""
  [ -f "production/stage.txt" ] && LEGACY_FILES="production/stage.txt"
  [ -f "production/review-mode.txt" ] && LEGACY_FILES="${LEGACY_FILES:+$LEGACY_FILES, }production/review-mode.txt"
  if [ -f ".claude/docs/technical-preferences.md" ]; then
    TP_ENGINE=$(grep -E "^[[:space:]]*-[[:space:]]+\*\*Engine\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
    if [ -n "$TP_ENGINE" ] && ! echo "$TP_ENGINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
      LEGACY_FILES="${LEGACY_FILES:+$LEGACY_FILES, }.claude/docs/technical-preferences.md"
    fi
  fi
  if [ -n "$LEGACY_FILES" ]; then
    FRESH_PROJECT=false
    echo ""
    echo "⬆️  v1.0 PROJECT: legacy config ($LEGACY_FILES) but no project.yaml."
    echo "   Run: /saas-adopt — it detects this and drives the migration (non-destructive)."
    echo "   Preview first: bash .claude/scripts/migrate-v1-config.sh --dry-run"
  fi
fi

if [ "$FRESH_PROJECT" = true ]; then
  echo ""
  echo "🚀 NEW PROJECT: No stack configured, no product concept, no source code."
  echo "   This looks like a fresh start! Run: /saas-start"
  echo ""
  echo "💡 To get a comprehensive project analysis, run: /saas-project-stage-detect"
  echo "==================================="
  exit 0
fi

# --- Resolve the workflow tier once, for the checks below ---
#
# Checks 1, 3 and 4 all ask "where is the design/architecture document for this
# code?". At `minimal` the answer is that there deliberately is none:
# workflow-modes.md requires only engine choice and a filled
# `design/product-brief.md` before code starts, and says everything else can be
# skipped. Reporting their absence as a GAP nags the user about work their own
# configuration told them to skip -- and a warning that fires when nothing is
# wrong trains the user to ignore the ones that matter.
#
# resolve_setting, NOT get_yaml_key: `modes.workflow` is rigor-fronted, so a
# project that set `rigor: minimal` and nothing else has no `modes.workflow` key
# to read. Only the full chain sees the expansion. Same pattern and same reason
# as validate-commit.sh.
#
# Resolved AFTER the fresh-project early-exit above, so a brand-new project
# never pays for the lookup.
WORKFLOW="standard"
if [ -f .claude/hooks/yaml-helper.sh ]; then
    . .claude/hooks/yaml-helper.sh 2>/dev/null
    W=$(resolve_setting modes.workflow 2>/dev/null | cut -f1)
    [ -n "$W" ] && WORKFLOW="$W"
fi

# Check 2 is NOT gated: an undocumented prototype is a gap about the prototype
# itself, not about the design pipeline the tier scales.
if [ "$WORKFLOW" = "minimal" ]; then
    DOC_CHECKS=false
else
    DOC_CHECKS=true
fi

# --- Resolve the stack-specific code root for checks 1, 3 and 4 ------------
#
# Checks 1, 3 and 4 were all hardcoded to `src/`, which .claude/docs/directory-
# structure.md defines as the Next.js/standard row of the code-root table -- FastAPI uses
# `Assets/`, Cloudflare `Source/`. On those two engines every directory test below
# failed, the source-file count came back 0, and NONE of the three checks ran.
# A project with 200 undocumented FastAPI systems produced the same empty output
# as a fully documented one.
#
# Only the ROOT is stack-specific. The `core/`, `engine/` and `core business workflow/`
# sub-layout is SAAS_STUDIO's own convention, unchanged by the engine, so it stays
# literal.
#
# Resolved AFTER the fresh-project early-exit, so a brand-new project never
# pays for the lookup.
if command -v resolve_code_root >/dev/null 2>&1; then
  CODE_ROOT=$(resolve_code_root 2>/dev/null | cut -f1)
else
  CODE_ROOT=""
fi

# A doc check that cannot locate the code root has not established that there
# are no gaps -- it has established nothing (obligation 1 and 3 of
# .claude/rules/skill-authoring.md). Announce it, once, and only when the checks
# would otherwise have had somewhere to look.
if [ "$DOC_CHECKS" = true ] && [ -z "$CODE_ROOT" ]; then
  if [ -d src ] || [ -d app ] || [ -d pages ] || [ -d server ] || [ -d api ] || [ -d Assets ] || [ -d Source ]; then
    echo "ℹ️  NOT CHECKED: code exists but the code root is ambiguous (stack.frontend/backend unset in project.yaml)."
    echo "    Checks 1, 3 and 4 (design and architecture docs for existing code) did NOT run."
    echo "    Suggested action: /saas-setup-stack, or set stack.frontend in project.yaml"
  fi
fi

# --- Check 1: Substantial codebase but sparse design docs ---
if [ -n "$CODE_ROOT" ] && [ -d "$CODE_ROOT" ]; then
  SRC_FILES=$(find "$CODE_ROOT" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.sql" -o -name "*.prisma" -o -name "*.ts" -o -name "*.cs" \) 2>/dev/null | wc -l)
else
  SRC_FILES=0
fi

DESIGN_FILES=0
SUB_DESIGN_FILES=0
if [ -d "docs/specs" ]; then
  D_CNT=$(find docs/specs -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
  DESIGN_FILES=$((DESIGN_FILES + D_CNT))
  S_CNT=$(find docs/specs -mindepth 2 -type f -name "*.md" 2>/dev/null | wc -l)
  SUB_DESIGN_FILES=$((SUB_DESIGN_FILES + S_CNT))
fi
if [ -d "design/prd" ]; then
  D_CNT=$(find design/prd -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)
  DESIGN_FILES=$((DESIGN_FILES + D_CNT))
  S_CNT=$(find design/prd -mindepth 2 -type f -name "*.md" 2>/dev/null | wc -l)
  SUB_DESIGN_FILES=$((SUB_DESIGN_FILES + S_CNT))
fi

SRC_FILES=$(echo "$SRC_FILES" | tr -d ' ')
DESIGN_FILES=$(echo "$DESIGN_FILES" | tr -d ' ')
SUB_DESIGN_FILES=$(echo "$SUB_DESIGN_FILES" | tr -d ' ')

if [ "$DOC_CHECKS" = true ] && [ "$SRC_FILES" -gt 50 ] && [ "$DESIGN_FILES" -lt 5 ]; then
  echo "⚠️  GAP: Substantial codebase ($SRC_FILES source files) but sparse specs/PRDs ($DESIGN_FILES files in docs/specs/)"
  [ "$SUB_DESIGN_FILES" -gt 0 ] && echo "    Not counted: $SUB_DESIGN_FILES .md file(s) in subfolders"
  echo "    Suggested action: /saas-reverse-document design ${CODE_ROOT:-<code root>}/[module]"
  echo "    Or run: /saas-project-stage-detect to get full analysis"
fi

# --- Check 2: Prototypes without documentation ---
if [ -d "prototypes" ]; then
  PROTOTYPE_DIRS=$(find prototypes -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  UNDOCUMENTED_PROTOS=()

  if [ -n "$PROTOTYPE_DIRS" ]; then
    while IFS= read -r proto_dir; do
      # Normalize path separators for Windows
      proto_dir=$(echo "$proto_dir" | sed 's|\\|/|g')

      # Check for README.md or CONCEPT.md
      if [ ! -f "${proto_dir}/README.md" ] && [ ! -f "${proto_dir}/CONCEPT.md" ]; then
        proto_name=$(basename "$proto_dir")
        UNDOCUMENTED_PROTOS+=("$proto_name")
      fi
    done <<< "$PROTOTYPE_DIRS"

    if [ ${#UNDOCUMENTED_PROTOS[@]} -gt 0 ]; then
      echo "⚠️  GAP: ${#UNDOCUMENTED_PROTOS[@]} undocumented prototype(s) found:"
      for proto in "${UNDOCUMENTED_PROTOS[@]}"; do
        echo "    - prototypes/$proto/ (no README or CONCEPT doc)"
      done
      echo "    Suggested action: /saas-reverse-document concept prototypes/[name]"
    fi
  fi
fi

# --- Check 3: Core systems without architecture docs ---
if [ "$DOC_CHECKS" = true ] && [ -n "$CODE_ROOT" ] && { [ -d "$CODE_ROOT/core" ] || [ -d "$CODE_ROOT/api" ] || [ -d "$CODE_ROOT/server" ] || [ -d "prisma" ] || [ -d "supabase" ]; }; then
  if [ ! -d "docs/architecture" ]; then
    echo "⚠️  GAP: Core systems/APIs exist but no docs/architecture/ directory"
    echo "    Suggested action: Create docs/architecture/ and run /saas-architecture-decision"
  else
    ADR_COUNT=$(find docs/architecture -type f -name "*.md" 2>/dev/null | wc -l)
    ADR_COUNT=$(echo "$ADR_COUNT" | tr -d ' ')

    if [ "$ADR_COUNT" -lt 3 ]; then
      echo "⚠️  GAP: Core systems exist but only $ADR_COUNT ADR(s) documented"
      echo "    Suggested action: /saas-architecture-decision or /saas-reverse-document architecture $CODE_ROOT"
    fi
  fi
fi

# --- Check 4: Modules / Features without specs ---
if [ "$DOC_CHECKS" = true ] && [ -n "$CODE_ROOT" ]; then
  MODULE_PARENT=""
  for d in "$CODE_ROOT/features" "$CODE_ROOT/modules" "$CODE_ROOT/app/api" "$CODE_ROOT/routes" "$CODE_ROOT/core business workflow"; do
    if [ -d "$d" ]; then MODULE_PARENT="$d"; break; fi
  done
  if [ -n "$MODULE_PARENT" ]; then
    MODULE_SYSTEMS=$(find "$MODULE_PARENT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    if [ -n "$MODULE_SYSTEMS" ]; then
      while IFS= read -r system_dir; do
        system_dir=$(echo "$system_dir" | sed 's|\\|/|g')
        system_name=$(basename "$system_dir")
        file_count=$(find "$system_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [ "$file_count" -ge 5 ]; then
          spec_doc_1="docs/specs/${system_name}.md"
          spec_doc_2="docs/specs/${system_name}-prd.md"
          design_doc_1="design/prd/${system_name}.md"
          if [ ! -f "$spec_doc_1" ] && [ ! -f "$spec_doc_2" ] && [ ! -f "$design_doc_1" ]; then
            echo "⚠️  GAP: Feature module '$MODULE_PARENT/$system_name/' ($file_count files) has no spec document"
            echo "    Expected: docs/specs/${system_name}.md"
            echo "    Suggested action: /saas-reverse-document design $MODULE_PARENT/$system_name"
          fi
        fi
      done <<< "$MODULE_SYSTEMS"
    fi
  fi
fi

# --- Check 5: Production planning ---
if [ "$SRC_FILES" -gt 100 ]; then
  # For projects with substantial code, check for production planning
  if [ ! -d "production/sprints" ] && [ ! -d "production/milestones" ]; then
    echo "⚠️  GAP: Large codebase ($SRC_FILES files) but no production planning found"
    echo "    Suggested action: /saas-sprint-plan or create production/ directory"
  fi
fi

# --- Check 6: project.stage is behind what is actually on disk ---
#
# Only a /saas-gate-check PASS (or a CONCERNS whose risks you accepted) advances
# the stage. A project that writes stories and product code without running one
# keeps reporting `Concept` to the status line, to /saas-help, and to every gate
# checklist that branches on stage.
#
# This is an OBSERVATION, never a write. CLAUDE.md is explicit that the stage
# advances on a /saas-gate-check PASS (or a CONCERNS whose risks you accepted) with
# the user confirming, so a hook that advanced it silently would be the worse
# bug. Say what is inconsistent and name
# the skill that resolves it.
#
# Not at `minimal`: nothing on that path runs /saas-gate-check, so a stage that never
# moves is the design, not a gap. The status line shows story progress there
# instead, and /saas-help routes by the brief -- telling the user to run /saas-gate-check
# contradicted both.
STAGE=""
if [ "$WORKFLOW" != "minimal" ] && [ -f .claude/hooks/yaml-helper.sh ]; then
    # get_yaml_key takes the file first; called with the key alone it returned
    # nothing, and only the legacy stage.txt was ever read.
    STAGE=$(get_yaml_key project.yaml project.stage 2>/dev/null)
fi
[ "$WORKFLOW" != "minimal" ] && [ -z "$STAGE" ] && [ -f production/stage.txt ] && STAGE=$(head -1 production/stage.txt 2>/dev/null | tr -d '
' | tr -d ' ')

if [ -n "$STAGE" ]; then
    STORY_COUNT=$(find production/epics -name "story-*.md" 2>/dev/null | wc -l | tr -d ' ')
    case "$STAGE" in
      Concept|concept|Pre-Production|"Pre-Production")
        if [ "$STORY_COUNT" -gt 0 ] && [ "$SRC_FILES" -gt 0 ]; then
            echo "⚠️  GAP: project.stage says '$STAGE', but $STORY_COUNT stories and $SRC_FILES source files exist"
            echo "    The stage only advances on a /saas-gate-check PASS (or a CONCERNS whose risks you accepted),"
            echo "    and none has moved it yet -- so the status line can sit at '$STAGE' indefinitely."
            echo "    Suggested action: /saas-gate-check  (it asks before advancing; this hook never writes the stage)"
        fi
        ;;
    esac
fi

# --- Summary ---
echo ""
echo "💡 To get a comprehensive project analysis, run: /saas-project-stage-detect"
echo "==================================="

exit 0
