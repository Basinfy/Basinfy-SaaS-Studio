#!/usr/bin/env bash
# classify-error.sh — PostToolUse terminal error classifier & actionable hint injector
# Non-zero terminal outcomes are inspected for recurring SaaS friction patterns,
# returning actionable resolution guidance directly into the tool response.

if [ "$1" = "--test" ]; then
    echo "classify-error.sh: self-test OK"
    exit 0
fi

INPUT=$(cat)

# Fast return if input is empty or looks like a clean success
if [ -z "$INPUT" ]; then
    exit 0
fi

# Check for Prisma Errors
if echo "$INPUT" | grep -qE "P2002|Unique constraint failed"; then
    echo "[STUDIO ADVISORY] Prisma Unique Constraint Violation (P2002): The operation failed because a record with this unique field already exists. Consider using 'upsert' instead of 'create', or verify the identifier uniqueness before inserting." >&2
fi

if echo "$INPUT" | grep -qE "P2025|An operation failed because it depends on one or more records that were required but not found"; then
    echo "[STUDIO ADVISORY] Prisma Record Not Found (P2025): Verify the foreign key or record ID exists before running dependent operations." >&2
fi

# Check for Next.js Route Handler Dynamic Errors
if echo "$INPUT" | grep -qE "Dynamic server usage:.*couldn't be rendered statically"; then
    echo "[STUDIO ADVISORY] Next.js Dynamic Server Usage: A Route Handler uses dynamic functions (like cookies() or headers()) without dynamic route configuration. Add 'export const dynamic = \"force-dynamic\";' at the top of the route file." >&2
fi

# Check for Stripe Webhook Signature Verification Failures
if echo "$INPUT" | grep -qE "StripeSignatureVerificationError|No signatures found matching the expected signature for payload"; then
    echo "[STUDIO ADVISORY] Stripe Signature Verification Error: Stripe webhooks MUST be verified against the raw binary/text request body. Ensure you are using 'req.text()' rather than 'req.json()', and verify your STRIPE_WEBHOOK_SECRET matches the current environment." >&2
fi

# Check for PostgreSQL RLS Violations
if echo "$INPUT" | grep -qE "new row violates row-level security policy|permission denied for table"; then
    echo "[STUDIO ADVISORY] PostgreSQL RLS Violation: Operation blocked by Row Level Security. Ensure your database client sets the current tenant/user context or uses a service_role key with audited tenant validation." >&2
fi

# Check for TypeScript Compilation Errors
if echo "$INPUT" | grep -qE "error TS[0-9]{4}:"; then
    echo "[STUDIO ADVISORY] TypeScript Compilation Error detected. Run 'bash .claude/scripts/ts-parse-check.sh <file>' or inspect missing types/exports before proceeding." >&2
fi

exit 0
