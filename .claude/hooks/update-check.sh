#!/bin/bash
# Hook helper: update-check.sh
# Purpose: one line at session start when a newer Claude Code SaaS Studio
# release is out. Sourced by session-start.sh; run directly as
# `bash update-check.sh refresh` or `notice` (to see the line by hand).
#
#   update_check_notice
#     Prints the notice line when the cached latest release is newer than this
#     framework, or nothing. Starts a background refresh when the cache is
#     missing or a day old. Never touches the network itself and never waits.
#
#   bash update-check.sh refresh
#     Asks GitHub for the latest release and writes the cache. Run in the
#     background by update_check_notice; safe to run by hand.
#
# Off when `updates.check: false` (project.local.yaml first, then project.yaml;
# see effects-map.md) or when the CI environment variable is set: nobody reads a
# session-start line in CI, and a fresh runner has no cache to stop it asking
# GitHub on every run.
#
# Cross-platform: Windows Git Bash, macOS bash 3.2, Linux. Needs curl or wget
# for the refresh only.

# THE VERSION OF THE FRAMEWORK THESE FILES BELONG TO. Bumped at every release,
# with framework.version in the template's project.yaml.
#
# Not framework.version itself: that is the project's file, and an upgrade
# that keeps your project.yaml leaves it on the old number (UPGRADING.md says
# so), which would announce the release you already have. This file is replaced
# with the rest of .claude/hooks/ on every upgrade, so its number is the
# framework actually installed.
UPDATE_CHECK_VERSION="1.0.0"
UPDATE_CHECK_REPO="Basinfy/Basinfy-SaaS-Studio"

# This file's absolute path, taken before anything changes directory, so the
# background refresh can always find it. Builtins only: this runs every session.
case "${BASH_SOURCE[0]}" in
  /*|[A-Za-z]:*) _UPDATE_CHECK_SELF="${BASH_SOURCE[0]}" ;;
  *)             _UPDATE_CHECK_SELF="$PWD/${BASH_SOURCE[0]}" ;;
esac

# Per user, outside every project: git status stays clean, and one check a day
# covers every project on the machine.
_update_check_cache() {
  printf '%s' "${XDG_CACHE_HOME:-$HOME/.cache}/saas-studio/latest-release"
}

_update_check_now() {
  # EPOCHSECONDS is bash 5 and costs no process; macOS bash 3.2 falls to date.
  if [ -n "${EPOCHSECONDS:-}" ]; then printf '%s' "$EPOCHSECONDS"; else date +%s; fi
}

# 0 when $1 is a newer release than $2. Plain x.y.z numbers only; anything after
# a `-` is ignored, so 1.2.0-dev is not newer than 1.2.0.
_update_check_newer() {
  local a="${1%%-*}" b="${2%%-*}" i x y
  local IFS=.
  set -- $a; local a1="${1:-0}" a2="${2:-0}" a3="${3:-0}"
  set -- $b; local b1="${1:-0}" b2="${2:-0}" b3="${3:-0}"
  for i in 1 2 3; do
    eval "x=\$a$i; y=\$b$i"
    case "$x$y" in *[!0-9]*|'') return 1 ;; esac
    [ "$x" -gt "$y" ] && return 0
    [ "$x" -lt "$y" ] && return 1
  done
  return 1
}

# 0 unless updates.check is false. project.local.yaml first (it is a personal
# setting), then project.yaml. A value other than true or false is skipped, as
# resolve_setting skips it, and the session-start schema check names it.
# awk, not get_effective_yaml_key: that starts Python twice per session start.
_update_check_enabled() {
  local f v root="${_YH_ROOT:-.}"
  [ -n "${CI:-}" ] && return 1
  for f in "$root/project.local.yaml" "$root/project.yaml"; do
    [ -f "$f" ] || continue
    v=$(awk '
      /^updates:[[:space:]]*(#.*)?$/ { inu=1; next }
      /^[^[:space:]#]/               { inu=0 }
      inu && /^[[:space:]]+check:/ {
        sub(/^[[:space:]]*check:[[:space:]]*/, "")
        sub(/[[:space:]]*#.*$/, "")
        gsub(/["'"'"'[:space:]]/, "")   # [:space:] also strips the CR of a CRLF line
        print; exit
      }' "$f" 2>/dev/null)
    case "$v" in
      false) return 1 ;;
      true)  return 0 ;;
    esac
  done
  return 0
}


