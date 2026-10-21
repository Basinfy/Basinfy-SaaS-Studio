#!/usr/bin/env bash
# hook-input.sh — what a PreToolUse payload for Write or Edit says, read one
# way: the tool, the file it writes (made project-relative), the subagent that
# calls it, and the content the file will hold once the call has run. The hooks
# that check writes (validate-registry.sh, validate-write.sh) and reads
# (validate-read.sh) read the payload through this script, so the JSON
# decoding and the Edit rebuild exist once.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
#
# Usage: bash .claude/scripts/hook-input.sh [--root DIR] [--new FILE] < payload.json
#   --new FILE   also write the content the file will hold to FILE: Write's
#                content, or Edit's old_string replaced by new_string in the
#                current file (first match, or every one with replace_all)
#   --root DIR   the project; defaults to the repo this script is in
#   -h, --help   this text
# The payload is parsed with jq when it is on PATH, else by the awk below.
#
# Output: TSV, one row each, in this order:
#   tool <tool_name | ->
#   path <the file, project-relative | the absolute path when outside | ->
#   where <inside | outside | none>
#   existed <yes | no | ->      the file was there before the call
#   agent <agent_type | ->      set when a subagent makes the call
#   replace_all <true | false>
#   bounded <yes | no>          Read only: the read gives an offset or a limit
#                               (validate-read.sh)
#   new <ok | -> | new <unread FIELD> | new <notfound> | new <empty-old>
#       (only with --new): ok, the content is in FILE; unread, the payload
#       has no such string; notfound, old_string is not in the current file;
#       empty-old, an empty old_string on a file that has content
#
# Exit codes: 0 read (what it found is rows); 1 the root cannot be read;
# 2 usage error. Writes only FILE; never prompts.
#
# bash 3.2 and BWK awk safe, no Python.

set -u
LC_ALL=C
export LC_ALL

usage() { echo "hook-input: $1 (try --help)" >&2; exit 2; }
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT_ARG=""; NEWF=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || usage "--root needs a value"; ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    --new) [ $# -ge 2 ] || usage "--new needs a file"; NEWF="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# //; s/^#//'; exit 0 ;;
    *) usage "unknown argument: $1" ;;
  esac
