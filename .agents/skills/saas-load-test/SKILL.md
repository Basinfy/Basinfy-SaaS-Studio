---
name: saas-load-test
description: "High-concurrency load, stress, and endurance soak test protocol for SaaS endpoints — simulates virtual users, monitors p95/p99 latency, RPS, connection pool limits, and memory leaks."
argument-hint: "[duration: 15m | 30m | 1h | 2h | 4h] [focus: concurrency | latency | memory | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/saas-load-test/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys locale,automation,workflow`

**Automation mode**: Resolve `modes.automation` (`project.local.yaml` →
`project.yaml` → default `collaborative`). Every `AskUserQuestion` call and
every file write follows `.claude/docs/automation-modes.md`
(collaborative asks always · guided major-only · autonomous logs and proceeds;
`automation_always_ask` categories always prompt).

# SaaS Load & Endurance Soak Test Protocol

> **Interaction Localization Rule**:
> When `locale: pt-BR` (or user speaks Portuguese), ALL questions (`AskUserQuestion` / `ask_question`), confirmation prompts, and selectable options MUST be translated and presented in **Brazilian Portuguese (PT-BR)**.
> Any English question text or options in this skill are illustrative examples — NEVER display English questions or options to a Portuguese developer.
> Internal reasoning, code synthesis, tests, and documentation files MUST remain in English.

> **Engineering Standard (skills.sh Reference: `k6-load-testing` & `artillery-soak`)**:
> A SaaS load test (also called an endurance or soak test) executes automated synthetic user traffic
> against web APIs and frontend routes to validate operational stability under sustained traffic.
> Unlike a smoke check (single happy-path request, ~1 min) or unit/integration tests, a load test runs for
> **15 minutes to several hours** under high concurrency to surface:
>
> - **Server Memory Leaks** — gradual process heap growth or unbounded caching that causes OOM crashes after hours of traffic
> - **Database Connection Pool Exhaustion** — connection leaks or pool starvation under concurrent queries
> - **Latency Drift & Degradation** — p95 and p99 response times worsening as table sizes and worker queues grow
> - **Rate-Limiter & Webhook Backpressure** — queue overflows, worker starvation, and dead-letter queue growth
> - **Third-Party API Bottlenecks** — rate limit throttling from Stripe, Resend, OpenAI, or auth providers under sustained RPS

**Output:** `production/qa/saas-load-test-[date]-[duration].md`

**When to run:**
- Polish phase — before `/saas-gate-check release`
- Pre-launch or major version cut — validating production SLA thresholds
- After refactoring database models, caching, or high-throughput API endpoints
- After addressing a production memory leak or connection starvation incident

---

## 1. Parse Arguments

**Duration** (default: `30m`):
- `15m` — short load check; suitable for smoke load testing a single API route
- `30m` — standard soak; verifies connection pool stability and basic heap recycling
- `1h` — extended soak; recommended for first pre-release Polish audit
- `2h–4h` — deep production endurance soak; verifies multi-tenant isolation, cache recycling, and OOM resilience

**Focus** (default: `all`):
- `concurrency` — focus on virtual users (VUs), throughput (RPS), connection pool headroom
- `latency` — focus on p95/p99 response times and API timeout rates
- `memory` — focus on process heap size, container RSS, GC pauses, leak trends
- `all` — comprehensive audit covering all dimensions

---

## 2. Load Context & Performance Budgets

Read:
- `project.yaml` — `performance.*` targets:
  - `api_p95_latency_ms` (default: 250ms)
  - `max_initial_bundle_kb` (default: 200KB)
  - `target_lcp_ms` (default: 2000ms)
- `project.yaml` — `stack.*` (identifies backend framework, database, and auth provider)
- `tests/` or `scripts/` — existing load test scripts (e.g. k6 scripts, artillery yaml, locustfile)
- Prior test reports in `production/qa/`

Define the performance criteria:
- **Throughput target**: [N requests/second (RPS)]
- **Target Concurrent Virtual Users (VUs)**: [e.g., 50–500 VUs]
- **Latency ceiling (p95)**: [e.g., < 250ms]
- **Latency ceiling (p99)**: [e.g., < 500ms]
- **Error rate ceiling (5xx/4xx)**: [< 0.1%]
- **Memory growth limit**: [< 15% increase after initial warm-up]

---

## 3. Define Timed Checkpoints

