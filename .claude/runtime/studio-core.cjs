#!/usr/bin/env node
/**
 * studio-core.cjs — Zero-Dependency Cross-Platform Node.js Runtime for Basinfy SaaS Studio
 *
 * Eliminates multi-process Bash + awk + sed + Python startup overhead on Windows, WSL,
 * macOS, and Linux (~30ms single-process execution vs ~800ms multi-spawn shell chains).
 *
 * Usable both as a CommonJS module (`require('./studio-core.cjs')`) and CLI:
 *   node .claude/runtime/studio-core.cjs resolve-code-root [--root <dir>]
 *   node .claude/runtime/studio-core.cjs resolve-config [--keys k1,k2] [--root <dir>]
 *   node .claude/runtime/studio-core.cjs hook <post-write|classify-error> [--root <dir>]
 */

'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

function resolveProjectRoot(explicitRoot) {
  if (explicitRoot && fs.existsSync(explicitRoot)) return path.resolve(explicitRoot);
  const cwd = process.cwd();
  if (fs.existsSync(path.join(cwd, 'project.yaml')) ||
      (fs.existsSync(path.join(cwd, '.claude')) && path.basename(cwd) !== '.claude')) {
    return cwd;
  }
  const envDir = process.env.CLAUDE_PROJECT_DIR;
  if (envDir && fs.existsSync(envDir) && path.basename(envDir.replace(/[\\/]+$/, '')) !== '.claude') {
    return path.resolve(envDir);
  }
  return path.resolve(__dirname, '..', '..');
}

/**
 * Lightweight subset YAML parser matching yaml-helper.sh semantics
 * (nested maps, scalar leaves, inline & block-dash arrays, block-scalar skipping).
 */
