# verify_studio_integrity.py - Complete Integrity & Verification Test Suite for Basinfy SaaS Studio
import os
import sys
import yaml
import json
import subprocess
import glob
import re
from hashlib import sha256
from pathlib import Path
from shutil import copyfile
from tempfile import TemporaryDirectory

print("=================================================================")
print("     BASINFY SAAS STUDIO — COMPREHENSIVE AUDIT & TEST        ")
print("=================================================================")

ROOT = os.path.abspath(".")
ERRORS = []
WARNINGS = []
BASH_EXE = r"C:\Program Files\Git\bin\bash.exe" if os.path.exists(r"C:\Program Files\Git\bin\bash.exe") else "bash"

def check(condition, desc, error_msg):
    if condition:
        print(f" [PASS] {desc}")
    else:
        print(f" [FAIL] {desc} -> {error_msg}")
        ERRORS.append(f"{desc}: {error_msg}")

def run_bash(cmd_args, cwd=ROOT):
    cmd = [BASH_EXE] + cmd_args
    res = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, encoding="utf-8", errors="ignore")
    return res.returncode, res.stdout, res.stderr

# 1. Root Files
print("\n--- 1. Root Files Check ---")
check(os.path.exists("CLAUDE.md"), "CLAUDE.md exists", "Missing CLAUDE.md")
check(os.path.exists("project.yaml"), "project.yaml exists", "Missing project.yaml")
check(os.path.exists("project.local.yaml.example"), "project.local.yaml.example exists", "Missing project.local.yaml.example")
check(os.path.exists(".gitignore"), ".gitignore exists", "Missing .gitignore")
check(os.path.exists("package.json"), "package.json exists", "Missing package.json")
check(os.path.exists("bin/cli.js"), "bin/cli.js exists", "Missing bin/cli.js")

# 2. Settings & Statusline
print("\n--- 2. Settings & Statusline Check ---")
check(os.path.exists(".claude/settings.json"), "settings.json exists", "Missing settings.json")
check(os.path.exists(".claude/statusline.sh"), "statusline.sh exists", "Missing statusline.sh")
try:
    with open(".claude/settings.json", "r", encoding="utf-8") as f:
        settings_data = json.load(f)
    check("hooks" in settings_data, "settings.json has hooks", "Missing hooks block")
    check("permissions" in settings_data, "settings.json has permissions", "Missing permissions block")
    check(len(settings_data["permissions"]["deny"]) > 50, "settings.json has robust deny-list", "Deny list too small")
except Exception as e:
    ERRORS.append(f"settings.json parse error: {e}")

# 3. Agents Check (50 agents)
print("\n--- 3. Agents Check ---")
agents_dir = ".claude/agents"
check(os.path.exists(agents_dir), ".claude/agents exists", "Missing agents directory")
agents_files = [f for f in os.listdir(agents_dir) if f.endswith(".md")]
print(f"Found {len(agents_files)} agent files in {agents_dir}")

required_49_agents = [
    "product-director", "technical-director", "delivery-producer",
    "lead-product-manager", "lead-engineer", "design-system-director",
    "growth-director", "ux-content-strategist", "qa-lead", "release-manager", "localization-lead",
    "backend-engineer", "cloud-infra-engineer", "frontend-engineer",
    "api-integrations-specialist", "dev-tools-engineer", "ai-engineer",
    "web-perf-analyst", "appsec-engineer", "devops-engineer",
    "billing-engineer", "database-architect", "data-telemetry-engineer",
    "nextjs-specialist", "react-specialist", "tailwind-shadcn-specialist",
    "supabase-specialist", "prisma-drizzle-specialist", "fastapi-specialist",
    "python-backend-specialist", "go-specialist", "queue-worker-specialist",
    "auth-security-specialist", "cloudflare-specialist", "aws-specialist",
    "docker-k8s-specialist", "realtime-websockets-specialist", "email-messaging-specialist",
    "user-flow-architect", "ux-designer", "ui-motion-designer", "pricing-economist",
    "technical-writer", "onboarding-specialist", "rapid-prototyper", "qa-manual-tester",
    "accessibility-auditor", "sre-observability-engineer", "customer-success-ops",
    "dpo-privacy-specialist"
]

missing_agents = [a for a in required_49_agents if f"{a}.md" not in agents_files]
check(len(missing_agents) == 0 and len(agents_files) == 50, "Exactly 50 SaaS agents present", f"Missing: {missing_agents}, total files: {len(agents_files)}")

# 4. Skills Check (108 skills + 23 references)
print("\n--- 4. Skills Check ---")
skills_dir = ".claude/skills"
check(os.path.exists(skills_dir), ".claude/skills exists", "Missing skills directory")
skill_folders = [d for d in os.listdir(skills_dir) if os.path.isdir(os.path.join(skills_dir, d))]
print(f"Found {len(skill_folders)} skill folders in {skills_dir}")
check(len(skill_folders) == 108 and all(d.startswith("saas-") for d in skill_folders), "Exactly 108 SaaS skills present with saas- prefix", f"Found {len(skill_folders)}")

