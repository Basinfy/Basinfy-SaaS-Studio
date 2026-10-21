#!/usr/bin/env bash
# adr-status.sh — each ADR's status, layer, dates, dependencies and missing
# sections, in one pass, so a skill reads a table instead of opening every ADR
# and grepping `## Status -A 3` per file.
#
# Replaces the hand-run ADR reads in /saas-architecture-decision, /saas-architecture-review,
# /saas-create-control-manifest, /saas-create-epics, /saas-create-stories, /saas-dev-story,
# /saas-gate-check, /saas-code-review, /saas-story-readiness, /saas-adopt, /saas-create-architecture,
# /saas-propagate-design-change and /saas-project-stage-detect. adr-dep-graph.sh still
# owns the dependency graph and its cycles; this script reads the same
# Depends On row the same way, so the two agree on every edge.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# Whether a Proposed ADR blocks a story, which sections an ADR must have, and
# what a missing Layer row means are the calling skill's rules: the skills'
# own lists of required sections disagree, so this script reports every
# section of the shipped template that is missing and leaves the choice there.
#
# Usage: bash .claude/scripts/adr-status.sh [--root DIR] [ID|PATH ...]
#   ID          ADR-0003, adr-0003 or 0003: the ADR whose file name carries it
#   PATH        an ADR file, relative to the root or absolute
#   (none)      every docs/architecture/adr-*.md (one level, as adr-dep-graph.sh)
#   --root DIR  the project; defaults to the repo this script is in
#   -h, --help  this text
# An ADR named more than once (by ID, number or path) is reported once.
#
# Output: TSV. Counts first, then one row per ADR:
#   adrs <n> <scope>, template_sections <n> <template path>, then the number of
#   ADRs in each status: accepted, proposed, deprecated, superseded, unfilled,
#   other, no_status
#   ADR <id> <path> <status> <layer> <date> <last_verified> <version>
#       <depends_on> <superseded_by> <missing> <unfilled>
#   NOT_FOUND <ID or PATH>          for an argument that names no ADR
# Columns (`-` means not there):
#   status        Accepted | Proposed | Deprecated | Superseded: the first word
#                 under `## Status`; UNFILLED while it is still the template's
#                 [bracket]; OTHER for anything else
#   layer         the `**Layer**` row's value, or UNFILLED
#   date, last_verified   the first YYYY-MM-DD under `## Date` and `## Last
#                 Verified`, or UNFILLED
#   version       last_verified, else date, else `unversioned` (the rule
#                 /saas-create-stories and /saas-dev-story stamp stories with)
#   depends_on    every ADR-N on the `**Depends On**` row of `## ADR
#                 Dependencies`, as adr-NNNN, comma-separated; `none` when the
#                 row names none; UNFILLED while it is the template's bracket
#   superseded_by the ADR a Superseded status names
#   missing       the template's `##` sections this ADR lacks, comma-separated
#                 (titles compared without case or a leading number)
#   unfilled      how many lines are still a [bracketed] line of the template,
#                 word for word
# An empty file is still a row: no status (`-`, counted as no_status), every
# template section missing.
#
# Exit codes: 0 every ADR asked for was read; 1 the root cannot be read;
# 2 usage error; 3 an ID or PATH named no ADR (its NOT_FOUND row is printed,
# the others are still reported). Reads only; never writes, never prompts.
#
# bash 3.2 and BWK awk safe, no Python.

set -u
# Byte semantics for awk, sort and tolower.
LC_ALL=C
export LC_ALL

ROOT_ARG=""
ARGS=""
NL='
'
while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      [ $# -ge 2 ] || { echo "adr-status: --root needs a value" >&2; exit 2; }
      ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -?*) echo "adr-status: unknown argument: $1 (try --help)" >&2; exit 2 ;;
    *) ARGS="$ARGS$1$NL"; shift ;;
  esac
done

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "adr-status: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$(dirname "$0")/../.." 2>/dev/null || { echo "adr-status: cannot reach the repo root" >&2; exit 1; }
fi

