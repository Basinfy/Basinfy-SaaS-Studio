# Domain Experience: Authentication & Access Control

## Experience: Multi-Tenant PostgreSQL RLS Tenant Bypass Prevention
- **cue**: Tenant A queries leaking records belonging to Tenant B when database queries omit explicit workspace filtering or use insecure join clauses.
- **lesson**: Always enforce PostgreSQL Row Level Security (RLS) directly on all user/tenant tables. Never rely purely on application-level `where tenant_id = ?` filters. Define policies using `current_setting('app.current_tenant_id', true)::uuid`.
- **evidence**: Passing multi-tenant isolation unit test where querying with Tenant A context yields 0 rows for Tenant B data.

## Experience: Next.js Server Actions Session Validation
- **cue**: Unauthenticated callers invoking Server Actions directly via forged POST requests.
- **lesson**: Always validate the user session inside each Server Action before executing business logic, using a reusable `authenticatedAction` wrapper with Zod schema parsing.
- **evidence**: Security test verifies that requests without active session cookies return `{ error: "Unauthorized", status: 401 }`.
