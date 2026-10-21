### Certification: SOC 2 (Type I / Type II)
- [ ] **CC6.1 Logical Access Controls**: Multi-Factor Authentication (MFA) enforced on all production and administrative access; Role-Based Access Control (RBAC) enforced with least privilege principle.
- [ ] **CC6.6 Network Perimeter & Transport Security**: TLS 1.3 strictly enforced; Cloudflare/WAF DDoS protection active; Database and private services isolated in VPC / private subnet.
- [ ] **CC6.8 Vulnerability & Dependency Management**: Automated dependency scanning (Dependabot/Snyk) active with zero critical or high unfixed CVEs; container image scan passing.
- [ ] **CC7.2 Security Monitoring & Audit Logging**: Immutable audit logs enabled for authentication, privilege changes, and customer data access; real-time alerting via Sentry/Datadog.
- [ ] **CC8.1 Change Management**: Branch protection rules enabled on `main`; pull request approval and automated CI checks (linters, unit, and integration tests) required prior to deploy.
- [ ] **A1.2 Availability, Backup & Disaster Recovery**: Automated encrypted daily database backups configured with point-in-time recovery (PITR); verified restore tested with documented RTO < 4h, RPO < 1h.
- [ ] **C1.1 Confidentiality & Data Encryption**: Production data encrypted at rest (AES-256) and in transit (TLS 1.3/HTTPS); environment variables and database credentials stored in secure secrets manager.
- [ ] **P1.1 Privacy & Customer Data Lifecycle**: Published Privacy Policy and Terms of Service; verified customer data deletion, export, and retention lifecycle compliant with SOC 2 Trust Services Criteria.
