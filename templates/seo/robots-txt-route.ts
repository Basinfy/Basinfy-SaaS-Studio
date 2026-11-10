import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/robots.txt/route.ts
 * Use this instead of app/robots.ts when declaring Content-Signal preferences.
 */
export async function GET() {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://example.com';

  const robotsTxt = `User-agent: *
Content-Signal: search=yes, ai-input=yes, ai-train=no
Allow: /
Disallow: /api/
Disallow: /admin/
Disallow: /dashboard/
Disallow: /settings/

User-agent: OAI-SearchBot
User-agent: Claude-SearchBot
User-agent: PerplexityBot
Content-Signal: search=yes, ai-input=yes, ai-train=no
Allow: /
Disallow: /api/
Disallow: /dashboard/

User-agent: GPTBot
User-agent: ClaudeBot
User-agent: Google-Extended
User-agent: Applebot-Extended
User-agent: CCBot
User-agent: Bytespider
User-agent: Amazonbot
Content-Signal: search=yes, ai-input=yes, ai-train=no
Disallow: /internal/
Disallow: /private/

Sitemap: ${baseUrl}/sitemap.xml
`;

  return new NextResponse(robotsTxt, {
    status: 200,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
    },
  });
}
