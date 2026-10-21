#!/usr/bin/env bash
# test-run.sh — run a SaaS project's automated tests under a timeout, and read
# the result with the exit-code ladder for web/SaaS testing stacks (Vitest, Jest,
# Pytest, Go test, Playwright).
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# The `rule` row says which row of the ladder the exit code and output fall on;
# PASS, FAIL, NOT ASSESSED stay with the calling skill (/saas-smoke-check).
#
# Usage: bash .claude/scripts/test-run.sh [stack] [options]
#   [stack]             saas, nextjs, react, node, python, fastapi, go (default: saas)
#   --cmd COMMAND       the test command to run, instead of project.yaml's
#                       commands.test or the framework default
#   --exe PATH          optional test runner executable
#   --timeout SECONDS   default 900
#   --tool T            force timeout tool: timeout, gtimeout, perl or none
#   --log FILE          keep the runner's output here (default: temp file)
#   --dry-run           print what would run; run nothing
#   --root DIR          the project; defaults to repo root
#   -h, --help          this text
#
# Output: TSV.
#   engine      SaaS
#   exe         <path|->  <source>
#   command     <source>  <command>
#   timeout     <seconds> <tool>
#   precheck    <what>    <present|absent>
#   ran         <yes|no>  <reason>
#   exit        <exit-code>
#   timed_out   <yes|no>
#   zero_tests  <yes|no|unknown>  <marker>
#   tests       <summary>
#   rule        <id>      <description>
#   log         <path>

set -u
LC_ALL=C
export LC_ALL

HERE="$(cd "$(dirname "$0")" && pwd)"
usage() { echo "test-run: $1 (try --help)" >&2; exit 2; }

STACK_ARG=""; CMD_ARG=""; EXE_ARG=""; TIMEOUT=900; TOOL_ARG=""
LOG=""; DRY=0; ROOT_ARG=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --dry-run) DRY=1; shift ;;
    --cmd|--exe|--timeout|--log|--root|--tool)
      [ $# -ge 2 ] || usage "$1 needs a value"
      case "$1" in
        --cmd) CMD_ARG="$2" ;; --exe) EXE_ARG="$2" ;;
        --timeout) TIMEOUT="$2" ;; --log) LOG="$2" ;;
        --root) ROOT_ARG="$2" ;; --tool) TOOL_ARG="$2" ;;
      esac
      shift 2 ;;
    -?*) usage "unknown argument: $1" ;;
    *) [ -z "$STACK_ARG" ] || usage "one stack only"; STACK_ARG="$1"; shift ;;
  esac
done

if [ -z "$STACK_ARG" ]; then
  if [ -f project.yaml ] && [ -f "$HERE/yaml-get.awk" ]; then
    STACK_ARG=$(YG_PATH=stack.frontend awk -f "$HERE/yaml-get.awk" project.yaml 2>/dev/null)
    [ -z "$STACK_ARG" ] && STACK_ARG=$(YG_PATH=stack.frontend awk -f "$HERE/yaml-get.awk" project.yaml 2>/dev/null)
  fi
  [ -z "$STACK_ARG" ] && STACK_ARG="saas"
fi

case "$(printf '%s' "$STACK_ARG" | tr 'A-Z' 'a-z')" in
  saas|nextjs*|react*|node*|python*|fastapi*|go*|web|fullstack|studio|*)
    ENGINE=saas; ENAME="SaaS" ;;
esac

case "$TIMEOUT" in ''|*[!0-9]*) usage "--timeout is whole seconds" ;; esac
[ "$TIMEOUT" -gt 0 ] || usage "--timeout must be above 0"

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "test-run: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "test-run: cannot reach the repo root" >&2; exit 1; }
fi

printf 'engine\t%s\n' "$ENAME"

# --- runner executable ---
EXE="${EXE_ARG:--}"; EXE_SRC="-"
[ -n "$EXE_ARG" ] && EXE_SRC="--exe"
printf 'exe\t%s\t%s\n' "$EXE" "$EXE_SRC"

# --- timeout tool ---
if [ -n "$TOOL_ARG" ]; then
  case "$TOOL_ARG" in timeout|gtimeout|perl|none) TOOL="$TOOL_ARG" ;; *) usage "--tool is timeout, gtimeout, perl or none" ;; esac
elif command -v timeout >/dev/null 2>&1; then TOOL=timeout
elif command -v gtimeout >/dev/null 2>&1; then TOOL=gtimeout
elif command -v perl >/dev/null 2>&1; then TOOL=perl
else TOOL=none; fi

PERL_TIMEOUT='
  my $t = shift @ARGV;
  my $pid = fork;
  defined $pid or die "test-run: fork failed: $!\n";
  if ($pid == 0) { setpgrp(0, 0); exec @ARGV or exit 127; }
  setpgrp($pid, $pid);
  my $timed = 0;
  $SIG{ALRM} = sub { if ($timed++) { kill "KILL", -$pid } else { kill "TERM", -$pid; alarm 5 } };
  for my $s (qw(INT TERM HUP)) { $SIG{$s} = sub { kill $_[0], -$pid } }
  alarm $t;
  my $st = 0;
  while (1) {
    my $w = waitpid($pid, 0);
    if ($w == $pid) { $st = $?; last }
    last if $w == -1;
  }
  alarm 0;
  if ($timed) {
    for (1 .. 50) { last unless kill 0, -$pid; select(undef, undef, undef, 0.1) }
    kill "KILL", -$pid if kill 0, -$pid;
    exit 142;
  }
  exit(($st & 127) ? 128 + ($st & 127) : $st >> 8);
