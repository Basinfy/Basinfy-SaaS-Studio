# Brand Voice, Tone & Audio Alerts Guide: [Project Name]

> **Status**: [Draft | In Review | Approved]
> **Owner**: [Lead Product Manager / UX Content Strategist]
> **Last Updated**: [YYYY-MM-DD]
> **Template**: Brand Voice, Tone & Audio Alerts Guide

---

## 1. Brand Voice Principles

Define 3-4 foundational voice characteristics:
1. **Clear & Direct**: Prioritize brevity and comprehension over cleverness. No corporate jargon.
2. **Empowering & Helpful**: Treat the user as a competent professional; explain *what* happened and *how to proceed*.
3. **Calm & Confident**: Avoid alarmist phrasing even during critical system errors or downtime.
4. **Delightful in Context**: Subtle celebration during achievements (e.g., first deployment, successful invoice payment), never intrusive.

---

## 2. Tone Matrix by Context

| User Context | Goal | Tone Characteristics | Example Phrasing |
|---|---|---|---|
| Landing & Marketing | Inspire & convert | Confident, forward-looking, value-driven | "Deploy fullstack applications in seconds, not sprints." |
| Product Onboarding | Guide & activate | Encouraging, step-by-step, welcoming | "Welcome aboard! Let's connect your first GitHub repository." |
| Day-to-Day Tasks | Speed & focus | Neutral, concise, invisible | "3 invoices exported to CSV." |
| Errors & Validation | Inform & unblock | Empathetic, precise, actionable | "Unable to connect to Stripe. Please verify your API keys in Settings." |
| Billing & Payments | Transparent & fair | Honest, respectful, clear numbers | "Your Pro subscription will renew on May 1st for $29/mo." |

---

## 3. UX Microcopy Standards

- **Buttons & Actions**: Start with strong verbs (`Create workspace`, `Invite member`, `Export report`). Avoid vague labels like `Submit` or `Click here`.
- **Empty States**: Structure as: (1) What is missing, (2) Why it matters, (3) Direct action button.
  - *Example*: "No API keys created yet. Create a secret key to authenticate your server requests. [Create API Key]"
- **Destructive Confirmations**: State the exact entity and consequence.
  - *Example*: "Are you sure you want to delete **Production DB**? This action cannot be undone."

---

## 4. UI Audio Alerts & Sound Design (Optional)

When the application uses audio cues for feedback:

| Event | Audio Role | Character / Frequency | Default Setting |
|---|---|---|---|
| Success / Task Complete | Positive reinforcement | Subtle, warm chime (< 200ms) | Enabled (soft) |
| System Warning / Error | Notice of required action | Low, non-jarring tone (< 300ms) | Enabled (soft) |
| Incoming Chat / Notification | Urgent communication | Clean double-ping (< 250ms) | Muted by default |

### Audio Accessibility Rules:
- All audio alerts MUST have a visual equivalent (toast alert, badge, or banner).
- Provide a global toggle in user preferences: `Enable sound effects: On / Off`.
- Respect system reduced-motion and silence settings.

---

## 5. Review & Approval

- **UX Content Strategist**: Approved
- **Design System Director**: Approved
