# Certification Checklist: PCI-DSS (Payment Card Security)

**Purpose**: Verify compliance with Payment Card Industry Data Security Standards (PCI-DSS) for SaaS billing.
**Run via**: `/saas-release-checklist` or `/saas-launch-checklist`

### Payment Card Data Architecture (Zero PAN Footprint)
- [ ] Direct payment card entry on our servers is strictly prohibited
- [ ] Payment forms use hosted iframe elements (Stripe Elements / Checkout / Paddle)
- [ ] No Primary Account Numbers (PAN), CVV, or magnetic stripe data touches our application servers or logs
- [ ] Customers interact directly with PCI-DSS Level 1 certified payment gateway
- [ ] Payment tokens and customer IDs stored in Postgres; raw card data never touches database

### Webhook & Transaction Integrity
- [ ] Stripe / Payment webhook endpoints enforce raw request body cryptographic signature verification
- [ ] Webhook timestamp replay-attack protection configured with 5-minute tolerance
- [ ] Webhook events are idempotent and tolerate duplicate delivery without double-charging
- [ ] Failed webhook transactions record structured audit log with event ID

### Infrastructure & Operational Security
- [ ] All traffic served over HTTPS with TLS 1.3 enforced and HSTS header enabled
- [ ] PCI Self-Assessment Questionnaire (SAQ A or SAQ A-EP) completed and on file
- [ ] Annual third-party vulnerability scan or clean automated dependency CVE audit
- [ ] Payment provider API keys stored securely in environment variables (never committed to repository)
- [ ] Restricted access to production payment gateway dashboard (MFA enforced for all team members)
