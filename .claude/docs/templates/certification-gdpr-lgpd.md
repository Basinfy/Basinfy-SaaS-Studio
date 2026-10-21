# Certification Checklist: GDPR & LGPD (Data Privacy)

**Purpose**: Verify compliance with European Union GDPR and Brazilian LGPD data protection regulations before public launch.
**Run via**: `/saas-release-checklist` or `/saas-launch-checklist`

### Consent & Legal Transparency
- [ ] Cookie consent banner implemented with granular opt-in (Analytics, Marketing, Essential)
- [ ] No tracking scripts (PostHog, Google Analytics, Meta Pixel) fire prior to explicit user consent
- [ ] Privacy Policy published with clear legal basis, data collection purposes, and retention periods
- [ ] Terms of Service published with dispute resolution and user rights
- [ ] Subprocessor list published (hosting, database, email, payment provider) with locations

### User Data Rights
- [ ] Right to Access: Users can view all personal profile data in Account Settings
- [ ] Right to Portability: Users can export all account data in machine-readable JSON/CSV format
- [ ] Right to Rectification: Users can update email, name, organization, and profile details
- [ ] Right to Erasure ("Right to be Forgotten"): Self-serve or support-assisted account deletion with cascading cleanup
- [ ] Cascade Deletion: Account deletion removes or anonymizes user PII from database, logs, and backups within 30 days

### Security & Operational Safeguards
- [ ] All database connections and external API traffic encrypted with TLS 1.3
- [ ] Database backups encrypted at rest with AES-256
- [ ] Row-Level Security (RLS) or tenant isolation prevents cross-tenant data access
- [ ] Audit logs record access to sensitive user data without logging passwords, tokens, or PII
- [ ] Data Breach Incident Response Plan documented with 72-hour regulatory notification timeline
- [ ] Data Protection Officer (DPO) or Privacy Lead contact information published