Generate observation intervals based on duration:
- **15m soak**: T+0, T+5, T+10, T+15
- **30m soak**: T+0, T+10, T+20, T+30
- **1h soak**: T+0, T+15, T+30, T+45, T+60
- **2h soak**: T+0, T+30, T+60, T+90, T+120
- **4h soak**: T+0, T+60, T+120, T+180, T+240

---

## 4. Execution Guidance & Tooling Harness

### Tool Selection:
1. **k6 (Recommended standard)**:
   ```bash
   k6 run --vus 50 --duration [duration] scripts/load-test.js
   ```
2. **Autocannon / Artillery** (Node.js environments):
   ```bash
   npx autocannon -c 100 -d [duration_sec] http://localhost:3000/api/health
   ```
3. **Locust** (Python / FastAPI environments):
   ```bash
   locust -f tests/load/locustfile.py --headless -u 100 -r 10 --run-time [duration]
   ```

### Metric Collection:
- **Process Memory**: Node.js `process.memoryUsage().heapUsed` / Python `tracemalloc` / container RSS memory via `docker stats`
- **Database Metrics**: Active connections, idle connections, waiting queries from PostgreSQL `pg_stat_activity`
- **HTTP Status Codes**: 2xx count, 4xx count, 5xx count

---

## 5. Generate Protocol Document

Create the structured report template in `production/qa/saas-load-test-[date]-[duration].md`:

```markdown
# SaaS Load & Endurance Soak Test Report

> **Date**: [YYYY-MM-DD]
> **Duration**: [duration]
> **Focus**: [concurrency | latency | memory | all]
> **Stack**: [Frontend / Backend / Database]
> **Tool Used**: [k6 / Artillery / Locust / Autocannon]
> **Generated by**: /saas-load-test

---

## Pre-Session Configuration

- [ ] Target environment isolated (staging/load environment or dedicated container)
- [ ] Database seeded with realistic data volume (users, tenants, invoices)
- [ ] Monitoring active (Datadog / Prometheus / CloudWatch / Docker stats)
- [ ] Connection pool limits verified (e.g., Postgres max_connections: 100)

---

## Baseline (T+0)

| Metric | Target / Ceiling | Baseline Value (T+0) |
|--------|------------------|----------------------|
| Concurrent Virtual Users (VUs) | [N VUs] | [baseline] |
| Throughput (RPS) | [Target RPS] | [baseline] |
| p95 Latency (ms) | < 250 ms | [baseline] |
| p99 Latency (ms) | < 500 ms | [baseline] |
| Error Rate (%) | < 0.1% | 0.0% |
| Memory (Heap/RSS) | < 512 MB | [baseline] |
| DB Active Connections | < Pool Max | [baseline] |

---

## Checkpoint Log

### Checkpoint T+[N] min
- **Virtual Users**: [N]
- **Current RPS**: [N]
- **p95 Latency**: [N ms]
- **p99 Latency**: [N ms]
- **Error Rate (4xx/5xx)**: [N%]
- **Server Memory (RSS)**: [N MB] (Δ from T+0: [N%])
- **DB Connection Pool**: [N active / N idle]
- **Status / Anomaly**: [None / latency spike / connection timeout]

---

## Post-Session Analysis & SLA Evaluation

| Metric | Target | Peak Observed | Final (T_end) | SLA Met? |
|--------|--------|---------------|---------------|----------|
| Throughput (RPS) | [N] | [N] | [N] | [YES / NO] |
| p95 Latency | < 250ms | [N ms] | [N ms] | [YES / NO] |
| p99 Latency | < 500ms | [N ms] | [N ms] | [YES / NO] |
| 5xx Error Rate | < 0.1% | [N%] | [N%] | [YES / NO] |
| Memory Stability | No steady leak | [N MB] | [N MB] | [STABLE / LEAK] |

### Bottlenecks & Issues Identified
- **Issue 1**: [Description, root cause, and remediation plan]

---

## Verdict: PASS / PASS WITH CONCERNS / NOT ASSESSED / FAIL

- **PASS**: All routes met p95/p99 SLAs, zero connection pool starvation, memory recycled cleanly
- **PASS WITH CONCERNS**: Minor latency spikes under peak concurrency; addressable before launch
- **NOT ASSESSED**: Test stopped before reaching steady-state duration
- **FAIL**: Unhandled 5xx errors > 0.1%, server OOM crash, or sustained connection pool lockup
```

---

## 6. Write Output

Present the protocol summary to the developer and ask:
"May I write this SaaS load test protocol to `production/qa/saas-load-test-[date]-[duration].md`?"
