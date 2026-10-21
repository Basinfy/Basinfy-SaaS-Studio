#!/usr/bin/env bash
# content-count.sh — counts for /saas-content-audit: named SaaS entities planned
# in the entity registry (entries, deprecated ones left out), SaaS resource files
# found on disk per stack and per resource type, and a specified / found pair's
# percentage and status band, with the gap table's totals.
#
# Replaces hand-run counting in /saas-content-audit (Phase 1 step 2, Phase 2
# and Phase 3) and the "planned content" count /saas-consistency-check and
# /saas-asset-spec make from the same registry.
#
# EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
# A band name is the rule row that matched. Whether a system is HIGH PRIORITY
# stays in the skill: each gap row says only whether its band is a low one
# (NOT STARTED or EARLY). The counts are of files and entries across SaaS
# application architecture layers.
#
# Usage: bash .claude/scripts/content-count.sh [--root DIR] COMMAND [ARGS]
#   registry        the planned named content: the entries of design/registry/
#                   entities.yaml's entities and items sections, read through
#                   registry.sh, deprecated ones left out
#   found [--engine E] [--files]
#                   resource files on disk for the stack (nextjs, fastapi or
#                   saas; default: stack.frontend as project-state.sh reads it)
#   band FOUND SPECIFIED
#                   the percentage and status band of one pair
#   gap             rows `system<TAB>type<TAB>specified<TAB>found` on stdin:
#                   the gap table, with totals
#   --root DIR      the project; defaults to the repo this script is in
#   -h, --help      this text
#
# The status bands. The edges are half-open, found / specified compared exactly,
# never as a rounded or printed percentage, so every value falls in exactly one band:
#   found = 0                          NOT STARTED
#   0 < found/specified < 50%          EARLY          ("1-49%")
#   50% <= found/specified < 100%      IN PROGRESS    ("50-99%")
#   found >= specified                 COMPLETE       ("100%+")
# A specified of 0 has no percentage and no band: `-`. Percentages are
# truncated, not rounded, to one decimal, so a printed value never sits on the
# far side of a band edge (99.96% prints 99.9, never 100.0).
#
# Where `found` looks for SaaS resource types:
#   routes      API endpoints, route handlers, webhooks, pages (src/app/**, src/api/**, routes/)
#   components  UI components, layout widgets, design system tokens (src/components/**, ui/**)
#   schemas     Database models, Prisma/Drizzle schemas, migrations, Supabase SQL
#   services    Backend services, lib, utils, worker jobs, auth/billing logic
#   docs        Architecture blueprints, PRDs, UX specs, API specs (docs/**, design/**)
#
# Output: TSV.
#   registry:  registry <path> <entries | missing | layout>, planned
#              entities <n>, planned items <n>, planned_total <n>,
#              deprecated_skipped <n>, no_status <n> (counted, status absent),
#              status_other <n> <values> (counted, status not active or
#              deprecated), duplicate_names <n> (a name twice in a section),
#              source <prd> <n> per source PRD of the planned entries, then
#              PLANNED <section> <name> <source> and
#              SKIPPED <section> <name> <source> deprecated, in registry order
#   found:     engine <name> <source: project.yaml, project.local.yaml, flag...>,
#              root <dir> <present|absent>, found <type> <n> (five types), by
#              <type> <folder | extension> <n>, and with --files
#              FILE <type> <path>
#   band:      band <F>/<S> <name | -> <percent | -> <rule>
#   gap:       rows <counted> <read>, excluded <n>, total_specified,
#              total_found, total_gap (specified - found; negative when over-built),
#              gap_pct, unbuilt, unbuilt_pct, systems <n>,
#              ROW <system> <type> <specified> <found> <gap> <percent> <status> <low>,
#              EXCLUDED <system> <type> <reason>
#
# Exit codes: 0 answered; 1 root unreadable or dependency missing; 2 usage error;
# 3 found: no stack set; gap: no rows with numbers; 4 registry unsupported layout.

set -u
LC_ALL=C
export LC_ALL

