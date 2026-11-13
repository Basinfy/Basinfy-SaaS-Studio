"""Regression checks for client output parsing and smoke evidence."""

import importlib.util
import io
import json
import re
import unittest
from pathlib import Path
from contextlib import redirect_stdout
from tempfile import TemporaryDirectory
from unittest.mock import Mock, patch


spec = importlib.util.spec_from_file_location('client_smoke', Path(__file__).with_name('client-smoke.py'))
smoke = importlib.util.module_from_spec(spec)
spec.loader.exec_module(smoke)


class ModelEvidenceTests(unittest.TestCase):
    def execute(self, response):
        with TemporaryDirectory() as directory:
            project = Path(directory)
            skill = project / '.agents/skills/saas-help/SKILL.md'
            skill.parent.mkdir(parents=True)
            skill.write_text('---\nname: saas-help\ndescription: Find next steps\n---\nRead the project brief.\n', encoding='utf-8')

            def client(*args, **kwargs):
                result = Mock()
                result.args = args[0]
                result.returncode = 0
                result.communicate.return_value = (json.dumps(response(project, skill)) + '\n', '')
                return result

            with patch.object(smoke.subprocess, 'Popen', side_effect=client), redirect_stdout(io.StringIO()):
                smoke.run_model('agy', 'antigravity', project, 10, 'example-medium')

    def test_brief_read_alone_does_not_prove_skill_loading(self):
        def brief_only(project, skill):
            code = re.search(r'code: ([0-9a-f]+)', (project / 'design/product-brief.md').read_text(encoding='utf-8'))[1]
            return {'response': f'{code} STORIES_ABSENT'}

        with self.assertRaisesRegex(RuntimeError, 'workspace skill code'):
            self.execute(brief_only)

    def test_structured_provider_error_is_reported(self):
        with self.assertRaisesRegex(RuntimeError, 'UNAVAILABLE'):
            self.execute(lambda project, skill: {'error': {'code': 'UNAVAILABLE', 'message': 'Provider has no capacity'}})

    def test_both_reads_and_story_status_pass(self):
        def verified(project, skill):
            source = skill.read_text(encoding='utf-8')
            skill_code = re.search(r'final answer: ([0-9a-f]+)', source)[1]
            brief_code = re.search(r'code: ([0-9a-f]+)', (project / 'design/product-brief.md').read_text(encoding='utf-8'))[1]
            return {'response': f'{skill_code} {brief_code} STORIES_ABSENT'}

        self.execute(verified)


if __name__ == '__main__':
    unittest.main()
