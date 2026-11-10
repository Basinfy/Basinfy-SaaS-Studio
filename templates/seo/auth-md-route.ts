import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/auth.md/route.ts
 * Implements Auth.md agent registration and OAuth discovery documentation.
 */
export async function GET() {
  const baseUrl = (process.env.NEXT_PUBLIC_APP_URL || 'https://example.com').replace(/\/$/, '');

  const authMd = `# Basinfy SaaS auth.md

> Machine-readable agent authentication and registration guide.

## Audience
AI agents, MCP clients, and automated workflows accessing protected SaaS APIs.

## OAuth Discovery Metadata
- Protected Resource Metadata (RFC 9728): ${baseUrl}/.well-known/oauth-protected-resource
- Authorization Server Metadata (RFC 8414): ${baseUrl}/.well-known/oauth-authorization-server

## Supported Flows
- OAuth 2.1 Authorization Code + PKCE
- Bearer token authentication via \`Authorization: Bearer <token>\`
`;

  return new NextResponse(authMd, {
    status: 200,
    headers: {
      'Content-Type': 'text/markdown; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
    },
  });
}
