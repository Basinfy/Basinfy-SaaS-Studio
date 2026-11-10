import { NextResponse } from 'next/server';

export async function GET() {
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'https://example.com';

  const llmsContent = `# Basinfy SaaS Platform

> Autonomous AI Cloud Engineering Platform for Production SaaS Applications.

## Core Capabilities
- Next.js 14+ App Router Full-Stack Architecture
- PostgreSQL Row Level Security (RLS) Multi-Tenant Isolation
- Stripe Metered & Tiered Billing Integration
- Real-time Observability & Telemetry

## Documentation & Machine-Readable Resources
- [Architecture Overview](${baseUrl}/docs/architecture.md)
- [API Reference](${baseUrl}/docs/api.md)
- [Pricing & Tiers](${baseUrl}/pricing.md)
- [Security & Compliance](${baseUrl}/docs/security.md)
`;

  return new NextResponse(llmsContent, {
    status: 200,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400',
    },
  });
}
