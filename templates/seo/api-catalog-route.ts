import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/.well-known/api-catalog/route.ts
 * Implements RFC 9727 API Catalog (application/linkset+json).
 */
export async function GET() {
  const baseUrl = (process.env.NEXT_PUBLIC_APP_URL || 'https://example.com').replace(/\/$/, '');

  const catalog = {
    linkset: [
      {
        anchor: `${baseUrl}/api/v1`,
        'service-desc': [
          {
            href: `${baseUrl}/openapi.json`,
            type: 'application/openapi+json',
          },
        ],
        'service-doc': [
          {
            href: `${baseUrl}/docs`,
            type: 'text/html',
          },
        ],
        status: [
          {
            href: `${baseUrl}/api/health`,
            type: 'application/json',
          },
        ],
      },
    ],
  };

  return new NextResponse(JSON.stringify(catalog, null, 2), {
    status: 200,
    headers: {
      'Content-Type': 'application/linkset+json; profile="https://www.rfc-editor.org/info/rfc9727"',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
      'Access-Control-Allow-Origin': '*',
    },
  });
}
