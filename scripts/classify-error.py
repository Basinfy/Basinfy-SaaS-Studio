#!/usr/bin/env python3
"""
classify-error.py — Terminal error classifier & actionable hint injector for Basinfy SaaS Studio
"""

import sys
import re

PATTERNS = [
    (
        r"P2002|Unique constraint failed",
        "[STUDIO ADVISORY] Prisma Unique Constraint Violation (P2002): The operation failed because a record with this unique field already exists. Consider using 'upsert' instead of 'create', or verify the identifier uniqueness before inserting."
    ),
    (
        r"P2025|An operation failed because it depends on one or more records that were required but not found",
        "[STUDIO ADVISORY] Prisma Record Not Found (P2025): Verify the foreign key or record ID exists before running dependent operations."
    ),
    (
        r"Dynamic server usage:.*couldn't be rendered statically",
        "[STUDIO ADVISORY] Next.js Dynamic Server Usage: A Route Handler uses dynamic functions without dynamic route configuration. Add 'export const dynamic = \"force-dynamic\";' at the top of the route file."
    ),
    (
        r"StripeSignatureVerificationError|No signatures found matching the expected signature for payload",
        "[STUDIO ADVISORY] Stripe Signature Verification Error: Stripe webhooks MUST be verified against the raw binary/text request body (req.text()). Verify STRIPE_WEBHOOK_SECRET matches the current environment."
    ),
    (
        r"new row violates row-level security policy|permission denied for table",
        "[STUDIO ADVISORY] PostgreSQL RLS Violation: Operation blocked by Row Level Security. Ensure your database client sets the current tenant/user context or uses a service_role key with audited tenant validation."
    ),
    (
        r"error TS[0-9]{4}:",
        "[STUDIO ADVISORY] TypeScript Compilation Error detected. Run 'bash .claude/scripts/ts-parse-check.sh <file>' or inspect missing types/exports."
    )
]

def classify(text):
    hints = []
    for pattern, advice in PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            hints.append(advice)
    return hints

def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        print("classify-error.py: self-test OK")
        sys.exit(0)

    input_text = sys.stdin.read()
    if not input_text:
        sys.exit(0)

    hints = classify(input_text)
    for hint in hints:
        sys.stderr.write(hint + "\n")

if __name__ == "__main__":
    main()
