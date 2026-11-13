"""Verify native discovery and optionally run read-only client smoke cases."""

import argparse
import json
import os
import queue
import secrets
import shutil
import subprocess
import threading
from pathlib import Path
from tempfile import TemporaryDirectory
from time import monotonic


ROOT = Path(__file__).resolve().parent.parent


def codex_discovery(executable, project, timeout):
    messages = queue.Queue()
    with subprocess.Popen([executable, 'app-server', '--stdio'], cwd=project,
                          stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                          stderr=subprocess.DEVNULL, text=True, encoding='utf-8') as server:
        def read_messages():
            for line in server.stdout:
                try:
                    messages.put(json.loads(line))
                except ValueError:
                    continue
            messages.put(None)

        def request(method, params=None, request_id=None):
            message = {'method': method}
            if params is not None:
                message['params'] = params
            if request_id is not None:
                message['id'] = request_id
            server.stdin.write(json.dumps(message) + '\n')
            server.stdin.flush()

        def response(request_id):
            deadline = monotonic() + timeout
            while (remaining := deadline - monotonic()) > 0:
                try:
                    message = messages.get(timeout=remaining)
                except queue.Empty:
                    break
                if message is None:
                    raise RuntimeError('Codex app-server closed before responding')
                if message.get('id') == request_id:
                    if 'error' in message:
                        raise RuntimeError(message['error'])
                    return message['result']
            raise TimeoutError('Codex app-server discovery timed out')

        threading.Thread(target=read_messages, daemon=True).start()
        try:
            request('initialize', {'clientInfo': {'name': 'studio-smoke', 'version': '1.0.0'}}, 1)
            response(1)
            request('initialized')
            request('skills/list', {'cwds': [str(project)], 'forceReload': True}, 2)
            entry, = response(2)['data']
        finally:
            server.stdin.close()
            try:
                server.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server.kill()

    installed = project / '.agents' / 'skills'
    expected = {file.parent.name for file in installed.glob('*/SKILL.md')}
    discovered = {skill['name'] for skill in entry['skills'] if Path(skill['path']).is_relative_to(project)}
    errors = [error for error in entry['errors'] if Path(error['path']).is_relative_to(project)]
    if errors or expected != discovered:
        raise RuntimeError(f'Native discovery errors: {errors}; missing: {sorted(expected - discovered)}; unexpected: {sorted(discovered - expected)}')
    print(f'[PASS] Codex natively discovered all {len(expected)} workspace skills', flush=True)


