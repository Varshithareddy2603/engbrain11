# EngBrain

**AI Engineering Organizational Memory Agent**

> “EngBrain doesn’t just understand your code. It remembers why your code became the way it is.”

## What it does

EngBrain answers three questions every engineer asks:

1. **Why does this code exist?**
2. **Have we seen this problem before?**
3. **What should I know before changing this?**

The differentiator is **persistent Hindsight memory**: commits, PRs, incidents, deployments, root causes, fixes, and architecture decisions — linked and searchable.

## Architecture

```
GitHub + Engineering Data
          ↓
   Hindsight Memory
          ↓
   Engineering Agent
          ↓
       /ask API
          ↓
      Frontend UI
```

## Production: Hindsight Cloud

This version uses **Hindsight Cloud** for persistent semantic memory. The API key is
read from `HINDSIGHT_API_KEY`; it is never stored in the repository.

### 1. Create a Hindsight Cloud API key

Create an API key in Hindsight Cloud and copy it once. Hindsight Cloud uses bearer
authentication and the official Python SDK.

### 2. Configure environment variables

```bash
HINDSIGHT_API_KEY=hsk_...
HINDSIGHT_BASE_URL=https://api.hindsight.vectorize.io
HINDSIGHT_BANK_ID=engbrain-engineering
```

Never commit `.env` or a real API key.

### 3. Seed the cloud memory bank once

```bash
cd engbrain/backend
pip install -r requirements.txt
python seed_hindsight.py
```

The script uploads the engineering records from `data/sample_data.json` to the
persistent Hindsight Cloud bank.

### 4. Deploy EngBrain

The repository includes a `Dockerfile` and `render.yaml`. Deploy the repository
as a Docker web service and add the same `HINDSIGHT_API_KEY` as a secret/environment
variable in the hosting platform.

After deployment, open the public service URL. The frontend and `/api/*` routes
are served by the same service, so the browser does not use `localhost`.

### Local development

Local execution is still possible for development, but **memory retrieval is cloud-backed**
when `HINDSIGHT_API_KEY` is configured.

## Core demo (2 minutes)

1. Open the **Dashboard** → click the demo buttons, or go to **Ask EngBrain**.
2. Ask:

   > Why does the retry logic in payment_service.py exist?

   EngBrain traces: **Code → Commit → PR → Incident → Root Cause → Fix** (INC-2025-0310 → PR-42 → ADR-007).

3. Then ask:

   > What should I know before changing the retry logic in payment-service?

   The answer combines GitHub history, three incidents, deployments, ADR-007, and Hindsight lessons (max attempts = 3, circuit breaker required, retry-rate is a leading indicator).

### Hindsight growth path

| Interaction | Question | What memory contributes |
|-------------|----------|-------------------------|
| 1 | What happened with payment-service? | Service history + incidents |
| 5 | Have we seen this timeout before? | Similar-incident search |
| 10 | What caused previous failures? | Root causes + linked PRs |
| 20 | What should I know before changing this? | Full evidence graph |

## Sample data

5 services · 8 commits · 8 PRs · 5 incidents · 8 deployments · 3 ADRs · 5 memory lessons

Canonical relationship for the core demo:

```
PR-42 → Commit a1b2c3 → payment-service → Deploy v2.4.0
       → INC-2025-0310 → Root cause (no backoff) → Fix (exponential backoff)
       → ADR-007 (retry policy)
```

Later refinements: PR-87 (max attempts 5→3 after latency regression), PR-112 (circuit breaker after thundering herd), PR-134 (retry metrics).

## API

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/ask` | Ask EngBrain (body: `{ "question": "..." }`) |
| GET | `/api/health` | Memory stats |
| GET | `/api/services` | List services |
| GET | `/api/services/{id}` | Full service history |
| GET | `/api/incidents` | List incidents |
| GET | `/api/incidents/{id}` | Incident + related PRs/commits |
| GET | `/api/timeline` | Unified engineering timeline |
| GET | `/api/memory` | Hindsight lessons |
| GET | `/api/tools` | Agent tool catalogue |

Answers always include **source IDs**. Historical facts are never invented — only retrieved.

## Agent tools

- `search_memory` — keyword search across all Hindsight stores
- `get_file_history` — commits that touched a file
- `find_similar_incidents` — past incidents matching a problem description
- `get_service_history` — commits, PRs, incidents, deployments, ADRs, lessons
- `get_deployment_history` — recent deploys

## Project layout

```
engbrain/
├── backend/
│   ├── main.py          # FastAPI app + routes
│   ├── agent.py         # Tools + grounded answer synthesis
│   ├── data_loader.py   # Sample data + indexes
│   └── requirements.txt
├── data/
│   └── sample_data.json # Connected realistic history
├── frontend/
│   ├── index.html
│   ├── styles.css
│   └── app.js
└── README.md
```

## Team split (hackathon)

| Person | Owns |
|--------|------|
| 1 | Hindsight memory, agent tools, `/ask` API |
| 2 | Sample data model, frontend UI |

Keep it small, polished, and demo-ready. No unnecessary infrastructure.


## Hindsight Cloud configuration

- `HINDSIGHT_API_KEY` — required secret.
- `HINDSIGHT_BASE_URL` — defaults to `https://api.hindsight.vectorize.io`.
- `HINDSIGHT_BANK_ID` — defaults to `engbrain-engineering`.
- `HINDSIGHT_TIMEOUT` — request timeout in seconds.

`search_memory()` calls Hindsight Cloud `recall()` instead of the old local keyword
search. The existing JSON dataset remains as structured source data for deterministic
dashboard relationships and evidence cards.

The cloud bank is populated separately with `backend/seed_hindsight.py`, which avoids
silently duplicating memories every time the web service restarts.
