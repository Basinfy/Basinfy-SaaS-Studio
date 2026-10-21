# yaml-get.awk — print the scalar at one dotted path of a YAML file, or nothing.
# The one YAML reader the bash/awk helpers share (project-state.sh,
# config-set.sh), so they read a file the same way:
#
#   YG_PATH=project.stage awk -f .claude/scripts/yaml-get.awk project.yaml
#
# The rules are get_yaml_key's (yaml-helper.sh, which needs Python), so the
# two readers give one answer for one file; the test suite holds them to it:
#   - indentation is leading spaces; a tab-led line is skipped, not nested
#   - blank lines and lines whose first non-space is `#` are skipped
#   - the key runs to the first `:`; it may not start with `:`, `#` or a space
#   - a value starting with `#` is empty; a quoted value is the text up to the
#     closing quote of the same kind (rest of the line if unclosed); otherwise
#     the value is cut at the first ` #`
#   - an empty value opens a mapping, and a repeated key merges into it; a
#     scalar assigned to a key replaces everything under that key
#   - a value of `|` or `>`, with any indicators (`|-`, `>+`, `|2`) and an
#     optional comment, opens a block scalar: the lines after it indented
#     deeper than its key (or than the dash, for a `- |` list item), and the
#     blank lines among them, are its text, never keys; the value is the
#     indicator itself
#   - CR line ends and a UTF-8 BOM on line 1 are ignored
# A path that ends on a mapping prints nothing, as get_yaml_key does.
# BWK awk safe: no gawk extensions. Run it under LC_ALL=C (byte semantics for
# the BOM test).

# opens(s, n) -- when line s (at indent n, its leading spaces removed) opens
# a block scalar, the indent its text must exceed; else -1.
function opens(s, n,    r, p, v) {
  r = s
  if (r == "-" || substr(r, 1, 2) == "- ") {
    r = substr(r, 2); sub(/^ +/, "", r)
    if (r ~ /^[|>][-+0-9]*[ \t]*(#.*)?$/) return n
    n = n + length(s) - length(r)
  }
  if (r == "" || r ~ /^[:# \t]/) return -1
  p = index(r, ":"); if (p == 0) return -1
  v = substr(r, p + 1); sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v)
  return (v ~ /^[|>][-+0-9]*[ \t]*(#.*)?$/) ? n : -1
}

BEGIN { want = ENVIRON["YG_PATH"]; depth = 0; val = ""; blk = -1 }
{
  line = $0
  # "\357\273\277" is the UTF-8 byte-order mark.
  if (NR == 1 && substr(line, 1, 3) == "\357\273\277") line = substr(line, 4)
  sub(/\r$/, "", line)
  n = 0
  while (substr(line, n + 1, 1) == " ") n++
  s = substr(line, n + 1)
  t = s
  sub(/^[ \t]+/, "", t)
  if (t == "" || substr(t, 1, 1) == "#") next
  if (blk >= 0) { if (n > blk) next; blk = -1 }
  blk = opens(s, n)
  c = substr(s, 1, 1)
  if (c == ":" || c == "#" || c == "\t") next
  p = index(s, ":")
  if (p == 0) next
  key = substr(s, 1, p - 1)
  sub(/[ \t]+$/, "", key)
  v = substr(s, p + 1)
  sub(/^[ \t]+/, "", v)
  sub(/[ \t]+$/, "", v)
  q = substr(v, 1, 1)
  if (q == "#") v = ""
  else if (q == "\"" || q == "'") {
    rest = substr(v, 2)
    e = index(rest, q)
    v = (e > 0) ? substr(rest, 1, e - 1) : rest
  } else {
    h = index(v, " #")
    if (h > 0) { v = substr(v, 1, h - 1); sub(/[ \t]+$/, "", v) }
  }
  while (depth > 0 && ind[depth] >= n) depth--
  full = ""
  for (i = 1; i <= depth; i++) full = full keys[i] "."
  full = full key
  if (v == "") {
    depth++; ind[depth] = n; keys[depth] = key
    if (full == want) val = ""
  } else {
    if (full == want) val = v
    # A scalar replaces the mapping it lands on, and every value under it.
    else if (substr(want, 1, length(full) + 1) == full ".") val = ""
  }
}
END { printf "%s", val }