'

run_timed() {
  case "$TOOL" in
    timeout|gtimeout) "$TOOL" "$1" bash -c "$2" ;;
    perl) perl -e "$PERL_TIMEOUT" "$1" bash -c "$2" ;;
    *) bash -c "$2" ;;
  esac
}

is_timeout() {
  case "$TOOL" in
    timeout|gtimeout) [ "$1" = 124 ] ;;
    perl) [ "$1" = 142 ] ;;
    *) return 1 ;;
  esac
}

# --- test command resolution ---
CMD=""; CMD_SRC="default"
if [ -n "$CMD_ARG" ]; then
  CMD="$CMD_ARG"; CMD_SRC="--cmd"
elif [ -f project.yaml ] && [ -f "$HERE/yaml-get.awk" ]; then
  CFG_TEST=$(YG_PATH=commands.test awk -f "$HERE/yaml-get.awk" project.yaml 2>/dev/null)
  if [ -n "$CFG_TEST" ]; then
    CMD="$CFG_TEST"; CMD_SRC="commands.test"
  fi
fi

if [ -z "$CMD" ]; then
  if [ -f package.json ] && grep -qi '"test":' package.json 2>/dev/null; then
    CMD="npm test"
  elif [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ] || [ -f "vitest.config.mjs" ]; then
    CMD="npx vitest run"
  elif [ -f "jest.config.js" ] || [ -f "jest.config.ts" ] || [ -f "jest.config.mjs" ]; then
    CMD="npx jest"
  elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    CMD="pytest"
  elif [ -f "go.mod" ]; then
    CMD="go test ./..."
  else
    CMD="npm test"
  fi
fi

printf 'command\t%s\t%s\n' "$CMD_SRC" "$CMD"
printf 'timeout\t%s\t%s\n' "$TIMEOUT" "$TOOL"

# --- prechecks ---
if [ -f package.json ] || [ -f pyproject.toml ] || [ -f go.mod ] || [ -d tests ]; then
  printf 'precheck\ttest environment\tpresent\n'
else
  printf 'precheck\ttest environment\tabsent\n'
fi

if [ "$DRY" = 1 ]; then
  printf 'ran\tno\tdry run\n'
  exit 0
fi

# --- execution ---
if [ -z "$LOG" ]; then
  LOG=$(mktemp "${TMPDIR:-/tmp}/test-run-XXXXXX" 2>/dev/null) || { echo "test-run: cannot create a log file" >&2; exit 1; }
fi
: > "$LOG" 2>/dev/null || { echo "test-run: cannot write the log $LOG" >&2; exit 1; }

run_timed "$TIMEOUT" "$CMD" > "$LOG" 2>&1
CODE=$?
printf 'ran\tyes\t-\n'
printf 'exit\t%s\n' "$CODE"
TIMED=no
is_timeout "$CODE" && TIMED=yes
printf 'timed_out\t%s\n' "$TIMED"

# --- output analysis ---
first_line() { grep -E -m 1 "$1" "$LOG" 2>/dev/null | head -1 | tr -d '\r'; }
list_failed() {
  n=$(grep -E -c "$1" "$2" 2>/dev/null); n=${n:-0}
  grep -E "$1" "$2" 2>/dev/null | head -10 | tr -d '\r' | while IFS= read -r l; do printf 'failed\t%s\n' "$(printf '%s' "$l" | sed 's/^[[:blank:]]*//')"; done
  [ "$n" -gt 10 ] && printf 'failed_more\t%s\n' "$((n - 10))"
  return 0
}

marker=$(first_line '(No test files found|collected 0 items|0 passed, 0 failed|no tests to run|PASS.*0 tests|ran 0 tests)')
if [ -n "$marker" ]; then printf 'zero_tests\tyes\t%s\n' "$marker"; else printf 'zero_tests\tno\t-\n'; fi

summary=$(grep -E '(Tests:|passed,|failed,|=== .* passed)' "$LOG" 2>/dev/null | tail -1 | tr -d '\r')
if [ -n "$summary" ]; then
  printf 'tests\t%s\n' "$summary"
else
  printf 'tests\t-\toutput captured in log\n'
fi

list_failed '(FAIL|FAILED|✕|--- FAIL:)' "$LOG"

case "$CODE" in
  0)
    if [ -n "$marker" ]; then
      RULE_ID="saas:zero-tests"; RULE_TXT="exit 0 over zero tests: runner found no test cases"
    else
      RULE_ID="saas:0"; RULE_TXT="exit 0: every test passed"
    fi ;;
  126|127)
    RULE_ID="runner-unavailable"; RULE_TXT="test runner was not found on PATH or not executable" ;;
  *)
    if [ -n "$marker" ]; then
      RULE_ID="saas:no-tests"; RULE_TXT="runner failed and reported zero tests"
    else
      RULE_ID="saas:fail"; RULE_TXT="test run failed (exit $CODE)"
    fi ;;
esac

if [ "$TIMED" = yes ]; then
  RULE_ID="timeout"; RULE_TXT="test run did not complete: timed out after ${TIMEOUT}s"
fi

printf 'rule\t%s\t%s\n' "$RULE_ID" "$RULE_TXT"
printf 'log\t%s\n' "$LOG"
exit 0
