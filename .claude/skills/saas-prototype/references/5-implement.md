# /saas-prototype — Phase 5: Implement

> Part of `/saas-prototype`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Implement

Ask: "May I create the prototype directory at `prototypes/[concept-name]-concept/`
and begin implementation?"

If yes, create the directory. Every file must begin with:

```
[comment] PROTOTYPE - NOT FOR PRODUCTION
[comment] Question: [Core question being tested]
[comment] Date: [Current date]
```

Write `[comment]` in each file's own comment syntax — `#` in TypeScript (`.ts`) and
Python, `//` in C#, C++ and JavaScript, `--` in Lua, `<!-- … -->` in HTML and
Markdown. A header in another language's syntax is a parse error, not a label.
Files that cannot hold a comment (JSON, engine-generated scene and project
files) are exempt.

Standards are intentionally relaxed:

- Hardcode values freely
- Use placeholder assets (colored rectangles, debug shapes)
- Skip error handling entirely
- Use the simplest approach that works
- Copy code rather than importing from production
- No architecture, no patterns, no abstractions

**Do not add polish.** No menus, no product over screens, no music, no tutorial text
unless onboarding IS the workflow being tested. Every addition beyond the
hypothesis is waste.

**Usability testing tip:** If you have access to anyone who hasn't seen the application —
friends, family, strangers online — watching them navigate without explanation gives
far better signal than testing it yourself. Watch silently; don't guide them.
Confusion is data. Ask one question after: "What was confusing?" Not "Did you
like it?"

**No external testers available?** Use rotation: if you built system A, you're a
naive tester for system B. In a two-person team this works well. Solo developer?
Step away for 2-3 days before evaluating fresh — you won't have perfect first-impression
signal, but you'll surface the worst blockers. Another option: walk through your own
prototype as a rapid friction test (force yourself through the workflow in 5 minutes without stopping
to fix things) — the friction you feel is what end-users will hit.

**Want more granular UX data?** Ask the tester to **think aloud** as they interact —
narrate their thoughts in real time: "I'm clicking the invite button... nothing happened... is
it waiting for email confirmation?" This surfaces confusion the moment it happens rather than
waiting for a post-session debrief. Best for UI/UX and onboarding clarity. Silent
observation is still better for testing workflow friction; think-aloud changes how people
interact slightly but gives much richer data about why they're confused.

**HTML prototype?** Product Hunt, Hacker News (Show HN), Reddit (r/SaaS, r/SideProject), and Twitter/X
let you reach strangers today at zero cost — see the distribution options in the
HTML path section above.

**Testing AI, background worker, or complex system behavior before writing the code?** Use the
**Wizard of Oz** technique: one person acts as the end-user while a second person secretly
simulates the worker, service, or API response in real time — making the decisions a
human would make, not an algorithm. The user believes it's automated. This lets
you validate whether your service design *feels right* before writing a single line of
integration or decision tree code. When you observe what responses the human
operator naturally produces, you learn exactly what the automated service needs to do.

### Engine path: multi-turn loop

After writing the initial code:

> "The prototype files are written. Run the project in your engine now.
> If there are errors, paste them here and I'll fix them. If it runs,
> describe what you see and whether it feels like it's answering the question."

Iterate until the prototype is functional end-to-end. Each loop:
1. User runs → reports errors or observations
2. Agent fixes errors or adjusts the workflow logic
3. Repeat until functional or sunk cost rule triggers

### HTML path: single output

Write a single `prototype.html` to `prototypes/[concept-name]-concept/`. Include
all styles, logic, and assets inline. The file must be openable by double-clicking
with no server required.

### Spec Walkthrough path: document + log

Write `prototypes/[concept-name]-concept/spec.md` (the product workflow rules) and
`prototypes/[concept-name]-concept/interaction-log.md` (a simulated session walking
through one complete user workflow step by step with inputs, state changes, decisions, and
outcomes narrated).

---
