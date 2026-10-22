# Domain Experience: Database & Migrations

## Experience: Prisma Migration Lock Deadlock in Serverless
- **cue**: Prisma migrations hanging or throwing `P2002` / connection timeout when run during concurrent serverless container startup.
- **lesson**: Never run `prisma migrate deploy` inside Next.js application startup or Route Handlers. Execute migrations strictly in a standalone CI/CD pipeline step or pre-deploy container task before routing traffic.
- **evidence**: CI pipeline deploys schema cleanly with zero concurrent connection timeouts.
