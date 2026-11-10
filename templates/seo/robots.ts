import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://example.com';

  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/admin/', '/dashboard/', '/settings/'],
      },
      // Allow AI Search citability while disallowing scraping of private apps
      {
        userAgent: ['OAI-SearchBot', 'Claude-SearchBot', 'PerplexityBot'],
        allow: ['/', '/blog/', '/integrations/', '/vs/', '/templates/', '/docs/'],
        disallow: ['/api/', '/dashboard/'],
      },
      // Block pure LLM bulk training crawlers if desired
      {
        userAgent: ['GPTBot', 'ClaudeBot', 'Bytespider', 'Google-Extended'],
        disallow: ['/internal/', '/private/'],
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
  };
}
