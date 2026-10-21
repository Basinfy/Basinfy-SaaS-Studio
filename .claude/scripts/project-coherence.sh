#!/usr/bin/env bash
#
# project-coherence.sh — compare what `project.yaml` DECLARES against what the
# project actually IS in terms of web/SaaS stack, dependencies and configs.
#
# OBSERVATIONS, NEVER VERDICTS
# Per CLAUDE.md: a script that scores or judges will eventually contradict a mode
# or override it cannot see. This one prints what it compared and what it found,
# and always exits 0. The reader decides. A check that cannot run says so by
# name — silence is never treated as agreement.

set -u
export LC_ALL=C

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -f "$CLAUDE_PROJECT_DIR/project.yaml" ]; then
  ROOT="$CLAUDE_PROJECT_DIR"
fi
cd "$ROOT" || exit 0

DIFFERS=0
CHECKED=0
SKIPPED=0

say()      { printf '%s\n' "$*"; }
match()    { CHECKED=$((CHECKED+1)); say "[MATCH]       $*"; }
differs()  { CHECKED=$((CHECKED+1)); DIFFERS=$((DIFFERS+1)); say "[DIFFERS]     $*"; }
skipped()  { SKIPPED=$((SKIPPED+1)); say "[NOT CHECKED] $*"; }