ADR_DIR="docs/architecture"
TEMPLATE=".claude/docs/templates/architecture-decision-record.md"
# adr_id PATH — adr-dep-graph.sh's id: the first adr-<digits> in the name, lower case.
adr_id() { printf '%s\n' "${1##*/}" | tr '[:upper:]' '[:lower:]' | grep -oE 'adr-[0-9]+' | head -1; }

FILES=""; MISSED=""; SCOPE="$ADR_DIR/adr-*.md"
ALL=$(find "$ADR_DIR" -maxdepth 1 -type f -name 'adr-*.md' 2>/dev/null | sort)
# add_file PATH — onto FILES unless that file is there already, under any
# spelling (-ef: the same file, whether named by ID, ./path or absolute path).
add_file() {
  while IFS= read -r g; do
    [ -n "$g" ] && [ "$g" -ef "$1" ] && return 0
  done <<EOF
$FILES
EOF
  FILES="$FILES$1$NL"
}
if [ -z "$ARGS" ]; then
  FILES="$ALL"
else
  SCOPE="arguments"
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    # A Windows path's backslashes as slashes, so its file name reads alike.
    case "$a" in [A-Za-z]:\\*) a=$(printf '%s' "$a" | sed 's|\\|/|g') ;; esac
    if [ -f "$a" ]; then add_file "${a#./}"; continue; fi
    # An ID: ADR-0003, adr-0003 or 0003, compared on its number.
    want=$(printf '%s' "$a" | tr '[:upper:]' '[:lower:]' | sed 's/^adr-//')
    hit=""
    case "$want" in
      ''|*[!0-9]*) ;;
      *) while IFS= read -r f; do
           [ -n "$f" ] || continue
           n=$(adr_id "$f"); n="${n#adr-}"
           # Numbers compare as numbers: 3 and 0003 are one ADR.
           [ -n "$n" ] && [ "$((10#$n))" = "$((10#$want))" ] && { hit="$f"; break; }
         done <<EOF
$ALL
EOF
         ;;
    esac
    if [ -n "$hit" ]; then add_file "$hit"; else MISSED="$MISSED$a$NL"; fi
  done <<EOF
$ARGS
EOF
fi

LIST=$(printf '%s' "$FILES" | awk 'NF' )
TPL_ARG=""
[ -f "$TEMPLATE" ] && TPL_ARG="$TEMPLATE"

