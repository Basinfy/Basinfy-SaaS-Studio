import { NextResponse } from 'next/server';

/**
 * Next.js App Router Route Handler: app/.well-known/http-message-signatures-directory/route.ts
 * Implements IETF Web Bot Auth JWKS key directory for signed outgoing agent requests.
 */
export async function GET() {
  // Replace with your active Ed25519 public JWK loaded from environment or KMS
  const jwks = {
    keys: [
      {
        kty: 'OKP',
        crv: 'Ed25519',
        use: 'sig',
        alg: 'EdDSA',
        kid: process.env.WEB_BOT_AUTH_KID || 'replace-with-key-id',
        x: process.env.WEB_BOT_AUTH_PUBLIC_X || 'replace-with-base64url-public-key',
      },
    ],
  };

  return new NextResponse(JSON.stringify(jwks, null, 2), {
    status: 200,
    headers: {
      'Content-Type': 'application/http-message-signatures-directory+json',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
      'Access-Control-Allow-Origin': '*',
    },
  });
}
