#!/usr/bin/env bash
# debt-register.sh — the technical-debt register's arithmetic: the next TD ID,
# the impact / effort score, open items per category, items added and resolved
# in a window, item ages, and the Open entries that already cover a file and a
# category, read from docs/saas-tech-debt-register.md, so one table is read instead
# of counting rows by hand.
#
# Replaces the register steps a skill would otherwise do by hand: numbering a
# new entry, scoring and prioritizing, reporting, and the "match before
# appending" check.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# stats prints added and resolved counts and their difference, not the words
# growing, stable or shrinking; ages are in days, because the register records
# dates, not sprints. What "more than 3 sprints" is in days, and which items
# go in the next sprint, stay in the skill.
#
# Usage: bash .claude/scripts/debt-register.sh [--root DIR] COMMAND [ARGS]
#   next-id                 the next TD ID: registry.sh's `next-id td`, passed
#                           through unchanged (the one ID rule in the codebase)
#   score IMPACT EFFORT     the score of one pair: Low, Med (Medium), High or
#                           Critical over S, M, L or XL, any case; - or an em
#                           dash means not judged and gives no score
#   score                   every item of the register scored from its own
#                           columns, in the order /saas-tech-debt prioritize writes
#   stats [--today D] [--since D] [--until D] [--older-than N]
#                           open items per category, added and resolved in the
#                           window --since..--until (both days included; --until
#                           defaults to --today), and the age of each open item
#   match --file PATH [--category CAT]
#                           the Open entries whose Files list PATH, and whose
#                           category is CAT when given (Debt dropped, any case)
#   --register PATH         the register, relative to the root or absolute
#                           (default docs/saas-tech-debt-register.md); not for
#                           next-id
#   --root DIR              the project; defaults to the repo this script is in
#   --today D               the date ages count to (default: today)
#   -h, --help              this text
# Dates are YYYY-MM-DD.
#
# What it reads (the format /saas-tech-debt writes): the Markdown table whose header
# row starts with ID. Columns are found by their header name (ID, Category,
# Description, Files, Effort, Impact, Priority, Status, Added, Sprint), so a
# register with the columns in another order, or some missing, still reads; a
# missing column reads as -. A table row starting TD-n whose cell count is not
# the header's is reported as MALFORMED and left out. A \| inside a cell is a
# pipe. Category: the six names, with or without a trailing "Debt", any case.
# Status: Open, Resolved YYYY-MM-DD, Accepted - reason (anything else is
# other_status); the date of a Resolved item is the first date in its Status.
#
# The score (the skill's rule, with the rounding it left out):
#   score = impact / effort, Impact Low 1, Med 2, High 3, Critical 4; Effort S 1,
#   M 2, L 3, XL 4. Rounded to one decimal, a half rounding UP: Low/XL 0.25 is
#   0.3 and High/XL 0.75 is 0.8 (printf alone would give 0.2, rounding to even).
#   Done in whole numbers: tenths = floor((20 * impact + effort) / (2 * effort)).
#   Order (register mode): higher score first, ties to the older Added date
#   (an undated item last), then register order; the order is of the
#   one-decimal scores, because the one-decimal score is what the register
#   shows. Items with no score follow, in register order, with the reason.
#
# Output: TSV. Every register command starts:
#   register <path> <items>       items = rows read (malformed ones left out)
#   columns <names found, in header order, comma-joined | ->
#   items <n>, duplicate_ids <n>, malformed <n>
#   MALFORMED <line> <cells> <expected> <id>
#   DUPLICATE_ID <id> <lines>
# score IMPACT EFFORT: score <value | -> <Impact>/<Effort> <i/e | reason>
# score (register): scored <n>, not_scored <n>, open_ranked <n>, then
#   ROW <rank | -> <id> <score | -> <impact> <effort> <priority as written>
#       <added> <state> <reason | ->
#   state is OPEN, RESOLVED, ACCEPTED or OTHER; rank counts the scored OPEN
#   items only, in the printed order; rows are in that order
# stats: open, resolved, accepted, other_status, today,
#   window <since | -> <until | ->, added_in_window, resolved_in_window,
#   net_in_window (added - resolved; - with no window), undated <added>
#   <resolved> (rows whose date could not be read), older_than <N | -> <count>,
#   category <name> <open> <S> <M> <L> <XL> <none> <other> (the six names, then
#   any other, sorted; none = Effort not judged, other = a word that is not
#   S, M, L or XL), effort_open (the same columns summed), then
#   OPEN <id> <category> <effort> <impact> <priority> <added> <age_days>
#       <sprint> <older>      older is yes or no against --older-than (strictly
#                             more than N days), - when not asked or no date
# match: register <path> <items>, matches <n> file=<path> category=<cat|any>,
#   MATCH <id> <line> <category> <status> <files>
# `-` means not there.
#
# Exit codes: 0 answered; 1 the root cannot be read, or registry.sh is missing;
# 2 usage error (an unknown command or flag, a bad date or number, --until
# without --since, a reversed window, an impact or effort that is not one);
# 3 no register file (stats, score, match; its register row is printed).
# next-id passes registry.sh's own codes through. Reads only; never writes,
# never prompts.
#
# bash 3.2 and BWK awk safe, no Python. BWK awk's split() with
# a one-character separator also splits on newlines, so split() is used here
# only on a single line (a table row, a Files cell).

