#!/usr/bin/env bash
# test-scaffold.sh — creates the testing infrastructure files for a SaaS project,
# never overwriting one that exists, and prints per path whether it was
# created, already there or skipped, then the inputs it still needs.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# It reports what it did with each path and what is still missing; whether
# the project may advance a gate on the strength of it is the skill's call.
#
# Usage: bash .claude/scripts/test-scaffold.sh [STACK] [--dry-run | --list] [--root DIR]
#          [--date YYYY-MM-DD]
#   STACK           saas, nextjs, react, node, python, fastapi, go (default: saas)
#   --dry-run       print what would be created (WOULD_CREATE), write nothing
#   --list          print the project-relative paths this stack's scaffold creates
#   --root DIR      the project; defaults to repo root
#   --date D        the setup date for the README (default: today)
#   -h, --help      this text

set -u
LC_ALL=C
export LC_ALL

HERE="$(cd "$(dirname "$0")" && pwd)"
usage() { echo "test-scaffold: $1 (try --help)" >&2; exit 2; }
TAB=$(printf '\t')

ENGINE=""; MODE=write; ROOT_ARG=""; DATE_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) [ "$MODE" != list ] || usage "--list and --dry-run cannot be combined"; MODE=dry-run; shift ;;
    --list) [ "$MODE" != dry-run ] || usage "--list and --dry-run cannot be combined"; MODE=list; shift ;;
    --root) [ $# -ge 2 ] || usage "--root needs a value"; ROOT_ARG="$2"; shift 2 ;;
    --date) [ $# -ge 2 ] || usage "--date needs a value"; DATE_ARG="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -?*) usage "unknown argument: $1" ;;
    *) [ -z "$ENGINE" ] || usage "one stack at a time, got $ENGINE and $1"; ENGINE="$1"; shift ;;
  esac
done

if [ -z "$ENGINE" ]; then
  if [ -f project.yaml ] && [ -f "$HERE/yaml-get.awk" ]; then
    ENGINE=$(YG_PATH=stack.frontend awk -f "$HERE/yaml-get.awk" project.yaml 2>/dev/null)
    [ -z "$ENGINE" ] && ENGINE=$(YG_PATH=stack.frontend awk -f "$HERE/yaml-get.awk" project.yaml 2>/dev/null)
  fi
  [ -z "$ENGINE" ] && ENGINE="saas"
fi

ENG="saas"
ENGNAME="SaaS (Modern Web)"

if [ -n "$DATE_ARG" ]; then
  case "$DATE_ARG" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
    *) usage "--date takes YYYY-MM-DD, got $DATE_ARG" ;;
  esac
fi

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "test-scaffold: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "test-scaffold: cannot reach the repo root" >&2; exit 1; }
fi

DATE="${DATE_ARG:-$(date +%Y-%m-%d 2>/dev/null || date -u +%Y-%m-%d)}"

# --- file list ---
scaffold_paths() {
  echo "tests/README.md"
  echo "production/qa/evidence/.gitkeep"
  echo "tests/unit/.gitkeep"
  echo "tests/integration/.gitkeep"
  echo "tests/e2e/.gitkeep"
  echo ".github/workflows/tests.yml"
  echo "tests/smoke/critical-paths.md"
}

if [ "$MODE" = list ]; then
  scaffold_paths
  exit 0
fi

printf 'engine\t%s\tmode\t%s\n' "$ENGNAME" "$MODE"

tpl_readme_saas() {
cat <<TPL_README_SAAS
# Test Infrastructure

**Stack**: $ENGNAME
**Test Framework**: Vitest / Playwright / Pytest / Go test
**CI**: \`.github/workflows/tests.yml\`
**Setup date**: $DATE

## Directory Layout

\`\`\`
tests/
  unit/           # Isolated unit tests (schemas, utility functions, business logic)
  integration/    # Integration tests (API route handlers, database queries, webhooks)
  e2e/            # End-to-end tests (user flows, Playwright/Cypress)
  smoke/          # Critical path test list for /saas-smoke-check gate
\`\`\`

\`\`\`
production/qa/
  evidence/       # Screenshot logs and manual test sign-off records
\`\`\`

## Running Tests

- **Unit & Integration**: \`npm test\` or \`npx vitest run\` (Python: \`pytest\`, Go: \`go test ./...\`)
- **End-to-End**: \`npx playwright test\`
- **Smoke Check**: \`/saas-smoke-check\`

## Test Naming

- **Unit/Integration**: \`[module].test.ts\` or \`[module].spec.ts\`
- **E2E**: \`[flow].e2e.ts\`
TPL_README_SAAS
}

tpl_ci_saas() {
cat <<'TPL_CI_SAAS'
name: Tests

on:
  push:
    branches: [main, master, develop]
  pull_request:
    branches: [main, master]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - name: Install dependencies
        run: npm ci || npm install
      - name: Run unit & integration tests
        run: npm test --if-present
TPL_CI_SAAS
}

tpl_smoke() {
cat <<'TPL_SMOKE'
# Critical Paths — Smoke Test Seed

List of critical paths verified by `/saas-smoke-check`:
1. Authentication (Signup, Login, Session Refresh)
2. Core Feature Workflow
3. Billing & Subscription Webhooks
4. API Health Endpoint (/api/health)
TPL_SMOKE
}

CREATED=0
WOULD=0
EXISTS_N=0
SKIPPED=0

write_file() {
  local p="$1" content="$2"
  if [ -e "$p" ]; then
    printf 'EXISTS\t%s\n' "$p"
    EXISTS_N=$((EXISTS_N + 1))
    return
  fi
  if [ "$MODE" = dry-run ]; then
    printf 'WOULD_CREATE\t%s\n' "$p"
    WOULD=$((WOULD + 1))
    return
  fi
  local dir="${p%/*}"
  [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null
  printf '%s\n' "$content" > "$p" 2>/dev/null
  if [ $? -eq 0 ]; then
    printf 'CREATED\t%s\n' "$p"
    CREATED=$((CREATED + 1))
  else
    printf 'FAILED\t%s\tcannot write\n' "$p"
    SKIPPED=$((SKIPPED + 1))
  fi
}

write_file "tests/README.md" "$(tpl_readme_saas)"
write_file "production/qa/evidence/.gitkeep" ""
write_file "tests/unit/.gitkeep" ""
write_file "tests/integration/.gitkeep" ""
write_file "tests/e2e/.gitkeep" ""
write_file ".github/workflows/tests.yml" "$(tpl_ci_saas)"
write_file "tests/smoke/critical-paths.md" "$(tpl_smoke)"

if [ "$MODE" = dry-run ]; then
  printf 'would_create\t%s\texists\t%s\tskipped\t%s\n' "$WOULD" "$EXISTS_N" "$SKIPPED"
else
  printf 'created\t%s\texists\t%s\tskipped\t%s\n' "$CREATED" "$EXISTS_N" "$SKIPPED"
fi
exit 0
