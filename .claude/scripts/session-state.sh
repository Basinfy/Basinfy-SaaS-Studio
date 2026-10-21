#!/usr/bin/env bash
# session-state.sh — read and write production/session-state/active.md in the
# layout .claude/docs/templates/session-state.md defines, so a skill hands
# over the words and this script places them.
#
# Replaces the hand-run checkpoint steps in /saas-story-done and /saas-dev-story.
#
# rotate-session-state.sh owns the layout: the file splits at the
# `<!-- /CHECKPOINT -->` marker, the checkpoint above it, the narrative below.
# A marker here is a line holding only the marker (spaces and CR ignored);
# the same words inside a sentence, as in the template's own HOW comment, are
# not a marker.
#
# Usage: bash .claude/scripts/session-state.sh <command> [--root DIR]
#   show        print the STATUS block (when there is one) through the end of
#               the CHECKPOINT block
#   checkpoint  replace what is between the CHECKPOINT markers with stdin.
#               No file: create it from the template first. A file with no
#               CHECKPOINT markers: add the block after the STATUS block, or,
#               with no STATUS block either, put the template's STATUS and
#               CHECKPOINT blocks at the top and leave the rest as it was.
#   append      add stdin at the end of the file (after the narrative), unless
#               the file already ends with exactly those lines. No file: create
#               it from the template first.
#   --root DIR  the project; defaults to the repo this script is in
#   -h, --help  this text
# Stdin may include or leave out the two CHECKPOINT marker lines; blank lines
# at its start and end are dropped. The file's line endings (LF or CRLF) are
# kept for every line written. The new file is made in full first, then copied
# over active.md in place, so it keeps its mode and a symlink stays one.
#
# Output (checkpoint, append): TSV
#   file   production/session-state/active.md   <created|replaced|inserted|appended|unchanged>
#   lines  <lines written from stdin>           -
# show prints the block lines themselves.
#
# Exit codes: 0 done; 1 cannot read the root, find the template, or write the
# file; 2 usage error (no command, nothing on stdin); 3 the file has one
# CHECKPOINT marker without the other, or they are out of order (nothing is
# written: the same refusal rotate-session-state.sh gives, with the same code);
# 4 `show` found no active.md. Never prompts. Observations only: what goes in
# the checkpoint is the skill's to write.
#
# bash 3.2 and BWK awk safe, no Python.

set -u
# Byte semantics for awk: the CR tests below compare bytes.
LC_ALL=C
export LC_ALL

STATE="production/session-state/active.md"
TEMPLATE=".claude/docs/templates/session-state.md"
# The template asks for a checkpoint under ~25 lines because session-start.sh
# shows it whole in every new session; longer is allowed but warned about.
MAX_LINES=25