set -u
# Byte semantics for awk, sort and tolower.
LC_ALL=C
export LC_ALL

HERE="$(cd "$(dirname "$0")" && pwd)"
usage() { echo "debt-register: $1 (try --help)" >&2; exit 2; }
is_date() { case "$1" in [0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]) return 0 ;; esac; return 1; }
# An em dash and an en dash, as bytes: the "not judged" marks of the register.
EMD=$(printf '\342\200\224'); END_=$(printf '\342\200\223')

CMD=""; ROOT_ARG=""; REG="docs/saas-tech-debt-register.md"; REG_SET=0; TODAY=""
SINCE=""; UNTIL=""; OLDER=""; FILEARG=""; CATARG=""; NPOS=0; P1=""; P2=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || usage "--root needs a value"; ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    --register) [ $# -ge 2 ] || usage "--register needs a path"; REG="$2"; REG_SET=1; shift 2 ;;
    --today) [ $# -ge 2 ] || usage "--today needs a date"; TODAY="$2"; shift 2 ;;
    --today=*) TODAY="${1#--today=}"; shift ;;
    --since) [ $# -ge 2 ] || usage "--since needs a date"; SINCE="$2"; shift 2 ;;
    --until) [ $# -ge 2 ] || usage "--until needs a date"; UNTIL="$2"; shift 2 ;;
    --older-than) [ $# -ge 2 ] || usage "--older-than needs a number of days"; OLDER="$2"; shift 2 ;;
    --file) [ $# -ge 2 ] || usage "--file needs a path"; FILEARG="$2"; shift 2 ;;
    --category) [ $# -ge 2 ] || usage "--category needs a name"; CATARG="$2"; shift 2 ;;
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -?*) usage "unknown argument: $1" ;;
    *)
      if [ -z "$CMD" ]; then CMD="$1"
      else
        NPOS=$((NPOS + 1))
        case $NPOS in 1) P1="$1" ;; 2) P2="$1" ;; *) usage "too many arguments" ;; esac
      fi
      shift ;;
  esac
done
case "$CMD" in
  next-id) [ $NPOS -eq 0 ] || usage "next-id takes no arguments"
           [ $REG_SET -eq 0 ] || usage "next-id reads the register registry.sh knows; --register does not apply" ;;
  score) [ $NPOS -eq 0 ] || [ $NPOS -eq 2 ] || usage "score takes IMPACT and EFFORT, or nothing" ;;
  stats|match) [ $NPOS -eq 0 ] || usage "$CMD takes no arguments" ;;
  "") usage "no command" ;;
  *) usage "unknown command: $CMD" ;;
esac
[ -n "$TODAY" ] || TODAY=$(date +%Y-%m-%d)
is_date "$TODAY" || usage "--today must be YYYY-MM-DD, got $TODAY"
if [ -n "$SINCE" ] || [ -n "$UNTIL" ]; then
  [ "$CMD" = stats ] || usage "--since and --until belong to stats"
  [ -n "$SINCE" ] || usage "--until needs --since"
  is_date "$SINCE" || usage "--since must be YYYY-MM-DD, got $SINCE"
  [ -n "$UNTIL" ] || UNTIL="$TODAY"
  is_date "$UNTIL" || usage "--until must be YYYY-MM-DD, got $UNTIL"
  if [[ "$SINCE" > "$UNTIL" ]]; then usage "--since $SINCE is after --until $UNTIL"; fi
fi
if [ -n "$OLDER" ]; then
  [ "$CMD" = stats ] || usage "--older-than belongs to stats"
  case "$OLDER" in ''|*[!0-9]*) usage "--older-than takes a whole number of days" ;; esac
