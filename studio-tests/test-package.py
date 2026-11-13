"""Exercise the files shipped to users through the npm tarball."""

import os
import shutil
import subprocess
import tarfile
from pathlib import Path
from tempfile import TemporaryDirectory


ROOT = Path(__file__).resolve().parent.parent


def main():
    npm = shutil.which('npm.cmd' if os.name == 'nt' else 'npm')
    if not npm:
        raise RuntimeError('npm executable not found')
    with TemporaryDirectory(prefix='studio-package-') as directory:
        temporary = Path(directory)
        subprocess.run([npm, 'pack', '--pack-destination', directory, '--quiet'], cwd=ROOT, check=True)
        archive, = temporary.glob('*.tgz')
        with tarfile.open(archive) as package:
            package.extractall(temporary, filter='data')
        cli = temporary / 'package' / 'bin' / 'cli.js'
        project = temporary / 'installed'
        subprocess.run(['node', str(cli), 'all', '--inject', '--target', str(project)], check=True)
        expected = {file.parent.name for file in (ROOT / '.claude/skills').glob('saas-*/SKILL.md')}
        for skill_root in ('.claude/skills', '.agents/skills', '.cline/skills', '.windsurf/skills'):
            actual = {file.parent.name for file in (project / skill_root).glob('saas-*/SKILL.md')}
            if actual != expected:
                raise RuntimeError(f'{skill_root}: missing {sorted(expected - actual)}; unexpected {sorted(actual - expected)}')
        manual_skills = {
            file.parent.name for file in (ROOT / '.claude/skills').glob('saas-*/SKILL.md')
            if 'disable-model-invocation: true' in file.read_text(encoding='utf-8').split('\n---\n', 1)[0]
        }
        for name in manual_skills:
            skill = project / '.agents' / 'skills' / name
            if 'disable-model-invocation: true' not in (skill / 'SKILL.md').read_text(encoding='utf-8'):
                raise RuntimeError(f'{name} lost its manual invocation frontmatter')
            if 'allow_implicit_invocation: false' not in (skill / 'agents/openai.yaml').read_text(encoding='utf-8'):
                raise RuntimeError(f'{name} lost its Codex invocation policy')
        for resource in ('project.yaml', '.claude/hooks/yaml-helper.sh', '.claude/docs/workflow-catalog.yaml',
                         '.codex/studio-hook.cjs', 'studio-tests/catalog.yaml', 'templates/seo/api-catalog-route.ts'):
            if not (project / resource).is_file():
                raise RuntimeError(f'Installed package missing {resource}')
        if (project / '.github/workflows/studio-integrity.yml').exists():
            raise RuntimeError('Studio CI workflow was copied into the consumer project')
        print(f'[PASS] npm tarball installs {len(expected)} workflows and their shared resources')


if __name__ == '__main__':
    main()
