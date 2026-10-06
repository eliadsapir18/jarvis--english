# Free-tier, private deployment

Goal: Jarvis running 24/7 on a free-tier VM, reachable only by you.

## What is free, and what is not

| Item | Cost |
|---|---|
| Tailscale personal plan (private network + HTTPS) | free |
| The VM on a cloud "always free" tier | free **within the provider's limits** — check the provider's current terms |
| Account sign-up | most providers require a **credit/debit card for identity verification** (often a temporary hold; no charge if you stay inside the free resources). **Your decision — nothing here does it for you.** |
| Model API usage (Gemini/OpenAI/Anthropic/...) | billed by that provider per use. A local model (Ollama) is free but needs a stronger machine than a 1 GB VM |
| This repo / scripts | free |

Pitfalls to watch: free VMs are small (about 1 GB RAM — the script adds swap), some
providers only offer the free tier in certain regions, and a VM left running
past the free limits (extra disks, public IPs, bigger shapes) can start billing.
Set a budget alert at your provider.

## Steps

1. Create a free Tailscale account and an **auth key**
   (https://login.tailscale.com/admin/settings/keys — reusable off, expiry short).
2. Create the free-tier VM (Ubuntu 22.04/24.04). You do not need to open any
   inbound ports — leave only the default SSH rule for the first login.
3. SSH in and run:
   ```bash
   sudo apt-get update && sudo apt-get install -y git
   git clone --depth 1 https://github.com/eliadsapir18/jarvis--english /tmp/j
   sudo TS_AUTHKEY=tskey-auth-XXXX bash /tmp/j/deploy/free-tier/setup.sh
   ```
4. Edit `/opt/jarvis/.env`, add **one** model key (e.g. `GEMINI_API_KEY=...`),
   then `cd /opt/jarvis && sudo docker compose up -d`.
5. From a device signed in to your Tailscale, open the HTTPS address the script
   prints. Remove the provider's public SSH rule afterwards — Tailscale SSH
   (`ssh jarvis`) replaces it.

## Security in place

- Firewall denies all inbound; only the private Tailscale interface is allowed.
- App listens on `127.0.0.1` only; Tailscale serves HTTPS to your devices.
- Random 256-bit control key generated on the VM; `.env` is `chmod 600`.
- Containers run non-root with `no-new-privileges`; automatic OS security
  updates and fail2ban enabled; no secrets in git.

## Not yet verified

The script was syntax-checked and the compose file validated, but it has **not
been run on a real VM** (no cloud access from the authoring sandbox). Run it
once and send me any error output.