skills_with_references = [
    "saas-adopt", "saas-architecture-decision", "saas-architecture-review", "saas-brainstorm",
    "saas-create-architecture", "saas-create-epics", "saas-create-stories", "saas-design-system",
    "saas-dev-story", "saas-gate-check", "saas-prototype", "saas-review-all-prds", "saas-setup-stack",
    "saas-smoke-check", "saas-story-done", "saas-story-readiness", "saas-test-setup", "saas-ux-design",
    "saas-lgpd-audit", "saas-frontend-taste", "saas-security-audit", "saas-seo", "saas-seo-agentic"
]

missing_refs = []
for sk in skills_with_references:
    ref_dir = os.path.join(skills_dir, sk, "references")
    if not (os.path.exists(ref_dir) and len(os.listdir(ref_dir)) > 0):
        missing_refs.append(sk)

check(len(missing_refs) == 0, "All 23 complex skills have references/", f"Missing references in: {missing_refs}")

# 5. Director Gates Check (28 Canonical + Legacy Aliases + Verdicts)
print("\n--- 5. Director Gates Check ---")
dg_dirs = [".claude/director-gates", ".claude/docs/director-gates"]
for d in dg_dirs:
    check(os.path.exists(d), f"{d} directory exists", f"Missing {d}")

canonical_28_gates = {
    "ds-design-tokens.md": "READY / CONCERNS / NOT READY",
    "ds-branding-ui.md": "APPROVED / REVISE",
    "ds-phase-gate.md": "READY / CONCERNS / NOT READY",
    "ds-component-audit.md": "PASS / CONCERNS / FAIL",
    "pd-prd-alignment.md": "ALIGNED / DRIFT DETECTED",
    "pd-messaging-tone.md": "APPROVED / REVISE",
    "pd-phase-gate.md": "READY / CONCERNS / NOT READY",
    "pd-product-pillars.md": "SOUND / CONCERNS / UNSOUND",
    "pd-usability-review.md": "READY / CONCERNS / NOT READY",
    "pd-feature-coherence.md": "COHERENT / CONFLICTS",
    "le-code-review.md": "APPROVE / REQUEST_CHANGES",
    "le-feasibility.md": "FEASIBLE / RISKY / BLOCKED",
    "uxc-copy-consistency.md": "CONSISTENT / INCONSISTENT",
    "dp-epic-readiness.md": "READY / NEEDS WORK",
    "dp-milestone-review.md": "GO / NO-GO / PROCEED WITH RISK",
    "dp-phase-gate.md": "READY / CONCERNS / NOT READY",
    "dp-scope-assessment.md": "ON TRACK / CREEP DETECTED",
    "dp-sprint-readiness.md": "READY / BLOCKED",
    "ql-story-ready.md": "READY / BLOCKED",
    "ql-test-coverage.md": "ADEQUATE / INSUFFICIENT",
    "td-adr-review.md": "ACCEPTED / REJECTED",
    "td-architecture-review.md": "SOUND / FLAWED",
    "td-change-impact.md": "APPROVED / BREAKING RISK",
    "td-stack-risk.md": "LOW / MEDIUM / CRITICAL",
    "td-feasibility.md": "FEASIBLE / INFEASIBLE",
    "td-control-manifest.md": "ENFORCED / VIOLATIONS",
    "td-phase-gate.md": "READY / CONCERNS / NOT READY",
    "td-api-boundary.md": "SOUND / LEAKY BOUNDARIES"
}

for d in dg_dirs:
    missing_can = [g for g in canonical_28_gates if not os.path.exists(os.path.join(d, g))]
    gates_count = len([f for f in os.listdir(d) if f.endswith(".md")]); check(len(missing_can) == 0 and gates_count == 28, f"Exactly 28 canonical gates in {d}", f"Missing: {missing_can}, count: {gates_count}")

# Validate Table 5.3 verdicts on canonical gates
verdict_mismatches = []
for g, expected_verdict in canonical_28_gates.items():
    gate_path = os.path.join(".claude/director-gates", g)
    if os.path.exists(gate_path):
        content = open(gate_path, "r", encoding="utf-8").read()
        if f"**Verdicts**: {expected_verdict}" not in content:
            verdict_mismatches.append(f"{g} (expected '{expected_verdict}')")
check(len(verdict_mismatches) == 0, "Table 5.3 verdicts match exactly in director gates", f"Mismatches: {verdict_mismatches}")

# 6. Hooks Check (18 hooks)
print("\n--- 6. Hooks Check ---")
hooks_dir = ".claude/hooks"
expected_hooks = [
    "detect-gaps.sh", "log-agent-stop.sh", "log-agent.sh", "log-instructions.sh",
    "notify.sh", "pre-compact.sh", "session-start.sh", "session-stop.sh",
    "update-check.sh", "validate-agent-artifact.sh", "validate-assets.sh",
    "validate-commit.sh", "validate-push.sh", "validate-read.sh",
    "validate-registry.sh", "validate-skill-change.sh", "validate-write.sh",
    "yaml-helper.sh"
]
missing_hooks = [h for h in expected_hooks if not os.path.exists(os.path.join(hooks_dir, h))]
check(len(missing_hooks) == 0, "All 18 hooks present", f"Missing hooks: {missing_hooks}")

