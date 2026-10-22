#!/usr/bin/env python3
"""
spec.py — SaaS-Bench Specification Engine
Autonomous task evaluation contracts, shape preservation gates, and automated grading rubrics.
"""

import os
import yaml
import json

class SaaSBenchTask:
    def __init__(self, task_id, title, domain, description, inputs, expected_deliverables, rubrics):
        self.task_id = task_id
        self.title = title
        self.domain = domain
        self.description = description
        self.inputs = inputs or {}
        self.expected_deliverables = expected_deliverables or []
        self.rubrics = rubrics or []

    @classmethod
    def load_from_yaml(cls, path):
        with open(path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        return cls(
            task_id=data.get("id"),
            title=data.get("title"),
            domain=data.get("domain"),
            description=data.get("description"),
            inputs=data.get("inputs"),
            expected_deliverables=data.get("expected_deliverables"),
            rubrics=data.get("rubrics")
        )

    def validate_spec(self):
        """Validates specification integrity (shape preservation, non-empty criteria)."""
        errors = []
        if not self.task_id:
            errors.append("Missing task ID")
        if not self.domain:
            errors.append("Missing domain")
        if not self.expected_deliverables:
            errors.append("Task must define expected deliverables")
        if not self.rubrics:
            errors.append("Task must define grading rubrics")
        return len(errors) == 0, errors

class BenchmarkSuite:
    def __init__(self, root_dir):
        self.root_dir = root_dir
        self.tasks = []

    def load_all_tasks(self):
        tasks_dir = os.path.join(self.root_dir, "tasks")
        if not os.path.exists(tasks_dir):
            return []
        
        self.tasks = []
        for d in sorted(os.listdir(tasks_dir)):
            task_yaml = os.path.join(tasks_dir, d, "task.yaml")
            if os.path.isfile(task_yaml):
                task = SaaSBenchTask.load_from_yaml(task_yaml)
                self.tasks.append(task)
        return self.tasks
