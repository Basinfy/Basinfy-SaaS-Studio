# Platform Requirements

One block per platform the release checklist's platform argument names (`web`,
`cloud`, `mobile`; `all` is all three). Copy only the blocks named.

### Platform Requirements: Web
- [ ] Cross-browser compatibility verified (Chrome, Firefox, Safari, Edge)
- [ ] Responsive layouts verified across desktop and mobile viewports
- [ ] Keyboard navigation and accessibility (WCAG 2.1 AA) audited
- [ ] Core Web Vitals (LCP, FID/INP, CLS) within production thresholds
- [ ] Progressive Web App (PWA) manifest and service worker verified (if applicable)
- [ ] Client-side error tracking and session replay initialized

### Platform Requirements: Cloud & Backend
- [ ] Environment secrets and credentials verified in production secret store
- [ ] Database migrations executed and backward compatibility confirmed
- [ ] Container health check and readiness/liveness probes operational
- [ ] Rate limiting, CORS policies, and security headers configured
- [ ] APM, structured logging, and alert monitors active in production

### Platform Requirements: Mobile & PWA
- [ ] App store guidelines or PWA install criteria compliance verified
- [ ] Touch gestures, drawers, and modal transitions responsive across devices
- [ ] Privacy policy linked, accurate, and GDPR/CCPA compliant
- [ ] Offline caching and network retry handling functional
- [ ] Push notification delivery and permission prompts verified
