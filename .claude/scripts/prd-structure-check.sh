#!/usr/bin/env bash
# prd-structure-check.sh — deterministic section-presence check for SaaS PRDs & functional specs.
#
# Checks docs/specs/*.md and docs/prd/*.md (and design/prd/*.md) for required SaaS PRD sections.
#
# Sections checked:
# 1. Problem Statement / Overview
# 2. Success Metrics
# 3. User Stories
# 4. Requirements Pool / Functional Requirements
# 5. Data Models / Schema
# 6. Security & Permissions
# 7. Edge Cases
# 8. Acceptance Criteria
#
# Usage:
#   bash .claude/scripts/prd-structure-check.sh                    # all PRDs in docs/specs/ and docs/prd/
#   bash .claude/scripts/prd-structure-check.sh docs/specs/auth.md # one specific PRD
#
# Output per PRD:
#   auth.md PRESENT: Problem Statement,Success Metrics,User Stories,...
#   auth.md ABSENT:  Security & Permissions,Edge Cases
#   auth.md PLACEHOLDER: Data Models / Schema

set -u

cd "$(dirname "$0")/../.." || { echo "prd-structure-check: cannot reach repo root" >&2; exit 1; }

# ERE patterns for each required section and canonical labels
MATCH=(
  "(Problem[[:space:]]+Statement|Background|Product[[:space:]]+Goals|Overview|Summary)"
  "(Success[[:space:]]+Metrics|Goals[[:space:]]+&[[:space:]]+Metrics|KPIs|Measurable[[:space:]]+Goals|Metrics)"
  "(User[[:space:]]+Stories|User[[:space:]]+Personas|Customer[[:space:]]+Journey|Workflows|Use[[:space:]]+Cases)"
  "(Requirements[[:space:]]+Pool|Functional[[:space:]]+Requirements|Detailed[[:space:]]+Design|Feature[[:space:]]+Scope|Core[[:space:]]+Rules|Detailed[[:space:]]+Rules)"
  "(Data[[:space:]]+Models?|Data[[:space:]]+Schema|Database[[:space:]]+Schema|Data[[:space:]]+Structures|Entities)"
  "(Security|Permissions|Authentication|Auth[[:space:]]+&[[:space:]]+Access|Authorization|Access[[:space:]]+Control)"
  "(Edge[[:space:]]+Cases|Error[[:space:]]+Handling|Failure[[:space:]]+Modes)"
  "(Acceptance[[:space:]]+Criteria|Definition[[:space:]]+of[[:space:]]+Done|Acceptance[[:space:]]+Tests)"
)

LABEL=(
  "Problem Statement"
  "Success Metrics"
  "User Stories"
  "Requirements Pool"
  "Data Models / Schema"
  "Security & Permissions"
  "Edge Cases"
  "Acceptance Criteria"
)

not_a_prd() {
  case "$(basename "$1")" in
    product-concept.md|product-brief.md|product-pillars.md|features-index.md|features-modules-index.md) return 0 ;;
    customer-journey-map.md|user-persona-profile.md|prd-cross-review-*.md|prd-cross-review-*.md) return 0 ;;
    features-modules-index.md|product-concept.md|product-brief.md|product-pillars.md|brand-voice-tone-guide.md) return 0 ;;
    README.md|index.md) return 0 ;;
    *) return 1 ;;
  esac
}

placeholders() {
  local pats="" labels="" i
  for i in "${!MATCH[@]}"; do pats="$pats;${MATCH[$i]}"; labels="$labels;${LABEL[$i]}"; done
  awk -v pats="${pats#;}" -v labels="${labels#;}" '
    { sub(/\r$/, ""); line[NR] = $0 }
    END {
      n = split(pats, P, ";"); split(labels, L, ";"); out = ""
      for (i = 1; i <= n; i++) {
        re = "^##+[ \t]+([0-9]+[.)]?[ \t]*)?" tolower(P[i])
        found = 0; start = 0
        for (j = 1; j <= NR; j++) {
          if (tolower(line[j]) ~ re) { found = 1; start = j + 1; break }
        }
        if (!found) continue
        has_content = 0
        for (j = start; j <= NR; j++) {
          if (line[j] ~ /^##+[ \t]+/) break
          t = line[j]
          sub(/^[ \t]+/, "", t); sub(/[ \t]+$/, "", t)
          if (t == "" || t ~ /^\[To be designed\]$/i || t ~ /^\[TBD\]$/i || t ~ /^###+[ \t]+/) continue
          has_content = 1; break
        }
        if (!has_content) out = out "," L[i]
      }
      sub(/^,/, "", out)
      print out
    }
  '
}

check_file() {
  local f="$1" present="" absent="" i s
  for i in "${!MATCH[@]}"; do
    s="${MATCH[$i]}"
    if grep -qiE "^##+[[:space:]]+([0-9]+[.)]?[[:space:]]*)?${s}" "$f"; then
      present="$present,${LABEL[$i]}"
    else
      absent="$absent,${LABEL[$i]}"
    fi
  done
  local b; b="$(basename "$f")"
  echo "$b PRESENT: ${present#,}"
  [ -n "$absent" ] && echo "$b ABSENT:  ${absent#,}"
  local held; held=$(placeholders < "$f")
  [ -n "$held" ] && echo "$b PLACEHOLDER: $held"
  return 0
}

# Target file passed directly
if [ $# -gt 0 ]; then
  for arg in "$@"; do
    if [ -f "$arg" ]; then
      check_file "$arg"
    else
      echo "prd-structure-check: file not found: $arg" >&2
    fi
  done
  exit 0
fi

# Auto-discovery across docs/specs, docs/prd, and design/prd
FOUND=0
for d in docs/specs docs/prd design/prd; do
  [ -d "$d" ] || continue
  for f in "$d"/*.md; do
    [ -f "$f" ] || continue
    not_a_prd "$f" && continue
    check_file "$f"
    FOUND=1
  done
done

if [ $FOUND -eq 0 ]; then
  echo "prd-structure-check: no PRD files found to inspect"
fi

exit 0
