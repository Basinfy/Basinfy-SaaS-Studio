import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/.well-known/mcp/server-card.json/route.ts
 * Implements MCP Server Card discovery (SEP-1649 / IsItAgentReady).
 */
export async function GET() {
  const baseUrl = (process.env.NEXT_PUBLIC_APP_URL || 'https://example.com').replace(/\/$/, '');

  return NextResponse.json(
    {
      serverInfo: {
        name: 'Basinfy SaaS MCP Server',
        version: '1.0.0',
      },
      description: 'Model Context Protocol server exposing SaaS workspace tools and resources.',
      endpoint: `${baseUrl}/mcp`,
      transport: {
        type: 'streamable-http',
      },
      capabilities: {
        tools: true,
        resources: true,
        prompts: false,
      },
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
