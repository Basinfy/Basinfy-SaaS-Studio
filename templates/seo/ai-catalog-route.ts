import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/.well-known/ai-catalog.json/route.ts
 * Implements Agentic Resource Discovery (ARD) 1.0 with host metadata and CORS.
 */
export async function GET() {
  const baseUrl = (process.env.NEXT_PUBLIC_APP_URL || 'https://example.com').replace(/\/$/, '');
  const hostname = new URL(baseUrl).hostname;

  const catalog = {
    specVersion: '1.0',
    host: {
      displayName: 'Basinfy SaaS Platform',
      identifier: `did:web:${hostname}`,
    },
    entries: [
      {
        identifier: `urn:air:${hostname}:mcp:core`,
        displayName: 'Core SaaS MCP Server',
        type: 'application/mcp-server-card+json',
        url: `${baseUrl}/.well-known/mcp/server-card.json`,
        representativeQueries: [
          'How do I query workspace usage metrics?',
          'Create or inspect SaaS billing subscriptions',
        ],
      },
    ],
  };

  return NextResponse.json(catalog, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
    },
  });
}
