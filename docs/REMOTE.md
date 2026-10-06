# Running your Jarvis remotely

Jarvis runs headless on any machine that can run Docker (or Python 3.11+) and
is used from your browser. **Nothing in this repo buys or provisions hosting** —
you choose where it runs. Hosted model providers bill per use; keys are yours.

## 1. Docker (recommended)

```bash
git clone https://github.com/eliadsapir18/jarvis--english && cd jarvis--english
export JARVIS_CONTROL_API_KEY=$(openssl rand -hex 32)   # required; keep it secret
export GEMINI_API_KEY=...     # or ANTHROPIC_API_KEY / OPENAI_API_KEY / OPENROUTER_API_KEY
docker compose up --build -d
```

Open http://localhost:8000. On first boot the container copies
`jarvis.toml.example` (English) to the persisted volume as `jarvis.toml`; edits
you make there are never overwritten. Data lives in the `jarvis-data` volume.

## 2. Reaching it from your phone/laptop — do NOT expose port 8000 publicly

The control key is the only protection, so keep the port on loopback
(`127.0.0.1:8000`, the compose default) and reach it through a tunnel:

- **SSH tunnel:** `ssh -L 8000:127.0.0.1:8000 you@your-server`, then open
  http://localhost:8000.
- **Tailscale** (free personal tier) or similar private network: install it on
  the server and your devices, then open the server's private address.

Microphone access from a browser needs HTTPS; `localhost` through an SSH tunnel
counts as secure.

## 3. Where to run it (free options first)

| Option | Cost |
|---|---|
| An always-on computer or spare machine at home | free |
| A cloud VM's always-free tier, if you already have an account | free tier |
| A small paid VPS | paid — **decide yourself; I will not buy anything** |

## 4. Without Docker

```bash
python3 -m venv ~/jarvis-venv && ~/jarvis-venv/bin/pip install -e .
cp jarvis.toml.example jarvis.toml
JARVIS_NONINTERACTIVE=1 ~/jarvis-venv/bin/python -m jarvis.ui.web.launcher --headless --port 8000
```

See `docs/headless-vps-deployment.md` (upstream) for a systemd service and what
degrades on a headless host (no local wake word, no screen control).

## Verified

The seeding entrypoint and the headless server start were tested natively
(`/api/health` → ok; second start keeps your edits). The Docker image itself was
**not built** in the authoring sandbox (no Docker daemon) — run
`docker compose build` once and report any error.
