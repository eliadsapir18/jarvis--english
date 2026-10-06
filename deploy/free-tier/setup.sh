#!/usr/bin/env bash
# One-shot, idempotent setup of a private Jarvis on a fresh Ubuntu/Debian VM
# (e.g. a cloud "always free" instance). Run as root:
#
#   sudo TS_AUTHKEY=tskey-auth-xxxxx bash setup.sh
#
# Security model: NOTHING is exposed to the internet. The firewall denies all
# inbound traffic; you reach Jarvis only through your private Tailscale network
# (free personal plan), over HTTPS (so the browser microphone works).
# Costs: this script buys nothing. Hosted-model API usage is billed by the
# provider whose key you add.
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root (sudo)"; exit 1; }
: "${TS_AUTHKEY:?Set TS_AUTHKEY (Tailscale auth key, https://login.tailscale.com/admin/settings/keys)}"
REPO="${JARVIS_REPO:-https://github.com/eliadsapir18/jarvis--english}"
DIR="${JARVIS_DIR:-/opt/jarvis}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl git ufw fail2ban unattended-upgrades openssl

# Docker (official convenience script) and Tailscale
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh
command -v tailscale >/dev/null || curl -fsSL https://tailscale.com/install.sh | sh

# Small free-tier VMs (~1 GB RAM): add swap so the image build/startup do not OOM
if [ "$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)" -lt 1800 ] && [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Automatic security updates + brute-force protection
dpkg-reconfigure -f noninteractive unattended-upgrades || true
systemctl enable --now fail2ban

# Join your private network
tailscale up --authkey "$TS_AUTHKEY" --ssh --hostname "${TS_HOSTNAME:-jarvis}"

# Firewall: deny all inbound; allow only traffic arriving over Tailscale.
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow in on tailscale0
ufw --force enable

# Get/refresh the code
if [ -d "$DIR/.git" ]; then git -C "$DIR" pull --ff-only; else git clone --depth 1 "$REPO" "$DIR"; fi
cd "$DIR"

# Secrets live only in /opt/jarvis/.env on this VM (chmod 600, never committed)
if [ ! -f .env ]; then
  umask 077
  printf 'JARVIS_CONTROL_API_KEY=%s\n' "$(openssl rand -hex 32)" > .env
  echo "# add ONE model key, e.g. GEMINI_API_KEY=..., then: docker compose up -d" >> .env
  echo "Created $DIR/.env — edit it to add your model API key."
fi
chmod 600 .env

docker compose up --build -d

# HTTPS inside your tailnet only (not the public internet)
tailscale serve --bg --https=443 http://127.0.0.1:8000

echo
echo "Done. Open https://$(tailscale status --json | python3 -c 'import sys,json;print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))') from a device on your tailnet."