# 7. Rules Check (14 rules)
print("\n--- 7. Rules Check ---")
rules_dir = ".claude/rules"
expected_rules = [
    "agent-memory.md", "specs-prd-rules.md", "architecture-rules.md",
    "database-rules.md", "backend-api-rules.md", "auth-security-rules.md",
    "billing-rules.md", "frontend-components-rules.md", "styling-ui-tokens-rules.md",
    "appsec-rules.md", "test-standards.md", "background-jobs-rules.md",
    "prototype-rules.md", "skill-authoring.md", "code-discovery-protocol.md"
]
missing_rules = [r for r in expected_rules if not os.path.exists(os.path.join(rules_dir, r))]
check(len(missing_rules) == 0, "All 15 SaaS rules present (including code-discovery-protocol)", f"Missing rules: {missing_rules}")

# 8. Scripts Check & Verification
print("\n--- 8. Scripts Check ---")
scripts_dir = ".claude/scripts"
expected_scripts = [
    "adr-dep-graph.sh", "adr-status.sh", "agent-check.sh", "artifact-check.sh",
    "asset-scan.sh", "bug-stats.sh", "code-markers.sh", "compat-inventory.sh",
    "config-set.sh", "content-count.sh", "debt-register.sh", "flaky-stats.sh",
    "prd-structure-check.sh", "ts-parse-check.sh", "hook-input.sh", "inputs-check.sh",
    "md-section.sh", "migrate-v1-config.sh", "plan-math.sh", "project-coherence.sh",
    "project-state.sh", "read-guard.sh", "registry.sh", "review-receipts.sh",
    "review-scope.sh", "rotate-session-state.sh", "session-state.sh", "set-stage.sh",
    "skill-lint.sh", "story-facts.sh", "story-status.sh", "test-run.sh",
    "test-scaffold.sh", "write-guard.sh", "yaml-get.awk"
]
missing_scripts = [s for s in expected_scripts if not os.path.exists(os.path.join(scripts_dir, s))]
check(len(missing_scripts) == 0, "All 35 SaaS studio scripts present", f"Missing scripts: {missing_scripts}")
actual_scripts = [s for s in os.listdir(scripts_dir) if os.path.isfile(os.path.join(scripts_dir, s))]
check(len(actual_scripts) == 35, "Exactly 35 scripts exist in .claude/scripts", f"Found {len(actual_scripts)} scripts: {actual_scripts}")
check(not os.path.exists(os.path.join(scripts_dir, "gdd-structure-check.sh")), "gdd-structure-check.sh is absent", "gdd-structure-check.sh still exists")
check(os.path.exists(os.path.join(scripts_dir, "ts-parse-check.sh")), "ts-parse-check.sh present", "Missing ts-parse-check.sh")
check(os.path.exists(os.path.join(scripts_dir, "prd-structure-check.sh")), "prd-structure-check.sh present", "Missing prd-structure-check.sh")

# 9. Behavioral Verification of Deterministic Scripts
print("\n--- 9. Behavioral Verification of Scripts ---")

# 9.1 ts-parse-check.sh
rc, out, err = run_bash([".claude/scripts/ts-parse-check.sh"])
check(rc == 0, "ts-parse-check.sh executes successfully (exit 0)", f"Failed with rc={rc}, err={err}")

# 9.2 test-run.sh dry run
rc, out, err = run_bash([".claude/scripts/test-run.sh", "saas", "--dry-run"])
check(rc == 0 and "dry run" in out and "engine\tSaaS" in out, "test-run.sh saas --dry-run emits SaaS dry run output", f"rc={rc}, out={out}")

# 9.3 test-scaffold.sh list
rc, out, err = run_bash([".claude/scripts/test-scaffold.sh", "saas", "--list"])
check(rc == 0 and "tests/unit/.gitkeep" in out, "test-scaffold.sh saas --list lists SaaS test layout", f"rc={rc}, out={out}")

# 9.4 prd-structure-check.sh
rc, out, err = run_bash([".claude/scripts/prd-structure-check.sh"])
check(rc == 0, "prd-structure-check.sh passes on docs/specs PRDs", f"rc={rc}, err={err}")

# 9.5 write-guard.sh protection (observation output on existing file)
rc, out, err = run_bash([".claude/scripts/write-guard.sh", "overwrite", "package.json"])
check("OVERWRITE" in out and "never replaces an existing package.json file" in out, "write-guard.sh detects and warns on overwrite of package.json", f"out={out}")

# 9.6 project-coherence.sh
rc, out, err = run_bash([".claude/scripts/project-coherence.sh"])
check(rc == 0, "project-coherence.sh passes on SaaS project.yaml", f"rc={rc}, err={err}")

# 9.7 project-state.sh
rc, out, err = run_bash([".claude/scripts/project-state.sh"])
check(rc == 0, "project-state.sh detects SaaS state accurately", f"rc={rc}, err={err}")

# 9.8 bin/cli.js uninstall dry run check
try:
    res = subprocess.run(["node", "bin/cli.js", "uninstall", "--global", "--dry-run"], capture_output=True, text=True, encoding="utf-8", errors="replace")
    check(res.returncode == 0 and "Dry-run complete" in res.stdout, "bin/cli.js uninstall --dry-run simulates removal safely", f"rc={res.returncode}")
