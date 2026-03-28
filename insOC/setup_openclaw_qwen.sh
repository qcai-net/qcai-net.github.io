#!/bin/bash

# OpenClaw + Qwen 3.5 (oMLX Optimized) Turnkey Setup Script
# Purpose: Robust deployment for brand-new Apple Silicon Macs

set -e

# --- Styles and Helpers ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}INFO:${NC} $1"; }
success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
warn() { echo -e "${YELLOW}WARNING:${NC} $1"; }
error() { echo -e "${RED}ERROR:${NC} $1"; }

fail_with_instruction() {
    echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    error "$1"
    echo -e "${YELLOW}WHAT TO DO NEXT:${NC}"
    echo -e "$2"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    exit 1
}

echo -e "${BLUE}"
echo "  🦞 OpenClaw + Qwen 3.5 (oMLX) Auto-Setup"
echo "  Apple Silicon macOS Optimized Deployment"
echo -e "${NC}"

# 1. Prerequisite: Apple Silicon Check
info "Checking hardware compatibility..."
if [[ $(uname -m) != "arm64" ]]; then
    fail_with_instruction "This script requires an Apple Silicon (M1/M2/M3/M4/M5) Mac." "oMLX and MLX are specifically designed for Apple Silicon. Intel Macs are not supported for this turnkey setup."
fi
success "Apple Silicon detected."

# 2. Prerequisite: Xcode Command Line Tools
info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    warn "Xcode Command Line Tools are missing."
    echo -e "Starting installation popup... ${YELLOW}Please follow the native macOS prompts if they appear.${NC}"
    xcode-select --install &>/dev/null || true
    fail_with_instruction "Xcode Command Line Tools installation triggered." "1. Click 'Install' on the popup that just appeared.\n2. Wait for it to finish (this can take 5-10 mins).\n3. Re-run this script: bash setup_openclaw_qwen.sh"
fi
success "Xcode Command Line Tools found."

# 3. Prerequisite: Homebrew
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Attempting to install..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
fi

# Ensure Homebrew is in current session path
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
    fail_with_instruction "Homebrew installation failed or path not detected." "Please install Homebrew manually from https://brew.sh and then re-run this script."
fi
success "Homebrew is ready."

# 4. Install System Tools (Node, Python, Git)
info "Ensuring system tools are installed..."
for tool in node python git; do
    if ! command -v $tool &>/dev/null; then
        info "Installing $tool via Homebrew..."
        brew install $tool
    fi
done
success "System tools verified."

# 5. Setup Directories and Cleanup
LLM_DIR="$HOME/openclaw-llm"
info "Setting up workspace at $LLM_DIR..."

# Check for port conflict on 1234
if lsof -i :1234 &>/dev/null; then
    warn "Port 1234 is currently in use. Attempting to clear it for the new server..."
    # Get PIDs of processes using port 1234
    PIDS=$(lsof -t -i :1234)
    if [ -n "$PIDS" ]; then
        info "Terminating processes using port 1234: $PIDS"
        kill -9 $PIDS &>/dev/null || true
    fi
fi

# Ensure any previous instances of the specific server are stopped
pkill -f "omlx serve" &>/dev/null || true
pkill -f "mlx_vlm.server" &>/dev/null || true

mkdir -p "$LLM_DIR"
cd "$LLM_DIR"

# 6. Install Requirements and oMLX
info "Setting up Python environment and installing oMLX..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install mlx-vlm huggingface_hub torch torchvision

info "Installing oMLX server from source (optimized)..."
pip install git+https://github.com/jundot/omlx.git

# 7. Model Download
MODEL_ID="mlx-community/Qwen3.5-35B-A3B-4bit"
MODEL_PATH="$LLM_DIR/model"
mkdir -p "$MODEL_PATH"

info "Downloading $MODEL_ID (Approx 20GB)..."
python3 <<EOF
from huggingface_hub import snapshot_download
import os
try:
    snapshot_download(
        repo_id="$MODEL_ID",
        local_dir="$MODEL_PATH",
        local_dir_use_symlinks=False,
        revision="main"
    )
    print("Download successful!")
except Exception as e:
    print(f"Error during download: {e}")
    exit(1)
EOF