# One awk over the template (when there is one) and every ADR. The heading and
# fence rules are md-section.sh's: 1-6 # and a space after at most 3 spaces of
# indent; nothing inside a ``` or ~~~ fence or an HTML comment is a heading.
# The template, then the ADRs, go to awk on stdin, never as arguments (a long
# list passes the command-line limit of some systems). Each becomes an input
# file, "./" in front of a relative one so a name like x=1.md is not read as an
# assignment; an absolute one (/..., C:/...) is opened as it is.
{ [ -n "$TPL_ARG" ] && printf '%s\n' "$TPL_ARG"; printf '%s\n' "$LIST"; } | awk 'NF { sub(/^\.\//, ""); print }' | \
TPL="$TPL_ARG" SCOPE="$SCOPE" awk '
  # Git for Windows gawk reads files in text mode; BINMODE keeps the bytes.
  BEGIN {
    BINMODE = 3; tpl = ENVIRON["TPL"]; nadr = 0
    # The list arrives on /dev/stdin, named, so the main input stays the files: with
    # a bare getline, gawk read the first file as more of stdin and skipped its FNR 1.
    while ((getline f < "/dev/stdin") > 0) lst[++nlst] = f
    for (i = 1; i <= nlst; i++) ARGV[ARGC++] = (lst[i] ~ /^(\/|[A-Za-z]:)/) ? lst[i] : "./" lst[i]
    na = 1
  }
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
  function norm(s) {
    s = tolower(trim(s)); gsub(/[ \t]+/, " ", s)
    if (s ~ /^[0-9]+[.)]? /) sub(/^[0-9]+[.)]? /, "", s)
    return s
  }
  function fence_of(s,    n, c, k) {
    n = 0; while (n < 3 && substr(s, n + 1, 1) == " ") n++
    s = substr(s, n + 1); c = substr(s, 1, 1)
    if (c != "`" && c != "~") return ""
    k = 0; while (substr(s, k + 1, 1) == c) k++
    return (k >= 3) ? substr(s, 1, k) : ""
  }
  function closes(s, f,    n, c, k) {
    n = 0; while (n < 3 && substr(s, n + 1, 1) == " ") n++
    s = substr(s, n + 1); c = substr(f, 1, 1)
    k = 0; while (substr(s, k + 1, 1) == c) k++
    return k >= length(f) && trim(substr(s, k + 1)) == ""
  }
  function first_date(s) { return match(s, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) ? substr(s, RSTART, RLENGTH) : "" }
  # Every ADR-N in s, as adr-N lower case, in order, without repeats.
  function adr_ids(s,    out, seen, id) {
    out = ""; split("", seen)
    while (match(s, /[Aa][Dd][Rr]-[0-9]+/)) {
      id = tolower(substr(s, RSTART, RLENGTH)); s = substr(s, RSTART + RLENGTH)
      if (!(id in seen)) { seen[id] = 1; out = out (out == "" ? "" : ",") id }
    }
    return out
  }
  function cell2(s,    n, c) { n = split(s, c, "|"); return n >= 3 ? trim(c[3]) : "" }
  function value_of(raw) { return (raw == "") ? "-" : raw }

  function flush(    st, w, sb, ver, miss, i, t) {
    if (cur == "") return
    st = "-"; sb = "-"
    if (status_line != "") {
      w = status_line; gsub(/[*_`]/, "", w); w = tolower(trim(w)); sub(/[^a-z].*$/, "", w)
      if (w == "accepted") st = "Accepted"
      else if (w == "proposed") st = "Proposed"
      else if (w == "deprecated") st = "Deprecated"
      else if (w == "superseded") { st = "Superseded"; sb = adr_ids(status_line); if (sb == "") sb = "-"; else sub(/,.*/, "", sb) }
      else if (substr(trim(status_line), 1, 1) == "[") st = "UNFILLED"
      else st = "OTHER"
    } else if ("status" in has) st = "OTHER"
    cnt[st == "-" ? "no_status" : tolower(st)]++
    d = (date_line == "") ? (("date" in has) ? "UNFILLED" : "-") : (first_date(date_line) != "" ? first_date(date_line) : "UNFILLED")
    lv = (lv_line == "") ? (("last verified" in has) ? "UNFILLED" : "-") : (first_date(lv_line) != "" ? first_date(lv_line) : "UNFILLED")
    ver = (lv ~ /^[0-9]/) ? lv : ((d ~ /^[0-9]/) ? d : "unversioned")
    # The ids come from the whole row and an ADR naming itself is dropped, as
    # adr-dep-graph.sh builds its edges; the cell decides UNFILLED versus none.
    if (dep_seen) {
      dep = ""; nd = split(adr_ids(dep_row), dl, ",")
      for (i = 1; i <= nd; i++) if (dl[i] != cur_id) dep = dep (dep == "" ? "" : ",") dl[i]
      if (dep == "") dep = (substr(dep_cell, 1, 1) == "[") ? "UNFILLED" : "none"
    } else dep = "-"
    lay = (layer_seen) ? ((substr(layer_cell, 1, 1) == "[") ? "UNFILLED" : value_of(layer_cell)) : "-"
    miss = ""
    for (i = 1; i <= ntpl; i++) if (!(tsec[i] in has)) miss = miss (miss == "" ? "" : ",") ttitle[i]
    nadr++
    t = cur_path; gsub(/\t/, " ", t); gsub(/\t/, " ", lay)
    rows[nadr] = "ADR\t" cur_id "\t" t "\t" st "\t" lay "\t" d "\t" lv "\t" ver "\t" dep "\t" sb "\t" (miss == "" ? "-" : miss) "\t" unfilled
    cur = ""
  }

  function begin(f) {
    flush()
    infence = ""; incomment = 0; sec = ""
    if (f == "./" tpl) { intpl = 1 } else {
      intpl = 0; cur = f; cur_path = f; sub(/^\.\//, "", cur_path)
      # The id adr-dep-graph.sh uses: the first adr-<digits> in the file name, lower case.
      b = tolower(cur_path); sub(/^.*\//, "", b); cur_id = match(b, /adr-[0-9]+/) ? substr(b, RSTART, RLENGTH) : "-"
      split("", has); status_line = ""; date_line = ""; lv_line = ""
      dep_seen = 0; dep_cell = ""; dep_row = ""; layer_seen = 0; layer_cell = ""; unfilled = 0
    }
  }
  # An empty file has no line, so no FNR 1: every listed file awk passed over
  # before f (all of them, for f "") is one, and is still a row.
  function reach(f) {
    while (na < ARGC && ARGV[na] != f) { begin(ARGV[na]); flush(); na++ }
    if (na < ARGC) na++
  }
  FNR == 1 { reach(FILENAME); begin(FILENAME) }
  {
    line = $0; sub(/\r$/, "", line)
    if (infence) { if (closes(line, infence)) infence = ""; next }
    f = fence_of(line); if (f != "") { infence = f; next }
    cstart = incomment; rest = ""; s = line
    while (s != "") {
      if (incomment) { p = index(s, "-->"); if (p == 0) { s = ""; break } s = substr(s, p + 3); incomment = 0 }
      else { p = index(s, "<!--"); if (p == 0) { rest = rest s; s = ""; break } rest = rest substr(s, 1, p - 1); s = substr(s, p + 4); incomment = 1 }
    }
    h = line; n = 0; while (n < 3 && substr(h, n + 1, 1) == " ") n++
    h = substr(h, n + 1); k = 0; while (substr(h, k + 1, 1) == "#") k++
    if (!cstart && line !~ /^[ \t]*<!--/ && k >= 1 && k <= 6 && (length(h) == k || substr(h, k + 1, 1) == " " || substr(h, k + 1, 1) == "\t")) {
      t = trim(substr(h, k + 1)); if (t ~ /(^| )#+$/) { sub(/#+$/, "", t); t = trim(t) }
      if (k <= 2) sec = (k == 2) ? norm(t) : ""
      if (k == 2) {
        if (intpl) { if (!(norm(t) in tseen)) { tseen[norm(t)] = 1; ntpl++; tsec[ntpl] = norm(t); ttitle[ntpl] = t } }
        else has[norm(t)] = 1
      }
      next
    }
    r = trim(rest)
    if (intpl) { if (r ~ /\[/) tbr[r] = 1; next }
    if (r == "") next
    if (r in tbr) unfilled++
    # The first line of text under a field heading is its value; a > quote is
    # the template guidance, not the value.
    if (substr(r, 1, 1) != ">") {
      if (sec == "status" && status_line == "") status_line = r
      if (sec == "date" && date_line == "") date_line = r
      if (sec == "last verified" && lv_line == "") lv_line = r
    }
    if (!layer_seen && r ~ /^\|[ \t]*\*\*Layer\*\*[ \t]*\|/) { layer_seen = 1; layer_cell = cell2(r) }
    if (sec == "adr dependencies" && !dep_seen && r ~ /\*\*Depends On\*\*/) { dep_seen = 1; dep_row = r; dep_cell = cell2(r); if (dep_cell == "") dep_cell = r }
  }
  END {
    flush(); reach("")
    printf "adrs\t%d\t%s\n", nadr, ENVIRON["SCOPE"]
    printf "template_sections\t%d\t%s\n", ntpl, (tpl == "" ? "-" : tpl)
    split("accepted proposed deprecated superseded unfilled other no_status", names, " ")
    for (i = 1; i <= 7; i++) printf "%s\t%d\n", names[i], cnt[names[i]] + 0
    for (i = 1; i <= nadr; i++) print rows[i]
  }
'

rc=0
while IFS= read -r m; do
  [ -n "$m" ] || continue
  printf 'NOT_FOUND\t%s\n' "$m"; rc=3
done <<EOF
$MISSED
EOF
exit $rc
