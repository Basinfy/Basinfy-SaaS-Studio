# Domain Experience: API Endpoints & Server Actions

## Experience: Next.js App Router Dynamic Server Usage in Route Handlers
- **cue**: Next.js build failing with `Error: Dynamic server usage: Route /api/... couldn't be rendered statically because it used headers() or cookies()`.
- **lesson**: In Next.js App Router, routes reading request cookies or dynamic headers must explicitly declare `export const dynamic = "force-dynamic";` at the top of the route file to bypass static optimization.
- **evidence**: `npm run build` compiles with route marked with `f (Dynamic)` without build failures.

## Experience: Zod Input Validation in Server Actions
- **cue**: Runtime errors or SQL injection attempts occurring inside Next.js Server Actions when callers submit malformed FormData or JSON bodies.
- **lesson**: Always define an explicit Zod schema for Server Action input payloads and parse via `schema.safeParse()`. Reject invalid payloads early with structured validation errors `{ success: false, errors: result.error.flatten().fieldErrors }` before querying the database.
- **evidence**: Automated test verifies that malformed input returns HTTP 422/validation failure without triggering database queries.