done
case "$NEWF" in ""|/*|[A-Za-z]:[\\/]*) ;; *) NEWF="$PWD/$NEWF" ;; esac
INPUT=$(cat)

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "hook-input: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "hook-input: cannot reach the repo root" >&2; exit 1; }
fi

# Decodes the payload without jq. HI_MODE=head prints the tool name, the
# replace_all flag, the file path, the agent type and "end", one per line;
# HI_MODE=body writes the decoded content (Write) or old_string and new_string
# (Edit) to HI_NEW, HI_OS and HI_NS and prints ok, or the field it could not read.
DECODE='
  BEGIN { BINMODE = 3 }
  { buf = buf (NR > 1 ? "\n" : "") $0 }
  function hexval(h,    i, c, v) {
    v = 0
    for (i = 1; i <= 4; i++) {
      c = index("0123456789abcdef", tolower(substr(h, i, 1)))
      if (c == 0) return -1
      v = v * 16 + c - 1
    }
    return v
  }
  # A code point as UTF-8 bytes (LC_ALL=C makes %c one byte).
  function utf8(cp) {
    if (cp < 128) return sprintf("%c", cp)
    if (cp < 2048) return sprintf("%c%c", 192 + int(cp / 64), 128 + cp % 64)
    if (cp < 65536) return sprintf("%c%c%c", 224 + int(cp / 4096), 128 + int(cp / 64) % 64, 128 + cp % 64)
    return sprintf("%c%c%c%c", 240 + int(cp / 262144), 128 + int(cp / 4096) % 64, 128 + int(cp / 64) % 64, 128 + cp % 64)
  }
  # The string value of the first "k": "..." pair, decoded; FOUND says whether
  # there was one. Inside a JSON string every quote is escaped, so "k" followed
  # by a colon is only ever a key. The body ends at the first quote preceded
  # by an even number of backslashes.
  function jv(k,    rest, n, q, i, t, j, body, out, cp, lo) {
    FOUND = 0
    if (!match(buf, "\"" k "\"[ \t\r\n]*:[ \t\r\n]*\"")) return ""
    rest = substr(buf, RSTART + RLENGTH)
    n = split(rest, q, "\"")
    body = ""
    for (i = 1; i <= n; i++) {
      t = q[i]; j = 0
      while (j < length(t) && substr(t, length(t) - j, 1) == "\\") j++
      body = body t
      if (j % 2 == 0) { FOUND = (i < n); break }
      body = body "\""
    }
    if (!FOUND) return ""
    # \\ first, through \001 (a raw control byte never appears in JSON text),
    # so the n of an escaped backslash followed by n stays an n.
    gsub(/\\\\/, "\001", body)
    gsub(/\\"/, "\"", body); gsub(/\\\//, "/", body)
    gsub(/\\n/, "\n", body); gsub(/\\t/, "\t", body); gsub(/\\r/, "\r", body)
    gsub(/\\b/, "\b", body); gsub(/\\f/, "\f", body)
    # \uXXXX next. Each \001 goes back to a backslash in the text between the
    # escapes only, never in what an escape decodes to, so a \u0001 in the
    # content stays the byte 01.
    out = ""
    while (match(body, /\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]/)) {
      out = out unbs(substr(body, 1, RSTART - 1))
      cp = hexval(substr(body, RSTART + 2, 4)); body = substr(body, RSTART + 6)
      # A UTF-16 surrogate pair (D800-DBFF then DC00-DFFF) is one code point.
      if (cp >= 55296 && cp < 56320 && match(body, /^\\u[dD][c-fC-F][0-9A-Fa-f][0-9A-Fa-f]/)) {
        lo = hexval(substr(body, 3, 4)); body = substr(body, 7)
        cp = 65536 + (cp - 55296) * 1024 + (lo - 56320)
      }
      out = out utf8(cp)
    }
    return out unbs(body)
  }
  # \001 back to a backslash with index(), not split(): BWK awk splits on a
  # newline too when the separator is one character, which turned every
  # decoded newline into a backslash.
  function unbs(s,    out, i) {
    out = ""
    while ((i = index(s, "\001")) > 0) { out = out substr(s, 1, i - 1) "\\"; s = substr(s, i + 1) }
    return out s
  }
  END {
    if (ENVIRON["HI_MODE"] == "head") {
      print jv("tool_name")
      print (match(buf, /"replace_all"[ \t\r\n]*:[ \t\r\n]*true/) ? "true" : "false")
      print jv("file_path")
      print jv("agent_type")
      print (match(buf, /"(offset|limit)"[ \t\r\n]*:[ \t\r\n]*[0-9]/) ? "yes" : "no")
      print "end"
      exit 0
    }
    t = jv("tool_name")
    if (t == "Write") {
      v = jv("content"); if (!FOUND) { print "content"; exit 0 }
      printf "%s", v > ENVIRON["HI_NEW"]
    } else {
      v = jv("old_string"); if (!FOUND) { print "old_string"; exit 0 }
      printf "%s", v > ENVIRON["HI_OS"]
      v = jv("new_string"); if (!FOUND) { print "new_string"; exit 0 }
      printf "%s", v > ENVIRON["HI_NS"]
    }
    print "ok"
  }'

HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1
# -b (jq 1.7+): a native Windows jq.exe otherwise writes every newline as CRLF,
# so the rebuilt content would differ from what the awk reader gives. An older
# jq refuses the flag and needs none.
JQB=""
[ "$HAVE_JQ" = 1 ] && jq -b -n 1 >/dev/null 2>&1 && JQB=-b
if [ "$HAVE_JQ" = 1 ]; then
  # tr: a native Windows jq.exe ends its lines CRLF under Git Bash.
  HEAD=$(printf '%s' "$INPUT" | jq -r '(.tool_name // ""), (.tool_input.replace_all // false), (.tool_input.file_path // ""), (.agent_type // ""), (if ((.tool_input.offset | type) == "number" or (.tool_input.limit | type) == "number") then "yes" else "no" end), "end"' 2>/dev/null | tr -d '\r')
else
  HEAD=$(printf '%s' "$INPUT" | HI_MODE=head awk "$DECODE")
fi
# Split in the shell. The closing "end" line keeps an empty field from being
# lost with the trailing newlines.
NL='
'
TOOL=${HEAD%%"$NL"*}; HEAD=${HEAD#*"$NL"}
REPLACE_ALL=${HEAD%%"$NL"*}; HEAD=${HEAD#*"$NL"}
FILE_PATH=${HEAD%%"$NL"*}; HEAD=${HEAD#*"$NL"}
AGENT=${HEAD%%"$NL"*}; HEAD=${HEAD#*"$NL"}
BOUNDED=${HEAD%%"$NL"*}
[ "$REPLACE_ALL" = true ] || REPLACE_ALL=false
[ "$BOUNDED" = yes ] || BOUNDED=no

# Windows separators to slashes: an escaped pair from the awk path is already
# one backslash, so one rule covers both readers. Then project-relative,
# against the root in either spelling Git Bash gives it, and failing those, by
# physical path: the root's `pwd -P` against the path with its deepest
# existing directory resolved, so a root reached through a symlink (macOS
# /tmp is /private/tmp) and a path that comes resolved, or the other way
# round, still read as inside.
FILE_PATH=$(printf '%s' "$FILE_PATH" | sed 's|\\|/|g')
ROOT_P=$(pwd); ROOT_W=$(pwd -W 2>/dev/null || printf '%s' "$ROOT_P"); ROOT_PP=$(pwd -P)
# phys PATH — PATH with its deepest existing directory resolved (symlinks
# followed, .. folded) and the rest as it came; empty when none can be entered.
phys() {
  _pd=$1; _pt=""
  while [ -n "$_pd" ] && [ ! -d "$_pd" ]; do
    _pt="/${_pd##*/}$_pt"; _pn=${_pd%/*}
    [ "$_pn" = "$_pd" ] && return 0
    _pd=$_pn
  done
  [ -n "$_pd" ] || _pd=/
  _pd=$(cd "$_pd" 2>/dev/null && pwd -P) || return 0
  printf '%s%s' "${_pd%/}" "$_pt"
}
WHERE=inside
shopt -s nocasematch
case "$FILE_PATH" in
  "") WHERE=none ;;
  "$ROOT_P"/*) REL="${FILE_PATH:${#ROOT_P}+1}" ;;
  "$ROOT_W"/*) REL="${FILE_PATH:${#ROOT_W}+1}" ;;
  /*|[A-Za-z]:/*)
    _fp=$(phys "$FILE_PATH")
    case "$_fp" in
      "$ROOT_PP"/*) REL="${_fp:${#ROOT_PP}+1}" ;;
      *) WHERE=outside; REL="$FILE_PATH" ;;
    esac ;;
  *) REL="${FILE_PATH#./}" ;;
esac
shopt -u nocasematch
EXISTED=-
if [ "$WHERE" = inside ]; then if [ -e "$REL" ]; then EXISTED=yes; else EXISTED=no; fi; fi
tsv() { printf '%s' "$1" | tr '\t\n' '  '; }
printf 'tool\t%s\npath\t%s\nwhere\t%s\nexisted\t%s\nagent\t%s\nreplace_all\t%s\n' \
  "$(tsv "${TOOL:--}")" "$(tsv "${REL:--}")" "$WHERE" "$EXISTED" "$(tsv "${AGENT:--}")" "$REPLACE_ALL"
[ "$TOOL" = Read ] && printf 'bounded\t%s\n' "$BOUNDED"
[ -n "$NEWF" ] || exit 0

# ---------------------------------------------------- the content after the call
if [ "$WHERE" != inside ]; then printf 'new\t-\n'; exit 0; fi
case "$TOOL" in Write|Edit) ;; *) printf 'new\t-\n'; exit 0 ;; esac
OS="$NEWF.old"; NS="$NEWF.new"
trap 'rm -f "$OS" "$NS"' EXIT
: > "$NEWF" 2>/dev/null || { echo "hook-input: cannot write $NEWF" >&2; exit 2; }
if [ "$HAVE_JQ" = 1 ]; then
  GOT=ok
  # -e: a field that is absent or not a string exits non-zero instead of
  # writing nothing, which would read as an emptied file.
  # shellcheck disable=SC2086
  if [ "$TOOL" = Write ]; then
    printf '%s' "$INPUT" | jq $JQB -e -j '.tool_input.content | strings' > "$NEWF" 2>/dev/null || GOT=content
  else
    printf '%s' "$INPUT" | jq $JQB -e -j '.tool_input.old_string | strings' > "$OS" 2>/dev/null || GOT=old_string
    [ "$GOT" = ok ] && { printf '%s' "$INPUT" | jq $JQB -e -j '.tool_input.new_string | strings' > "$NS" 2>/dev/null || GOT=new_string; }
  fi
else
  GOT=$(printf '%s' "$INPUT" | HI_MODE=body HI_NEW="$NEWF" HI_OS="$OS" HI_NS="$NS" awk "$DECODE")
fi
[ "$GOT" = ok ] || { printf 'new\tunread %s\n' "$GOT"; exit 0; }
[ "$TOOL" = Write ] && { printf 'new\tok\n'; exit 0; }

# Each file read whole, CRLF made LF on both sides as the Edit tool matches;
# first match, or every one with replace_all. RS is the byte 01, rare in text,
# and the records are joined back with it, so a file that holds one is still
# read whole (only a 01 as its very last byte is lost).
SPLICE=$(HI_CUR="$REL" HI_OS="$OS" HI_NS="$NS" HI_ALL="$REPLACE_ALL" HI_OUT="$NEWF" awk '
  function slurp(f,    r, x, s, k) {
    s = ""; k = 0
    while ((r = (getline x < f)) > 0) { s = s (k++ ? "\001" : "") x }
    close(f); READ = (r == 0 || k > 0)
    return s
  }
  BEGIN {
    BINMODE = 3; RS = "\001"
    c = slurp(ENVIRON["HI_CUR"]); have = READ
    o = slurp(ENVIRON["HI_OS"]); n = slurp(ENVIRON["HI_NS"])
    gsub(/\r\n/, "\n", c); gsub(/\r\n/, "\n", o)
    if (o == "") {
      if (have && c != "") { print "empty-old"; exit 0 }
      printf "%s", n > ENVIRON["HI_OUT"]; print "ok"; exit 0
    }
    p = index(c, o)
    if (!p) { print "notfound"; exit 0 }
    out = ""
    while (p) {
      out = out substr(c, 1, p - 1) n; c = substr(c, p + length(o))
      if (ENVIRON["HI_ALL"] != "true") break
      p = index(c, o)
    }
    printf "%s", out c > ENVIRON["HI_OUT"]
    print "ok"
  }')
printf 'new\t%s\n' "${SPLICE:-notfound}"
exit 0
