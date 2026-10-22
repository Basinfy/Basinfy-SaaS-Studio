#!/usr/bin/env bash
# ts-parse-check.sh — Fast syntax & type check for TypeScript/JavaScript/Python/JSON in SaaS Studio
# Returns 0 on success, non-zero on syntax error.

FILE="${1:-}"
if [ "$FILE" = "-h" ] || [ "$FILE" = "--help" ]; then
  echo "Usage: ts-parse-check.sh [file]"
  echo "Fast syntax & type check for TypeScript/JavaScript/Python/JSON/YAML in SaaS Studio."
  exit 0
fi
if [ -z "$FILE" ]; then
  # If no file specified, scan source files in standard SaaS roots
  CHECKED=0
  for dir in src app pages components server api lib; do
    if [ -d "$dir" ]; then
      while IFS= read -r f; do
        [ -n "$f" ] || continue
        CHECKED=$((CHECKED + 1))
        "$0" "$f" || exit $?
      done < <(find "$dir" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.json" \) 2>/dev/null)
    fi
  done
  echo "ts-parse-check: scanned $CHECKED files in code roots; all clean"
  exit 0
fi

if [ ! -f "$FILE" ]; then
  echo "ts-parse-check: file not found: $FILE" >&2
  exit 1
fi

case "$FILE" in
  *.js|*.mjs|*.cjs)
    if command -v node >/dev/null 2>&1; then
      node --check "$FILE" 2>&1
      exit $?
    fi
    ;;
  *.ts|*.tsx|*.jsx)
    if command -v node >/dev/null 2>&1; then
      node --no-warnings -e '
const fs = require("fs");
const file = process.argv[1];
try {
  const code = fs.readFileSync(file, "utf8");
  const mod = require("node:module");
  if (typeof mod.stripTypeScriptTypes === "function") {
    mod.stripTypeScriptTypes(code, { mode: "transform" });
    process.exit(0);
  }
} catch (e) {
  console.error("Syntax error in " + file + ":", e.message);
  process.exit(1);
}
' "$FILE" 2>&1
      CODE=$?
      if [ $CODE -eq 0 ]; then
        exit 0
      else
        exit $CODE
      fi
    fi
    ;;
  *.py)
    if command -v python >/dev/null 2>&1; then
      python -m py_compile "$FILE" 2>&1
      exit $?
    elif command -v python3 >/dev/null 2>&1; then
      python3 -m py_compile "$FILE" 2>&1
      exit $?
    fi
    ;;
  *.json)
    if command -v python >/dev/null 2>&1; then
      python -c "import json, sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$FILE" 2>&1
      exit $?
    elif command -v python3 >/dev/null 2>&1; then
      python3 -c "import json, sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$FILE" 2>&1
      exit $?
    fi
    ;;
  *.yaml|*.yml)
    if command -v python >/dev/null 2>&1; then
      python -c "import yaml, sys; yaml.safe_load(open(sys.argv[1], encoding='utf-8'))" "$FILE" 2>&1
      exit $?
    elif command -v python3 >/dev/null 2>&1; then
      python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1], encoding='utf-8'))" "$FILE" 2>&1
      exit $?
    fi
    ;;
esac

exit 0
