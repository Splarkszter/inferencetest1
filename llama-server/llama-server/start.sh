#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by docker-compose / Coolify env vars)
MODEL_PATH=${MODEL_PATH:-/models/model.gguf}
MODEL_URL=${MODEL_URL:-}
HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN:-}
THREADS=${THREADS:-}
CONTEXT=${CONTEXT:-8192}
HOST=${HOST:-0.0.0.0}
PORT=${PORT:-8080}

# helper: download model if MODEL_URL provided and file missing
download_model() {
  if [ -n "$MODEL_URL" ] && [ ! -f "$MODEL_PATH" ]; then
    echo "[start] MODEL_URL set — downloading model to $MODEL_PATH ..."
    mkdir -p "$(dirname "$MODEL_PATH")"
    # use curl with optional HF token header
    if [ -n "$HUGGINGFACE_TOKEN" ]; then
      curl -L -H "Authorization: Bearer $HUGGINGFACE_TOKEN" "$MODEL_URL" -o "$MODEL_PATH"
    else
      curl -L "$MODEL_URL" -o "$MODEL_PATH"
    fi
    echo "[start] Download finished."
  fi
}

# if threads unset, detect
if [ -z "$THREADS" ]; then
  # nproc exists in base images
  if command -v nproc >/dev/null 2>&1; then
    THREADS=$(nproc)
  else
    THREADS=1
  fi
fi

# attempt model download if needed
download_model

# verify model exists
if [ ! -f "$MODEL_PATH" ]; then
  echo "[start] ERROR: model file not found at $MODEL_PATH"
  echo "[start] Place a GGUF model in the /models directory or set MODEL_URL to a direct download URL."
  ls -lah /models || true
  exit 1
fi

echo "[start] Starting llama-server with:"
echo "  model: $MODEL_PATH"
echo "  threads: $THREADS"
echo "  context: $CONTEXT"

# run the server (OpenAI-compatible)
# the binary path after make should be ./main/llama-server
exec ./main/llama-server -m "$MODEL_PATH" --host "$HOST" --port "$PORT" -t "$THREADS" -c "$CONTEXT"