CMD=""
ROOT_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    show|checkpoint|append)
      [ -z "$CMD" ] || { echo "session-state: one command only" >&2; exit 2; }
      CMD="$1"; shift ;;
    --root)
      [ $# -ge 2 ] || { echo "session-state: --root needs a value" >&2; exit 2; }
      ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "session-state: unknown argument: $1 (try --help)" >&2; exit 2 ;;
  esac
done
[ -n "$CMD" ] || { echo "session-state: no command; use show, checkpoint or append (try --help)" >&2; exit 2; }

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "session-state: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$(dirname "$0")/../.." 2>/dev/null || { echo "session-state: cannot reach the repo root" >&2; exit 1; }
fi

# locate FILE — print "so sc co cc": the line numbers of the STATUS opener and
# closer and the CHECKPOINT opener and the first closer after it (0 = none).
# `co` with `cc` 0, or a closer with no opener, means a broken block.
locate() {
  awk '
    function is(m) { return line == m }
    { line = $0; sub(/\r$/, "", line); sub(/^[ \t]+/, "", line); sub(/[ \t]+$/, "", line) }
    is("<!-- STATUS -->") && !so { so = NR }
    is("<!-- /STATUS -->") && so && !sc { sc = NR }
    is("<!-- CHECKPOINT -->") && !co { co = NR }
    is("<!-- /CHECKPOINT -->") { if (co && !cc) cc = NR; else if (!co) stray = NR }
    END { if (stray && !co) cc = stray; printf "%d %d %d %d\n", so, sc, co, cc }
  ' "$1"
}

if [ "$CMD" = "show" ]; then
  [ -f "$STATE" ] || { echo "session-state: no $STATE" >&2; exit 4; }
  set -- $(locate "$STATE")
  so=$1; sc=$2; co=$3; cc=$4
  if [ "$co" = 0 ] || [ "$cc" = 0 ] || [ "$cc" -lt "$co" ]; then
    echo "session-state: $STATE has no complete CHECKPOINT block (<!-- CHECKPOINT --> ... <!-- /CHECKPOINT -->)" >&2
    exit 3
  fi
  start=$co
  [ "$so" -gt 0 ] && [ "$sc" -gt "$so" ] && [ "$so" -lt "$co" ] && start=$so
  awk -v a="$start" -v b="$cc" 'NR >= a && NR <= b { sub(/\r$/, ""); print }' "$STATE"
  exit 0
fi

# --- checkpoint / append: read stdin -----------------------------------------
STATE_DIR=$(dirname "$STATE")
mkdir -p "$STATE_DIR" 2>/dev/null || { echo "session-state: cannot create $STATE_DIR" >&2; exit 1; }
BODY=$(mktemp "$STATE_DIR/.saas-body-XXXXXX" 2>/dev/null) || { echo "session-state: cannot create a temporary file in $STATE_DIR" >&2; exit 1; }
NEW=$(mktemp "$STATE_DIR/.saas-state-XXXXXX" 2>/dev/null) || { rm -f "$BODY"; echo "session-state: cannot create a temporary file in $STATE_DIR" >&2; exit 1; }
trap 'rm -f "$BODY" "$NEW"' EXIT
# CR off, marker lines out, blank lines at both ends dropped.
awk '
  { sub(/\r$/, ""); t = $0; sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t) }
  t == "<!-- CHECKPOINT -->" || t == "<!-- /CHECKPOINT -->" { next }
  { l[++n] = $0; if (t != "") { if (!first) first = n; last = n } }
  END { for (i = first; first && i <= last; i++) print l[i] }
' > "$BODY"
NBODY=$(wc -l < "$BODY" | tr -d ' ')
[ "$NBODY" -gt 0 ] || { echo "session-state: nothing on stdin to write" >&2; exit 2; }

ACTION=""
if [ ! -f "$STATE" ]; then
  [ -f "$TEMPLATE" ] || { echo "session-state: no $STATE and no template at $TEMPLATE to create it from" >&2; exit 1; }
  BASE="$TEMPLATE"; ACTION="created"
else
  BASE="$STATE"
fi
# Git for Windows gawk reads files in text mode and drops the CR of a CRLF
# line, so the two awks below that must see or keep a CR set BINMODE 3 (every
# byte as it is). Other awks treat BINMODE as a plain variable.
CR=$(awk 'BEGIN { BINMODE = 3 } NR == 1 { print ($0 ~ /\r$/) ? 1 : 0; exit }' "$BASE")
[ -n "$CR" ] || CR=0

# emit FILE — FILE's lines with the base file's line ending.
emit() { awk -v cr="$CR" '{ sub(/\r$/, ""); printf "%s%s\n", $0, (cr == 1 ? "\r" : "") }' "$1"; }
emit_text() { printf '%s\n' "$@" > "$NEW.txt"; emit "$NEW.txt"; rm -f "$NEW.txt"; }
# lines FILE A B — lines A..B of FILE as they are (B 0 = to the end).
lines() { awk -v a="$2" -v b="$3" 'BEGIN { BINMODE = 3 } NR >= a && (b == 0 || NR <= b)' "$1"; }