_update_auto_enabled() {
  local f v root="${_YH_ROOT:-${SAAS_STUDIO_ROOT:-.}}"
  [ -n "${CI:-}" ] && return 1
  for f in "$root/project.local.yaml" "$root/project.yaml"; do
    [ -f "$f" ] || continue
    v=$(awk '
      /^updates:[[:space:]]*(#.*)?$/ { inu=1; next }
      /^[^[:space:]#]/               { inu=0 }
      inu && /^[[:space:]]+auto:/ {
        sub(/^[[:space:]]*auto:[[:space:]]*/, "")
        sub(/[[:space:]]*#.*$/, "")
        gsub(/["'"'"'[:space:]]/, "")
        print; exit
      }' "$f" 2>/dev/null)
    case "$v" in
      true|on|auto) return 0 ;;
      false|off|prompt|"") return 1 ;;
    esac
  done
  return 1
}

update_check_apply() {
  local root="${SAAS_STUDIO_ROOT:-.}"
  if [ -f "$root/bin/cli.js" ]; then
    node "$root/bin/cli.js" update --target "$root" --force
  else
    npx github:Basinfy/Basinfy-SaaS-Studio update --target "$root" --force
  fi
}

update_check_notice() {
  _update_check_enabled || return 0
  local cache latest="" checked=0 line now
  cache=$(_update_check_cache)
  if [ -f "$cache" ]; then
    while IFS= read -r line; do
      case "$line" in
        latest=*)  latest="${line#latest=}" ;;
        checked=*) checked="${line#checked=}" ;;
      esac
    done < "$cache"
  fi
  case "$checked" in ''|*[!0-9]*) checked=0 ;; esac

  # A day old or never checked: ask again in the background. Every descriptor
  # is redirected and the job is started from a subshell, so this hook returns
  # at once and nothing it prints can reach the session.
  # A stamp in the future (a clock that was wrong) counts as old, or it would
  # hold off every refresh until that date.
  now=$(_update_check_now)
  if { [ $((now - checked)) -ge 86400 ] || [ "$checked" -gt "$now" ]; } && [ -f "$_UPDATE_CHECK_SELF" ]; then
    ( bash "$_UPDATE_CHECK_SELF" refresh </dev/null >/dev/null 2>&1 & ) >/dev/null 2>&1
  fi

  local installed_sha=""
  local root="${SAAS_STUDIO_ROOT:-.}"
  if [ -f "$root/.claude/framework-version.json" ]; then
    installed_sha=$(grep -o '"commit"[[:space:]]*:[[:space:]]*"[^"]*"' "$root/.claude/framework-version.json" 2>/dev/null | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  fi
  local is_newer=0
  if [ -n "$latest" ]; then
    if [ -n "$installed_sha" ] && [ "${#latest}" -ge 7 ] && [ "${#installed_sha}" -ge 7 ]; then
      [ "$latest" != "$installed_sha" ] && is_newer=1
    elif _update_check_newer "$latest" "$UPDATE_CHECK_VERSION"; then
      is_newer=1
    fi
  fi

  if [ "$is_newer" -eq 1 ]; then
    echo "Update: Basinfy SaaS Studio ($latest) disponível no GitHub! Para atualizar: bash .claude/hooks/update-check.sh apply (ou npx github:Basinfy/Basinfy-SaaS-Studio update)"
  fi
  return 0
}