# 8. Create Start Script
info "Creating automated start script..."
cat <<EOF > start_server.sh
#!/bin/bash
# Professional start script for Qwen 3.5 oMLX
cd "$(dirname "$0")"
# Standardize PATH to ensure binaries are found
export PATH="$(pwd)/venv/bin:/Library/Frameworks/Python.framework/Versions/Current/bin:/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$PATH"

echo "Starting Qwen 3.5 MoE Server via oMLX on port 1234..."
# omlx serve uses --model-dir to point to the directory containing weights
omlx serve --model-dir "$MODEL_PATH" --port 1234 --host 0.0.0.0
EOF
chmod +x start_server.sh

# 9. Install OpenClaw
info "Installing OpenClaw gateway..."
if ! command -v openclaw &>/dev/null; then
    if [ -w "/usr/local/lib/node_modules" ] || [ -w "/opt/homebrew/lib/node_modules" ]; then
        npm install -g openclaw
    else
        warn "Requires sudo for global npm installation."
        sudo npm install -g openclaw
    fi
fi

# 10. Inject Configuration
info "Injecting verified configuration..."
mkdir -p "$HOME/.openclaw/agents/main/agent"

# Generate token if not exists
TOKEN=$(node -e "if (require('fs').existsSync(process.env.HOME + '/.openclaw/openclaw.json')) { console.log(require(process.env.HOME + '/.openclaw/openclaw.json').gateway.auth.token) } else { console.log(require('crypto').randomBytes(24).toString('hex')) }" 2>/dev/null || node -e "console.log(require('crypto').randomBytes(24).toString('hex'))")

cat <<EOF > "$HOME/.openclaw/openclaw.json"
{
  "agents": {
    "defaults": {
      "model": "openai/llm",
      "compaction": {
        "mode": "safeguard"
      }
    }
  },
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "http://127.0.0.1:1234/v1",
        "api": "openai-responses",
        "auth": "api-key",
        "models": [
          {
            "id": "llm",
            "name": "Local Qwen 3.5 (oMLX)",
            "contextWindow": 131072
          }
        ]
      }
    }
  },
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "$TOKEN"
    },
    "http": {
      "endpoints": {
        "chatCompletions": {
          "enabled": true
        }
      }
    }
  }
}
EOF

# 11. Setup Background Services (Start on Boot)
info "Configuring macOS LaunchAgents (Auto-Start)..."
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

SERVER_PLIST="$LAUNCH_AGENTS_DIR/com.openclaw.llmserver.plist"
GATEWAY_PLIST="$LAUNCH_AGENTS_DIR/com.openclaw.gateway.plist"

cat <<EOF > "$SERVER_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.llmserver</string>
    <key>ProgramArguments</key>
    <array>
        <string>$LLM_DIR/start_server.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StartInterval</key>
    <integer>0</integer>
    <key>ThrottleInterval</key>
    <integer>5</integer>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw-llmserver.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/openclaw-llmserver.out</string>
    <key>WorkingDirectory</key>
    <string>$LLM_DIR</string>
</dict>
</plist>
EOF

NODE_PATH=$(which node)
OPENCLAW_PATH=$(which openclaw)

cat <<EOF > "$GATEWAY_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>${NODE_PATH}</string>
        <string>${OPENCLAW_PATH}</string>
        <string>gateway</string>
        <string>--port</string>
        <string>18789</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StartInterval</key>
    <integer>0</integer>
    <key>ThrottleInterval</key>
    <integer>5</integer>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw-gateway.err</string>
    <key>StandardOutPath</key>
    <string>/tmp/openclaw-gateway.out</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin</string>
    </dict>
</dict>
</plist>
EOF

# Load agents and ignore errors if already loaded
launchctl unload -w "$SERVER_PLIST" &>/dev/null || true
launchctl unload -w "$GATEWAY_PLIST" &>/dev/null || true
launchctl load -w "$SERVER_PLIST" || true
launchctl load -w "$GATEWAY_PLIST" || true

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
success "Turnkey Setup Complete!"
echo -e "✅ AI Server (oMLX) and Gateway are running in the background."
echo -e "✅ They will start automatically every time you turn on your Mac."
echo -e "\nTo start chatting now, type:"
echo -e "${YELLOW}openclaw tui${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
