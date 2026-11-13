#!/usr/bin/env python3
"""
sync-agent-skills.py — Substrate Synchronization Script for Basinfy SaaS Studio
Mirrors SaaS skills from .claude/skills/ to .agents/skills/ for OpenAI/Codex/Antigravity parity.
Ensures universal tool-runner discovery across heterogeneous substrates.
"""

import os
import sys
import shutil
import argparse
import re
from pathlib import Path

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CLAUDE_SKILLS_DIR = os.path.join(REPO_ROOT, ".claude", "skills")
AGENTS_SKILLS_DIR = os.path.join(REPO_ROOT, ".agents", "skills")
CODEX_POLICY = Path('agents/openai.yaml')
MANUAL_CODEX_POLICY = b'policy:\n  allow_implicit_invocation: false\n'

PORTABLE_GUIDANCE = """<!-- Generated from .claude/skills by scripts/sync-agent-skills.py. -->

## Running this workflow on this client

Run shell commands from the project root. On Windows, use Git Bash for the `bash` commands if `bash` resolves to an unavailable WSL distribution. Shared studio files are under `.claude/`; run the local Studio installer for this project if those files are missing. Read `.claude/docs/config-resolution.md` and apply its defaults when configuration cannot be resolved. Use this client's tools for reads, edits, and structured questions. If structured questions are unavailable, ask in chat and wait when a decision requires approval. Use the client's delegation feature with the role brief in `.claude/agents/` when available. Otherwise perform the specialist checks in sequence and disclose that they were done in one session. If a workflow requires independent sign-off, report it as pending until an independent reviewer can provide it. Treat `Task*` steps as local workflow tracking using the client's equivalent when available. Report missing tools and unexecuted checks explicitly.
"""


def portable_skill(source):
    text = source.decode("utf-8").replace("\r\n", "\n")
    frontmatter, body = text.split("\n---\n", 1)
    frontmatter = re.sub(r"(?m)^(?:model|allowed-tools|context|agent):[^\n]*\n?", "", frontmatter)
    body = body.replace('"${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh"', '.claude/hooks/yaml-helper.sh')
    body = body.replace('"${CLAUDE_SKILL_DIR}/../../scripts/story-status.sh"', '.claude/scripts/story-status.sh')
    body = re.sub(r"(?m)^!`([^\n]+)`$", r"Run `\1` and use its output below.", body)
    manual = ''
    if manual_only(frontmatter):
        manual = 'Start this workflow only when the user explicitly asks for it. Otherwise, describe what it would do and wait for that request.\n\n'
    return (frontmatter.rstrip() + "\n---\n\n" + PORTABLE_GUIDANCE + "\n" + manual + body.lstrip("\n")).encode("utf-8")


def manual_only(frontmatter):
    return bool(re.search(r'(?m)^disable-model-invocation:[ \t]*true[ \t]*$', frontmatter))


def generated_policy(canonical):
    frontmatter = (canonical / 'SKILL.md').read_text(encoding='utf-8').split('\n---\n', 1)[0]
    if manual_only(frontmatter):
        return MANUAL_CODEX_POLICY
    return None

def get_claude_skills():
    if not os.path.exists(CLAUDE_SKILLS_DIR):
        return []
    return sorted([
        d for d in os.listdir(CLAUDE_SKILLS_DIR)
        if os.path.isdir(os.path.join(CLAUDE_SKILLS_DIR, d)) and d.startswith("saas-")
    ])

def get_agents_skills():
    if not os.path.exists(AGENTS_SKILLS_DIR):
        return []
    return sorted([
        d for d in os.listdir(AGENTS_SKILLS_DIR)
        if os.path.isdir(os.path.join(AGENTS_SKILLS_DIR, d)) and d.startswith("saas-")
    ])

def verify_parity():
    claude_skills = set(get_claude_skills())
    agents_skills = set(get_agents_skills())

    problems = []
    for skill in sorted(claude_skills - agents_skills):
        problems.append(f"Missing skill: {skill}")
    for skill in sorted(agents_skills - claude_skills):
        problems.append(f"Unexpected skill: {skill}")
    for skill in sorted(claude_skills & agents_skills):
        canonical = Path(CLAUDE_SKILLS_DIR, skill)
        mirror = Path(AGENTS_SKILLS_DIR, skill)
        policy = generated_policy(canonical)
        source_files = {p.relative_to(canonical) for p in canonical.rglob('*') if p.is_file()}
        if policy:
            source_files.add(CODEX_POLICY)
        mirrored_files = {p.relative_to(mirror) for p in mirror.rglob('*') if p.is_file()}
        problems.extend(f"Missing file: {skill}/{p.as_posix()}" for p in sorted(source_files - mirrored_files))
        problems.extend(f"Unexpected file: {skill}/{p.as_posix()}" for p in sorted(mirrored_files - source_files))
        for p in sorted(source_files & mirrored_files):
            source = policy if p == CODEX_POLICY and policy else (canonical / p).read_bytes().replace(b'\r\n', b'\n')
            mirrored = (mirror / p).read_bytes().replace(b'\r\n', b'\n')
            expected = portable_skill(source) if p == Path('SKILL.md') else source
            if expected != mirrored:
                problems.append(f"Different content: {skill}/{p.as_posix()}")

    if problems:
        print('\n'.join(f"[FAIL] {problem}" for problem in problems))
        return False

    print(f"[PASS] Portable build matches all {len(claude_skills)} canonical skills")
    return True

def sync_skills():
    os.makedirs(AGENTS_SKILLS_DIR, exist_ok=True)
    claude_skills = get_claude_skills()
    synced = 0

    for skill in claude_skills:
        src = os.path.join(CLAUDE_SKILLS_DIR, skill)
        dst = os.path.join(AGENTS_SKILLS_DIR, skill)

        source = Path(src)
        destination = Path(dst)
        policy = generated_policy(source)
        for file in source.rglob('*'):
            if not file.is_file():
                continue
            relative = file.relative_to(source)
            target = destination / relative
            data = file.read_bytes()
            if relative == Path('SKILL.md'):
                data = portable_skill(data)
            elif relative == CODEX_POLICY and policy:
                continue
            if target.is_file() and target.read_bytes().replace(b'\r\n', b'\n') == data.replace(b'\r\n', b'\n'):
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            if relative == Path('SKILL.md'):
                target.write_bytes(data)
            else:
                shutil.copy2(file, target)
        policy_path = destination / CODEX_POLICY
        if policy:
            policy_path.parent.mkdir(parents=True, exist_ok=True)
            if not policy_path.is_file() or policy_path.read_bytes().replace(b'\r\n', b'\n') != policy:
                policy_path.write_bytes(policy)
        elif not (source / CODEX_POLICY).exists() and policy_path.is_file() and policy_path.read_bytes().replace(b'\r\n', b'\n') == MANUAL_CODEX_POLICY:
            policy_path.unlink()
        synced += 1

    print(f"[OK] Successfully synchronized {synced} skills from .claude/skills/ to .agents/skills/")

def main():
    parser = argparse.ArgumentParser(description="Synchronize SaaS skills between substrates.")
    parser.add_argument("--verify", action="store_true", help="Verify 1:1 parity without writing")
    args = parser.parse_args()

    if args.verify:
        if not verify_parity():
            sys.exit(1)
        sys.exit(0)

    sync_skills()
    if not verify_parity():
        sys.exit(1)

if __name__ == "__main__":
    main()
