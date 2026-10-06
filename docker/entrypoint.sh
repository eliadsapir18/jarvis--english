#!/bin/sh
# Seed the English-first config into the persisted data volume on first boot.
# An existing /app/data/jarvis.toml (your edits) is never overwritten.
set -eu
CFG="${JARVIS_CONFIG:-/app/data/jarvis.toml}"
if [ ! -f "$CFG" ]; then
  mkdir -p "$(dirname "$CFG")"
  cp /app/jarvis.toml.example "$CFG"
  echo "[entrypoint] seeded English config -> $CFG"
fi
exec "$@"
