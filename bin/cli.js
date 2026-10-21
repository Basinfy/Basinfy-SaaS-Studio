#!/usr/bin/env node

/**
 * Basinfy SaaS Studio — Autonomous Multi-LLM Installer & Scaffolder
 * Compatible with Claude Code, Cursor, Antigravity / Gemini CLI, Windsurf, Cline & Copilot
 * Zero external dependencies — pure Node.js standard library.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');

const PKG_ROOT = path.resolve(__dirname, '..');
const pkgJson = JSON.parse(fs.readFileSync(path.join(PKG_ROOT, 'package.json'), 'utf8'));

// ANSI color helpers
const c = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  dim: '\x1b[2m',
  cyan: '\x1b[36m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  magenta: '\x1b[35m',
  red: '\x1b[31m',
  blue: '\x1b[34m',
  gray: '\x1b[90m',
};

function banner() {
  console.log(`
${c.cyan}${c.bold}   ██████╗   █████╗  ███████╗██╗███╗   ██╗███████╗██╗   ██╗
   ██╔══██╗ ██╔══██╗ ██╔════╝██║████╗  ██║██╔════╝╚██╗ ██╔╝
   ██████╔╝ ███████║ ███████╗██║██╔██╗ ██║█████╗   ╚████╔╝ 
   ██╔══██╗ ██╔══██║ ╚════██║██║██║╚██╗██║██╔══╝    ╚██╔╝  
   ██████╔╝ ██║  ██║ ███████║██║██║ ╚████║██║        ██║   ${c.reset}
   ${c.magenta}${c.bold}SAAS STUDIO${c.reset} ${c.dim}v${pkgJson.version} — Autonomous Engineering Platform${c.reset}
  `);
}

function printHelp() {
  banner();
  console.log(`${c.bold}USAGE:${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio [command] [options]

${c.bold}COMMANDS:${c.reset}
  ${c.cyan}all${c.reset}           Install & configure for ALL supported LLMs & IDEs
  ${c.cyan}claude${c.reset}        Install specifically for Claude Code (.claude/, CLAUDE.md)
  ${c.cyan}antigravity${c.reset}   Install specifically for Antigravity & Gemini CLI (GEMINI.md, skills)
  ${c.cyan}cursor${c.reset}        Install specifically for Cursor (.cursor/, .cursorrules, mcp.json)
  ${c.cyan}windsurf${c.reset}      Install specifically for Windsurf (.windsurf/, .windsurfrules)
  ${c.cyan}cline${c.reset}         Install specifically for Cline / Roo-Code (.clinerules)
  ${c.cyan}continue${c.reset}      Install specifically for Continue.dev (.continue/)
  ${c.cyan}init${c.reset}          Interactive guided installation wizard (default)
  ${c.cyan}update${c.reset}        Check and update studio framework to latest version from GitHub

${c.bold}OPTIONS:${c.reset}
  ${c.green}-g, --global${c.reset}      Install globally into user home directory (~/.claude, ~/.gemini, etc.)
  ${c.green}-t, --target <dir>${c.reset} Set custom target directory (default: current directory .)
  ${c.green}-m, --mode <mode>${c.reset}  Installation mode:
                      ${c.bold}scaffold${c.reset} (default) — Full new SaaS studio architecture
                      ${c.bold}inject${c.reset} — Add AI studio to an existing repo safely
  ${c.green}-f, --force${c.reset}       Overwrite existing files without prompting
  ${c.green}-v, --version${c.reset}     Show version
  ${c.green}-h, --help${c.reset}        Show this help message

${c.bold}EXAMPLES:${c.reset}
  ${c.dim}# Global install for all tools (available in ANY folder on your machine):${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio all --global

  ${c.dim}# Global install specifically for Antigravity or Claude Code:${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio antigravity --global
  npx github:Basinfy/Basinfy-SaaS-Studio claude --global

  ${c.dim}# Create a brand new SaaS studio project in ./my-saas-app:${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio all --target ./my-saas-app

  ${c.dim}# Inject SaaS Studio into an existing Next.js / FastAPI project:${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio all --mode inject

  ${c.dim}# Update existing project or global installation to latest GitHub version:${c.reset}
  npx github:Basinfy/Basinfy-SaaS-Studio update
  npx github:Basinfy/Basinfy-SaaS-Studio update --global
`);
}

// Recursive copy helper
function copyRecursive(src, dest, force = false, filter = null) {
  if (!fs.existsSync(src)) return 0;
  let count = 0;
  const stat = fs.statSync(src);

  if (stat.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    const entries = fs.readdirSync(src);
    for (const entry of entries) {
      if (filter && !filter(entry, path.join(src, entry))) continue;
      count += copyRecursive(path.join(src, entry), path.join(dest, entry), force, filter);
    }
  } else {
    if (fs.existsSync(dest) && !force) {
      return 0; // Skip if exists and not forced
    }
    const destDir = path.dirname(dest);
    if (!fs.existsSync(destDir)) {
      fs.mkdirSync(destDir, { recursive: true });
    }
    fs.copyFileSync(src, dest);
    // Preserve executable permissions on unix-like systems
    if (src.endsWith('.sh') || src.endsWith('cli.js')) {
      try {
        fs.chmodSync(dest, 0o755);
      } catch (_) {}
    }
    count++;
  }
  return count;
}

// Path resolver for global installations
function getGlobalPaths() {
  const home = os.homedir();
  return {
    claude: {
      agents: path.join(home, '.claude', 'agents'),
      skills: path.join(home, '.claude', 'skills'),
      directorGates: path.join(home, '.claude', 'director-gates'),
      rules: path.join(home, '.claude', 'rules'),
      scripts: path.join(home, '.claude', 'scripts'),
    },
    antigravity: {
      studioSkill: path.join(home, '.gemini', 'config', 'skills', 'basinfy-saas-studio'),
      skillsDir: path.join(home, '.gemini', 'config', 'skills'),
    },
    cursor: {
      rules: path.join(home, '.cursor', 'rules'),
      skills: path.join(home, '.cursor', 'skills'),
    },
    windsurf: {
      rules: path.join(home, '.codeium', 'windsurf', 'rules'),
    },
  };
}

// Global installation executor
function installGlobal(targets, force) {
  console.log(`\n${c.bold}${c.magenta}🌐 Executing Global Installation...${c.reset}\n`);
  const gPaths = getGlobalPaths();
  let totalFiles = 0;

  // 1. Claude Code
  if (targets.claude || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Installing globally for Claude Code (~/.claude/)... `);
    let cCount = 0;
    cCount += copyRecursive(path.join(PKG_ROOT, '.claude', 'agents'), gPaths.claude.agents, force);
    cCount += copyRecursive(path.join(PKG_ROOT, '.claude', 'skills'), gPaths.claude.skills, force);
    cCount += copyRecursive(path.join(PKG_ROOT, '.claude', 'director-gates'), gPaths.claude.directorGates, force);
    cCount += copyRecursive(path.join(PKG_ROOT, '.claude', 'rules'), gPaths.claude.rules, force);
    cCount += copyRecursive(path.join(PKG_ROOT, '.claude', 'scripts'), gPaths.claude.scripts, force);
    totalFiles += cCount;
    console.log(`${c.green}✔ Done (${cCount} files)${c.reset}`);
  }

  // 2. Antigravity / Gemini CLI
  if (targets.antigravity || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Installing globally for Antigravity (~/.gemini/config/skills/)... `);
    let aCount = 0;
    // Install primary studio skill
    aCount += copyRecursive(
      path.join(PKG_ROOT, '.agents', 'skills', 'basinfy-saas-studio'),
      gPaths.antigravity.studioSkill,
      force
    );
    // Also copy all 74 saas-* workflow skills so every /saas-* command registers natively in Antigravity
    const skillsSource = path.join(PKG_ROOT, '.claude', 'skills');
    if (fs.existsSync(skillsSource)) {
      const skillDirs = fs.readdirSync(skillsSource);
      for (const sk of skillDirs) {
        if (sk.startsWith('saas-')) {
          aCount += copyRecursive(
            path.join(skillsSource, sk),
            path.join(gPaths.antigravity.skillsDir, sk),
            force
          );
        }
      }
    }
    totalFiles += aCount;
    console.log(`${c.green}✔ Done (${aCount} files)${c.reset}`);
  }

  // 3. Cursor
  if (targets.cursor || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Installing globally for Cursor (~/.cursor/)... `);
    let curCount = 0;
    curCount += copyRecursive(path.join(PKG_ROOT, '.cursor', 'rules'), gPaths.cursor.rules, force);
    curCount += copyRecursive(path.join(PKG_ROOT, '.cursor', 'skills'), gPaths.cursor.skills, force);
    totalFiles += curCount;
    console.log(`${c.green}✔ Done (${curCount} files)${c.reset}`);
  }

  // 4. Windsurf
  if (targets.windsurf || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Installing globally for Windsurf (~/.codeium/windsurf/)... `);
    let wCount = 0;
    wCount += copyRecursive(path.join(PKG_ROOT, '.windsurf', 'rules'), gPaths.windsurf.rules, force);
    totalFiles += wCount;
    console.log(`${c.green}✔ Done (${wCount} files)${c.reset}`);
  }

  console.log(`\n${c.green}${c.bold}🎉 Global installation successfully completed!${c.reset} (${totalFiles} files installed)`);
  console.log(`\n${c.bold}Now you can use Basinfy SaaS Studio in ANY project on this machine:${c.reset}`);
  console.log(`  ${c.cyan}• Claude Code:${c.reset} Type ${c.bold}/saas-help${c.reset} or ${c.bold}/saas-start${c.reset} in any terminal session.`);
  console.log(`  ${c.cyan}• Antigravity:${c.reset} The ${c.bold}basinfy-saas-studio${c.reset} and all ${c.bold}/saas-*${c.reset} skills are now active.`);
  console.log(`  ${c.cyan}• Cursor / Windsurf:${c.reset} Global studio rules are active in every chat.`);
}

// Local workspace installation executor
function installLocal(targetDir, targets, mode, force) {
  const dest = path.resolve(process.cwd(), targetDir);
  console.log(`\n${c.bold}${c.magenta}📦 Installing Basinfy SaaS Studio to: ${c.cyan}${dest}${c.reset}`);
  console.log(`   ${c.dim}Mode: ${mode.toUpperCase()} | Force overwrite: ${force}${c.reset}\n`);

  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  let totalFiles = 0;

  // 1. Claude Code
  if (targets.claude || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Claude Code (.claude/, CLAUDE.md, project.yaml)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.claude'), path.join(dest, '.claude'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'CLAUDE.md'), path.join(dest, 'CLAUDE.md'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'project.yaml'), path.join(dest, 'project.yaml'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'project.local.yaml.example'), path.join(dest, 'project.local.yaml.example'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 2. Cursor
  if (targets.cursor || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Cursor (.cursor/, .cursorrules)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.cursor'), path.join(dest, '.cursor'), force);
    count += copyRecursive(path.join(PKG_ROOT, '.cursorrules'), path.join(dest, '.cursorrules'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 3. Antigravity & Gemini CLI
  if (targets.antigravity || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Antigravity & Gemini (GEMINI.md, .agents/)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.agents'), path.join(dest, '.agents'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'GEMINI.md'), path.join(dest, 'GEMINI.md'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'CONVENTIONS.md'), path.join(dest, 'CONVENTIONS.md'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 4. Windsurf
  if (targets.windsurf || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Windsurf (.windsurf/, .windsurfrules)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.windsurf'), path.join(dest, '.windsurf'), force);
    count += copyRecursive(path.join(PKG_ROOT, '.windsurfrules'), path.join(dest, '.windsurfrules'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 5. Cline / Roo-Code
  if (targets.cline || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Cline / Roo-Code (.clinerules)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.clinerules'), path.join(dest, '.clinerules'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 6. Continue.dev
  if (targets.continue || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Continue.dev (.continue/)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.continue'), path.join(dest, '.continue'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 7. Copilot & Devin & Universal AGENTS.md
  if (targets.copilot || targets.all) {
    process.stdout.write(`  ${c.cyan}•${c.reset} Configuring Copilot & Devin (.github/, .devin/, AGENTS.md)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, '.github'), path.join(dest, '.github'), force);
    count += copyRecursive(path.join(PKG_ROOT, '.devin'), path.join(dest, '.devin'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'AGENTS.md'), path.join(dest, 'AGENTS.md'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  // 8. Scaffold Mode specifics (templates, docs, design, production dirs)
  if (mode === 'scaffold') {
    process.stdout.write(`  ${c.cyan}•${c.reset} Scaffolding SaaS product directories (design/, docs/, production/)... `);
    let count = 0;
    count += copyRecursive(path.join(PKG_ROOT, 'design'), path.join(dest, 'design'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'docs'), path.join(dest, 'docs'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'production'), path.join(dest, 'production'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'studio-tests'), path.join(dest, 'studio-tests'), force);
    count += copyRecursive(path.join(PKG_ROOT, '.gitignore'), path.join(dest, '.gitignore'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'README.md'), path.join(dest, 'README.md'), force);
    count += copyRecursive(path.join(PKG_ROOT, 'README.en.md'), path.join(dest, 'README.en.md'), force);
    totalFiles += count;
    console.log(`${c.green}✔ Done (${count} files)${c.reset}`);
  }

  console.log(`\n${c.green}${c.bold}🎉 Studio successfully installed at: ${c.cyan}${dest}${c.reset} (${totalFiles} files)`);
  console.log(`\n${c.bold}Next Steps:${c.reset}`);
  console.log(`  1. Open this directory in your AI tool: ${c.cyan}cd "${targetDir}"${c.reset}`);
  console.log(`  2. Type ${c.bold}/saas-start${c.reset} to initiate the guided onboarding wizard.`);
  console.log(`  3. Type ${c.bold}/saas-help${c.reset} to view the full workflow catalog anytime.`);
}

// Interactive wizard for when no flags are passed
function runInteractiveWizard() {
  banner();
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const prompt = (query) => new Promise((resolve) => rl.question(query, resolve));

  (async () => {
    console.log(`${c.bold}Welcome to Basinfy SaaS Studio Setup!${c.reset}\n`);

    // Question 1: Scope (Global vs Local)
    console.log(`${c.bold}1. Installation Scope:${c.reset}`);
    console.log(`   ${c.cyan}[1]${c.reset} Global (~/.claude, ~/.gemini, etc. — available everywhere)`);
    console.log(`   ${c.cyan}[2]${c.reset} Local Project (Current folder or new directory)`);
    const scopeAnswer = (await prompt(`   Select [1/2] (default: 2): `)).trim() || '2';

    if (scopeAnswer === '1') {
      console.log(`\n${c.bold}2. Target Platforms for Global Installation:${c.reset}`);
      console.log(`   ${c.cyan}[1]${c.reset} All Platforms (Claude Code, Antigravity, Cursor, Windsurf)`);
      console.log(`   ${c.cyan}[2]${c.reset} Claude Code only`);
      console.log(`   ${c.cyan}[3]${c.reset} Antigravity / Gemini CLI only`);
      console.log(`   ${c.cyan}[4]${c.reset} Cursor only`);
      const platAns = (await prompt(`   Select [1/2/3/4] (default: 1): `)).trim() || '1';
      rl.close();

      const targets = {
        all: platAns === '1',
        claude: platAns === '2' || platAns === '1',
        antigravity: platAns === '3' || platAns === '1',
        cursor: platAns === '4' || platAns === '1',
      };
      installGlobal(targets, true);
      return;
    }

    // Question 2: Destination directory
    console.log(`\n${c.bold}2. Target Destination:${c.reset}`);
    const targetDir = (await prompt(`   Directory path (default: current directory .): `)).trim() || '.';

    // Question 3: Mode
    console.log(`\n${c.bold}3. Installation Mode:${c.reset}`);
    console.log(`   ${c.cyan}[1]${c.reset} Scaffold New Project (complete SaaS studio structure)`);
    console.log(`   ${c.cyan}[2]${c.reset} Inject into Existing Project (add AI studio without overwriting app)`);
    const modeAns = (await prompt(`   Select [1/2] (default: 1): `)).trim() || '1';
    const mode = modeAns === '2' ? 'inject' : 'scaffold';

    // Question 4: Platforms
    console.log(`\n${c.bold}4. Target AI Platforms:${c.reset}`);
    console.log(`   ${c.cyan}[1]${c.reset} All / Universal (Claude, Cursor, Antigravity, Windsurf, Cline, Copilot)`);
    console.log(`   ${c.cyan}[2]${c.reset} Claude Code only`);
    console.log(`   ${c.cyan}[3]${c.reset} Cursor only`);
    console.log(`   ${c.cyan}[4]${c.reset} Antigravity / Gemini only`);
    const platAns = (await prompt(`   Select [1/2/3/4] (default: 1): `)).trim() || '1';
    rl.close();

    const targets = {
      all: platAns === '1',
      claude: platAns === '2' || platAns === '1',
      cursor: platAns === '3' || platAns === '1',
      antigravity: platAns === '4' || platAns === '1',
      windsurf: platAns === '1',
      cline: platAns === '1',
      continue: platAns === '1',
      copilot: platAns === '1',
    };

    installLocal(targetDir, targets, mode, false);
  })().catch((err) => {
    console.error(`\n${c.red}Error:${c.reset}`, err.message);
    rl.close();
    process.exit(1);
  });
}

// CLI Argument parsing
function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = {
    command: null,
    global: false,
    target: '.',
    mode: 'scaffold',
    force: false,
    help: false,
    version: false,
    targets: {
      all: false,
      claude: false,
      antigravity: false,
      cursor: false,
      windsurf: false,
      cline: false,
      continue: false,
      copilot: false,
    },
  };

  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '-h' || a === '--help' || a === 'help') {
      parsed.help = true;
    } else if (a === '-v' || a === '--version') {
      parsed.version = true;
    } else if (a === '-g' || a === '--global' || a === 'global') {
      parsed.global = true;
    } else if (a === '-f' || a === '--force' || a === '-y' || a === '--yes') {
      parsed.force = true;
    } else if (a === '-t' || a === '--target') {
      parsed.target = args[++i] || '.';
    } else if (a === '-m' || a === '--mode') {
      parsed.mode = args[++i] || 'scaffold';
    } else if (a === '--inject') {
      parsed.mode = 'inject';
    } else if (a === 'claude' || a === '--claude') {
      parsed.targets.claude = true;
      parsed.command = 'claude';
    } else if (a === 'antigravity' || a === '--antigravity' || a === 'gemini' || a === '--gemini') {
      parsed.targets.antigravity = true;
      parsed.command = 'antigravity';
    } else if (a === 'cursor' || a === '--cursor') {
      parsed.targets.cursor = true;
      parsed.command = 'cursor';
    } else if (a === 'windsurf' || a === '--windsurf') {
      parsed.targets.windsurf = true;
      parsed.command = 'windsurf';
    } else if (a === 'cline' || a === '--cline' || a === 'roo' || a === '--roo') {
      parsed.targets.cline = true;
      parsed.command = 'cline';
    } else if (a === 'continue' || a === '--continue') {
      parsed.targets.continue = true;
      parsed.command = 'continue';
    } else if (a === 'copilot' || a === '--copilot' || a === 'devin' || a === '--devin') {
      parsed.targets.copilot = true;
      parsed.command = 'copilot';
    } else if (a === 'all' || a === '--all') {
      parsed.targets.all = true;
      parsed.command = 'all';
    } else if (a === 'init') {
      parsed.command = 'init';
    } else if (a === 'update' || a === '--update' || a === 'upgrade') {
      parsed.command = 'update';
    } else if (!a.startsWith('-') && !parsed.command) {
      parsed.target = a;
    }
  }

  return parsed;
}


// Framework Auto-Updater implementation
function executeUpdate(opts) {
  banner();
  console.log(`${c.bold}${c.cyan}🔄 Basinfy SaaS Studio — Framework Updater${c.reset}\n`);

  const targetDir = path.resolve(opts.target || '.');
  const isGlobal = opts.global;
  const repo = 'Basinfy/Basinfy-SaaS-Studio';

  console.log(`  ${c.dim}Checking GitHub repository (${repo})...${c.reset}`);

  const https = require('https');
  const { execSync } = require('child_process');

  const fetchJson = (urlPath) => {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'api.github.com',
        path: urlPath,
        headers: {
          'User-Agent': 'Basinfy-SaaS-Studio-Updater',
          'Accept': 'application/vnd.github+json',
        },
      };
      https.get(options, (res) => {
        let data = '';
        res.on('data', chunk => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(data) });
          } catch (_) {
            resolve({ status: res.statusCode, data: null });
          }
        });
      }).on('error', err => reject(err));
    });
  };

  fetchJson(`/repos/${repo}/commits/master`)
    .then(({ status, data: commitData }) => {
      let latestSha = 'latest';
      let commitMsg = '';
      if (status === 200 && commitData && commitData.sha) {
        latestSha = commitData.sha.substring(0, 7);
        commitMsg = commitData.commit && commitData.commit.message ? commitData.commit.message.split('\n')[0] : '';
        console.log(`  ${c.green}✔ Remote commit on GitHub:${c.reset} ${c.bold}${latestSha}${c.reset} (${c.dim}${commitMsg}${c.reset})`);
      } else {
        console.log(`  ${c.yellow}⚠ Could not fetch GitHub API info (status ${status}). Proceeding with package update...${c.reset}`);
      }

      // Check local version stamp
      let installedSha = null;
      const vFile = path.join(targetDir, '.claude', 'framework-version.json');
      if (fs.existsSync(vFile)) {
        try {
          const vObj = JSON.parse(fs.readFileSync(vFile, 'utf8'));
          installedSha = vObj.commit;
        } catch (_) {}
      }

      if (installedSha) {
        console.log(`  ${c.dim}Currently installed commit:${c.reset} ${c.bold}${installedSha}${c.reset}`);
        if (installedSha === latestSha && !opts.force) {
          console.log(`\n  ${c.green}✨ Basinfy SaaS Studio is already up to date!${c.reset} (${latestSha})\n`);
          return;
        }
      }

      console.log(`\n  ${c.cyan}⚡ Downloading and applying latest updates from GitHub...${c.reset}`);

      const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'basinfy-update-'));
      const tarPath = path.join(tmpDir, 'repo.tar.gz');
      const file = fs.createWriteStream(tarPath);

      function download(url) {
        https.get(url, { headers: { 'User-Agent': 'Basinfy-SaaS-Studio-Updater' } }, (res) => {
          if (res.statusCode === 301 || res.statusCode === 302) {
            download(res.headers.location);
            return;
          }
          res.pipe(file);
          file.on('finish', () => {
            file.close(() => {
              try {
                execSync(`tar -xzf "${tarPath}" -C "${tmpDir}"`);
                const extractedName = fs.readdirSync(tmpDir).find(f => f.startsWith('Basinfy') && fs.statSync(path.join(tmpDir, f)).isDirectory());
                if (!extractedName) {
                  throw new Error('Could not find extracted repository directory');
                }
                const sourceRoot = path.join(tmpDir, extractedName);

                let updatedCount = 0;

                if (isGlobal) {
                  const gPaths = getGlobalPaths();
                  updatedCount += copyRecursive(path.join(sourceRoot, '.claude', 'agents'), gPaths.claude.agents, true);
                  updatedCount += copyRecursive(path.join(sourceRoot, '.claude', 'skills'), gPaths.claude.skills, true);
                  updatedCount += copyRecursive(path.join(sourceRoot, '.claude', 'director-gates'), gPaths.claude.directorGates, true);
                  updatedCount += copyRecursive(path.join(sourceRoot, '.claude', 'rules'), gPaths.claude.rules, true);
                  updatedCount += copyRecursive(path.join(sourceRoot, '.claude', 'scripts'), gPaths.claude.scripts, true);

                  updatedCount += copyRecursive(path.join(sourceRoot, '.agents', 'skills', 'basinfy-saas-studio'), gPaths.antigravity.studioSkill, true);
                  const skillsSrc = path.join(sourceRoot, '.claude', 'skills');
                  if (fs.existsSync(skillsSrc)) {
                    for (const sk of fs.readdirSync(skillsSrc)) {
                      if (sk.startsWith('saas-')) {
                        updatedCount += copyRecursive(path.join(skillsSrc, sk), path.join(gPaths.antigravity.skillsDir, sk), true);
                      }
                    }
                  }

                  updatedCount += copyRecursive(path.join(sourceRoot, '.cursor', 'rules'), gPaths.cursor.rules, true);
                  updatedCount += copyRecursive(path.join(sourceRoot, '.cursor', 'skills'), gPaths.cursor.skills, true);

                  console.log(`\n  ${c.green}✔ Global installation successfully updated! (${updatedCount} files synced)${c.reset}\n`);
                } else {
                  const frameworkDirs = ['.claude', '.agents', '.cursor', '.windsurf'];
                  for (const fd of frameworkDirs) {
                    const srcFd = path.join(sourceRoot, fd);
                    if (fs.existsSync(srcFd)) {
                      updatedCount += copyRecursive(srcFd, path.join(targetDir, fd), true);
                    }
                  }

                  const ruleFiles = ['CLAUDE.md', 'AGENTS.md', 'GEMINI.md', '.cursorrules', '.windsurfrules', '.clinerules', 'CONVENTIONS.md'];
                  for (const rf of ruleFiles) {
                    const srcRf = path.join(sourceRoot, rf);
                    if (fs.existsSync(srcRf)) {
                      fs.copyFileSync(srcRf, path.join(targetDir, rf));
                      updatedCount++;
                    }
                  }

                  const srcCli = path.join(sourceRoot, 'bin', 'cli.js');
                  const destCli = path.join(targetDir, 'bin', 'cli.js');
                  if (fs.existsSync(srcCli) && fs.existsSync(destCli)) {
                    fs.copyFileSync(srcCli, destCli);
                    try { fs.chmodSync(destCli, 0o755); } catch (_) {}
                    updatedCount++;
                  }

                  const targetVFile = path.join(targetDir, '.claude', 'framework-version.json');
                  const vPayload = {
                    name: 'Basinfy-SaaS-Studio',
                    version: pkgJson.version,
                    repository: repo,
                    branch: 'master',
                    commit: latestSha,
                    updated_at: new Date().toISOString()
                  };
                  fs.mkdirSync(path.dirname(targetVFile), { recursive: true });
                  fs.writeFileSync(targetVFile, JSON.stringify(vPayload, null, 2) + '\n');

                  console.log(`\n  ${c.green}✔ Project successfully updated to commit ${latestSha}! (${updatedCount} framework files synced)${c.reset}`);
                  console.log(`  ${c.dim}🔒 All user code (src/), configs (project.yaml, project.local.yaml), and secrets (.env) were untouched.${c.reset}\n`);
                }

              } catch (e) {
                console.error(`  ${c.red}✖ Update failed during extraction: ${e.message}${c.reset}`);
              } finally {
                try { fs.rmSync(tmpDir, { recursive: true, force: true }); } catch (_) {}
              }
            });
          });
        }).on('error', (err) => {
          console.error(`  ${c.red}✖ Download failed: ${err.message}${c.reset}`);
          try { fs.rmSync(tmpDir, { recursive: true, force: true }); } catch (_) {}
        });
      }

      download(`https://github.com/${repo}/archive/refs/heads/master.tar.gz`);
    })
    .catch((err) => {
      console.error(`  ${c.red}✖ Error connecting to GitHub: ${err.message}${c.reset}`);
    });
}
// Main execution routine
function main() {
  const opts = parseArgs();

  if (opts.command === 'update') {
    executeUpdate(opts);
    return;
  }

  if (opts.help) {
    printHelp();
    return;
  }

  if (opts.version) {
    console.log(`v${pkgJson.version}`);
    return;
  }

  // If no specific command or target was given and stdin is a TTY, launch interactive wizard
  const hasSpecificTarget = Object.values(opts.targets).some(Boolean);
  if (!hasSpecificTarget && !opts.global && opts.command !== 'all' && process.stdin.isTTY && process.argv.length <= 2) {
    runInteractiveWizard();
    return;
  }

  banner();

  // If no specific platform was flagged, default to all
  if (!hasSpecificTarget) {
    opts.targets.all = true;
  }

  if (opts.global) {
    installGlobal(opts.targets, opts.force);
  } else {
    installLocal(opts.target, opts.targets, opts.mode, opts.force);
  }
}

main();
