const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const mode = process.argv[2];
const event = JSON.parse(fs.readFileSync(0, 'utf8'));
const root = path.resolve(__dirname, '..');

let studioCore = null;
try {
  studioCore = require(path.join(root, '.claude', 'runtime', 'studio-core.cjs'));
} catch (_) {}

const gitBash = process.platform === 'win32' && [process.env.ProgramFiles, process.env['ProgramFiles(x86)']]
  .filter(Boolean)
  .map(dir => path.join(dir, 'Git', 'bin', 'bash.exe'))
  .find(candidate => fs.existsSync(candidate));

function invokeShellHook(script, input) {
  const result = spawnSync(gitBash || 'bash', [`.claude/hooks/${script}.sh`], {
    cwd: root,
    encoding: 'utf8',
    input: JSON.stringify(input),
    timeout: 2000,
  });
  return result.error ? `[Studio] ${script}: ${result.error.message}` : [result.stdout, result.stderr].filter(Boolean).join('\n').trim();
}

const notes = [];
if (mode === 'shell') {
  const response = event.tool_response ?? event.tool_output;
  if (response) {
    notes.push(studioCore ? studioCore.classifyError(response) : invokeShellHook('classify-error', response));
  }
} else {
  const patch = event.tool_input?.command;
  if (typeof patch === 'string') {
    const entries = patch.split(/\r?\n/).filter(line => /^\*\*\* (Add File|Update File|Delete File|Move to): /.test(line));
    for (const line of entries) {
      const filename = path.resolve(event.cwd || root, line.slice(line.indexOf(': ') + 2));
      const relative = path.relative(root, filename);
      if (!relative || relative === '..' || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) continue;
      const relSlash = relative.split(path.sep).join('/');
      const tool = line.startsWith('*** Add File:') ? 'Write' : 'Edit';
      const input = { tool_name: tool, tool_input: { file_path: relSlash } };
      if (mode === 'pre') {
        notes.push(invokeShellHook('validate-write', input));
      }
      if (mode === 'post') {
        if (studioCore) {
          if (fs.existsSync(filename)) {
            const { warnings, errors } = studioCore.validateAssets(root, relSlash);
            if (errors.length) notes.push(errors.join('\n'));
            if (warnings.length) notes.push(warnings.join('\n'));
          }
          const skillMsg = studioCore.validateSkillChange(root, relSlash);
          if (skillMsg) notes.push(skillMsg);
        } else {
          if (fs.existsSync(filename)) notes.push(invokeShellHook('validate-assets', input));
          notes.push(invokeShellHook('validate-skill-change', input));
        }
      }
    }
  }
}

const context = notes.filter(Boolean).join('\n');
if (context) {
  const hookEventName = mode === 'pre' ? 'PreToolUse' : 'PostToolUse';
  process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName, additionalContext: context } }));
}
