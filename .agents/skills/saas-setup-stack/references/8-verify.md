# /saas-setup-stack — Sections 8 and 8.5: Verify and Read Back

> Part of `/saas-setup-stack`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 8. Verify the CLAUDE.md Import

**This import was already written in Section 4 — do not edit it again and do not
ask again.** Section 4 sets it as part of the same CLAUDE.md write, anchored to
the `ENGINE-REFERENCE-IMPORT` marker. This step only confirms the result.

Read `CLAUDE.md` and confirm the line under the marker reads:

```markdown
@docs/engine-reference/<engine>/VERSION.md
```

with `<engine>` the engine just configured. If it still points at a different
engine, Section 4 did not complete — go back and finish it rather than patching
the line here.

> **Why this is a check and not a second write.** Repeating the edit here with
> its own approval prompt would ask the user twice for one change, and the second
> ask would be for work already done. Locate the line by its marker, never by the
> `## Engine Version Reference` heading — the marker exists precisely so the line
> can still be found when the heading moves or is reworded.

---

## 8.5 Read Back What You Just Wrote

Verify the configuration files after writing them:

```bash
bash .claude/scripts/project-coherence.sh
```

It compares `project.yaml` against `docs/engine-reference/<engine>/VERSION.md`,
against `package.json` / `pyproject.toml`, and checks that the commands defined
in `commands.build` and `commands.test` match project scripts.

**Report every `[DIFFERS]` line to the user and resolve it before finishing.**
Each one means two files this skill just wrote disagree, or describe something
that is not there.

One is expected on a new Next.js project: `commands.test` names the test
runner (e.g. `vitest run` or `npm test`), which `/saas-test-setup` installs and configures later. Report that
line as expected, name `/saas-test-setup` as the step that clears it, and never edit
`commands.test` to make it go away. Every other `[DIFFERS]` line is resolved here.

**`[NOT CHECKED]` is not a pass.** Each such line names why a comparison could
not be made -- an absent binary, a missing `project.nextjs`. Say which ones
applied. A comparison that could not run has not established agreement.

The script emits observations and never a verdict, per the convention in
CLAUDE.md. The judgement is yours and the user's.

---
