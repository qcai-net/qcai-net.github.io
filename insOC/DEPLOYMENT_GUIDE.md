# Professional Deployment Guide: OpenClaw + Qwen 3.5 (oMLX Optimized)

This guide provides a turnkey solution for deploying a high-performance, private AI agent system on a new Mac using OpenClaw and the Qwen 3.5-35B Model (optimized with oMLX).

## 🖥️ Hardware Requirements

- **Apple Silicon Mac**: M1 Pro/Max, M2 Pro/Max, M3, or M4.
- **Unified Memory (RAM)**: 
    - **Recommended**: 32GB or more (for smooth operation of the 35B MoE model).
    - **Minimum**: 24GB.
- **Disk Space**: At least 30GB free for the model and environment.

## 🚀 Installation Steps (Starting from Zero)

### 1. Run the Setup Script
Open your terminal and run the following command to download and execute the automated setup script:

```bash
# Create a workspace
mkdir -p ~/openclaw-llm && cd ~/openclaw-llm

# Run the setup script
bash <(curl -s -L https://raw.githubusercontent.com/your-repo/path/to/setup_openclaw_qwen.sh)
```
*(Note: For now, you can copy the `setup_openclaw_qwen.sh` file provided or host it on your GitHub/Server.)*

### 2. What the Script Does
- **System Prerequisites**: Automatically checks and triggers installation for **Xcode Command Line Tools** and **Homebrew** if missing.
- **Toolchain Setup**: Installs and configures **Node.js**, **Python**, and **Git** via Homebrew.
- **High-Performance Engine**: Installs the **oMLX** inference engine (optimized for Apple Silicon) and the **Qwen 3.5-35B-A3B** model.
- **Self-Healing & Robustness**: 
    - Automatically detects and **clears port conflicts** (e.g., port 1234).
    - Ensures all paths are synchronized for background services.
- **Configures Auto-Start**: Installs macOS `LaunchAgents` so the AI server and OpenClaw gateway start silently every time the Mac boots.

## 🛠️ Operating the System

Because the setup installs background `LaunchAgents`, **you do not need to manually start any servers!** They are always running and ready.

### Chat via Terminal (TUI)
Open a terminal and type:
```bash
openclaw tui
```

### Web Control UI (Recommended)
OpenClaw has a full **web-based management dashboard** called the **Control UI**. For security, it requires a token to log in.

**The correct way to open it:**
```bash
openclaw dashboard
```
This command automatically opens your browser to `http://127.0.0.1:18789/` with the correct auth token injected.

> [!WARNING]
> **Unauthorized Errors:** If you visit the URL directly in your browser without the token, you will see an "unauthorized" error. Always use the `openclaw dashboard` command to log in automatically.

The Control UI lets you:
- 💬 **Chat** with your agent and browse full message/session history
- ⚙️ **Configure** the system via a visual form editor (no JSON editing needed)
- 📡 **Connect chat channels** — Telegram, Discord, WhatsApp, and more
- 🩺 **Monitor health** — see backend status, active nodes, and activity logs
- 🔧 **Manage agents**, cron jobs, memory, approvals, and plugins

> **Note:** Do not expose this URL publicly — it is an admin interface intended for local access only.

### Setting Up a Telegram Channel
To receive and send messages via Telegram:
1. Open the Control UI: `openclaw dashboard`
2. Go to the **Channels** tab
3. Click **Add Channel → Telegram**
4. Follow the on-screen steps to connect your Telegram bot token

Or use the CLI wizard:
```bash
openclaw channels --help
```

### Other Useful Commands
```bash
openclaw doctor          # Run health checks and diagnose issues
openclaw logs            # Tail live gateway logs
openclaw configure       # Re-run the interactive setup wizard
openclaw config get <path>   # Read a config value
openclaw config set <path> <value>  # Set a config value
```

## 🛠️ Managing Services Locally

If you need to manually restart, stop, or check the status of your background services, we have provided a utility script:

```bash
cd ~/llm
./manage_services.sh status   # Check if services are running
./manage_services.sh restart  # Restart everything (Port 1234 and 18789)
./manage_services.sh stop     # Stop all background processes
```

If you download this script from the portal, remember to make it executable:
```bash
chmod +x manage_services.sh
```

## 🔒 Security & Privacy
- **100% Local**: No data leaves the machine. No API keys from OpenAI or Anthropic are required.
- **Encrypted Gateway**: Uses a local token-based protocol for secure channel connections.
- The web Control UI (`http://127.0.0.1:18789/`) is admin-only — never expose it to the internet.

## 🛠️ Troubleshooting
- **Missing Xcode Tools**: If prompted, click "Install" when the terminal asks for Command Line Tools.
- **Port 1234 in use**: Ensure no other LLM servers are running.
- **HTTP 404 from TUI/Dashboard**: Ensure the model is loaded as `openai/llm` and the gateway is pointing to `http://127.0.0.1:1234/v1`.
- **RAM Pressure**: If the system is sluggish, close browser tabs or other memory-heavy apps.
- **Gateway warnings about plugins**: Edit `~/.openclaw/openclaw.json` and remove any plugin entries that are not installed.