HERE="$(cd "$(dirname "$0")" && pwd)"
usage() { echo "content-count: $1 (try --help)" >&2; exit 2; }
TAB=$(printf '\t')

CMD=""; ROOT_ARG=""; ENGINE_ARG=""; SHOWFILES=0; NPOS=0; P1=""; P2=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || usage "--root needs a value"; ROOT_ARG="$2"; shift 2 ;;
    --root=*) ROOT_ARG="${1#--root=}"; shift ;;
    --engine) [ $# -ge 2 ] || usage "--engine needs a name"; ENGINE_ARG="$2"; shift 2 ;;
    --engine=*) ENGINE_ARG="${1#--engine=}"; shift ;;
    --files) SHOWFILES=1; shift ;;
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
  registry|gap) [ $NPOS -eq 0 ] || usage "$CMD takes no arguments" ;;
  found) [ $NPOS -eq 0 ] || usage "found takes no arguments" ;;
  band) [ $NPOS -eq 2 ] || usage "band needs FOUND and SPECIFIED"
        case "$P1$P2" in *[!0-9]*) usage "band takes whole numbers" ;; esac
        [ -n "$P1" ] && [ -n "$P2" ] || usage "band takes whole numbers" ;;
  "") usage "no command" ;;
  *) usage "unknown command: $CMD" ;;
esac
[ "$CMD" = found ] || [ -z "$ENGINE_ARG" ] || usage "--engine belongs to found"
[ "$CMD" = found ] || [ "$SHOWFILES" -eq 0 ] || usage "--files belongs to found"

# The band and percentage arithmetic, shared by band and gap.
AWK_LIB='
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
  function pct1(f, s,    t) {
    if (s == 0) return "-"
    t = int(f * 1000 / s)
    return sprintf("%d.%d", int(t / 10), t % 10)
  }
  function band(f, s) {
    if (s == 0) { BNAME = "-"; BRULE = "specified is 0: no percentage"; return }
    if (f == 0) { BNAME = "NOT STARTED"; BRULE = "found = 0"; return }
    if (f >= s) { BNAME = "COMPLETE"; BRULE = "found >= specified"; return }
    if (f * 2 >= s) { BNAME = "IN PROGRESS"; BRULE = "50% <= found/specified < 100%"; return }
    BNAME = "EARLY"; BRULE = "0 < found/specified < 50%"
  }
'

if [ "$CMD" = band ]; then
  F="$P1" S="$P2" awk "$AWK_LIB"'BEGIN {
    f = ENVIRON["F"] + 0; s = ENVIRON["S"] + 0
    band(f, s)
    printf "band\t%d/%d\t%s\t%s\t%s\n", f, s, BNAME, pct1(f, s), BRULE
  }'
  exit 0
fi

if [ "$CMD" = gap ]; then
  awk "$AWK_LIB"'
    BEGIN { BINMODE = 3 }
    {
      line = $0; sub(/\r$/, "", line)
      if (line == "") next
      nread++
      n = split(line, c, "\t")
      sy = trim(c[1]); ty = trim(c[2]); sp = trim(c[3]); fo = trim(c[4])
      if (n < 4) { ne++; ex[ne] = sy "\t" ty "\tfewer than 4 columns"; next }
      if (sp !~ /^[0-9]+$/) { ne++; ex[ne] = sy "\t" ty "\tspecified is not a number: " sp; next }
      if (fo !~ /^[0-9]+$/) { ne++; ex[ne] = sy "\t" ty "\tfound is not a number: " fo; next }
      sp += 0; fo += 0
      nc++
      band(fo, sp)
      sg = (sp > fo) ? sp - fo : 0
      rows[nc] = sprintf("ROW\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%s", sy, ty, sp, fo, sg, pct1(fo, sp), BNAME, (BNAME == "-") ? "-" : ((BNAME == "EARLY" || BNAME == "NOT STARTED") ? "yes" : "no"))
      ts += sp; tf += fo; ub += sg
      if (!(sy in sysseen)) { sysseen[sy] = 1; nsys++ }
    }
    END {
      printf "rows\t%d\t%d\nexcluded\t%d\n", nc, nread, ne
      if (nc == 0) {
        printf "total_specified\t-\ntotal_found\t-\ntotal_gap\t-\ngap_pct\t-\nunbuilt\t-\nunbuilt_pct\t-\nsystems\t0\n"
      } else {
        d = ts - tf
        printf "total_specified\t%d\ntotal_found\t%d\ntotal_gap\t%d\n", ts, tf, d
        if (ts == 0) printf "gap_pct\t-\n"
        else if (d < 0) printf "gap_pct\t-%s\n", pct1(-d, ts)
        else printf "gap_pct\t%s\n", pct1(d, ts)
        printf "unbuilt\t%d\nunbuilt_pct\t%s\nsystems\t%d\n", ub, pct1(ub, ts), nsys
      }
      for (i = 1; i <= nc; i++) print rows[i]
      for (i = 1; i <= ne; i++) printf "EXCLUDED\t%s\n", ex[i]
      exit ((nc == 0) ? 3 : 0)
    }
  '
  rc=$?
  [ $rc -ne 3 ] || echo "content-count: no row with a specified and a found number" >&2
  exit $rc