if [ "$CMD" = "checkpoint" ]; then
  set -- $(locate "$BASE")
  so=$1; sc=$2; co=$3; cc=$4
  if [ "$co" -gt 0 ] && [ "$cc" -gt "$co" ]; then
    [ -z "$ACTION" ] && ACTION="replaced"
    { lines "$BASE" 1 "$co"; emit "$BODY"; lines "$BASE" "$cc" 0; } > "$NEW"
  elif [ "$co" = 0 ] && [ "$cc" = 0 ]; then
    [ -z "$ACTION" ] && ACTION="inserted"
    if [ "$so" -gt 0 ] && [ "$sc" -gt "$so" ]; then
      { lines "$BASE" 1 "$sc"; emit_text "" "<!-- CHECKPOINT -->"; emit "$BODY"
        emit_text "<!-- /CHECKPOINT -->"; lines "$BASE" $((sc + 1)) 0; } > "$NEW"
    else
      [ -f "$TEMPLATE" ] || { echo "session-state: $STATE has no markers and there is no template at $TEMPLATE to take them from" >&2; exit 1; }
      set -- $(locate "$TEMPLATE")
      if [ "$1" -gt 0 ] && [ "$2" -gt "$1" ]; then
        lines "$TEMPLATE" "$1" "$2" > "$NEW.status"
      else
        : > "$NEW.status"
      fi
      { [ -s "$NEW.status" ] && { emit "$NEW.status"; emit_text ""; }
        emit_text "<!-- CHECKPOINT -->"; emit "$BODY"; emit_text "<!-- /CHECKPOINT -->" ""
        cat "$BASE"; } > "$NEW"
      rm -f "$NEW.status"
    fi
  else
    if [ "$cc" = 0 ]; then why="<!-- CHECKPOINT --> at line $co has no <!-- /CHECKPOINT --> after it"
    else why="<!-- /CHECKPOINT --> at line $cc has no <!-- CHECKPOINT --> before it"; fi
    echo "session-state: $BASE: $why. Nothing was written." >&2
    echo "  Fix the markers by hand (layout: $TEMPLATE); guessing where the block ends could swallow the narrative." >&2
    exit 3
  fi
  [ "$NBODY" -gt "$MAX_LINES" ] && echo "session-state: the checkpoint is $NBODY lines; the template asks for under ~$MAX_LINES, because session-start.sh shows it whole in every new session" >&2
else
  # append: skip when the file already ends with exactly these lines.
  if [ "$ACTION" != "created" ] && awk '
       FNR == NR { b[++nb] = $0; next }
       { sub(/\r$/, ""); f[++nf] = $0 }
       END {
         e = nf; while (e > 0 && f[e] ~ /^[ \t]*$/) e--
         if (e < nb) exit 1
         for (i = 1; i <= nb; i++) if (f[e - nb + i] != b[i]) exit 1
         exit 0
       }' "$BODY" "$BASE"; then
    ACTION="unchanged"; cp "$BASE" "$NEW"
  else
    [ -z "$ACTION" ] && ACTION="appended"
    { cat "$BASE"
      # Close an unterminated last line, then leave one blank line before the block.
      # ($(...) drops a trailing newline, so a non-empty result is a last byte
      # that is not one.)
      [ -n "$(tail -c 1 "$BASE")" ] && emit_text ""
      [ -s "$BASE" ] && [ -n "$(tail -n 1 "$BASE" | tr -d ' \t\r')" ] && emit_text ""
      emit "$BODY"; } > "$NEW"
  fi
fi

if [ -f "$STATE" ] && cmp -s "$NEW" "$STATE"; then
  ACTION="unchanged"
else
  # Copied over the file in place, not moved: the file keeps its mode, a
  # symlink stays a symlink and a hard link sees the change.
  cat "$NEW" > "$STATE" 2>/dev/null || { echo "session-state: could not write $STATE" >&2; exit 1; }
fi
printf 'file\t%s\t%s\nlines\t%s\t-\n' "$STATE" "$ACTION" "$NBODY"
exit 0
