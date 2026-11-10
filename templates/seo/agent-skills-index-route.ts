import { createHash } from 'crypto';
import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/.well-known/agent-skills/index.json/route.ts
 * Implements Agent Skills Discovery RFC v0.2.0.
 */
const SKILL_DEFINITIONS = [
  {
    name: 'quickstart-api',
    description: 'Authenticate and execute your first API workflow with this SaaS.',
    markdown: '# Quickstart API Skill\n\nUse OAuth 2.1 or Bearer tokens against `/api/v1`.\n',
  },
];

export async function GET() {
  const baseUrl = (process.env.NEXT_PUBLIC_APP_URL || 'https://example.com').replace(/\/$/, '');

  const skills = SKILL_DEFINITIONS.map((skill) => {
    const digest = createHash('sha256').update(skill.markdown, 'utf8').digest('hex');
    return {
      name: skill.name,
      type: 'skill-md',
      description: skill.description,
      url: `${baseUrl}/.well-known/agent-skills/${skill.name}/SKILL.md`,
      digest: `sha256:${digest}`,
    };
  });

  return NextResponse.json(
    {
      $schema: 'https://schemas.agentskills.io/discovery/0.2.0/schema.json',
      skills,
    },
    {
      status: 200,
      headers: {
        'Cache-Control': 'public, max-age=3600, s-maxage=3600',
        'Access-Control-Allow-Origin': '*',
      },
    }
  );
}
