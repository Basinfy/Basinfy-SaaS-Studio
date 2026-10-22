# /saas-setup-stack — Section 3: Look Up Current Version

> Part of `/saas-setup-stack`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 3. Look Up Current Version

Once the engine is chosen:

- If version was provided, use it
- If no version provided, use WebSearch to find the latest stable release:
  - Search: `"[engine] latest stable version [current year]"`
  - Confirm with the user: "The latest stable [engine] is [version]. Use this?"

### Check the chosen version against what is actually installed

A version found by web search is what exists, not what the developer has. Pinning
one they cannot run means every later instruction — build, test, smoke, the
stack reference docs — targets an engine that is not on the machine.

Probe for the binary (Bash), and treat failure as unknown, never as absent:

| Framework / Tool | Probe |
|---|---|
| Next.js / Node | `node -v` and `npx next --version` (or inspection in package.json) |
| FastAPI / Python | `python --version` and `python -c "import fastapi; print(fastapi.__version__)"` |
| Cloudflare / Wrangler | `npx wrangler --version` |
| Supabase CLI | `npx supabase --version` |

Keep the executable the probe found (for Next.js, whether bare `nextjs --version`
ran — that is, `nextjs` is on `PATH`): Section 5.5.1 writes it into `commands.*`
and `engine.path`.

Then:
- **Match** — say so in one line and continue.
- **Mismatch** — state both versions and ask, offering three options: pin the
  installed version, pin the newer one and upgrade later, or pin the newer one
  deliberately. Record the answer; do not pick silently.
- **Not found / probe failed** — report `installed version NOT DETERMINED` and
  continue with the chosen version. Do **not** report this as "no engine
  installed": a probe that could not run has not established absence.

Whatever the outcome, write it into Section 7's `VERSION.md` as an
`Installed at pin time` row, so a later reader can tell a deliberate
version-ahead pin from an accident.

---