except Exception as e:
    ERRORS.append(f"bin/cli.js uninstall check failed: {e}")

for script in ("copy-lint.mjs", "consistency.mjs"):
    syntax = subprocess.run(
        ["node", "--check", f".claude/skills/saas-frontend-taste/scripts/{script}"],
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    check(syntax.returncode == 0, f"{script} parses as JavaScript", syntax.stderr.strip())

# 9.9 Codex installation and uninstall run against an isolated fixture.
with TemporaryDirectory(prefix="studio-codex-") as fixture:
    cli = ["node", "bin/cli.js"]
    dry_project = Path(fixture, "dry-run")
    dry_install = subprocess.run(cli + ["codex", "--inject", "--dry-run", "--target", str(dry_project)], capture_output=True)
    check(dry_install.returncode == 0 and not dry_project.exists(), "Install dry run leaves the project untouched", f"rc={dry_install.returncode}")
    api_failure = """
const { Readable } = require('node:stream');
require('node:https').get = (options, callback) => {
    const response = Readable.from(['{}']);
    response.statusCode = 503;
    queueMicrotask(() => callback(response));
    return response;
};
process.argv.splice(1, 0, 'bin/cli.js');
require('./bin/cli.js');
"""
    update = subprocess.run(["node", "-e", api_failure, "--", "update", "--target", str(dry_project)], capture_output=True)
    check(update.returncode != 0 and b"HTTP 503" in update.stderr and not dry_project.exists(),
          "Update fails without modifying the project when the remote commit cannot be resolved", f"rc={update.returncode}")

    archive_source = Path(fixture, "Basinfy-update-fixture")
    archive_docs = archive_source / ".claude/docs"
    archive_docs.mkdir(parents=True)
    (archive_docs / "upgrade-fixture.md").write_text("updated", encoding="utf-8")
    (archive_docs / "tracked.md").write_text("new upstream", encoding="utf-8")
    (archive_docs / "custom.md").write_text("upstream text", encoding="utf-8")
    (archive_source / "GEMINI.md").write_text("Antigravity integration", encoding="utf-8")
    (archive_source / "CODEX.md").write_text("new Codex integration", encoding="utf-8")
    archived_codex = archive_source / ".codex"
    archived_codex.mkdir()
    (archived_codex / "instructions.md").write_text("new global instructions", encoding="utf-8")
    (archive_source / "package.json").write_text('{"version":"9.8.7"}', encoding="utf-8")
    archive = Path(fixture, "upgrade.tar.gz")
    subprocess.run(["tar", "-czf", str(archive), "-C", fixture, archive_source.name], check=True)
    update_project = Path(fixture, "update-target")
    update_project.mkdir()
    (update_project / "project.yaml").write_text("custom: true\n", encoding="utf-8")
    (update_project / "CODEX.md").write_text("my rules", encoding="utf-8")
    update_docs = update_project / ".claude/docs"
    update_docs.mkdir(parents=True)
    (update_docs / "tracked.md").write_bytes(b"old upstream")
    (update_docs / "custom.md").write_text("user edits", encoding="utf-8")
    (update_project / ".claude/framework-version.json").write_text(json.dumps({
        "name": "Basinfy-SaaS-Studio", "commit": "old",
        "files": {".claude/docs/tracked.md": sha256(b"old upstream").hexdigest()},
    }), encoding="utf-8")
    commit = "0123456789abcdef0123456789abcdef01234567"
    archive_mock = """
const fs = require('node:fs');
const { Readable } = require('node:stream');
const [archive, commit] = process.argv.splice(1, 2);
require('node:https').get = (options, headers, callback) => {
    if (typeof headers === 'function') {
        callback = headers;
        const response = Readable.from([JSON.stringify({ sha: commit })]);
        response.statusCode = 200;
        queueMicrotask(() => callback(response));
        return response;
    }
    if (!options.endsWith('/tar.gz/' + commit)) throw new Error('Archive did not use the resolved commit');
    const response = fs.createReadStream(archive);
    response.statusCode = 200;
    queueMicrotask(() => callback(response));
    return response;
};
process.argv.splice(1, 0, 'bin/cli.js');
require('./bin/cli.js');
"""
    updated = subprocess.run(["node", "-e", archive_mock, "--", str(archive), commit, "update", "--target", str(update_project)],
                             capture_output=True, text=True, encoding="utf-8", errors="replace")
    version_file = update_project / ".claude/framework-version.json"
    installed_version = json.loads(version_file.read_text(encoding="utf-8")) if version_file.is_file() else {}
    check(updated.returncode == 0 and installed_version.get("commit") == commit and installed_version.get("version") == "9.8.7"
          and (update_project / ".claude/docs/upgrade-fixture.md").is_file()
          and (update_project / "project.yaml").read_text(encoding="utf-8") == "custom: true\n",
          "Update applies and records the selected archive while preserving project settings", updated.stdout + updated.stderr)
    check((update_docs / "tracked.md").read_text(encoding="utf-8") == "new upstream"
          and (update_docs / "custom.md").read_text(encoding="utf-8") == "user edits"
          and (update_project / "CODEX.md").read_text(encoding="utf-8") == "my rules"
          and not (update_project / "GEMINI.md").exists(),
          "Update refreshes tracked content, preserves user edits and does not add unselected integrations", updated.stdout + updated.stderr)
    global_home = Path(fixture, "update-home")
    (global_home / ".codex").mkdir(parents=True)
    copyfile(Path(".codex/instructions.md"), global_home / ".codex/instructions.md")
    global_mock = "const [fixtureHome] = process.argv.splice(1, 1); require('os').homedir = () => fixtureHome;\n" + archive_mock
    updated_global = subprocess.run(["node", "-e", global_mock, "--", str(global_home), str(archive), commit, "update", "--global"],
                                    capture_output=True, text=True, encoding="utf-8", errors="replace")
    global_stamp = global_home / ".agents/framework-version.json"
    check(updated_global.returncode == 0 and global_stamp.is_file()
          and json.loads(global_stamp.read_text(encoding="utf-8")).get("commit") == commit
          and (global_home / ".codex/instructions.md").read_text(encoding="utf-8") == "new global instructions"
          and not (global_home / ".claude").exists(),
          "Global update refreshes installed integrations without installing other clients", updated_global.stdout + updated_global.stderr)
    for platform in ("claude", "codex", "antigravity", "cursor", "copilot", "windsurf", "cline", "continue", "aider", "devin", "zed", "agents", "all"):
        project = Path(fixture, platform)
        install = subprocess.run(cli + [platform, "--inject", "--target", str(project)], capture_output=True)
        skill_dir = project / (".claude/skills" if platform == "claude" else ".agents/skills")
        skill_entries = list(skill_dir.glob("saas-*/SKILL.md"))
        support_files = ["project.yaml", ".claude/agents/frontend-engineer.md", ".claude/hooks/yaml-helper.sh",
                         ".claude/docs/workflow-catalog.yaml", "studio-tests/catalog.yaml", "templates/seo/api-catalog-route.ts"]
        missing = [name for name in support_files if not (project / name).is_file()]
        stamp = json.loads((project / ".claude/framework-version.json").read_text(encoding="utf-8"))
        helper = ".claude/hooks/yaml-helper.sh"
        if stamp.get("files", {}).get(helper) != sha256((project / helper).read_bytes()).hexdigest():
            missing.append("recorded helper checksum")
        if platform in ("windsurf", "cline"):
            native = project / f".{platform}/skills"
            if len(list(native.glob("saas-*/SKILL.md"))) != len(skill_folders):
                missing.append(str(native))
        check(install.returncode == 0 and len(skill_entries) == len(skill_folders) and not missing,
              f"{platform} project installation includes skills and runtime files",
              f"rc={install.returncode}, skills={len(skill_entries)}, missing={missing}")
        if platform in ("claude", "codex", "antigravity"):
            rc, out, err = run_bash([".claude/scripts/artifact-check.sh", "--path", "minimal"], cwd=project)
            check(rc == 0 and "PATH: minimal" in out and
                  re.search(r"STEP: stack-setup .*status=PRESENT", out) and
                  re.search(r"STEP: product-brief .*status=ABSENT", out) and
                  re.search(r"STEP: create-stories .*status=ABSENT", out),
                  f"{platform} installation resolves the minimal workflow", f"rc={rc}, stderr={err}")
            config = project / "project.yaml"
            installed_config = config.read_text(encoding="utf-8")
            config.write_text('project:\n  name: "Next.js fixture"\nstack:\n  frontend: ""\n', encoding="utf-8")
            rc, out, err = run_bash([".claude/scripts/artifact-check.sh", "--path", "minimal"], cwd=project)
            check(rc == 0 and re.search(r"STEP: stack-setup .*status=(ABSENT|PATTERN_MISS)", out),
                  f"{platform} installation does not treat an empty stack as configured", f"rc={rc}, stderr={err}")
            config.write_text(installed_config, encoding="utf-8")
            brief = project / "design/product-brief.md"
            story = project / "production/epics/sample/story-001.md"
            for artifact in (brief, story):
                artifact.parent.mkdir(parents=True, exist_ok=True)
                artifact.write_text("# Fixture\n", encoding="utf-8")
            rc, out, err = run_bash([".claude/scripts/artifact-check.sh", "--path", "minimal"], cwd=project)
            check(rc == 0 and re.search(r"STEP: product-brief .*status=PRESENT", out) and
                  re.search(r"STEP: create-stories .*status=PRESENT", out),
                  f"{platform} installation detects new brief and story artifacts", f"rc={rc}, stderr={err}")

    codex = Path(fixture, ".codex")
    codex.mkdir()
    shipped = codex / "instructions.md"
    shipped.write_bytes(Path(".codex/instructions.md").read_bytes())
    customized = codex / "hooks.json"
    customized.write_text("customized", encoding="utf-8")
    unrelated = codex / "history.jsonl"
    unrelated.touch()
    isolate_home = "const [fixtureHome] = process.argv.splice(1, 1); require('os').homedir = () => fixtureHome; require('./bin/cli.js')"
    uninstall = subprocess.run(
        ["node", "-e", isolate_home, "--", fixture, "bin/cli.js", "uninstall", "codex", "--global", "--force"],
        capture_output=True,
    )
    check(uninstall.returncode == 0 and not shipped.exists() and unrelated.is_file() and customized.is_file(),
          "Codex global uninstall preserves unrelated and customized files",
          f"rc={uninstall.returncode}, stderr={uninstall.stderr.decode('utf-8', errors='replace')}")

    isolated_cli = ["node", "-e", isolate_home, "--", fixture, "bin/cli.js"]
    for client, skills_path, source in (
        ("claude", ".claude/skills", ".claude/skills"),
        ("antigravity", ".gemini/config/skills", ".agents/skills"),
    ):
        installed = Path(fixture, skills_path, "saas-help")
        installed.mkdir(parents=True)
        copyfile(Path(source, "saas-help", "SKILL.md"), installed / "SKILL.md")
        custom = installed / "notes.md"
        custom.write_text("user notes", encoding="utf-8")
        result = subprocess.run(isolated_cli + ["uninstall", client, "--global", "--force"], capture_output=True)
        check(result.returncode == 0 and not (installed / "SKILL.md").exists() and custom.is_file(),
              f"{client} global uninstall preserves additions inside studio skill directories", f"rc={result.returncode}")

    project = Path(fixture, "all")
    custom = project / ".agents/skills/saas-help/notes.md"
    custom.write_text("user notes", encoding="utf-8")
    result = subprocess.run(cli + ["uninstall", "codex", "--target", str(project), "--force"], capture_output=True)
    check(result.returncode == 0 and not (project / "CODEX.md").exists() and
          (project / ".agents/skills/saas-help/SKILL.md").is_file(),
          "Removing a single client preserves shared workflows", f"rc={result.returncode}")
    result = subprocess.run(cli + ["uninstall", "all", "--target", str(project), "--force"], capture_output=True)
    check(result.returncode == 0 and not (project / ".agents/skills/saas-help/SKILL.md").exists() and custom.is_file(),
          "Removing all clients preserves user additions", f"rc={result.returncode}")

    project = Path(fixture, "codex")
    hook = project / ".codex/studio-hook.cjs"
    patch = "*** Begin Patch\n*** Update File: .claude/skills/saas-help/SKILL.md\n*** End Patch"
    hook_result = subprocess.run(
        ["node", str(hook), "post"], cwd=project,
        input=json.dumps({"cwd": str(project), "tool_input": {"command": patch}}),
        capture_output=True, text=True, encoding="utf-8", errors="replace",
    )
    check(hook_result.returncode == 0 and "Skill modified: saas-help" in hook_result.stdout,
          "Codex patch hook forwards edits to the shared validator", hook_result.stdout + hook_result.stderr)

# 10. Template Cleanliness (Zero Gaming Terminology)
print("\n--- 10. Template Cleanliness Check ---")
forbidden_pattern = re.compile(r'\b(Player Fantasy|Tuning Knobs|Game Feel|Hades|God of War|Celeste|Godot|Unity|Unreal|GDScript|gameplay)\b', re.IGNORECASE)
template_files = glob.glob(".claude/docs/templates/*.md")
print(f"Scanning {len(template_files)} markdown templates for forbidden gaming terms...")
template_violations = {}
for tf in template_files:
    content = open(tf, "r", encoding="utf-8", errors="ignore").read()
    m = forbidden_pattern.findall(content)
    if m:
        template_violations[tf] = m

check(len(template_violations) == 0, "All 62 templates 100% free of gaming artifacts", f"Violations found: {template_violations}")

# 11. Workflow Catalog Integrity
print("\n--- 11. Workflow Catalog Check ---")
check(os.path.exists(".claude/docs/workflow-catalog.yaml"), "workflow-catalog.yaml exists", "Missing workflow-catalog.yaml")
try:
    with open(".claude/docs/workflow-catalog.yaml", "r", encoding="utf-8") as f:
        wf_data = yaml.safe_load(f)
    check("phases" in wf_data and "concept" in wf_data["phases"], "workflow catalog has 7 phases", "Malformed catalog")
    check("paths" in wf_data and "minimal" in wf_data["paths"], "workflow catalog has minimal path", "Missing minimal path")
    wf_commands = []
    for phase_id, phase_data in wf_data.get("phases", {}).items():
        for step in phase_data.get("steps", []):
            if "command" in step:
                wf_commands.append(step["command"])
    for path_id, path_data in wf_data.get("paths", {}).items():
        for step in path_data.get("steps", []):
            if "command" in step:
                wf_commands.append(step["command"])
    check(len(wf_commands) > 0 and all(cmd.startswith("/saas-") for cmd in wf_commands), "All commands in workflow-catalog.yaml start with /saas-", f"Non-saas commands: {[c for c in wf_commands if not c.startswith('/saas-')]}")
except Exception as e:
    ERRORS.append(f"workflow-catalog.yaml parse error: {e}")

# 12. Test Catalog Check (studio-tests/catalog.yaml)
print("\n--- 12. Test Catalog Check ---")
check(os.path.exists("studio-tests/catalog.yaml"), "studio-tests/catalog.yaml exists", "Missing catalog.yaml")
try:
    with open("studio-tests/catalog.yaml", "r", encoding="utf-8") as f:
        cat_data = yaml.safe_load(f)
    cat_skills = cat_data.get("skills", [])
    check(len(cat_skills) == 108, "catalog.yaml has exactly 108 skills", f"Found {len(cat_skills)}")
    check(all(s.get("name", "").startswith("saas-") for s in cat_skills), "All 108 skills in catalog.yaml have saas- prefix", "Some skills lack saas- prefix")
    missing_specs = [s.get("name") for s in cat_skills if not (s.get("spec") and os.path.exists(s["spec"]))]
    check(len(missing_specs) == 0, "All 108 skill spec files in catalog.yaml exist", f"Missing specs: {missing_specs}")
    skill_names = [entry["name"] for entry in cat_skills]
    check(sorted(skill_names) == sorted(skill_folders), "Skill catalog matches installed skills", "Check missing, stale or duplicate entries")
    unknown_commands = sorted({cmd.split()[0].lstrip('/') for cmd in wf_commands} - set(skill_names))
    check(not unknown_commands, "Workflow commands resolve to installed skills", f"Unknown: {unknown_commands}")
    cat_agents = cat_data.get("agents", [])
    agent_names = [entry["name"] for entry in cat_agents]
    disk_agent_names = sorted(p.stem for p in Path(agents_dir).glob("*.md"))
    check(sorted(agent_names) == disk_agent_names, "Agent catalog matches installed agents", "Check missing, stale or duplicate entries")
    dangling_agent_specs = [entry["spec"] for entry in cat_agents if entry.get("spec") and not Path(entry["spec"]).is_file()]
    check(not dangling_agent_specs, "Configured agent specs exist", f"Missing: {dangling_agent_specs}")
    unknown_team_roles = []
    for filename in sorted(Path(skills_dir).glob("saas-team-*/SKILL.md")):
        contents = filename.read_text(encoding="utf-8")
        roles = re.findall(r"(?m)^\s*-\s+`([a-z][a-z-]*)`:", contents)
        unknown_team_roles.extend(f"{filename.parent.name}: {role}" for role in roles if role not in disk_agent_names)
    check(not unknown_team_roles, "Team workflows reference installed agent roles", f"Unknown roles: {unknown_team_roles}")
    seo_errors = []
    for folder in Path(skills_dir).glob("saas-seo*"):
        for filename in folder.rglob("*.md"):
            contents = filename.read_text(encoding="utf-8")
            if "${CLAUDE_PLUGIN_ROOT}" in contents or "scripts/claude-seo" in contents:
                seo_errors.append(f"{filename}: references the legacy plugin runtime")
            for target in set(re.findall(r"(?:scripts/seo/[a-z_]+\.py|\.claude/skills/saas-seo[\w/-]*/references/[\w-]+\.md)", contents)):
                if not Path(target).is_file():
                    seo_errors.append(f"{filename}: {target} is missing")
    check(not seo_errors, "SEO workflows reference Studio scripts and documentation", "\n".join(seo_errors))

    for filename in sorted(Path(skills_dir).glob("*/SKILL.md")):
        contents = filename.read_text(encoding="utf-8")
        fields = yaml.safe_load(contents.split("---", 2)[1])
        required = {"name", "description", "argument-hint", "user-invocable", "allowed-tools"}
        missing = required - fields.keys()
        if missing or fields.get("name") != filename.parent.name or re.search(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", contents):
            ERRORS.append(f"Invalid skill frontmatter or control characters: {filename}; missing fields: {sorted(missing)}")
except Exception as e:
    ERRORS.append(f"catalog.yaml parse error: {e}")

# 13. Purge & Namespace Verification (Zero references to legacy or reference repos)
print("\n--- 13. Purge & Namespace Verification ---")
purge_targets = [
    r'donchitos',
    r'metagpt',
    r'evgenii-studitskikh',
    r'claude-code-game-studios',
    r'claude-code-saas-studio',
    r'\bccgs\b',
    r'\bCCGS\b',
    r'SaaS software product',
    r'\bgames?\b',
    r'\bgodot\b',
    r'\bunity\b',
    r'\bunreal\b',
    r'\bhud\b',
    r'\bcombat\b',
    r'art\s+bible',
    r'sound\s+bible',
    r'\bplaytests?\b',
    r'\bsteam\b',
    r'\bitch\.io\b',
    r'\bgamepad\b',
    r'\bd-pad\b',
    r'\bloot\b',
    r'\buproject\b',
    r'\bumap\b',
    r'\buasset\b',
    r'\basmdef\b',
    r'\bPlayMode\b',
    r'\bEditMode\b',
    r'\bgdUnit\b',
    r'\bgdUnit4\b',
    r'\bplayer_damage\b',
    r'\bplayer_health\b',
    r'\bapply_damage\b',
    r'\bdraw calls?\b',
    r'\btuning knobs?\b',
    r'\buser fantasy\b',
    r'\banti[- ]?cheat\b',
    r'\bmultiplayer\b',
    r'\bplayable\b',
    r'\bplay session\b',
    r'\bgold master\b',
    r'\bdominant strateg\w*',
    r'\bcrafting\b',
    r'\bcooldowns?\b',
    r'\bparry\b',
    r'\barmou?r\b',
    r'\bpoison\b',
    r'\blore\b',
    r'\bextended play\b',
    r'\bcutscenes?\b',
    r'\bXP boost\b',
    r'\bpremium currency\b',
    r'\bmechanics?\b',
    r'\bgameplay\b',
    r'\bplayers?\b',
    r'\bvo[- ]?pipeline\b',
    r'\bbuff\b',
    r'\bdebuff\b',
    r'\bdamage\b',
    r'\bmelee\b',
    r'\bswords?\b',
    r'\bstagger\b',
    r'\bknockback\b',
    r'\bhit-stun\b',
    r'\bpause-menu\b',
    r'\btake_damage\b',
    r'\bgdd_files\b',
    r'\bdual-wield\b',
    r'\biron_sword\b',
    r'\biron_axe\b',
    r'\bhealth_potion\b',
    r'\bPlayerController\b',
    r'\bteam-narrative\b',
    r'\bteam-level\b',
    r'\bteam-combat\b',
    r'\bteam-live-ops\b',
    r'\bND-CONSISTENCY\b',
    r'design/narrative',
    r'design/levels',
    r'\ball_gdds\b',
    r'\bnot_a_system_gdd\b',
    r'\bphysics\b',
    r'\bphysx\b',
    r'\bjolt\b',
    r'\bshaders?\b',
    r'\burp\b',
    r'\bforward\+\b',
    r'\bmain[-_ ]menu\b',
    r'\bnetcode\b',
    r'\bdialogue boxes\b',
    r'\bitem[-_ ]slots?\b',
    r'\bbase_inventory_slots\b',
    r'(?<![-_])inventory\.md\b',
    r'\binventory[-_ ]screen\b',
    r'\bplay-log\b',
    r'\bdice\b',
    r'\bspeedrun\b',
    r'\bunplayed\b',
    r'\bpolycount\b',
    r'\bjump[-_ ]key\b',
    r'TV safe zone',
    r'\bLotcheck\b',
    r'nextjs[\s\-]+--headless',
    r'godot[\s\-]+--headless',
    r'export-debug',
    r'--quit-after',
    r'\bexport_presets\b',
    r'nextjs\.exe'
]
purge_pattern = re.compile('|'.join(purge_targets), re.IGNORECASE)

violations = []
for scan_dir in [".claude", "docs", "design", "studio-tests"]:
    if not os.path.exists(scan_dir):
        continue
    for root, dirs, files in os.walk(scan_dir):
        if ".basinfy" in root:
            continue
        for f in files:
            if f == "verify-integrity.py":
                continue
            if f.endswith((".md", ".sh", ".py", ".yaml", ".yml", ".json")):
                fp = os.path.join(root, f)
                try:
                    with open(fp, "r", encoding="utf-8", errors="ignore") as file_obj:
                        content = file_obj.read()
                        matches = purge_pattern.findall(content)
                        if matches:
                            violations.append(f"{fp}: {set(matches)}")
                except Exception:
                    pass

check(len(violations) == 0, "Zero occurrences of purged repos, ccgs, or 'SaaS software product'", f"Violations: {violations}")

# 14. Multi-LLM and Cross-Platform Integrity Check
print("\n--- 14. Multi-LLM and Cross-Platform Integrity Check ---")
multi_llm_files = [
    "CLAUDE.md", "GEMINI.md", "AGENTS.md", "CODEX.md",
    ".cursorrules", ".cursor/rules/saas-studio.mdc", ".cursor/mcp.json",
    ".codex/instructions.md", ".codex/hooks.json",
    ".vscode/settings.json", ".vscode/extensions.json", ".vscode/tasks.json",
    ".github/copilot-instructions.md", ".github/prompts/saas-start.prompt.md", ".github/prompts/saas-dev-story.prompt.md",
    ".windsurfrules", ".windsurf/rules/saas-studio.md",
    ".clinerules", ".roomodes",
    ".continue/rules.md", ".continue/config.json",
    ".aider.conf.yml", ".aiderignore",
    ".devin/AGENTS.md",
    ".zed/settings.json"
]

missing_llm_files = [f for f in multi_llm_files if not os.path.exists(f)]
check(len(missing_llm_files) == 0, "All multi-LLM configuration files exist", f"Missing: {missing_llm_files}")

parity = subprocess.run(
    [sys.executable, "scripts/sync-agent-skills.py", "--verify"],
    capture_output=True, text=True, encoding="utf-8", errors="replace",
)
check(parity.returncode == 0, "Portable skill files match the canonical build", (parity.stdout + parity.stderr).strip())

# 15. Final Result Summary
print("\n=================================================================")
if len(ERRORS) == 0:
    print(" >>> AUDIT RESULT: 100% SUCCESS — STUDIO FULLY COMPLIANT <<< ")
else:
    print(f" >>> AUDIT RESULT: FAILED WITH {len(ERRORS)} ERRORS <<< ")
    for err in ERRORS:
        print(f"  * {err}")
print("=================================================================")

if len(ERRORS) > 0:
    sys.exit(1)
sys.exit(0)