fi

if [ -n "$ROOT_ARG" ]; then
  cd "$ROOT_ARG" 2>/dev/null || { echo "content-count: cannot read root $ROOT_ARG" >&2; exit 1; }
else
  cd "$HERE/../.." 2>/dev/null || { echo "content-count: cannot reach the repo root" >&2; exit 1; }
fi

# ------------------------------------------------------------------- registry
if [ "$CMD" = registry ]; then
  [ -f "$HERE/registry.sh" ] || { echo "content-count: $HERE/registry.sh is missing" >&2; exit 1; }
  OUT=$(bash "$HERE/registry.sh" --root . list entities 2>/dev/null); RC=$?
  case $RC in 0|4) ;; *) echo "content-count: registry.sh list entities failed (exit $RC)" >&2; exit 1 ;; esac
  printf '%s\n' "$OUT" | awk '
    BEGIN { BINMODE = 3; FS = "\t" }
    $1 == "registry" { rpath = $3; rstate = $4 }
    $1 == "LAYOUT" { lay[++nlay] = $0 }
    $1 == "ENTRY" && ($3 == "entities" || $3 == "items") {
      sec = $3; nm = $5; stt = $6; src = $7
      if (tolower(stt) == "deprecated") {
        nskip++; rows[++nr] = "SKIPPED\t" sec "\t" nm "\t" src "\tdeprecated"
      } else {
        planned[sec]++; total++
        rows[++nr] = "PLANNED\t" sec "\t" nm "\t" src
        if (stt == "-") nostat++
        else if (tolower(stt) != "active") {
          nother++
          if (!(stt in oseen)) { oseen[stt] = 1; olist = olist (olist == "" ? "" : ",") stt }
        }
        k = sec "\t" nm; nameN[k]++
        if (nameN[k] == 2) ndup++
        if (!(src in srcN)) so[++ns] = src
        srcN[src]++
      }
    }
    END {
      printf "registry\t%s\t%s\n", (rpath == "") ? "design/registry/entities.yaml" : rpath, (rstate == "") ? "missing" : rstate
      if (rstate == "layout") { for (i = 1; i <= nlay; i++) print lay[i]; exit 4 }
      printf "planned\tentities\t%d\nplanned\titems\t%d\nplanned_total\t%d\n", planned["entities"], planned["items"], total
      printf "deprecated_skipped\t%d\nno_status\t%d\nstatus_other\t%d\t%s\nduplicate_names\t%d\n", nskip, nostat, nother, (olist == "") ? "-" : olist, ndup
      for (i = 2; i <= ns; i++) { x = so[i]; for (j = i - 1; j >= 1 && so[j] > x; j--) so[j + 1] = so[j]; so[j + 1] = x }
      for (i = 1; i <= ns; i++) printf "source\t%s\t%d\n", so[i], srcN[so[i]]
      for (i = 1; i <= nr; i++) print rows[i]
    }
  '
  if [ "$RC" -eq 4 ]; then
    echo "content-count: unsupported registry layout; the LAYOUT rows give each line and the layout expected there" >&2
    exit 4
  fi
  exit 0
