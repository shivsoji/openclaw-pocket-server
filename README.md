# 🦞 OpenClaw 24/7 Pocket Server

<img src="docs/images/banner.png" alt="OpenClaw 24/7 Pocket Server">

> Turn any Android phone into a **24/7 AI server** — one command, zero hassle.

![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B-brightgreen)
![Termux](https://img.shields.io/badge/Termux-Required-orange)
![No proot](https://img.shields.io/badge/proot--distro-Not%20Required-blue)
![SSH](https://img.shields.io/badge/SSH-Port%208022-blueviolet)
![License MIT](https://img.shields.io/badge/License-MIT-yellow)

An enhanced, battle-tested installer for [OpenClaw](https://openclaw.ai) on Android via Termux. Runs natively — no proot, no Ubuntu, no bloat.

## Why a Phone?

- **Low power + built-in UPS** — runs 24/7 on minimal power; battery survives outages
- **Repurpose old phones** — put that spare phone to work instead of buying a mini PC
- **Sufficient performance** — even older models handle OpenClaw easily
- **Zero risk** — factory-reset a spare phone, no personal data involved

## What's Included

| Feature | Details |
|---|---|
| 🦞 OpenClaw | Latest version, auto-installed |
| 🔒 SSH Server | Auto-configured, port `8022`, default password `1234` |
| 🖥️ tmux Session | Persistent `OpenClaw` session for the gateway |
| 🔄 Auto-Start | Termux:Boot script for restart recovery |
| 📸 Image Processing | `sharp` native module built from source |
| 🔧 Native Fixes | `renameat2`, `ar` symlink, `--disable-warning` bypass |
| ⚡ Wakelock | Prevents Android from killing the process |

## Required Apps

Install these from **F-Droid** (NOT the Play Store):

| App | Version | Download |
|---|---|---|
| **Termux** | 0.118.3+ | [F-Droid](https://f-droid.org/en/packages/com.termux/) |
| **Termux:Boot** | 0.8.1+ | [F-Droid](https://f-droid.org/en/packages/com.termux.boot/) |
| **Termux:API** | 0.53.0+ | [F-Droid](https://f-droid.org/en/packages/com.termux.api/) |

> ⚠️ The Play Store version of Termux is discontinued and will **not** work.

> After installing Termux:Boot, **open it once** to grant boot permissions.

## Quick Install (One Command)

Open Termux and paste:

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/openclaw-pocket-server/main/bootstrap.sh | bash && source ~/.bashrc
```

That's it. The installer handles everything:

1. ✅ Installs Node.js, npm, build tools, tmux, SSH
2. ✅ Installs OpenClaw globally
3. ✅ Patches for Android compatibility (renameat2, paths, platform)
4. ✅ Builds `sharp` for image processing
5. ✅ Configures SSH server (port 8022, password `1234`)
6. ✅ Sets up Termux:Boot auto-start script
7. ✅ Runs verification checks

## After Installation

### Step 1: Configure OpenClaw

```bash
openclaw onboard
```

Follow the interactive wizard to set your AI provider (Google, OpenRouter, Copilot, etc.).

### Step 2: Start the Gateway

Create a persistent tmux session and start the gateway:

```bash
tmux new-session -s OpenClaw
openclaw gateway
```

**Detach** (keep running in background): `Ctrl+B` then `D`

**Reattach** later:
```bash
tmux attach -t OpenClaw
```

### Step 3: Connect from Your PC

```bash
ssh -p 8022 <username>@<phone-ip>
```

Default password: `1234`

> Find your phone's IP: run `ifconfig` in Termux and look for `wlan0` → `inet`.

### Step 4: Access the Dashboard

Set up an SSH tunnel from your PC:

```bash
ssh -N -L 18789:127.0.0.1:18789 -p 8022 <username>@<phone-ip>
```

Then open in your browser: `http://localhost:18789/`

> Run `openclaw dashboard` on the phone to get the full URL with token.

## SSH Setup

### Change Password

The default password is `1234`. Change it:

```bash
passwd
```

### Use SSH Keys (Recommended)

On your PC, generate a key and copy it:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/openclaw_key -N ""
ssh-copy-id -i ~/.ssh/openclaw_key.pub -p 8022 <username>@<phone-ip>
```

Connect without password:

```bash
ssh -i ~/.ssh/openclaw_key -p 8022 <username>@<phone-ip>
```

## Remote Access with Tailscale (Optional)

Want to access your OpenClaw server from **anywhere in the world** — not just your local WiFi? Use [Tailscale](https://tailscale.com/).

Tailscale creates a secure private network (tailnet) between your devices. No port forwarding, no dynamic DNS, no firewall headaches.

### Install Tailscale on Your Phone

1. Install [Tailscale from Google Play](https://play.google.com/store/apps/details?id=com.tailscale.ipn) or [F-Droid](https://f-droid.org/packages/com.tailscale.ipn/)
2. Open the Tailscale app → Sign in with your account
3. Toggle the VPN **ON**
4. Note your phone's Tailscale IP (it will be `100.x.x.x`)

> 💡 Install Tailscale on your PC/laptop too — both devices must be on the same tailnet.

### Mode 1: Tailnet-Only (Serve) — Recommended

Access your dashboard securely from any device on your tailnet:

```bash
openclaw gateway --tailscale serve
```

Or set it in config (`~/.openclaw/openclaw.json`):

```json
{
  "gateway": {
    "bind": "loopback",
    "tailscale": { "mode": "serve" }
  }
}
```

Then open `https://<your-phone-magicDNS>/` from any device on your tailnet.

### Mode 2: Public Internet (Funnel)

Expose your server to the **public internet** via Tailscale Funnel (HTTPS):

```bash
openclaw gateway --tailscale funnel --auth password
```

> ⚠️ Funnel requires a shared password (`OPENCLAW_GATEWAY_PASSWORD` env var or config). Never expose without auth!

### Mode 3: Direct Tailnet IP

Bind the gateway directly to your Tailnet IP (no Serve/Funnel):

```json
{
  "gateway": {
    "bind": "tailnet",
    "auth": { "mode": "token", "token": "your-token" }
  }
}
```

Connect from another device: `http://<tailscale-ip>:18789/`

### Tailscale Requirements

- Tailscale CLI installed and logged in
- Funnel needs: Tailscale v1.38.3+, MagicDNS, HTTPS enabled
- Funnel only supports ports `443`, `8443`, `10000`

> 📖 Full Tailscale docs: [OpenClaw Tailscale Guide](https://github.com/openclaw/openclaw/blob/main/docs/gateway/tailscale.md)

## Security

Running OpenClaw on a **dedicated Android phone** already gives you significant security advantages over a bare-metal PC or VPS setup:

### ✅ What's Already Secured

| Layer | Protection | Details |
|---|---|---|
| 🏗️ **Physical Isolation** | Your main PC is never at risk | OpenClaw runs on a separate phone — compromise doesn't spread to your laptop/desktop |
| 📱 **Android Sandbox** | Termux is sandboxed by Android | Even if compromised, it can't access other apps, photos, or system files |
| 🔒 **Localhost Binding** | Gateway only listens on `127.0.0.1` | Port 18789 is never exposed to the public internet |
| 🚫 **No Root Required** | Runs in Termux user space | No root privileges = smaller attack surface |
| 🔑 **SSH Protected** | Password-based auth on port `8022` | Not the default port 22, reduces automated scan risk |
| 🗑️ **Burner Device** | Factory-reset an old phone | Zero personal data on the server device |
| ⚙️ **No systemd** | Our `systemctl` stub prevents accidental service exposure | Services can't be enabled/disabled by the AI agent |

### ⚠️ What You Should NEVER Connect

Regardless of how well you harden your setup, **never** connect these to OpenClaw:

- ❌ Primary email accounts
- ❌ Banking or financial services
- ❌ Password managers (1Password, Bitwarden)
- ❌ Work accounts (Slack, Google Workspace, corporate)
- ❌ Social media with irreplaceable history
- ❌ Cryptocurrency wallets/exchanges
- ❌ Government or healthcare portals
- ❌ Your primary GitHub account

### ✅ Acceptable Connections (Burner Only)

- ✅ Dedicated Gmail created **only** for OpenClaw notifications
- ✅ Telegram bot account (not your personal Telegram)
- ✅ Development-only GitHub for test repos
- ✅ RSS feeds and news aggregators
- ✅ Low-stakes services you could recreate in an hour

> **Rule of thumb**: If losing the account would cause significant impact, don't connect it.

### 🔐 Hardening Tips

**1. Change the default SSH password immediately:**
```bash
passwd
```

**2. Use SSH keys instead of passwords** (see [SSH Guide](docs/ssh-guide.md)):
```bash
# On your PC:
ssh-keygen -t ed25519 -f ~/.ssh/openclaw_key -N ""
ssh-copy-id -i ~/.ssh/openclaw_key.pub -p 8022 <username>@<phone-ip>
```

**3. Set DM policy to `pairing`** — prevents strangers from sending commands to your bot:
```json
{
  "channels": {
    "telegram": { "dmPolicy": "pairing" }
  }
}
```

**4. Restrict filesystem access** — add to your OpenClaw config:
```yaml
tools:
  filesystem:
    allowedPaths:
      - "/data/data/com.termux/files/home/workspace"
    deniedPaths:
      - "/data/data/com.termux/files/home/.ssh"
      - "/data/data/com.termux/files/home/.openclaw/credentials"
```

**5. Run the built-in security audit:**
```bash
openclaw security audit --deep
```

**6. Use Tailscale** instead of exposing SSH to the internet (see [Tailscale section](#remote-access-with-tailscale-optional))

**7. Connect only burner accounts** — every account connected to OpenClaw should be one you could lose without significant impact.

> 📖 For advanced hardening (Docker sandboxing, credential brokering, egress filtering), see the [OpenClaw Security Hardening Guide](https://aimaker.substack.com/p/openclaw-security-hardening-guide).

## Phone Setup Tips

### Enable Stay Awake

1. **Settings** > **About phone** > Tap **Build number** 7 times (enables Developer Options)
2. **Settings** > **Developer options** > Enable **Stay awake**

### Set Charge Limit to 80%

Running 24/7 at 100% can damage the battery.

- **Samsung**: Settings > Battery > Battery Protection → Maximum 80%
- **Pixel**: Settings > Battery > Battery Protection → ON

### Disable Battery Optimization

1. **Settings** > **Battery** > **Battery optimization**
2. Find **Termux** → set to **Not optimized** / **Unrestricted**

## Troubleshooting

<details>
<summary><b>❌ <code>error: expected absolute path: "--disable-warning=ExperimentalWarning"</code></b></summary>

**Cause**: OpenClaw tries to respawn Node.js with `--disable-warning` flag, which conflicts with `NODE_OPTIONS` containing `-r bionic-compat.js` on Node v24+.

**Fix**: Already handled by the installer (`OPENCLAW_NODE_OPTIONS_READY=1`). If you see this after an update:

```bash
echo 'export OPENCLAW_NODE_OPTIONS_READY=1' >> ~/.bashrc
source ~/.bashrc
```
</details>

<details>
<summary><b>❌ <code>make: ar: No such file or directory</code> (sharp build)</b></summary>

**Cause**: Termux's `binutils` package installs `llvm-ar` but doesn't create the `ar` symlink that `node-gyp` expects.

**Fix**:
```bash
ln -sf $PREFIX/bin/llvm-ar $PREFIX/bin/ar
npm rebuild sharp --prefix $PREFIX/lib/node_modules/openclaw
```
</details>

<details>
<summary><b>❌ <code>renameat2</code> / <code>RENAME_NOREPLACE</code> undeclared</b></summary>

**Cause**: Android Bionic doesn't expose `renameat2()` in older API levels. The `koffi` native module needs it.

**Fix**: Already handled by `termux-compat.h`. If rebuilding:
```bash
export CXXFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
```
</details>

<details>
<summary><b>❌ SSH password not working</b></summary>

**Cause**: If the password was set from a Windows script, CRLF line endings may have corrupted it.

**Fix**:
```bash
passwd
# Type your new password twice
```
</details>

<details>
<summary><b>❌ Gateway shows <code>ECONNREFUSED</code></b></summary>

**Cause**: The gateway process isn't running.

**Fix**:
```bash
source ~/.bashrc
tmux new-session -s OpenClaw
openclaw gateway
```
</details>

<details>
<summary><b>❌ tmux: no sessions</b></summary>

The tmux session was lost (phone rebooted or process killed). Create a new one:

```bash
tmux new-session -s OpenClaw
openclaw gateway
```

For auto-recovery on reboot, ensure Termux:Boot is installed and opened once.
</details>

<details>
<summary><b>❌ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED</b></summary>

The phone's SSH host key changed (usually after reinstalling Termux).

**Fix** (on your PC):
```bash
ssh-keygen -R "[<phone-ip>]:8022"
```
</details>

## Update

```bash
openclaw update
```

Or re-run the installer to refresh patches:

```bash
curl -sL https://raw.githubusercontent.com/PsProsen-Dev/openclaw-pocket-server/main/bootstrap.sh | bash && source ~/.bashrc
```

## Uninstall

```bash
npm uninstall -g openclaw
rm -rf ~/.openclaw ~/.openclaw-android ~/openclaw-pocket-server
# Remove the environment block from ~/.bashrc manually
```

## Project Structure

```
openclaw-pocket-server/
├── bootstrap.sh                  # curl one-liner entry point
├── install.sh                    # Master installer (8 steps)
├── scripts/
│   ├── check-env.sh              # Pre-flight checks
│   ├── install-deps.sh           # Termux packages
│   ├── setup-env.sh              # .bashrc environment config
│   ├── setup-ssh.sh              # SSH server + password
│   ├── setup-tmux.sh             # tmux session info
│   └── setup-boot.sh             # Termux:Boot auto-start
├── patches/
│   ├── termux-compat.h           # renameat2 + RENAME_NOREPLACE
│   ├── bionic-compat.js          # Platform + os patches
│   ├── spawn.h                   # POSIX spawn stub
│   ├── patch-paths.sh            # /tmp → $PREFIX/tmp etc.
│   ├── apply-patches.sh          # Patch orchestrator + ar fix
│   └── systemctl                 # systemctl stub
├── tests/
│   └── verify-install.sh         # Post-install health check
├── docs/
│   ├── troubleshooting.md        # Full troubleshooting guide
│   └── ssh-guide.md              # SSH key setup guide
├── LICENSE                       # MIT
└── .gitignore
```

## Credits

- [OpenClaw](https://openclaw.ai) — The AI gateway
- Built with ❤️ by **Prosenjit Paul (PsProsen-Dev)** and **Jarvis (RTX⚡)**

## License

MIT
