#!/usr/bin/env bash
# read-guard.sh -- whether a Read is a whole-file read of a large design doc,
# and that doc's headings, so it can be read by section instead. The hook
# validate-read.sh calls `check` and refuses the read when it prints a LARGE
# row; a skill or another tool's hook can call it the same way, because hooks
# do not run in every tool.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
#
# Usage: bash .claude/scripts/read-guard.sh [--root DIR] <command> <path> [options]
#   check <path> [--bounded yes|no]
#                what the guard sees for a read of <path> (project-relative):
#                --bounded yes when the read gives an offset or a limit
#   sections <path>
#                each markdown heading of <path> with its line number,
#                skipping lines inside ``` or ~~~ fences (a fence closes only
#                on a run of its own character at least as long)
#   --root DIR   the project; defaults to the repo this script is in
#   -h, --help   this text
#
# Output of check: TSV rows, in this order
#   guard <on | off> <source>          features.read_guard
#   threshold <bytes> <source>         features.read_guard_kb x 1024
#   watched <yes | no>                 under design/, docs/architecture/ or
#                                      production/session-state/, and not an
#                                      image or a PDF
#   size <bytes | ->                   - when the file is not there
#   bounded <yes | no>
#   LARGE <path> <bytes> <threshold>   only when the guard is on, the file is
#                                      watched, the read is unbounded and the
#                                      file is over the threshold
# Output of sections: <line> TAB <heading line as written>
#
# Settings are read with yaml-get.awk, as the other helpers read project.yaml:
# project.local.yaml, then project.yaml, then the default (on, 40 KB).
# read_guard takes on or off, and true or false, YAML's other spelling of the
# two; another value is passed over, and when no file sets a valid one the
# guard row names it. The bar is file size, not lines, because token cost
# follows bytes.
#
# Exit codes: 0 read (what it found is rows); 1 the root cannot be read;
# 2 usage error. Reads only; never prompts.
#
# bash 3.2 and BWK awk safe, no Python.

set -u
LC_ALL=C
export LC_ALL

usage() { echo "read-guard: $1 (try --help)" >&2; exit 2; }
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT_ARG=""; CMD=""; RPATH=""; BOUNDED=no; NPOS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || usage "--root needs a value"; ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    --bounded) [ $# -ge 2 ] || usage "--bounded needs yes or no"; BOUNDED="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# //; s/^#//'; exit 0 ;;
    -*) usage "unknown option: $1" ;;
    *) NPOS=$((NPOS + 1))
       case $NPOS in 1) CMD="$1" ;; 2) RPATH="$1" ;; *) usage "too many arguments" ;; esac
       shift ;;
  esac
done
case "$CMD" in
  check|sections) ;;
  "") usage "no command" ;;
  *) usage "unknown command: $CMD" ;;
esac
[ -n "$RPATH" ] || usage "$CMD needs a path"
case "$BOUNDED" in yes|no) ;; *) usage "--bounded is yes or no, not $BOUNDED" ;; esac
[ "$CMD" = sections ] && [ "$BOUNDED" = yes ] && usage "--bounded is for check"

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "read-guard: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "read-guard: cannot reach the repo root" >&2; exit 1; }
fi
RPATH=$(printf '%s' "$RPATH" | sed 's|\\|/|g; s|^\./||')

if [ "$CMD" = sections ]; then
  [ -f "$RPATH" ] || exit 0
  # A fence opens on 3 or more ` or ~ after at most 3 spaces, and closes only
  # on a run of the same character at least as long with nothing after it,
  # so a ``` line inside a ```` or ~~~ fence stays inside.
  awk 'BEGIN { BINMODE = 3 }
    function run(s, c,    k) { k = 0; while (substr(s, k + 1, 1) == c) k++; return k }
    { sub(/\r$/, ""); l = $0; n = 0; while (n < 3 && substr(l, n + 1, 1) == " ") n++; l = substr(l, n + 1) }
    fc != "" {
      k = run(l, fc); r = substr(l, k + 1); sub(/^[ \t]+/, "", r)
      if (k >= fl && r == "") fc = ""
      next
    }
    { c = substr(l, 1, 1) }
    (c == "`" || c == "~") && run(l, c) >= 3 { fc = c; fl = run(l, c); next }
    /^#+[ \t]/ { print NR "\t" $0 }' "$RPATH"
  exit 0
fi

# ------------------------------------------------------------------ check
GUARD=on; GSRC=default; KB=40; KSRC=default
# rg_get FILE KEY -- the value at KEY in FILE, or nothing.
rg_get() { [ -f "$1" ] && YG_PATH="$2" awk -f "$HERE/yaml-get.awk" "$1"; }
if [ -f "$HERE/yaml-get.awk" ]; then
  _rgbad=""
  for _rgf in project.local.yaml project.yaml; do
    _rgv=$(rg_get "$_rgf" features.read_guard)
    case "$_rgv" in
      on|true) GUARD=on; GSRC="$_rgf"; break ;;
      off|false) GUARD=off; GSRC="$_rgf"; break ;;
      "") ;;
      *) [ -n "$_rgbad" ] || _rgbad="$_rgv" ;;
    esac
  done
  [ "$GSRC" = default ] && [ -n "$_rgbad" ] && GSRC="default (read_guard is $_rgbad, not on or off)"
  # The first file that sets read_guard_kb decides it, whole number or not.
  for _rgf in project.local.yaml project.yaml; do
    _rgv=$(rg_get "$_rgf" features.read_guard_kb)
    [ -n "$_rgv" ] || continue
    case "$_rgv" in
      *[!0-9]*|0) KSRC="default (read_guard_kb is $_rgv, not a whole number of KB)" ;;
      *) KB="$_rgv"; KSRC="$_rgf" ;;
    esac
    break
  done
else
  GSRC="default (yaml-get.awk missing)"; KSRC="$GSRC"
fi
LIMIT=$((KB * 1024))

WATCHED=no
case "$RPATH" in
  design/*|docs/architecture/*|production/session-state/*) WATCHED=yes ;;
esac
# Images and PDFs are read whole by the Read tool's own rules, not by lines.
shopt -s nocasematch
case "$RPATH" in *.png|*.jpg|*.jpeg|*.gif|*.webp|*.bmp|*.ico|*.pdf|*.ipynb) WATCHED=no ;; esac
shopt -u nocasematch

SIZE=-
[ -f "$RPATH" ] && SIZE=$(wc -c < "$RPATH" | tr -d ' ')

printf 'guard\t%s\t%s\nthreshold\t%s\t%s\nwatched\t%s\nsize\t%s\nbounded\t%s\n' \
  "$GUARD" "$GSRC" "$LIMIT" "$KSRC" "$WATCHED" "$SIZE" "$BOUNDED"
if [ "$GUARD" = on ] && [ "$WATCHED" = yes ] && [ "$BOUNDED" = no ] && [ "$SIZE" != - ] && [ "$SIZE" -gt "$LIMIT" ]; then
  printf 'LARGE\t%s\t%s\t%s\n' "$RPATH" "$SIZE" "$LIMIT"
fi
exit 0
