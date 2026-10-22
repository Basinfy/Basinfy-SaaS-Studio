# /saas-prototype — Phase 6: Usability test Debrief

> Part of `/saas-prototype`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 6: Usability test Debrief

The prototype is built. Now hand it to the user and capture what they actually
experienced. Do NOT skip to report generation — the report is only as good as the
observations you collect here.

**For HTML path:** Say exactly this:
> "The prototype is ready. Open `prototypes/[name]-concept/prototype.html` in your
> browser and test it. Take as long as you need. Don't rush through it — try to
> approach it the way a new user would. Come back here when you're done."

**For Engine path:** The multi-turn iteration loop already captured errors and
behavior. Now ask for the overall assessment:
> "Now that it's running — test through it a few times as if you're the user,
> not the developer. Come back when you have a feel for it."

**For Spec Walkthrough path:** Say exactly this:
> "Read through `prototypes/[name]-concept/spec.md` and walk through the
> `interaction-log.md` as if you're running it for the first time. If you have someone
> nearby, try running the workflow with them. Come back when you've seen at least one
> full workflow cycle."

**If nobody can evaluate it this session**, do not ask for a verdict and do not infer
one from how the build looks: the recommendation is **NOT ASSESSED — built, not
evaluated**. Write the report with that verdict (Phase 7, asking first) and name the
next step — evaluate it, then re-run this debrief.

Once the user returns, ask these questions **one at a time** — wait for each answer
before asking the next:

1. **Hypothesis check:**
   > "The hypothesis was: [restate the hypothesis from Phase 1]. Did it hold up —
   > CONFIRMED, PARTIALLY CONFIRMED, or REFUTED? Tell me what you saw."

2. **Best moment:**
   > "What was the moment — if any — where it felt like it was working? Be specific."

3. **Worst moment:**
   > "What was the most frustrating, confusing, or broken moment? Be specific —
   > not 'it felt slow' but 'the webhook trigger took about half a second to respond and it
   > felt like I was waiting without feedback'."

4. **Surprise:**
   > "Did anything happen that you didn't expect — good or bad?"

5. **Verdict:**
   > "PROCEED, PIVOT, or KILL — and one sentence why."

Collect all answers before moving to report generation. If any answer is vague
("it felt fine", "pretty good"), ask a follow-up: "Can you be more specific?
What exactly felt fine about it?" Precise observations make the report useful.
Vague ones make it useless.

---