def run_model(executable, client, project, timeout, model_name=None):
    brief_marker = secrets.token_hex(6)
    skill_marker = secrets.token_hex(6)
    brief = project / 'design' / 'product-brief.md'
    brief.parent.mkdir()
    brief.write_text(f'# Product brief\n\nFixture verification code: {brief_marker}\n', encoding='utf-8')
    skill_root = '.claude' if client == 'claude' else '.agents'
    skill_file = project / skill_root / 'skills' / 'saas-help' / 'SKILL.md'
    source = skill_file.read_text(encoding='utf-8')
    frontmatter, body = source.split('\n---\n', 1)
    skill_file.write_text(frontmatter + '\n---\n\n'
                          'For the read-only Studio smoke case, include this fixture-only '
                          f'skill verification code in the final answer: {skill_marker}.\n' + body,
                          encoding='utf-8')
    skill = '$saas-help' if client == 'codex' else '/saas-help'
    prompt = (f'{skill} This is the read-only Studio smoke case. Run only the minimal Product Brief and Stories checks. '
              'Use only this fixture workspace. If the shell is unavailable, use native file reads and directory search. '
              'Return the verification codes from the invoked skill and design/product-brief.md. '
              'Include STORIES_ABSENT if no story exists. '
              'Do not edit files or use the network.')
    if client == 'antigravity':
        prompt += (' For file reads, run these individual permitted commands exactly: '
                   '`cat .agents/skills/saas-help/SKILL.md`, `cat design/product-brief.md`, '
                   'and `test -d production/epics`. The last command returns exit 1 when the story directory is absent.')
    options = {
        'codex': ['exec', '--skip-git-repo-check', '--ephemeral', '--sandbox', 'read-only', '--json'],
        'claude': ['--print', '--permission-mode', 'plan', '--output-format', 'json', '--max-turns', '6'],
        'antigravity': ['--mode', 'plan', '--print-timeout', f'{timeout}s', '--output-format', 'stream-json', '--print'],
    }
    if client == 'antigravity':
        settings = {'permissions': {'allow': [
            f'read_file({project.as_posix()})',
            'command(bash .claude/scripts/artifact-check.sh)',
            'command(bash .claude/hooks/yaml-helper.sh resolve_config)',
            'command(cat .agents/skills/saas-help/SKILL.md)',
            'command(cat design/product-brief.md)',
            'command(test -d production/epics)',
        ]}}
        options[client][0:0] = ['--settings', json.dumps(settings)]
    if model_name:
        options[client][0:0] = ['--model', model_name]
    environment = os.environ.copy()
    if client == 'codex':
        # A standalone CLI cannot use the desktop's registered Windows runtime.
        for key in ('CODEX_WINDOWS_REGISTERED_CORE', 'CODEX_APP_RUNTIME_CLI_PATH', 'CODEX_APP_TOOLS_PIPE_PATH'):
            environment.pop(key, None)
    process = subprocess.Popen([executable, *options[client], prompt], cwd=project,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               text=True, encoding='utf-8', errors='replace',
                               stdin=subprocess.DEVNULL, env=environment,
                               creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if os.name == 'nt' else 0)
    try:
        stdout, stderr = process.communicate(timeout=timeout + 15)
    except subprocess.TimeoutExpired as error:
        if os.name == 'nt':
            subprocess.run(['taskkill', '/PID', str(process.pid), '/T', '/F'], capture_output=True, timeout=10)
        else:
            process.kill()
        process.communicate(timeout=10)
        raise RuntimeError(f'Client timed out after {error.timeout} seconds before completing the model case') from error
    result = subprocess.CompletedProcess(process.args, process.returncode, stdout, stderr)
    answer = ''
    execution_errors = []
    command_attempts = []
    for line in result.stdout.splitlines():
        try:
            message = json.loads(line)
        except ValueError:
            continue
        if client == 'codex' and message.get('type') == 'item.completed':
            item = message.get('item', {})
            if item.get('type') == 'agent_message':
                answer = item.get('text', '')
            if item.get('type') == 'command_execution' and item.get('exit_code') != 0:
                execution_errors.append(item.get('aggregated_output', ''))
        elif client == 'codex' and message.get('type') in ('error', 'turn.failed'):
            execution_errors.append(message.get('message') or str(message.get('error', '')))
        elif client != 'codex':
            payload = message.get('message')
            content = payload.get('content', []) if isinstance(payload, dict) else []
            for block in content:
                if isinstance(block, dict) and block.get('type') == 'tool_use' and block.get('name') == 'Bash':
                    command = block.get('input', {}).get('command')
                    if command:
                        command_attempts.append(command)
            answer = message.get('response') or message.get('result') or message.get('error') or answer
            denied = message.get('denied_actions') or message.get('permission_denials')
            if denied:
                execution_errors.append(f'Client denied required tools: {denied}; attempted commands: {command_attempts[-2:]}')
    missing = [label for label, marker in [('workspace skill code', skill_marker), ('brief code', brief_marker),
                                            ('story status', 'STORIES_ABSENT')] if marker not in answer]
    if result.returncode or missing:
        diagnostic = next((error for error in reversed(execution_errors) if error), answer)
        diagnostic = diagnostic or next((line for line in result.stderr.splitlines() if 'error' in line.lower()), '')
        if not isinstance(diagnostic, str):
            diagnostic = json.dumps(diagnostic, ensure_ascii=False)
        raise RuntimeError(f'Model case incomplete (exit {result.returncode}, missing: {", ".join(missing) or "none"}). {diagnostic[:350]}')
    print(f'[PASS] {client} model read the installed skill and brief and reported the missing story', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('client', choices=['codex', 'claude', 'antigravity'])
    parser.add_argument('--executable', help='Override the client CLI path')
    parser.add_argument('--model', action='store_true', help='Run an authenticated model smoke case')
    parser.add_argument('--client-model', help='Select a model supported by the client for the model case')
    parser.add_argument('--timeout', type=int, default=90)
    args = parser.parse_args()
    if args.timeout < 1:
        parser.error('--timeout must be positive')
    if args.client_model and not args.model:
        parser.error('--client-model requires --model')
    executable = args.executable or shutil.which('agy' if args.client == 'antigravity' else args.client)
    if not executable:
        parser.error(f'{args.client} CLI was not found')
    if args.client != 'codex' and not args.model:
        parser.error('Native discovery without a model is currently available for Codex')
    try:
        with TemporaryDirectory(prefix=f'studio-{args.client}-smoke-', ignore_cleanup_errors=True) as directory:
            project = Path(directory).resolve()
            subprocess.run(['node', str(ROOT / 'bin/cli.js'), args.client, '--inject', '--target', str(project)],
                           check=True, stdout=subprocess.DEVNULL)
            if args.client == 'codex':
                codex_discovery(executable, project, args.timeout)
            if args.model:
                run_model(executable, args.client, project, args.timeout, args.client_model)
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        parser.exit(1, f'[FAIL] {args.client}: {error}\n')


if __name__ == '__main__':
    main()
