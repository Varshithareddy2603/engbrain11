#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
pip install -r backend/requirements.txt -q
echo "Starting EngBrain (development only)"
exec uvicorn backend.main:app --host 0.0.0.0 --port "${PORT:-8000}" --reload