function parseSimpleYaml(text) {
  const root = {};
  const lines = text.replace(/^\uFEFF/, '').split(/\r?\n/);
  const stack = [{ indent: -1, map: root }];
  let blockScalarIndent = null;

  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const stripped = raw.replace(/^ +/, '');
    if (!stripped.trim() || stripped.trimStart().startsWith('#')) continue;
    const indent = raw.length - stripped.length;

    if (blockScalarIndent !== null) {
      if (indent > blockScalarIndent) continue;
      blockScalarIndent = null;
    }

    while (stack.length > 0 && stack[stack.length - 1].indent >= indent) {
      stack.pop();
    }
    if (stack.length === 0) break;
    const parent = stack[stack.length - 1].map;

    const m = stripped.match(/^([^:#\s][^:]*?)\s*:\s*(.*)$/);
    if (!m) continue;
    const key = m[1].trim();
    let val = m[2].trim();

    if (/^[|>][-+0-9]*\s*(#.*)?$/.test(val)) {
      blockScalarIndent = indent;
      parent[key] = val.split(/\s+#/)[0].trim();
      continue;
    }

    if (val.startsWith('#')) {
      val = '';
    } else if (val.startsWith('[')) {
      const parts = [];
      let buf = '';
      let quote = null;
      for (let idx = 1; idx < val.length; idx++) {
        const ch = val[idx];
        if (quote) {
          if (ch === quote) quote = null;
          else buf += ch;
        } else if (ch === '"' || ch === "'") {
          quote = ch;
        } else if (ch === ']') {
          break;
        } else if (ch === ',') {
          if (buf.trim()) parts.push(buf.trim());
          buf = '';
        } else {
          buf += ch;
        }
      }
      if (buf.trim()) parts.push(buf.trim());
      parent[key] = parts;
      continue;
    } else if (val.startsWith('"') || val.startsWith("'")) {
      const q = val[0];
      const end = val.indexOf(q, 1);
      val = end >= 0 ? val.slice(1, end) : val.slice(1);
    } else {
      const hp = val.indexOf(' #');
      if (hp >= 0) val = val.slice(0, hp).trim();
    }

    if (val === '') {
      // Peek ahead for block-dash list vs nested map
      const items = [];
      let j = i + 1;
      while (j < lines.length) {
        const pl = lines[j];
        const ps = pl.replace(/^ +/, '');
        if (!ps.trim() || ps.trimStart().startsWith('#')) { j++; continue; }
        const pIndent = pl.length - ps.length;
        if (pIndent <= indent) break;
        if (ps.startsWith('- ')) {
          let item = ps.slice(2).trim();
          if ((item.startsWith('"') && item.endsWith('"')) || (item.startsWith("'") && item.endsWith("'"))) {
            item = item.slice(1, -1);
          } else {
            const hp = item.indexOf(' #');
            if (hp >= 0) item = item.slice(0, hp).trim();
          }
          items.push(item);
          j++;
          continue;
        }
        break;
      }
      if (items.length > 0) {
        parent[key] = items;
        i = j - 1;
      } else {
        const child = (parent[key] && typeof parent[key] === 'object' && !Array.isArray(parent[key])) ? parent[key] : {};
        parent[key] = child;
        stack.push({ indent, map: child });
      }
    } else {
      parent[key] = val;
    }
  }
  return root;
}

function getNested(obj, dotted) {
  let cur = obj;
  for (const part of dotted.split('.')) {
    if (cur && typeof cur === 'object' && !Array.isArray(cur) && Object.hasOwn(cur, part)) {
      cur = cur[part];
    } else {
      return undefined;
    }
  }
  return cur;
}

function loadConfigPair(rootDir) {
  const baseFile = path.join(rootDir, 'project.yaml');
  const localFile = path.join(rootDir, 'project.local.yaml');
  const base = fs.existsSync(baseFile) ? parseSimpleYaml(fs.readFileSync(baseFile, 'utf8')) : {};
  const local = fs.existsSync(localFile) ? parseSimpleYaml(fs.readFileSync(localFile, 'utf8')) : {};
  return { base, local };
}

function resolveCodeRoot(rootDir) {
  const { base, local } = loadConfigPair(rootDir);
  const nonEmptyStack = v => (v && !/^(?:none|null|~)$/i.test(String(v).trim())) ? String(v).trim() : '';
  let stackName = nonEmptyStack(getNested(local, 'stack.frontend')) || nonEmptyStack(getNested(local, 'stack.backend'));
  let source = stackName ? 'project.local.yaml' : '';
  if (!stackName) {
    stackName = nonEmptyStack(getNested(base, 'stack.frontend')) || nonEmptyStack(getNested(base, 'stack.backend'));
    if (stackName) source = 'project.yaml';
  }
  if (!stackName) {
    const legacyFile = path.join(rootDir, '.claude', 'docs', 'technical-preferences.md');
    if (fs.existsSync(legacyFile)) {
      const m = fs.readFileSync(legacyFile, 'utf8').match(/^[ \t]*[-*]?[ \t]*\*{0,2}(?:Engine|Stack)\*{0,2}[ \t]*:[ \t]*([^\r\n]+)/im);
      if (m && !m[1].includes('[TO BE CONFIGURED]') && !m[1].trim().startsWith('[')) {
        stackName = m[1].trim().split(/\s+/)[0].replace(/\*/g, '');
        source = '.claude/docs/technical-preferences.md';
      }
    }
  }

  let codeRoot = '';
  const norm = String(stackName || '').toLowerCase();
  const pickFirst = (candidates, fallback) => {
    for (const c of candidates) {
      if (fs.existsSync(path.join(rootDir, c))) return c;
    }
    return fallback;
  };

  if (/^(nextjs|next\.js|react|vue|svelte)/.test(norm)) {
    codeRoot = pickFirst(['src', 'app', 'pages'], 'src');
  } else if (/^(fastapi|python|django)/.test(norm)) {
    codeRoot = pickFirst(['app', 'backend/app', 'src'], 'app');
  } else if (/^cloudflare/.test(norm)) {
    codeRoot = pickFirst(['src', 'workers'], 'src');
  } else if (/^go/.test(norm)) {
    codeRoot = pickFirst(['cmd', 'internal', 'src'], 'cmd');
  } else if (/^node/.test(norm)) {
    codeRoot = pickFirst(['src', 'server', 'api'], 'src');
  }

  if (!codeRoot) {
    const present = ['src', 'app', 'backend', 'server', 'api', 'cmd'].filter(d => fs.existsSync(path.join(rootDir, d)));
    if (present.length === 1) {
      codeRoot = present[0];
      source = 'detected';
    }
  }

  return { root: codeRoot, source: source || 'unset' };
}

function toRelativeProjectPath(rootDir, rawFilePath) {
  if (!rawFilePath) return null;
  const clean = String(rawFilePath).replace(/\\\\/g, '/').replace(/\\/g, '/');
  const normRoot = rootDir.replace(/\\/g, '/').replace(/\/+$/, '');
  if (clean.toLowerCase().startsWith(normRoot.toLowerCase() + '/')) {
    return clean.slice(normRoot.length + 1);
  }
  if (path.isAbsolute(rawFilePath)) return null;
  return clean.replace(/^\.\//, '');
}

const ERROR_PATTERNS = [
  [
    /P2002|Unique constraint failed/,
    "[STUDIO ADVISORY] Prisma Unique Constraint Violation (P2002): A record with this unique field already exists. Consider 'upsert' or check uniqueness before inserting.",
  ],
  [
    /P2025|An operation failed because it depends on one or more records that were required but not found/,
    "[STUDIO ADVISORY] Prisma Record Not Found (P2025): Verify the foreign key or target record ID exists before mutating.",
  ],
  [
    /Dynamic server usage:.*couldn't be rendered statically/,
    '[STUDIO ADVISORY] Next.js Dynamic Server Usage: Route reads cookies() or headers() without dynamic config. Add `export const dynamic = "force-dynamic";` at the top of the route.',
  ],
  [
    /StripeSignatureVerificationError|No signatures found matching the expected signature for payload/,
    "[STUDIO ADVISORY] Stripe Signature Verification Error: Verify Stripe webhooks against the raw request body (`await req.text()`), never `req.json()`.",
  ],
  [
    /new row violates row-level security policy|permission denied for table/,
    "[STUDIO ADVISORY] PostgreSQL RLS Violation: Operation blocked by Row-Level Security. Ensure current tenant/user session context is set.",
  ],
  [
    /error TS[0-9]{4}:/,
    "[STUDIO ADVISORY] TypeScript Compilation Error detected. Run `bash .claude/scripts/ts-parse-check.sh <file>` or check missing types/exports.",
  ],
];

function classifyError(inputText) {
  if (!inputText) return '';
  const text = typeof inputText === 'string' ? inputText : JSON.stringify(inputText);
  const advisories = [];
  for (const [rx, msg] of ERROR_PATTERNS) {
    if (rx.test(text)) advisories.push(msg);
  }
  return advisories.join('\n');
}

function validateSkillChange(rootDir, rawFilePath) {
  const rel = toRelativeProjectPath(rootDir, rawFilePath);
  if (!rel || !rel.startsWith('.claude/skills/')) return '';
  const parts = rel.split('/');
  const skillName = parts[2];
  if (!skillName) return '';
  return `Skill modified: ${skillName}. Run /saas-skill-test static ${skillName} to validate compliance, verify autotrigger registration, and run python scripts/sync-agent-skills.py.`;
}

function validateAssets(rootDir, rawFilePath) {
  const rel = toRelativeProjectPath(rootDir, rawFilePath);
  if (!rel || !/^(?:public|design\/tokens|assets)\//.test(rel)) {
    return { warnings: [], errors: [] };
  }
  const warnings = [];
  const errors = [];
  const baseName = path.basename(rel);
  if (rel.startsWith('assets/') && /[A-Z\s-]/.test(baseName)) {
    warnings.push(`NAMING: ${rel} should use lowercase_with_underscores (got: ${baseName})`);
  }
  if (/^(?:public|design\/tokens|assets)\/(?:.*\/)?[Dd]ata\/.*\.[Jj][Ss][Oo][Nn]$/.test(rel) ||
      (rel.startsWith('design/tokens/') && rel.toLowerCase().endsWith('.json'))) {
    const abs = path.join(rootDir, rel);
    if (fs.existsSync(abs)) {
      try {
        const txt = fs.readFileSync(abs, 'utf8').replace(/^\uFEFF/, '');
        JSON.parse(txt);
      } catch (_) {
        errors.push(`FORMAT: ${rel} is not valid JSON — fix syntax errors before continuing`);
      }
    }
  }
  return { warnings, errors };
}

function formatHookAdvisory(hookEventName, message) {
  return JSON.stringify({
    hookSpecificOutput: {
      hookEventName,
      additionalContext: message,
    },
  });
}

function runCli() {
  const args = process.argv.slice(2);
  let rootArg = null;
  const positional = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--root' && args[i + 1]) {
      rootArg = args[++i];
    } else {
      positional.push(args[i]);
    }
  }
  const rootDir = resolveProjectRoot(rootArg);
  const cmd = positional[0];

  if (cmd === 'resolve-code-root') {
    const { root, source } = resolveCodeRoot(rootDir);
    process.stdout.write(`${root}\t${source}`);
    return;
  }

  if (cmd === 'resolve-config') {
    const gitBash = process.platform === 'win32' && process.env.ProgramFiles
      ? path.join(process.env.ProgramFiles, 'Git', 'bin', 'bash.exe')
      : '';
    const bash = gitBash && fs.existsSync(gitBash) ? gitBash : 'bash';
    const helper = path.resolve(__dirname, '..', 'hooks', 'yaml-helper.sh');
    const resolve = 'source "$1" || exit $?; shift; _YH_ROOT="$PWD"; resolve_config "$@"';
    const result = spawnSync(bash, ['-c', resolve, 'studio-resolve-config', helper, ...positional.slice(1)], {
      cwd: rootDir,
      stdio: 'inherit',
    });
    if (result.error) console.error(`Could not run the configuration helper: ${result.error.message}`);
    process.exitCode = result.status ?? 1;
    return;
  }

  if (cmd === 'hook') {
    const hookType = positional[1];
    let rawStdin = '';
    try {
      rawStdin = fs.readFileSync(0, 'utf8');
    } catch (_) {}
    if (!rawStdin.trim()) return;

    if (hookType === 'classify-error') {
      const msg = classifyError(rawStdin);
      if (msg) process.stderr.write(msg + '\n');
      return;
    }

    if (hookType === 'post-write') {
      let payload = {};
      try { payload = JSON.parse(rawStdin); } catch (_) { return; }
      const filePath = payload?.tool_input?.file_path || '';
      const assetRes = validateAssets(rootDir, filePath);
      if (assetRes.errors.length > 0) {
        process.stderr.write(
          `=== Asset Validation: ERRORS ===\n  ${assetRes.errors.join('\n  ')}\n================================\nThe file was written but is broken. Fix it now, before continuing.\n`
        );
        process.exit(2);
      }
      const notes = [];
      if (assetRes.warnings.length > 0) {
        notes.push(`Asset warnings:\n  ${assetRes.warnings.join('\n  ')}`);
      }
      const skillNote = validateSkillChange(rootDir, filePath);
      if (skillNote) notes.push(skillNote);
      if (notes.length > 0) {
        process.stdout.write(formatHookAdvisory('PostToolUse', notes.join('\n')) + '\n');
      }
      return;
    }
  }

  console.error(`Unknown runtime command: ${positional.join(' ')}`);
  process.exitCode = 1;
}

if (require.main === module) {
  runCli();
}

module.exports = {
  resolveProjectRoot,
  parseSimpleYaml,
  resolveCodeRoot,
  classifyError,
  validateSkillChange,
  validateAssets,
  formatHookAdvisory,
};
