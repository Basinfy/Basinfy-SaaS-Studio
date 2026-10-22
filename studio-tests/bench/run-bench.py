#!/usr/bin/env python3
"""
run-bench.py — SaaS-Bench Autonomous Task Benchmark Runner
Evaluates agent performance against standardized SaaS engineering benchmarks.
"""

import os
import sys
import argparse
from spec import BenchmarkSuite

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def main():
    parser = argparse.ArgumentParser(description="Run SaaS-Bench Autonomous Benchmarks")
    parser.add_argument("--verify-specs", action="store_true", help="Verify integrity of all benchmark task contracts")
    parser.add_argument("--suite", default="all", help="Suite to run: all, auth, billing, database")
    args = parser.parse_args()

    suite = BenchmarkSuite(SCRIPT_DIR)
    tasks = suite.load_all_tasks()

    if not tasks:
        print("[FAIL] No benchmark tasks found under studio-tests/bench/tasks/")
        sys.exit(1)

    print("=================================================================")
    print("           SAAS-BENCH: AUTONOMOUS TASK EVALUATION                ")
    print("=================================================================")
    print(f"Loaded {len(tasks)} benchmark tasks across domains: {list(set(t.domain for t in tasks))}")

    if args.verify_specs:
        all_passed = True
        for task in tasks:
            valid, errors = task.validate_spec()
            if valid:
                print(f" [PASS] {task.task_id} ({task.domain}): {task.title}")
            else:
                print(f" [FAIL] {task.task_id}: {errors}")
                all_passed = False
        
        print("=================================================================")
        if all_passed:
            print(" >>> ALL BENCHMARK TASK CONTRACTS VERIFIED SUCCESSFULLY <<< ")
            sys.exit(0)
        else:
            print(" >>> BENCHMARK SPECIFICATION VERIFICATION FAILED <<< ")
            sys.exit(1)

    # Summary table output
    print("\nBenchmark Suite Ready for Model Evaluation Rollouts:")
    print(f"{'TASK ID':<22} | {'DOMAIN':<10} | {'DELIVERABLES':<12} | {'WEIGHTED RUBRICS'}")
    print("-" * 65)
    for task in tasks:
        print(f"{task.task_id:<22} | {task.domain:<10} | {len(task.expected_deliverables):<12} | {len(task.rubrics)} criteria")
    print("=================================================================")

if __name__ == "__main__":
    main()
