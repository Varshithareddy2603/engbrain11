# Deploy EngBrain with Hindsight Cloud

## A. Hindsight Cloud

1. Sign in to Hindsight Cloud.
2. Create a memory bank named `engbrain-engineering` (or choose your own ID).
3. Create an API key. For production, restrict the key to this bank if possible.
4. Keep the key secret. Do not put it in GitHub or the frontend.

## B. Seed the memory bank

From the project root:

```bash
cd backend
pip install -r requirements.txt
```

Set:

```bash
HINDSIGHT_API_KEY=hsk_...
HINDSIGHT_BASE_URL=https://api.hindsight.vectorize.io
HINDSIGHT_BANK_ID=engbrain-engineering
```

Then:

```bash
python seed_hindsight.py
```

## C. Deploy the web app

This project includes `Dockerfile` and `render.yaml`.

On Render:

1. Create a new Web Service from the Git repository.
2. Use the Docker runtime.
3. Add environment variable `HINDSIGHT_API_KEY` as a secret.
4. Add:
   - `HINDSIGHT_BASE_URL=https://api.hindsight.vectorize.io`
   - `HINDSIGHT_BANK_ID=engbrain-engineering`
5. Deploy.

The browser will use the same public URL for the frontend and `/api/ask`; there is no
`localhost` dependency in production.

## D. Verify

Open:

```text
https://YOUR-SERVICE.onrender.com/api/health
```

You should see:

```json
"hindsight": {
  "configured": true,
  "provider": "hindsight-cloud",
  "base_url": "https://api.hindsight.vectorize.io",
  "bank_id": "engbrain-engineering"
}
```

Then open the root URL and ask:

> What engineering incidents have happened before, and how were they resolved?

The semantic memory lookup is performed against Hindsight Cloud.
