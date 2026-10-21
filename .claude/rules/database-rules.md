---
paths:
  - "src/db/**"
  - "prisma/**"
  - "supabase/migrations/**"
---

# Database & Schema Rules

1. **Reversible Migrations**: Every migration must be version-controlled, deterministic, and reversible.
2. **Row Level Security (RLS)**: Mandatory on 100% of PostgreSQL tables in multi-tenant environments.
3. **Foreign Keys & Indices**: All foreign keys must have corresponding index definitions for query performance.
4. **No Raw SQL Concatenation**: Use parameterized queries or typed ORMs (Prisma / Drizzle) exclusively to prevent SQL injection.