# Ask GitHub, write the cache. A failed or unreadable answer keeps the last
# known release and still stamps the time, so an offline machine asks once a
# day, not every session; the reason is kept in the cache for anyone checking.
update_check_refresh() {
  local cache dir body="" tag="" err="" old="" line tmp
  cache=$(_update_check_cache); dir="${cache%/*}"
  [ -z "$UPDATE_CHECK_REPO" ] && return 0
  [ ! -d "$dir" ] && mkdir -p "$dir" 2>/dev/null
  local url="https://api.github.com/repos/$UPDATE_CHECK_REPO/releases/latest"
  if command -v curl >/dev/null 2>&1; then
    body=$(curl -fsSL --max-time 10 -H 'Accept: application/vnd.github+json' "$url" 2>/dev/null) || err="request failed"
  elif command -v wget >/dev/null 2>&1; then
    # One try (wget retries 20 times by default, and -T applies to each of
    # them, so an offline machine kept this job alive for minutes); -T is its
    # DNS, connect and read timeout each, so 5 keeps it near curl's 10 s total.
    body=$(wget -q -t 1 -T 5 -O - "$url" 2>/dev/null) || err="request failed"
  else
    err="neither curl nor wget found"
  fi
  if [ -z "$err" ]; then
    tag=$(printf '%s' "$body" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
          | sed 's/.*"\([^"]*\)"$/\1/; s/^v//')
    case "$tag" in
      [0-9]*.[0-9]*.[0-9]*) case "$tag" in *[!0-9.]*) err="unexpected tag: $tag"; tag="" ;; esac ;;
      *) err="no release tag in the answer"; tag="" ;;
    esac
  fi
  # If no release tag found, check latest commit on master
  if [ -z "$tag" ]; then
    local curl_opts=(--max-time 10 -H 'Accept: application/vnd.github+json')
    local c_url="https://api.github.com/repos/$UPDATE_CHECK_REPO/commits/master"
    local c_body=""
    if command -v curl >/dev/null 2>&1; then
      c_body=$(curl -fsSL "${curl_opts[@]}" "$c_url" 2>/dev/null)
    elif command -v wget >/dev/null 2>&1; then
      c_body=$(wget -q -t 1 -T 5 -O - "$c_url" 2>/dev/null)
    fi
    if [ -n "$c_body" ]; then
      tag=$(printf '%s' "$c_body" | grep -o '"sha"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' | cut -c1-7)
      err=""
    fi
  fi
  if [ -z "$tag" ] && [ -f "$cache" ]; then
    while IFS= read -r line; do
      case "$line" in latest=*) old="${line#latest=}" ;; esac
    done < "$cache"
    tag="$old"
  fi
  tmp="$cache.$$"
  {
    echo "checked=$(_update_check_now)"
    echo "latest=$tag"
    # An `if`, not `[ ] && echo`: as the block's last command that returns 1
    # when there is no error, and the cache was never written on a success.
    if [ -n "$err" ]; then echo "error=$err"; fi
  } > "$tmp" 2>/dev/null && mv -f "$tmp" "$cache" 2>/dev/null
  rm -f "$tmp" 2>/dev/null
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  # Run directly, work from the project root, in session-start.sh's order: a
  # cwd that is a project root wins, then CLAUDE_PROJECT_DIR, then this file's
  # own location. Sourced, it leaves the caller's directory alone.
  if [ -f "project.yaml" ] || { [ -d ".claude" ] && [ "${PWD##*/}" != ".claude" ]; }; then
    SAAS_STUDIO_ROOT="$PWD"
  elif [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -d "${CLAUDE_PROJECT_DIR}" ] && case "${CLAUDE_PROJECT_DIR%/}" in */.claude|*\\.claude) false ;; *) true ;; esac; then
    SAAS_STUDIO_ROOT="$CLAUDE_PROJECT_DIR"
  else
    SAAS_STUDIO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
  fi
  [ -n "$SAAS_STUDIO_ROOT" ] && cd "$SAAS_STUDIO_ROOT" 2>/dev/null || true
  case "${1:-}" in
    refresh) update_check_refresh ;;
    notice)  update_check_notice ;;
    apply|update) update_check_apply ;;
    *) echo "update-check.sh: usage: bash update-check.sh refresh|notice|apply" ;;
  esac
  exit 0
fi