fi

# ---------------------------------------------------------------------- found
if [ -n "$ENGINE_ARG" ]; then
  RAW="$ENGINE_ARG"; ESRC="flag"
else
  RAW=""; ESRC=""
  [ -f "$HERE/yaml-get.awk" ] || { echo "content-count: $HERE/yaml-get.awk is missing; pass --engine" >&2; exit 1; }
  for yf in project.local.yaml project.yaml; do
    if [ -z "$RAW" ] && [ -f "$yf" ]; then
      RAW=$(YG_PATH=stack.frontend awk -f "$HERE/yaml-get.awk" "$yf")
      [ -z "$RAW" ] || ESRC="$yf"
    fi
  done
  if [ -z "$RAW" ] && [ -f "$HERE/project-state.sh" ]; then
    ROW=$(bash "$HERE/project-state.sh" --root . | awk -F'\t' '$1 == "engine" { print $2 "\t" $3 }')
    RAW="${ROW%%"$TAB"*}"; ESRC="${ROW#*"$TAB"}"
  fi
fi

if [ -z "$RAW" ] || [ "$RAW" = "-" ]; then
  RAW="nextjs"
  ESRC="default"
fi

ENG="saas"
ROOTS="src app pages components lib prisma supabase docs design production"
printf 'engine\t%s\t%s\n' "$RAW" "$ESRC"

PRESENT=""; NPRES=0
for r in $ROOTS; do
  if [ -d "$r" ]; then
    printf 'root\t%s\tpresent\n' "$r"; PRESENT="$PRESENT $r"; NPRES=$((NPRES + 1))
  else
    printf 'root\t%s\tabsent\n' "$r"
  fi
done

LIST=""
[ -z "$PRESENT" ] || LIST=$(find $PRESENT -type f 2>/dev/null | sort)

printf '%s\n' "$LIST" | SHOWFILES="$SHOWFILES" awk '
  BEGIN {
    BINMODE = 3
    ng = split("routes components schemas services docs", G, " ")
  }
  NF > 0 {
    p = $0; sub(/\r$/, "", p)
    n = split(p, seg, "/")
    if (n < 2) next
    fname = seg[n]
    ext = ""
    if (match(fname, /\.[^.]*$/)) ext = tolower(substr(fname, RSTART + 1))

    hit_type = ""
    if (p ~ /\/(api|routes)\// || fname ~ /^(route|page)\.(ts|tsx|js|jsx)$/ || p ~ /\/endpoints\//) hit_type = "routes"
    else if (p ~ /\/(components|ui|views|widgets)\//) hit_type = "components"
    else if (ext == "prisma" || ext == "sql" || p ~ /\/(db|models|schemas|migrations)\//) hit_type = "schemas"
    else if (p ~ /\/(services|server|lib|utils|core|workers|jobs)\//) hit_type = "services"
    else if (ext == "md" && (p ~ /^(docs|design|production)\//)) hit_type = "docs"

    if (hit_type != "") {
      tot[hit_type]++
      folder = (n >= 3) ? seg[2] : seg[1]
      by[hit_type, folder]++
      seen_folder[hit_type, folder] = 1
      if (ENVIRON["SHOWFILES"] == "1") frow[++nfr] = "FILE\t" hit_type "\t" p
    }
  }
  END {
    for (gi = 1; gi <= ng; gi++) {
      g = G[gi]
      printf "found\t%s\t%d\n", g, tot[g] + 0
    }
    for (k in seen_folder) {
      split(k, parts, SUBSEP)
      g = parts[1]; f = parts[2]
      printf "by\t%s\t%s\t%d\n", g, f, by[g, f]
    }
    for (i = 1; i <= nfr; i++) print frow[i]
  }
'
exit 0