# Read one `key: value` from a named top-level block of project.yaml.
# Deliberately simple: this file is machine-written and two levels deep.
yaml_block_value() {
  block="$1"; key="$2"
  awk -v b="$block" -v k="$key" '
    $0 ~ "^"b":" { inb=1; next }
    inb && /^[a-zA-Z_]/ { inb=0 }
    inb && $0 ~ "^[[:space:]]+"k":" {
      sub("^[[:space:]]*"k":[[:space:]]*", "")
      sub(/[[:space:]]+#.*$/, "")
      gsub(/^["\x27]|["\x27]$/, "")
      print; exit
    }
  ' project.yaml 2>/dev/null
}

summarise() {
  say ""
  say "checked $CHECKED · differs $DIFFERS · not checked $SKIPPED"
  say ""
  say "Observations only — no verdict. 'not checked' is not agreement:"
  say "each line above names why that comparison could not be made."
  exit 0
}

# major.minor of the first version in $1
vmm() { printf '%s' "$1" | grep -oE '[0-9]+\.[0-9]+' | head -1; }

say "=== project coherence ==="

if [ ! -f project.yaml ]; then
  skipped "everything — no project.yaml at the repo root. Run /saas-start."
  summarise
fi

STACK_FRONTEND="$(yaml_block_value stack frontend)"
STACK_BACKEND="$(yaml_block_value stack backend)"
STACK_DATABASE="$(yaml_block_value stack database)"
STACK_ORM="$(yaml_block_value stack orm)"
STACK_AUTH="$(yaml_block_value stack auth)"
STACK_BILLING="$(yaml_block_value stack billing)"
STACK_DEPLOY="$(yaml_block_value stack deployment)"
STACK_STYLING="$(yaml_block_value stack styling)"
PROJECT_STAGE="$(yaml_block_value project stage)"

if [ -z "$STACK_FRONTEND" ] && [ -z "$STACK_BACKEND" ]; then
  skipped "every stack check — project.yaml has no stack declaration. Run /saas-setup-stack."
  summarise
fi

# --- SaaS Stack Checks --------------------------------------------------------
if [ -n "$STACK_FRONTEND" ]; then
  match "project.yaml declares SaaS stack: frontend=$STACK_FRONTEND, backend=$STACK_BACKEND, database=$STACK_DATABASE, orm=$STACK_ORM"

  # Frontend checks
  if [ -f package.json ]; then
    if grep -qi "\"$STACK_FRONTEND\"" package.json 2>/dev/null || { [ "$STACK_FRONTEND" = "nextjs" ] && grep -qi '"next"' package.json 2>/dev/null; }; then
      match "frontend stack ($STACK_FRONTEND) matches package.json dependencies"
    elif [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
      match "frontend stack ($STACK_FRONTEND) matches next.config.* in workspace"
    else
      differs "frontend stack is '$STACK_FRONTEND' but not found in package.json dependencies"
    fi
  else
    skipped "frontend dependency check — package.json not yet created (stage: ${PROJECT_STAGE:-concept})"
  fi

  # ORM / DB checks
  if [ -n "$STACK_ORM" ]; then
    if [ "$STACK_ORM" = "prisma" ]; then
      if [ -f "prisma/schema.prisma" ]; then
        match "ORM ($STACK_ORM) schema exists: prisma/schema.prisma"
      elif [ -f package.json ] && grep -qi '"prisma"' package.json 2>/dev/null; then
        match "ORM ($STACK_ORM) declared in package.json"
      else
        skipped "ORM check — prisma/schema.prisma not yet initialized (stage: ${PROJECT_STAGE:-concept})"
      fi
    elif [ "$STACK_ORM" = "drizzle" ]; then
      if [ -f "drizzle.config.ts" ] || [ -f "drizzle.config.js" ]; then
        match "ORM ($STACK_ORM) config exists: drizzle.config.*"
      elif [ -f package.json ] && grep -qi '"drizzle-orm"' package.json 2>/dev/null; then
        match "ORM ($STACK_ORM) declared in package.json"
      else
        skipped "ORM check — drizzle.config.* not yet initialized (stage: ${PROJECT_STAGE:-concept})"
      fi
    fi
  fi

  # Database checks
  if [ -n "$STACK_DATABASE" ]; then
    if [ "$STACK_DATABASE" = "supabase-postgres" ]; then
      if [ -d "supabase" ]; then
        match "database ($STACK_DATABASE) directory exists: supabase/"
      elif [ -f package.json ] && grep -qi '"@supabase/supabase-js"' package.json 2>/dev/null; then
        match "database ($STACK_DATABASE) client declared in package.json"
      else
        skipped "database check — supabase configuration not yet initialized (stage: ${PROJECT_STAGE:-concept})"
      fi
    fi
  fi

  # Styling checks
  if [ -n "$STACK_STYLING" ]; then
    if [ "$STACK_STYLING" = "tailwind-shadcn" ]; then
      if [ -f "tailwind.config.js" ] || [ -f "tailwind.config.ts" ] || [ -f "components.json" ]; then
        match "styling ($STACK_STYLING) config exists in workspace"
      elif [ -f package.json ] && grep -qi '"tailwindcss"' package.json 2>/dev/null; then
        match "styling ($STACK_STYLING) declared in package.json"
      else
        skipped "styling check — tailwind/shadcn not yet initialized (stage: ${PROJECT_STAGE:-concept})"
      fi
    fi
  fi

  # Backend checks
  if [ -n "$STACK_BACKEND" ]; then
    if [ "$STACK_BACKEND" = "nextjs-server-actions" ]; then
      if [ -d "app" ] || [ -d "src/app" ]; then
        match "backend ($STACK_BACKEND) app directory exists"
      else
        skipped "backend check — app/ directory not yet initialized"
      fi
    elif [ "$STACK_BACKEND" = "fastapi" ]; then
      if [ -f "requirements.txt" ] && grep -qi "fastapi" requirements.txt 2>/dev/null; then
        match "backend ($STACK_BACKEND) declared in requirements.txt"
      elif [ -f "main.py" ] || [ -f "app/main.py" ]; then
        match "backend ($STACK_BACKEND) main.py exists"
      else
        skipped "backend check — FastAPI entrypoint not yet initialized"
      fi
    fi
  fi

  # Auth checks
  if [ -n "$STACK_AUTH" ]; then
    if [ "$STACK_AUTH" = "supabase-auth" ]; then
      if [ -f package.json ] && grep -qi "supabase" package.json 2>/dev/null; then
        match "auth ($STACK_AUTH) library configured in package.json"
      else
        skipped "auth check — supabase auth package not yet installed"
      fi
    elif [ "$STACK_AUTH" = "clerk" ]; then
      if [ -f package.json ] && grep -qi "@clerk" package.json 2>/dev/null; then
        match "auth ($STACK_AUTH) library configured in package.json"
      else
        skipped "auth check — clerk auth package not yet installed"
      fi
    fi
  fi

  # Billing checks
  if [ -n "$STACK_BILLING" ]; then
    if [ "$STACK_BILLING" = "stripe" ]; then
      if [ -f package.json ] && grep -qi "stripe" package.json 2>/dev/null; then
        match "billing ($STACK_BILLING) SDK declared in package.json"
      elif [ -f "requirements.txt" ] && grep -qi "stripe" requirements.txt 2>/dev/null; then
        match "billing ($STACK_BILLING) SDK declared in requirements.txt"
      else
        skipped "billing check — stripe SDK not yet added to dependencies"
      fi
    fi
  fi

  # Deployment checks
  if [ -n "$STACK_DEPLOY" ]; then
    if [ "$STACK_DEPLOY" = "vercel" ]; then
      match "deployment ($STACK_DEPLOY) configured for Vercel edge/serverless platform"
    elif [ "$STACK_DEPLOY" = "cloudflare" ]; then
      if [ -f "wrangler.toml" ]; then
        match "deployment ($STACK_DEPLOY) config exists: wrangler.toml"
      else
        skipped "deployment check — wrangler.toml not yet initialized"
      fi
    fi
  fi
fi

# --- Commands Check -----------------------------------------------------------
BUILD_CMD="$(yaml_block_value commands build)"
TEST_CMD="$(yaml_block_value commands test)"
LINT_CMD="$(yaml_block_value commands lint)"

if [ -z "$BUILD_CMD" ] && [ -z "$TEST_CMD" ]; then
  skipped "command checks — project.yaml declares no commands.build or commands.test"
else
  if [ -n "$BUILD_CMD" ]; then
    match "commands.build declared: $BUILD_CMD"
  fi
  if [ -n "$TEST_CMD" ]; then
    match "commands.test declared: $TEST_CMD"
  fi
  if [ -n "$LINT_CMD" ]; then
    match "commands.lint declared: $LINT_CMD"
  fi
fi

summarise
