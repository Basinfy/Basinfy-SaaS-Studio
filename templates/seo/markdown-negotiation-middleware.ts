import { NextRequest, NextResponse } from 'next/server';

/**
 * Next.js App Router Middleware: middleware.ts
 * 1. Adds RFC 8288 / RFC 9727 Link headers on homepage for agent discovery.
 * 2. Negotiates Accept: text/markdown requests to Markdown sibling routes with Vary: Accept.
 */
const DISCOVERY_LINK_HEADER = [
  '</.well-known/api-catalog>; rel="api-catalog"',
  '</openapi.json>; rel="service-desc"; type="application/openapi+json"',
  '</docs>; rel="service-doc"; type="text/html"',
  '</llms.txt>; rel="describedby"; type="text/plain"',
  '</.well-known/ai-catalog.json>; rel="ai-catalog"; type="application/ai-catalog+json"',
].join(', ');

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const accept = request.headers.get('accept') || '';

  // Serve pre-generated or route-backed Markdown when agents send Accept: text/markdown
  if (
    accept.toLowerCase().includes('text/markdown') &&
    !pathname.startsWith('/api/') &&
    !pathname.startsWith('/.well-known/') &&
    !pathname.endsWith('.md')
  ) {
    const mdTarget = pathname === '/' ? '/index.md' : `${pathname.replace(/\/$/, '')}.md`;
    const url = request.nextUrl.clone();
    url.pathname = `/api/markdown-render`;
    url.searchParams.set('path', mdTarget);
    const res = NextResponse.rewrite(url);
    res.headers.set('Vary', 'Accept');
    return res;
  }

  const response = NextResponse.next();
  response.headers.set('Vary', 'Accept');
  if (pathname === '/') {
    response.headers.set('Link', DISCOVERY_LINK_HEADER);
  }
  return response;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