fi
if [ "$CMD" = match ]; then
  [ -n "$FILEARG" ] || usage "match needs --file"
elif [ -n "$FILEARG$CATARG" ]; then
  usage "--file and --category belong to match"
fi

AWK_LIB='
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
  # An empty cell, -, -- , an em dash or an en dash: not judged.
  function isdash(s) { return (s == "" || s == "-" || s == "--" || s == "\342\200\224" || s == "\342\200\223") }
  function v(s) { gsub(/\t/, " ", s); return isdash(s) ? "-" : s }
  function impact_n(s,    l) {
    l = tolower(s)
    if (l == "low") return 1
    if (l == "med" || l == "medium") return 2
    if (l == "high") return 3
    if (l == "critical") return 4
    return 0
  }
  function impact_name(n) { return (n == 1) ? "Low" : ((n == 2) ? "Med" : ((n == 3) ? "High" : "Critical")) }
  function effort_n(s,    u) {
    u = toupper(s)
    if (u == "S") return 1
    if (u == "M") return 2
    if (u == "L") return 3
    if (u == "XL") return 4
    return 0
  }
  function effort_name(n) { return (n == 1) ? "S" : ((n == 2) ? "M" : ((n == 3) ? "L" : "XL")) }
  # Tenths of a score, a half rounding up, in whole numbers.
  function score10(i, e) { return int((20 * i + e) / (2 * e)) }
  function fmt10(t) { return sprintf("%d.%d", int(t / 10), t % 10) }
  # The category as the six names without "Debt", any case; anything else as written.
  function canon_cat(s,    l) {
    l = tolower(trim(s)); sub(/ debt$/, "", l)
    if (l == "architecture") return "Architecture"
    if (l == "code quality") return "Code Quality"
    if (l == "test") return "Test"
    if (l == "documentation") return "Documentation"
    if (l == "dependency") return "Dependency"
    if (l == "performance") return "Performance"
    s = trim(s)
    return (s == "") ? "-" : s
  }
  # Days since a fixed origin for the Gregorian date y-m-d. Only differences are
  # used. The year is counted from March, so a leap day falls at the end of it.
  function days(d,    p) {
    split(d, p, "-")
    return dn(p[1] + 0, p[2] + 0, p[3] + 0)
  }
  function dn(y, m, d) {
    if (m <= 2) { y--; m += 12 }
    return 365 * y + int(y / 4) - int(y / 100) + int(y / 400) + int((153 * (m - 3) + 2) / 5) + d
  }
  function firstdate(s) {
    return match(s, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) ? substr(s, RSTART, RLENGTH) : ""
  }
  # A path from a Files cell or --file: no backticks, no leading ./
  function normpath(s) {
    gsub(/`/, "", s); s = trim(s)
    if (substr(s, 1, 2) == "./") s = substr(s, 3)
    return s
  }
'

# ----------------------------------------------------------------- score pair
# lc STRING — lower case. impact_n and effort_n print 1-4, or 0 for a word
# that is not one.
lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
impact_n() { case "$(lc "$1")" in low) echo 1 ;; med|medium) echo 2 ;; high) echo 3 ;; critical) echo 4 ;; *) echo 0 ;; esac; }
effort_n() { case "$(lc "$1")" in s) echo 1 ;; m) echo 2 ;; l) echo 3 ;; xl) echo 4 ;; *) echo 0 ;; esac; }
impact_name() { case "$1" in 1) echo Low ;; 2) echo Med ;; 3) echo High ;; 4) echo Critical ;; esac; }
effort_name() { case "$1" in 1) echo S ;; 2) echo M ;; 3) echo L ;; 4) echo XL ;; esac; }
not_judged() { case "$1" in ""|-|--|"$EMD"|"$END_") return 0 ;; esac; return 1; }

if [ "$CMD" = score ] && [ $NPOS -eq 2 ]; then
  ij=1; ej=1; iname="-"; ename="-"; in_=0; en=0
  if not_judged "$P1"; then ij=0; else
    in_=$(impact_n "$P1"); [ "$in_" != 0 ] || usage "not an impact (Low, Med, High, Critical): $P1"
    iname=$(impact_name "$in_")
  fi
  if not_judged "$P2"; then ej=0; else
    en=$(effort_n "$P2"); [ "$en" != 0 ] || usage "not an effort (S, M, L, XL): $P2"
    ename=$(effort_name "$en")
  fi
  if [ $ij -eq 1 ] && [ $ej -eq 1 ]; then
    # The same score10 and fmt10 the register mode uses: one rounding rule.
    val=$(IN="$in_" EN="$en" awk "$AWK_LIB"'BEGIN { print fmt10(score10(ENVIRON["IN"] + 0, ENVIRON["EN"] + 0)) }')
    printf 'score\t%s\t%s/%s\t%d/%d\n' "$val" "$iname" "$ename" "$in_" "$en"
  elif [ $ij -eq 0 ] && [ $ej -eq 0 ]; then
    printf 'score\t-\t%s/%s\timpact and effort not judged\n' "$iname" "$ename"
  elif [ $ij -eq 0 ]; then
    printf 'score\t-\t%s/%s\timpact not judged\n' "$iname" "$ename"
  else
    printf 'score\t-\t%s/%s\teffort not judged\n' "$iname" "$ename"
  fi
  exit 0
fi

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "debt-register: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "debt-register: cannot reach the repo root" >&2; exit 1; }
fi

if [ "$CMD" = next-id ]; then
  [ -f "$HERE/registry.sh" ] || { echo "debt-register: $HERE/registry.sh is missing" >&2; exit 1; }
  bash "$HERE/registry.sh" --root . next-id td
  exit $?
fi

if [ ! -f "$REG" ]; then
  printf 'register\t%s\tmissing\n' "$REG"
  echo "debt-register: no register at $REG" >&2
  exit 3
fi
# awk reads the register by name: "./" in front of a relative one keeps a name
# like x=1.md from reading as an assignment; an absolute one is opened as it is.
case "$REG" in /*|[A-Za-z]:*) REG_IN="$REG" ;; *) REG_IN="./$REG" ;; esac

CMD="$CMD" REGPATH="$REG" TODAY="$TODAY" SINCE="$SINCE" UNTIL="$UNTIL" OLDER="$OLDER" \
FILEARG="$FILEARG" CATARG="$CATARG" awk "$AWK_LIB"'
  BEGIN {
    BINMODE = 3
    cmd = ENVIRON["CMD"]; ncol = 0; hdr = 0; SEP = "\001"
    nk = split("id category description files effort impact priority status added sprint", KEYS, " ")
    split("ID Category Description Files Effort Impact Priority Status Added Sprint", NAMES, " ")
    for (i = 1; i <= nk; i++) NAME[KEYS[i]] = NAMES[i]
  }
  function header(n,    i, k) {
    ncol = n; hdr = 1; colslist = ""
    for (k in ci) delete ci[k]
    for (i = 1; i <= n; i++) {
      k = tolower(c[i])
      if (k in NAME) { ci[k] = i; colslist = colslist (colslist == "" ? "" : ",") NAME[k] }
    }
  }
  function get(k) { return (k in ci) ? c[ci[k]] : "" }
  FNR >= 1 {
    line = $0; sub(/\r$/, "", line)
    if (FNR == 1 && substr(line, 1, 3) == "\357\273\277") line = substr(line, 4)
    if (line !~ /^[ \t]*\|/) next
    t = line
    while ((p = index(t, "\\|")) > 0) t = substr(t, 1, p - 1) SEP substr(t, p + 2)
    sub(/^[ \t]*\|/, "", t); sub(/\|[ \t]*$/, "", t)
    n = split(t, c, "|")
    sepr = 1
    for (i = 1; i <= n; i++) {
      c[i] = trim(c[i])
      while ((p = index(c[i], SEP)) > 0) c[i] = substr(c[i], 1, p - 1) "|" substr(c[i], p + 1)
      if (c[i] !~ /^:?-+:?$/) sepr = 0
    }
    if (sepr) next
    if (tolower(c[1]) == "id") { header(n); next }
    if (c[1] !~ /^TD-[0-9]+$/) next
    if (!hdr) {
      # No header before the first row: the ten columns in the order /saas-tech-debt writes.
      ncol = 10; hdr = 1; colslist = ""
      for (i = 1; i <= nk; i++) { ci[KEYS[i]] = i; colslist = colslist (i == 1 ? "" : ",") NAMES[i] }
    }
    if (n != ncol) { nmal++; MR[nmal] = FNR "\t" n "\t" ncol "\t" c[1]; next }
    ni++
    id[ni] = c[1]; ln[ni] = FNR
    idc[c[1]]++; idl[c[1]] = idl[c[1]] (idl[c[1]] == "" ? "" : ",") FNR
    if (idc[c[1]] == 2) { ndup++; dupo[ndup] = c[1] }
    cat[ni] = canon_cat(get("category")); eff[ni] = get("effort"); imp[ni] = get("impact")
    pri[ni] = get("priority"); sta[ni] = get("status"); add[ni] = get("added")
    spr[ni] = get("sprint"); fil[ni] = get("files")
    low = tolower(sta[ni])
    if (low ~ /^open([^a-z]|$)/) st[ni] = "OPEN"
    else if (low ~ /^resolved([^a-z]|$)/) st[ni] = "RESOLVED"
    else if (low ~ /^accepted([^a-z]|$)/) st[ni] = "ACCEPTED"
    else st[ni] = "OTHER"
    ad[ni] = firstdate(add[ni])
    rd[ni] = (st[ni] == "RESOLVED") ? firstdate(sta[ni]) : ""
  }

  # Does item a come before item b (score order, a strict total order).
  function dkey(k) { return (ad[k] == "") ? "9999-99-99" : ad[k] }
  function before(a, b) {
    if ((sc[a] >= 0) != (sc[b] >= 0)) return (sc[a] >= 0)
    if (sc[a] >= 0) {
      if (sc[a] != sc[b]) return (sc[a] > sc[b])
      if (dkey(a) != dkey(b)) return (dkey(a) < dkey(b))
    }
    return (a < b)
  }
  function common(    i) {
    printf "register\t%s\t%d\n", ENVIRON["REGPATH"], ni
    if (cmd == "match") return
    printf "columns\t%s\n", (colslist == "") ? "-" : colslist
    printf "items\t%d\nduplicate_ids\t%d\nmalformed\t%d\n", ni, ndup, nmal
    for (i = 1; i <= nmal; i++) printf "MALFORMED\t%s\n", MR[i]
    for (i = 1; i <= ndup; i++) printf "DUPLICATE_ID\t%s\t%s\n", dupo[i], idl[dupo[i]]
  }

  END {
    common()
    if (cmd == "score") {
      for (k = 1; k <= ni; k++) {
        ij = isdash(imp[k]) ? 0 : 1; ej = isdash(eff[k]) ? 0 : 1
        in_ = ij ? impact_n(imp[k]) : 0; en = ej ? effort_n(eff[k]) : 0
        rs = ""
        if (!ij && !ej) rs = "impact and effort not judged"
        else {
          if (!ij) rs = "impact not judged"
          else if (in_ == 0) rs = "impact unrecognised: " v(imp[k])
          if (!ej) rs = rs (rs == "" ? "" : "; ") "effort not judged"
          else if (en == 0) rs = rs (rs == "" ? "" : "; ") "effort unrecognised: " v(eff[k])
        }
        reason[k] = (rs == "") ? "-" : rs
        sc[k] = (rs == "") ? score10(in_, en) : -1
        iname[k] = ij ? ((in_ > 0) ? impact_name(in_) : v(imp[k])) : "-"
        ename[k] = ej ? ((en > 0) ? effort_name(en) : v(eff[k])) : "-"
        srt[k] = k
        if (sc[k] >= 0) nscored++
      }
      for (i = 2; i <= ni; i++) {
        x = srt[i]
        for (j = i - 1; j >= 1 && before(x, srt[j]); j--) srt[j + 1] = srt[j]
        srt[j + 1] = x
      }
      for (i = 1; i <= ni; i++) { k = srt[i]; if (st[k] == "OPEN" && sc[k] >= 0) rank[k] = ++nrank }
      printf "scored\t%d\nnot_scored\t%d\nopen_ranked\t%d\n", nscored, ni - nscored, nrank
      for (i = 1; i <= ni; i++) {
        k = srt[i]
        printf "ROW\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", (k in rank) ? rank[k] : "-", id[k], (sc[k] >= 0) ? fmt10(sc[k]) : "-", \
          iname[k], ename[k], v(pri[k]), (ad[k] != "") ? ad[k] : v(add[k]), st[k], reason[k]
      }
      exit 0
    }

    if (cmd == "stats") {
      today = ENVIRON["TODAY"]; since = ENVIRON["SINCE"]; until = ENVIRON["UNTIL"]; older = ENVIRON["OLDER"]
      for (k = 1; k <= ni; k++) {
        if (st[k] == "OPEN") nopen++
        else if (st[k] == "RESOLVED") nres++
        else if (st[k] == "ACCEPTED") nacc++
        else noth++
        if (ad[k] == "") undadd++
        if (st[k] == "RESOLVED" && rd[k] == "") undres++
        if (since != "") {
          if (ad[k] != "" && ad[k] >= since && ad[k] <= until) nadd++
          if (rd[k] != "" && rd[k] >= since && rd[k] <= until) nresw++
        }
      }
      printf "open\t%d\nresolved\t%d\naccepted\t%d\nother_status\t%d\ntoday\t%s\n", nopen, nres, nacc, noth, today
      if (since != "") {
        printf "window\t%s\t%s\nadded_in_window\t%d\nresolved_in_window\t%d\nnet_in_window\t%d\n", since, until, nadd, nresw, nadd - nresw
      } else {
        printf "window\t-\t-\nadded_in_window\t-\nresolved_in_window\t-\nnet_in_window\t-\n"
      }
      printf "undated\t%d\t%d\n", undadd, undres
      td = days(today)
      for (k = 1; k <= ni; k++) {
        age[k] = (ad[k] != "") ? td - days(ad[k]) : "-"
        old[k] = (older != "" && age[k] != "-") ? ((age[k] > older + 0) ? "yes" : "no") : "-"
        if (old[k] == "yes" && st[k] == "OPEN") nold++
      }
      if (older != "") printf "older_than\t%s\t%d\n", older, nold
      else printf "older_than\t-\t-\n"
      # Categories: the six in the skill order, then any other, sorted.
      split("Architecture|Code Quality|Test|Documentation|Dependency|Performance", six, "|")
      nc = 0
      for (i = 1; i <= 6; i++) { cn[++nc] = six[i]; known[six[i]] = 1 }
      no = 0
      for (k = 1; k <= ni; k++) if (!(cat[k] in known) && !(cat[k] in extra)) { extra[cat[k]] = 1; ox[++no] = cat[k] }
      for (i = 2; i <= no; i++) { x = ox[i]; for (j = i - 1; j >= 1 && ox[j] > x; j--) ox[j + 1] = ox[j]; ox[j + 1] = x }
      for (i = 1; i <= no; i++) cn[++nc] = ox[i]
      for (k = 1; k <= ni; k++) {
        if (st[k] != "OPEN") continue
        co[cat[k]]++
        e = isdash(eff[k]) ? 0 : effort_n(eff[k])
        b = (e > 0) ? effort_name(e) : (isdash(eff[k]) ? "none" : "other")
        cb[cat[k], b]++; tb[b]++
      }
      split("S M L XL none other", bk, " ")
      for (i = 1; i <= nc; i++) {
        printf "category\t%s\t%d", cn[i], co[cn[i]]
        for (j = 1; j <= 6; j++) printf "\t%d", cb[cn[i], bk[j]]
        printf "\n"
      }
      printf "effort_open"
      for (j = 1; j <= 6; j++) printf "\t%d", tb[bk[j]]
      printf "\n"
      for (k = 1; k <= ni; k++) {
        if (st[k] != "OPEN") continue
        e = isdash(eff[k]) ? 0 : effort_n(eff[k]); ii = isdash(imp[k]) ? 0 : impact_n(imp[k])
        printf "OPEN\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", id[k], cat[k], (e > 0) ? effort_name(e) : v(eff[k]), \
          (ii > 0) ? impact_name(ii) : v(imp[k]), v(pri[k]), (ad[k] != "") ? ad[k] : v(add[k]), age[k], v(spr[k]), old[k]
      }
      exit 0
    }

    # match
    want = normpath(ENVIRON["FILEARG"]); wc = ENVIRON["CATARG"]
    if (wc != "") wc = canon_cat(wc)
    nm = 0
    for (k = 1; k <= ni; k++) {
      if (st[k] != "OPEN") continue
      if (wc != "" && cat[k] != wc) continue
      nf = split(fil[k], fp, ",")
      hit = 0
      for (j = 1; j <= nf; j++) if (normpath(fp[j]) == want) hit = 1
      if (hit) { nm++; mrow[nm] = sprintf("MATCH\t%s\t%d\t%s\t%s\t%s", id[k], ln[k], cat[k], v(sta[k]), v(fil[k])) }
    }
    printf "matches\t%d\tfile=%s category=%s\n", nm, want, (wc == "") ? "any" : wc
    for (i = 1; i <= nm; i++) print mrow[i]
    exit 0
  }
' "$REG_IN"
exit $?
