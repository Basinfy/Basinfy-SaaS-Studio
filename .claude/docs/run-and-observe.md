# Run and Observe: Headless Verification & Browser Capture

This guide explains how agents and automated tests launch the SaaS application locally,
verify health status endpoints, and capture visual UI screenshots using headless browser automation.

---

## 1. Running the Local Dev Server

Launch the application using standard stack commands:
```bash
# Next.js Fullstack (default port 3000)
npm run dev

# FastAPI / Python (port 8000)
uvicorn main:app --reload --port 8000
```

---

## 2. Headless Healthcheck & API Observation

Verify application startup and database connectivity:
```bash
# Verify health endpoint returns 200 OK
curl -s -f http://localhost:3000/api/health || exit 1

# Inspect JSON response payload
curl -s http://localhost:3000/api/health
```

---

## 3. Visual UI Screen Capture with Playwright

Capture headless viewport screenshots for design review and visual regression testing:
```bash
# Full page screenshot of dashboard
npx playwright screenshot --url http://localhost:3000/dashboard --full-page production/screenshots/dashboard-full.png

# Viewport screenshot of login screen
npx playwright screenshot --url http://localhost:3000/login production/screenshots/login.png
```

---

## 4. Troubleshooting Local Dev Runs

- **Port in use (EADDRINUSE)**: Check if another node process is running: `lsof -i :3000` or `netstat -ano | findstr 3000`.
- **Environment variables**: Verify `.env.local` contains valid connection strings (`DATABASE_URL`, `NEXTAUTH_SECRET`).
