# /saas-prototype — Spike Mode

> Part of `/saas-prototype`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

**Triggered by:** `--spike` flag OR "Mid-production spike" entry choice in Phase 1.

**Purpose:** Test a specific technical or design question mid-production, without
the overhead of a full concept prototype workflow. No PRD prerequisites. No phase
gate implications. Hard cap: ~4 hours.

**When to use:**
- You're in Production and want to test whether a new workflow/feature should be added
- You're unsure if a technical approach will work before building it properly
- A design change is being considered and you want a quick before/after comparison
- A PRD system is proving harder than expected and you want to prototype the hard part
- You need to confirm target hardware can sustain the required framerate before writing core business workflow code (**performance spike** — see below)

**Spike Mode workflow (replaces Phases 1–9):**

1. **Define the spike question** (plain text, not a widget): "What specific question does this spike answer? Give me one sentence: 'Can we [do X] using [approach Y]?'"

2. **Choose path** — same AskUserQuestion widget as Phase 3 (HTML / Engine / Paper).

3. **Scope** — maximum 2-3 bullet points. One workflow, one technical question, nothing else.

4. **Build** — first ask "May I create `prototypes/[concept-name]-spike-[date]/` and build the spike there?" Same relaxed standards and header as the concept prototype. Hard cap: 4 hours. If not demonstrable in 4 hours, the question is too large. Split it.

5. **Observe and decide** — no formal usability test debrief. Ask: "Did the spike answer the question? YES or NO, and why in one sentence."

6. **Write a spike note** (not a full report) to `prototypes/[concept-name]-spike-[date]/SPIKE-NOTE.md` — first ask once for this step and the next, naming both files: "May I write `prototypes/[concept-name]-spike-[date]/SPIKE-NOTE.md` and clear the spike from `production/session-state/active.md`?" The note holds:
   - Question tested
   - Result (YES it works / NO it doesn't / PARTIAL — needs more investigation)
   - What to do next (add to current sprint — at `workflow: minimal`, the brief's build order — / investigate further / abandon the idea)

7. **Update `production/session-state/active.md`** to clear the spike and return to the current sprint state (at `workflow: minimal`, the story in progress).

**No CD gate. No phase gate. No PROCEED/PIVOT/KILL.** Spike results inform decisions; they don't make them. The developer decides whether to add the feature/approach to the sprint backlog (at `workflow: minimal`, to the brief's build order) based on what the spike revealed.

**Performance spike (special case):** If the application involves high data throughput,
complex real-time operations, heavy client-side rendering (e.g., virtualized tables with 50k rows,
large canvas/SVG charts, client-side data crunching), or strict API latency targets (p95 < 100ms) —
run a performance spike before writing full business logic to confirm the stack and browser
can sustain the required throughput and responsiveness. This is distinct from other spikes in two ways:
- The question is "can the system process [workload X] with p95 < 200ms and smooth UI responsiveness under [target concurrency/data size]?"
  not "is the workflow intuitive?"
- The output is a benchmark metric (latency/throughput/memory), not a usability verdict
- No full business workflow logic is needed — just the maximum intended data or UI load (virtualized rows,
  bulk API payloads, concurrent WebSocket events) running at once
- Build time stays within the ~4-hour cap; the spike is benchmarking the throughput
  limits, not the whole application
- If the answer is NO at this scope, this is an architecture or scope constraint
  that affects everything downstream — better to surface it now than during Sprint 8

---
