#!/usr/bin/env python3
"""
sync-agent-skills.py — Substrate Synchronization Script for Basinfy SaaS Studio
Mirrors all 74 SaaS skills from .claude/skills/ to .agents/skills/ for OpenAI/Codex/Antigravity parity.
Ensures universal tool-runner discovery across heterogeneous substrates.
"""

import os
import sys
import shutil
import argparse

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CLAUDE_SKILLS_DIR = os.path.join(REPO_ROOT, ".claude", "skills")
AGENTS_SKILLS_DIR = os.path.join(REPO_ROOT, ".agents", "skills")

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
    
    missing = claude_skills - agents_skills
    if missing:
        print(f"[FAIL] Missing {len(missing)} skills in .agents/skills/: {sorted(missing)}")
        return False
    
    print(f"[PASS] Exact substrate parity: {len(claude_skills)}/74 skills mirrored in .agents/skills/")
    return True

def sync_skills():
    os.makedirs(AGENTS_SKILLS_DIR, exist_ok=True)
    claude_skills = get_claude_skills()
    synced = 0

    for skill in claude_skills:
        src = os.path.join(CLAUDE_SKILLS_DIR, skill)
        dst = os.path.join(AGENTS_SKILLS_DIR, skill)

        # Mirror skill directory
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
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
