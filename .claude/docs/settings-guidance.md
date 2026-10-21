# Settings Guidance — which value to recommend, and when

The **advisory** layer for project settings. This doc answers two questions no
other doc does:

1. **Which value should a skill recommend** for a given project or user?
2. **When should a skill proactively suggest changing** a setting already set?

## Boundary with its siblings

| Doc | Answers | Nature |
|---|---|---|
| `effects-map.md` | What each setting *does* | Descriptive |
| `config-resolution.md` | How a setting *resolves* (precedence chain) | Mechanical |
| **`settings-guidance.md`** (this file) | Which value to *recommend*, and *when* | Prescriptive |

Skills reference this doc **on demand**, only at a "recommend a setting" moment.
It is **not** a CLAUDE.md import — advisory content must not ride in per-turn
context.

---

## 1. The knob that matters most: `modes.rigor`

Almost every "what settings should I use?" question reduces to one choice:
`modes.rigor` (`minimal` | `standard` | `full`, default `minimal`). It fronts six
sub-knobs — `modes.workflow`, `docs.density`, `qa.level`, `modes.story_granularity`,
`modes.review_mode`, `team.size`. Recommend **rigor**, not the six; let the
expansion do the rest. The full expansion table is in `effects-map.md § modes.rigor`.

`modes.automation` (`collaborative` | `guided` | `autonomous`) is a **separate
axis** — how often skills stop to confirm — and is *not* fronted by rigor. Pick it
by working style, not by product type (see § 5).

---

## 2. Archetype → rigor presets

Match the project to an archetype; recommend the paired rigor. These are starting
points, not verdicts — the user can always override.

| Archetype | Rigor | Why | Common override |
|---|---|---|---|
| Weekend hackathon / prototype / throwaway | `minimal` | Shipping beats recording; architecture lives in maker's head | Bump one critical service: `workflow_overrides.system_overrides: {billing: full}` |
| Small solo / micro-SaaS / hobby app | `minimal` → `standard` if it grows | Start light; add rigor when scope proves real | — |
| Focused commercial B2B SaaS (CRM, invoicing, analytics) | `standard` | One well-understood loop; enough design to build correctly | "Comprehensive but compact": `rigor: full` + `docs.density: terse` |
| Systems-heavy / enterprise SaaS (multi-tenant ERP, compliance, fintech) | `full` | Many interacting services; a design mistake costs weeks | Solo dev: keep `full` on disk, set `review_mode: solo` locally |
| High-scale / mission-critical / fintech platform | `full` + domain emphasis | Full pipeline *plus* security/SOC2/audit trails | Raise `qa.level` / `testing.strict.*` for auth/billing |

**The model:** the table picks a baseline; overrides handle the diagonal. Most real
projects are one baseline plus one or two deliberate exceptions.

---

## 3. Seeding rigor from a described concept

When the user has described their SaaS product (e.g. `/saas-start` Phase 2 free text), map it to
an archetype and **pre-select** the recommendation rather than asking cold. Signals:

| Concept mentions… | Lean toward |
|---|---|
| enterprise, multi-tenant, billing, compliance, SOC2, data pipeline, team, permissions, "complex workflows" | `full` |
| hackathon, weekend, prototype, "first SaaS", MVP, small, "just trying", experiment | `minimal` |
| "commercial", "B2B", "subscription", "self-serve", a single clear core loop | `standard` |
| *ambiguous / nothing above* | `minimal` (the documented default) |

**Rules:** these are heuristics, never locks. Always confirm the pre-selection with
the user in their own terms ("Sounds like an enterprise SaaS system — I'd suggest `full`
rigor; want that?"). If the user has **no concept yet** (exploring), do not seed
`full` — default `minimal`, and revisit once a concept exists.

"No concept yet" means **no signal**, not a particular onboarding path. A rough
one-line hint is still a description: if it trips the signals above, seed from the
signal. Only fall back to `minimal`-for-exploring when the user has given you
nothing to map. (`/saas-start` Phase 4 applies the same rule when it infers rigor for its
Path A/B branch.)

---

## 4. When to recommend a *change* (adaptive triggers)

Bidirectional and **threshold-based**. Fire only on a threshold *crossing*, never
every session — that is what keeps this from becoming the nagging the `automation`
modes exist to eliminate.

| Trigger (crossing) | Direction | Detectable signal | Suggested action |
|---|---|---|---|
| Project grew past its band | ↑ raise | System-PRD count crosses ~9, or the code root (`src/`, `Assets/` or `Source/`) crosses the Production threshold, while rigor is `minimal` | "You're at N systems on `rigor: minimal` — most projects this size run `standard`. Revisit? → `/saas-settings`" |
| Stage advanced into Production | ↑ raise | `/saas-gate-check` PASS into Production while rigor is `minimal` | Same, offered once at the gate |
| User sounds overwhelmed by process | ↓ lower | Phrases like "too many steps", "so much documentation", "overwhelmed" — *and* rigor is not already `minimal` | "If the required-doc list feels heavy, a lower rigor trims it → `/saas-settings modes.rigor=standard`" |
| Chosen rigor mismatches described scope | flag once | Onboarding pick contradicts the Phase-2 description | State it in one sentence, offer `/saas-settings`, do not re-ask |

**Frequency guard:** the crossing *is* the gate. Because the hosts (`/saas-gate-check` on
PASS, `/saas-help` on request) are themselves infrequent, no persistent "already nudged"
state is needed — but never emit the same suggestion twice in one session.

---

## 5. Which skills reference this doc, and when

| Skill | Moment | Sections used |
|---|---|---|
| `/saas-start` | Phase 4 — inferring rigor for the card | § 2 (presets), § 3 (seed from concept) |
| `/saas-help` | escalation footer when user sounds stuck/overwhelmed | § 4 (lower trigger) |
| `/saas-gate-check` | on PASS into a new stage | § 4 (raise trigger) |
| `/saas-settings` | view output — further reading | § 2 (choosing a value) |

These skills each carry a **one-line pointer** to this doc.

---

## 6. How to phrase a recommendation

- **Recommend, don't dictate.** State the suggestion and the reason in one line;
  the user decides. (`collaborative`/`guided` require this; even `autonomous`
  treats a rigor change as a `schema_changes` decision and asks.)
- **Always route to `/saas-settings`** — never edit `project.yaml` as a side effect of a
  recommendation.
- **One line, then stop.** A nudge is a nudge, not a lecture.
